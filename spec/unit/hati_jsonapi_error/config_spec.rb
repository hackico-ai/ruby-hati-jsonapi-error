# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::Config do
  before(:all) { HatiJsonapiError::Kigen.load_errors! }

  before do
    HatiJsonapiError::Registry.instance_variable_set(:@fallback, nil)
    HatiJsonapiError::Registry.instance_variable_set(:@error_map, {})
  end

  describe '.configure' do
    it 'yields self when block given' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class)
    end

    it 'returns nil when no block given' do
      expect(described_class.configure).to be_nil
    end

    it 'allows configuration through block' do
      error_map = { StandardError => HatiJsonapiError::InternalServerError }
      fallback_error = HatiJsonapiError::InternalServerError

      described_class.configure do |config|
        config.map_errors = error_map
        config.use_unexpected = fallback_error
      end

      aggregate_failures 'configuration' do
        expect(HatiJsonapiError::Registry.error_map).to eq(error_map)
        expect(HatiJsonapiError::Registry.instance_variable_get(:@fallback)).to eq(fallback_error)
      end
    end
  end

  describe '.use_unexpected=' do
    let(:fallback_error) { HatiJsonapiError::InternalServerError }

    it 'sets fallback error in Registry' do
      described_class.use_unexpected = fallback_error

      expect(HatiJsonapiError::Registry.instance_variable_get(:@fallback)).to eq(fallback_error)
    end

    it 'accepts error class' do
      error_class = Class.new(HatiJsonapiError::BaseError)
      described_class.use_unexpected = error_class

      expect(HatiJsonapiError::Registry.instance_variable_get(:@fallback)).to eq(error_class)
    end

    it 'accepts symbol' do
      described_class.use_unexpected = :internal_server_error
      error_class = HatiJsonapiError::InternalServerError

      expect(HatiJsonapiError::Registry.instance_variable_get(:@fallback)).to eq(error_class)
    end

    it 'accepts status code' do
      described_class.use_unexpected = 500
      error_class = HatiJsonapiError::InternalServerError

      expect(HatiJsonapiError::Registry.instance_variable_get(:@fallback)).to eq(error_class)
    end
  end

  describe '.map_errors=' do
    let(:error_map) do
      {
        StandardError => HatiJsonapiError::InternalServerError,
        ArgumentError => HatiJsonapiError::BadRequest,
        RuntimeError => HatiJsonapiError::InternalServerError
      }
    end

    it 'sets error map in Registry' do
      described_class.map_errors = error_map
      expect(HatiJsonapiError::Registry.error_map).to eq(error_map)
    end

    it 'accepts mixed error mappings' do
      mixed_map = {
        StandardError => :internal_server_error,
        ArgumentError => 400,
        RuntimeError => HatiJsonapiError::BadRequest
      }

      described_class.map_errors = mixed_map

      aggregate_failures 'mixed mappings' do
        expect(HatiJsonapiError::Registry.error_map[StandardError]).to eq(HatiJsonapiError::InternalServerError)
        expect(HatiJsonapiError::Registry.error_map[ArgumentError]).to eq(HatiJsonapiError::BadRequest)
        expect(HatiJsonapiError::Registry.error_map[RuntimeError]).to eq(HatiJsonapiError::BadRequest)
      end
    end
  end

  describe '.error_map' do
    let(:error_map) { { StandardError => HatiJsonapiError::InternalServerError } }

    it 'returns error map from Registry' do
      HatiJsonapiError::Registry.error_map = error_map
      expect(described_class.error_map).to eq(error_map)
    end

    it 'returns empty hash when no error map set' do
      expect(described_class.error_map).to eq({})
    end
  end

  describe '.load_errors!' do
    it 'delegates to Kigen.load_errors!' do
      allow(HatiJsonapiError::Kigen).to receive(:load_errors!)
      described_class.load_errors!

      expect(HatiJsonapiError::Kigen).to have_received(:load_errors!)
    end

    it 'loads error classes' do
      described_class.load_errors!

      aggregate_failures 'loaded errors' do
        expect(HatiJsonapiError.const_defined?(:NotFound)).to be true
        expect(HatiJsonapiError.const_defined?(:InternalServerError)).to be true
        expect(HatiJsonapiError.const_defined?(:UnprocessableEntity)).to be true
      end
    end
  end

  describe 'configuration example' do
    it 'supports the documented configuration pattern' do
      error_map = {
        StandardError => HatiJsonapiError::InternalServerError,
        ArgumentError => HatiJsonapiError::BadRequest,
        RuntimeError => HatiJsonapiError::InternalServerError
      }
      fallback_error = HatiJsonapiError::InternalServerError

      described_class.configure do |config|
        config.load_errors!
        config.map_errors = error_map
        config.use_unexpected = fallback_error
      end

      aggregate_failures 'configuration result' do
        expect(HatiJsonapiError::Registry.error_map).to eq(error_map)
        expect(HatiJsonapiError::Registry.instance_variable_get(:@fallback)).to eq(fallback_error)
      end
    end
  end
end
