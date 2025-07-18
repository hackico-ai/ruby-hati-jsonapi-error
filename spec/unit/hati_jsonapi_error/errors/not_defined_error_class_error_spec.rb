# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::Errors::NotDefinedErrorClassError do
  describe '.new' do
    context 'with default message' do
      subject(:error) { described_class.new }

      it 'creates an error with default message' do
        expect(error.message).to eq('Error class not defined')
      end

      it 'inherits from StandardError' do
        expect(error).to be_a(StandardError)
      end

      it 'is a NotDefinedErrorClassError' do
        expect(error).to be_a(described_class)
      end
    end

    context 'with custom message' do
      subject(:error) { described_class.new(custom_message) }

      let(:custom_message) { 'Custom error class not found message' }

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
      custom_message = 'Error class XYZ not found'
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
        expect(error.class.name).to eq('HatiJsonapiError::Errors::NotDefinedErrorClassError')
      end
    end
  end

  describe 'module structure' do
    it 'is defined under HatiJsonapiError::Errors module' do
      expect(described_class.name).to start_with('HatiJsonapiError::Errors')
    end

    it 'is accessible through module path' do
      expect(HatiJsonapiError::Errors::NotDefinedErrorClassError).to eq(described_class)
    end
  end

  describe 'usage scenarios' do
    it 'provides meaningful error for undefined error classes' do
      error_message = 'Error unknown_error definition not found'
      error = described_class.new(error_message)

      aggregate_failures 'message' do
        expect(error.message).to eq(error_message)
        expect(error).to be_a(StandardError)
      end
    end

    it 'can be used in registry context' do
      # Simulate the actual usage pattern from registry.rb
      error_name = :unknown_error
      message = "Error #{error_name} definition not found in lib/hati_jsonapi_error/api_error/error_const.rb"

      expect { raise described_class.new(message) }.to raise_error(described_class, message)
    end

    it 'can be used in helpers context' do
      # Simulate the actual usage pattern from helpers.rb
      error_name = :unknown_code
      message = "Error #{error_name} not defined on load_errors!. Check kigen.rb and api_error/error_const.rb"

      expect { raise described_class.new(message) }.to raise_error(described_class, message)
    end
  end

  describe 'error distinction' do
    it 'is different from other error classes' do
      not_defined_error = described_class.new
      not_loaded_error = HatiJsonapiError::Errors::NotLoadedError.new

      aggregate_failures 'class' do
        expect(not_defined_error.class).not_to eq(not_loaded_error.class)
        expect(not_defined_error.message).not_to eq(not_loaded_error.message)
      end
    end

    it 'has specific error semantics' do
      error = described_class.new

      # This error specifically indicates that an error class definition is missing
      aggregate_failures 'message' do
        expect(error.message).to include('not defined')
        expect(error.class.name).to include('NotDefined')
      end
    end
  end
end
