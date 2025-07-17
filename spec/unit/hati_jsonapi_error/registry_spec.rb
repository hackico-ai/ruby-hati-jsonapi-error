# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::Registry do
  before(:all) { HatiJsonapiError::Kigen.load_errors! }

  before do
    described_class.instance_variable_set(:@fallback, nil)
    described_class.instance_variable_set(:@error_map, nil)
  end

  describe '.fallback=' do
    context 'when setting a valid error class' do
      it 'sets the fallback error directly' do
        described_class.fallback = HatiJsonapiError::NotFound
        expect(described_class.fallback).to eq(HatiJsonapiError::NotFound)
      end
    end

    context 'when setting an error by status code' do
      it 'fetches and sets the corresponding error class' do
        described_class.fallback = 404
        expect(described_class.fallback).to eq(HatiJsonapiError::NotFound)
      end
    end

    context 'when setting an error by symbol' do
      it 'fetches and sets the corresponding error class' do
        described_class.fallback = :not_found
        expect(described_class.fallback).to eq(HatiJsonapiError::NotFound)
      end
    end

    context 'when error definition is not found' do
      it 'raises an error' do
        expect { described_class.fallback = :unknown_error }.to raise_error(
          RuntimeError,
          'Error unknown_error definition not found in lib/hati_jsonapi_error/api_error/error_const.rb'
        )
      end
    end
  end

  describe '.error_map=' do
    it 'sets the error map with resolved error classes from status codes' do
      error_map = {
        KeyError => 404,
        ArgumentError => 400
      }
      error_class_map = {
        KeyError => HatiJsonapiError::NotFound,
        ArgumentError => HatiJsonapiError::BadRequest
      }

      described_class.error_map = error_map
      expect(described_class.error_map).to eq(error_class_map)
    end

    it 'sets the error map with resolved error classes from symbols' do
      error_map = {
        KeyError => :not_found, ArgumentError => :bad_request
      }
      error_class_map = {
        KeyError => HatiJsonapiError::NotFound,
        ArgumentError => HatiJsonapiError::BadRequest
      }

      described_class.error_map = error_map
      expect(described_class.error_map).to eq(error_class_map)
    end

    it 'keeps already resolved error classes unchanged' do
      error_map = {
        KeyError => HatiJsonapiError::NotFound,
        ArgumentError => :bad_request
      }
      error_class_map = {
        KeyError => HatiJsonapiError::NotFound,
        ArgumentError => HatiJsonapiError::BadRequest
      }

      described_class.error_map = error_map
      expect(described_class.error_map).to eq(error_class_map)
    end
  end

  describe '.lookup_error' do
    context 'when error class is mapped' do
      before do
        described_class.fallback = :internal_server_error
        described_class.error_map = {
          KeyError => :not_found,
          ArgumentError => :bad_request
        }
      end

      it 'returns the mapped error class' do
        error = KeyError.new
        expect(described_class.lookup_error(error)).to eq(HatiJsonapiError::NotFound)
      end

      it 'returns the fallback error class for unmapped errors' do
        error = StandardError.new
        expect(described_class.lookup_error(error)).to eq(HatiJsonapiError::InternalServerError)
      end
    end

    context 'when no fallback is set' do
      before do
        # Reset both fallback and error_map
        described_class.instance_variable_set(:@fallback, nil)
        described_class.error_map = {}
      end

      it 'returns nil for unmapped errors' do
        error = StandardError.new
        expect(described_class.lookup_error(error)).to be_nil
      end
    end
  end
end
