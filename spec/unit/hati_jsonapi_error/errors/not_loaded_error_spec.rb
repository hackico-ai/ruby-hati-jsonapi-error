# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::Errors::NotLoadedError do
  describe '.new' do
    context 'with default message' do
      subject(:error) { described_class.new }

      it 'creates an error with default message' do
        expect(error.message).to eq('HatiJsonapiError::Kigen not loaded')
      end

      it 'inherits from StandardError' do
        expect(error).to be_a(StandardError)
      end

      it 'is a NotLoadedError' do
        expect(error).to be_a(described_class)
      end
    end

    context 'with custom message' do
      subject(:error) { described_class.new(custom_message) }

      let(:custom_message) { 'Custom not loaded message' }

      it 'creates an error with custom message' do
        expect(error.message).to eq(custom_message)
      end

      it 'inherits from StandardError' do
        expect(error).to be_a(StandardError)
      end
    end
  end

  describe 'error handling' do
    it 'can be raised and caught' do
      expect { raise described_class.new }.to raise_error(described_class)
    end

    it 'can be raised with custom message' do
      custom_message = 'Kigen system not initialized'
      expect { raise described_class.new(custom_message) }.to raise_error(described_class, custom_message)
    end

    it 'can be caught as StandardError' do
      expect { raise described_class.new }.to raise_error(StandardError)
    end
  end

  describe 'error properties' do
    let(:error) { described_class.new }

    it 'has a backtrace when raised' do
      raise error
    rescue described_class => e
      aggregate_failures 'backtrace' do
        expect(e.backtrace).to be_an(Array)
        expect(e.backtrace).not_to be_empty
      end
    end

    it 'maintains error class information' do
      aggregate_failures 'class' do
        expect(error.class).to eq(described_class)
        expect(error.class.name).to eq('HatiJsonapiError::Errors::NotLoadedError')
      end
    end
  end

  describe 'module structure' do
    it 'is defined under HatiJsonapiError::Errors module' do
      expect(described_class.name).to start_with('HatiJsonapiError::Errors')
    end

    it 'is accessible through module path' do
      expect(HatiJsonapiError::Errors::NotLoadedError).to eq(described_class)
    end
  end

  describe 'usage scenarios' do
    it 'provides meaningful error for Kigen not loaded state' do
      error = described_class.new

      aggregate_failures 'message' do
        expect(error.message).to include('Kigen')
        expect(error.message).to include('not loaded')
        expect(error).to be_a(StandardError)
      end
    end

    it 'can be used in helpers context' do
      # Simulate the actual usage pattern from helpers.rb
      expect { raise described_class.new }.to raise_error(described_class, 'HatiJsonapiError::Kigen not loaded')
    end

    it 'provides context about initialization state' do
      error = described_class.new

      # The default message specifically mentions Kigen not being loaded
      expect(error.message).to eq('HatiJsonapiError::Kigen not loaded')
    end
  end

  describe 'error distinction' do
    it 'is different from other error classes' do
      not_loaded_error = described_class.new
      not_defined_error = HatiJsonapiError::Errors::NotDefinedErrorClassError.new

      aggregate_failures 'class' do
        expect(not_loaded_error.class).not_to eq(not_defined_error.class)
        expect(not_loaded_error.message).not_to eq(not_defined_error.message)
      end
    end

    it 'has specific loading-related semantics' do
      error = described_class.new

      # This error specifically indicates that Kigen (error loading system) is not loaded
      aggregate_failures 'message' do
        expect(error.message).to include('not loaded')
        expect(error.message).to include('Kigen')
        expect(error.class.name).to include('NotLoaded')
      end
    end
  end

  describe 'integration with Kigen' do
    before { HatiJsonapiError::Kigen.load_errors! }

    it 'represents state when Kigen is not properly initialized' do
      # Mock Kigen as not loaded
      allow(HatiJsonapiError::Kigen).to receive(:loaded?).and_return(false)

      error = described_class.new
      expect(error.message).to eq('HatiJsonapiError::Kigen not loaded')
    end

    it 'can be used to guard against uninitialized system access' do
      error_message = 'System not ready for error mapping'

      expect { raise described_class.new(error_message) }.to raise_error(described_class, error_message)
    end
  end
end
