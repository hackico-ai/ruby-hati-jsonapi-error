# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::PoroSerializer do
  let(:error_hash) do
    {
      id: 'test_error_1',
      status: '404',
      code: 'not_found',
      title: 'Not Found',
      detail: 'The requested resource was not found',
      source: { pointer: '/data/attributes/user_id' },
      meta: { timestamp: '2024-01-01T00:00:00Z' },
      links: { about: 'https://example.com/errors/404' }
    }
  end

  let(:error_hash_2) do
    {
      id: 'test_error_2',
      status: '422',
      code: 'unprocessable_entity',
      title: 'Unprocessable Entity',
      detail: 'Validation failed',
      source: { pointer: '/data/attributes/email' },
      meta: { field: 'email' },
      links: { about: 'https://example.com/errors/422' }
    }
  end

  let(:mock_error) { double('Error', to_h: error_hash) }
  let(:mock_error_2) { double('Error', to_h: error_hash_2) }

  describe '#initialize' do
    context 'with a single error' do
      it 'normalizes single error to array' do
        serializer = described_class.new(mock_error)

        expect(serializer.send(:errors)).to eq([mock_error])
      end
    end

    context 'with an array of errors' do
      it 'keeps array as is' do
        errors = [mock_error, mock_error_2]
        serializer = described_class.new(errors)

        expect(serializer.send(:errors)).to eq(errors)
      end
    end

    context 'with empty array' do
      it 'accepts empty array' do
        serializer = described_class.new([])

        expect(serializer.send(:errors)).to eq([])
      end
    end
  end

  describe '#serializable_hash' do
    let(:serializer) { described_class.new(mock_error) }

    context 'with short: false (default)' do
      it 'returns full error hash with all keys' do
        result = serializer.serializable_hash

        expect(result).to eq(errors: [error_hash])
      end

      it 'includes all error attributes' do
        result = serializer.serializable_hash(short: false)
        error = result[:errors].first

        expect(error).to eq(error_hash)
      end
    end

    context 'with short: true' do
      it 'returns only short keys' do
        result = serializer.serializable_hash(short: true)
        expected_result = {
          errors: [{
            status: '404',
            title: 'Not Found',
            detail: 'The requested resource was not found',
            source: { pointer: '/data/attributes/user_id' }
          }]
        }

        expect(result).to eq(expected_result)
      end

      it 'excludes non-short keys' do
        result = serializer.serializable_hash(short: true)
        error = result[:errors].first

        expect(error).not_to include(:id, :code, :meta, :links)
        expect(error.keys).to match_array(%i[status title detail source])
      end
    end

    context 'with multiple errors' do
      let(:serializer) { described_class.new([mock_error, mock_error_2]) }

      it 'serializes all errors in full mode' do
        result = serializer.serializable_hash

        expect(result[:errors]).to eq([error_hash, error_hash_2])
      end

      it 'serializes all errors in short mode' do
        result = serializer.serializable_hash(short: true)
        expected_result = {
          errors: [
            {
              status: '404',
              title: 'Not Found',
              detail: 'The requested resource was not found',
              source: { pointer: '/data/attributes/user_id' }
            },
            {
              status: '422',
              title: 'Unprocessable Entity',
              detail: 'Validation failed',
              source: { pointer: '/data/attributes/email' }
            }
          ]
        }

        expect(result).to eq(expected_result)
      end
    end
  end

  describe '#serialize_to_json' do
    let(:serializer) { described_class.new(mock_error) }

    context 'with short: false (default)' do
      it 'returns valid JSON string with full error data' do
        result = serializer.serialize_to_json
        expected_result = { errors: [error_hash] }
        parsed = JSON.parse(result, symbolize_names: true)

        expect(parsed).to eq(expected_result)
      end
    end

    context 'with short: true' do
      it 'returns valid JSON string with short error data' do
        result = serializer.serialize_to_json(short: true)
        expected_result = {
          errors: [{
            status: '404',
            title: 'Not Found',
            detail: 'The requested resource was not found',
            source: { pointer: '/data/attributes/user_id' }
          }]
        }
        parsed = JSON.parse(result, symbolize_names: true)

        expect(parsed).to eq(expected_result)
      end
    end

    context 'with multiple errors' do
      let(:serializer) { described_class.new([mock_error, mock_error_2]) }

      it 'returns JSON with array of errors' do
        result = serializer.serialize_to_json
        expected_result = { errors: [error_hash, error_hash_2] }
        parsed = JSON.parse(result, symbolize_names: true)
        expect(parsed).to eq(expected_result)
      end
    end

    context 'with empty errors array' do
      let(:serializer) { described_class.new([]) }

      it 'returns JSON with empty errors array' do
        result = serializer.serialize_to_json
        expected_result = { errors: [] }
        parsed = JSON.parse(result, symbolize_names: true)
        expect(parsed).to eq(expected_result)
      end
    end
  end

  describe 'SHORT_KEYS constant' do
    it 'contains expected keys' do
      expect(described_class::SHORT_KEYS).to eq(%i[status title detail source])
    end

    it 'is frozen' do
      expect(described_class::SHORT_KEYS).to be_frozen
    end
  end

  describe 'JSON:API compliance' do
    let(:serializer) { described_class.new(mock_error) }

    it 'wraps errors in errors array as per JSON:API spec' do
      result = serializer.serializable_hash

      expect(result).to have_key(:errors)
      expect(result[:errors]).to be_an(Array)
    end

    it 'maintains JSON:API error object structure' do
      result = serializer.serializable_hash
      error = result[:errors].first
      json_api_members = %i[id links status code title detail source meta]

      expect(error.keys - json_api_members).to be_empty
    end
  end

  describe 'private methods' do
    describe '#normalized_errors' do
      let(:serializer) { described_class.new(mock_error) }

      it 'converts single error to array' do
        result = serializer.send(:normalized_errors, mock_error)

        expect(result).to eq([mock_error])
      end

      it 'keeps array unchanged' do
        errors = [mock_error, mock_error_2]
        result = serializer.send(:normalized_errors, errors)

        expect(result).to eq(errors)
      end
    end
  end
end
