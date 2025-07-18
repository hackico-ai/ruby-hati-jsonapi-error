# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::Errors::HelpersRenderError do
  describe '.new' do
    context 'with default message' do
      subject(:error) { described_class.new }

      it 'creates an error with default message' do
        expect(error.message).to eq('Invalid Helpers:render_error')
      end

      it 'inherits from StandardError' do
        expect(error).to be_a(StandardError)
      end

      it 'is a HelpersRenderError' do
        expect(error).to be_a(described_class)
      end
    end

    context 'with custom message' do
      subject(:error) { described_class.new(custom_message) }

      let(:custom_message) { 'Custom error message' }

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
      custom_message = 'Test error message'

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
        expect(error.class.name).to eq('HatiJsonapiError::Errors::HelpersRenderError')
      end
    end
  end

  describe 'module structure' do
    it 'is defined under HatiJsonapiError::Errors module' do
      expect(described_class.name).to start_with('HatiJsonapiError::Errors')
    end

    it 'is accessible through module path' do
      expect(HatiJsonapiError::Errors::HelpersRenderError).to eq(described_class)
    end
  end
end
