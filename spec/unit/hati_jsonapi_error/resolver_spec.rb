# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::Resolver do
  let(:error_attrs) do
    {
      status: '404',
      title: 'Not Found',
      detail: 'Resource not found'
    }
  end

  let(:error_attrs_2) do
    {
      status: '422',
      title: 'Unprocessable Entity',
      detail: 'Validation failed'
    }
  end

  let(:mock_error) { double('Error', status: '404', **error_attrs) }
  let(:mock_error_2) { double('Error', status: '422', **error_attrs_2) }

  describe '#initialize' do
    context 'with default serializer' do
      it 'uses PoroSerializer by default' do
        resolver = described_class.new(mock_error)

        expect(resolver.serializer).to be_a(HatiJsonapiError::PoroSerializer)
      end

      it 'normalizes single error to array' do
        resolver = described_class.new(mock_error)

        expect(resolver.errors).to eq([mock_error])
      end

      it 'keeps array of errors unchanged' do
        errors = [mock_error, mock_error_2]
        resolver = described_class.new(errors)

        expect(resolver.errors).to eq(errors)
      end
    end

    context 'with custom serializer' do
      let(:custom_serializer) do
        Class.new do
          def initialize(errors); end
          def serialize_to_json; end
        end
      end

      it 'uses provided serializer' do
        resolver = described_class.new(mock_error, serializer: custom_serializer)

        expect(resolver.serializer).to be_a(custom_serializer)
      end
    end
  end

  describe '#status' do
    it 'returns status of first error for single error' do
      resolver = described_class.new(mock_error)

      expect(resolver.status).to eq('404')
    end

    it 'returns status of first error for multiple errors' do
      resolver = described_class.new([mock_error, mock_error_2])

      expect(resolver.status).to eq('404')
    end

    context 'with invalid error object' do
      it 'raises NoMethodError when error does not respond to status' do
        invalid_error = Object.new
        resolver = described_class.new(invalid_error)

        expect { resolver.status }.to raise_error(NoMethodError, /undefined method `status'/)
      end

      it 'raises NoMethodError when error is nil' do
        resolver = described_class.new(nil)

        expect { resolver.status }.to raise_error(NoMethodError, /undefined method `status'/)
      end
    end
  end

  describe '#to_json' do
    let(:expected_json) { '{"errors":[{"status":"404","title":"Not Found"}]}' }
    let(:mock_serializer) { instance_double(HatiJsonapiError::PoroSerializer) }

    before do
      allow(HatiJsonapiError::PoroSerializer).to receive(:new).and_return(mock_serializer)
      allow(mock_serializer).to receive(:serialize_to_json).and_return(expected_json)
    end

    it 'delegates to serializer' do
      resolver = described_class.new(mock_error)

      aggregate_failures 'delegation' do
        expect(resolver.to_json).to eq(expected_json)
        expect(mock_serializer).to have_received(:serialize_to_json)
      end
    end

    it 'ignores any arguments passed to to_json' do
      resolver = described_class.new(mock_error)

      expect(resolver.to_json(except: [:id])).to eq(expected_json)
    end
  end

  describe 'integration with PoroSerializer' do
    let(:error) do
      HatiJsonapiError::BaseError.new(
        status: '404',
        title: 'Not Found',
        detail: 'The requested resource was not found'
      )
    end

    it 'correctly serializes error to JSON API' do
      resolver = described_class.new(error)
      result = JSON.parse(resolver.to_json, symbolize_names: true)

      expected_result = {
        errors: [
          {
            id: '',
            code: '',
            status: '404',
            title: 'Not Found',
            detail: 'The requested resource was not found',
            source: {},
            meta: {},
            links: {}
          }
        ]
      }

      aggregate_failures 'format' do
        expect(result).to be_a(Hash)
        expect(result).to have_key(:errors)
        expect(result[:errors]).to be_an(Array)
        expect(result).to eq(expected_result)
      end
    end

    it 'correctly handles multiple errors' do
      error2 = HatiJsonapiError::BaseError.new(
        status: '422',
        title: 'Unprocessable Entity',
        detail: 'Validation failed'
      )

      resolver = described_class.new([error, error2])
      result = JSON.parse(resolver.to_json, symbolize_names: true)

      expected_result = {
        errors: [
          {
            id: '',
            code: '',
            status: '404',
            title: 'Not Found',
            detail: 'The requested resource was not found',
            source: {},
            meta: {},
            links: {}
          },
          {
            id: '',
            code: '',
            status: '422',
            title: 'Unprocessable Entity',
            detail: 'Validation failed',
            source: {},
            meta: {},
            links: {}
          }
        ]
      }

      aggregate_failures 'format' do
        expect(result).to be_a(Hash)
        expect(result).to have_key(:errors)
        expect(result[:errors]).to be_an(Array)
        expect(result).to eq(expected_result)
      end
    end
  end
end
