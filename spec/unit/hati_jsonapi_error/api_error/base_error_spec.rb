# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::BaseError do
  let(:error_attrs) do
    {
      id: 'error_123',
      code: 'invalid_request',
      title: 'Invalid Request',
      detail: 'The request was invalid',
      status: '400',
      meta: { timestamp: '2024-01-01T00:00:00Z' },
      links: {
        about: 'https://example.com/errors/invalid_request',
        type: 'error_documentation'
      },
      source: {
        pointer: '/data/attributes/email',
        parameter: 'email',
        header: 'Authorization'
      }
    }
  end

  describe 'constants' do
    it 'defines STR as empty string' do
      expect(described_class::STR).to eq('')
    end

    it 'defines OBJ as frozen' do
      aggregate_failures 'empty hash' do
        expect(described_class::OBJ).to eq({})
        expect(described_class::OBJ).to be_frozen
      end
    end
  end

  describe '#initialize' do
    context 'with all attributes' do
      subject(:error) { described_class.new(**error_attrs) }

      it 'sets all attributes correctly' do
        aggregate_failures 'attributes' do
          expect(error.id).to eq('error_123')
          expect(error.code).to eq('invalid_request')
          expect(error.title).to eq('Invalid Request')
          expect(error.detail).to eq('The request was invalid')
          expect(error.status).to eq('400')
          expect(error.meta).to eq(timestamp: '2024-01-01T00:00:00Z')
        end
      end

      it 'builds links object' do
        aggregate_failures 'links' do
          expect(error.links).to be_a(HatiJsonapiError::Links)
          expect(error.links.about).to eq('https://example.com/errors/invalid_request')
          expect(error.links.type).to eq('error_documentation')
        end
      end

      it 'builds source object' do
        aggregate_failures 'source' do
          expect(error.source).to be_a(HatiJsonapiError::Source)
          expect(error.source.pointer).to eq('/data/attributes/email')
          expect(error.source.parameter).to eq('email')
          expect(error.source.header).to eq('Authorization')
        end
      end
    end

    context 'with minimal attributes' do
      subject(:error) { described_class.new(title: 'Minimal Error') }

      it 'sets default values for missing attributes' do
        aggregate_failures 'defaults' do
          expect(error.id).to eq('')
          expect(error.code).to eq('')
          expect(error.detail).to eq('')
          expect(error.status).to eq('')
          expect(error.meta).to eq({})
          expect(error.links).to eq({})
          expect(error.source).to eq({})
        end
      end
    end

    context 'with nil attributes' do
      subject(:error) do
        described_class.new(
          links: nil,
          source: nil,
          meta: nil
        )
      end

      it 'handles nil values gracefully' do
        aggregate_failures 'nil handling' do
          expect(error.links).to eq({})
          expect(error.source).to eq({})
          expect(error.meta).to eq({})
        end
      end
    end
  end

  describe '#to_h' do
    subject(:error) { described_class.new(**error_attrs) }

    it 'returns hash with all attributes' do
      result = error.to_h

      expect(result).to include(
        id: 'error_123',
        code: 'invalid_request',
        title: 'Invalid Request',
        detail: 'The request was invalid',
        status: '400',
        meta: { timestamp: '2024-01-01T00:00:00Z' }
      )
    end

    it 'includes nested objects as hashes' do
      result = error.to_h

      aggregate_failures 'nested objects' do
        expect(result[:links]).to eq(
          about: 'https://example.com/errors/invalid_request',
          type: 'error_documentation'
        )

        expect(result[:source]).to eq(
          pointer: '/data/attributes/email',
          parameter: 'email',
          header: 'Authorization'
        )
      end
    end
  end

  describe '#to_s' do
    it 'returns string representation of full error hash' do
      error = described_class.new(**error_attrs)

      expect(error.to_s).to eq(error.to_h.to_s)
    end

    it 'includes all attributes in string representation' do
      error = described_class.new(title: 'Error Title', detail: 'Error Detail')

      aggregate_failures 'string representation' do
        expect(error.to_s).to include('Error Title')
        expect(error.to_s).to include('Error Detail')
      end
    end
  end

  describe '#serializable_hash' do
    subject(:error) { described_class.new(**error_attrs) }

    it 'returns same as to_h' do
      expect(error.serializable_hash).to eq(error.to_h)
    end
  end

  describe '#to_json' do
    subject(:error) { described_class.new(**error_attrs) }

    it 'returns valid JSON string' do
      json = error.to_json
      parsed = JSON.parse(json, symbolize_names: true)

      expect(parsed).to eq(error.to_h)
    end

    it 'ignores arguments passed to to_json' do
      json1 = error.to_json
      json2 = error.to_json(except: [:id])

      expect(json1).to eq(json2)
    end
  end

  describe 'JSON:API compliance' do
    subject(:error) { described_class.new(**error_attrs) }

    it 'follows JSON:API error object structure' do
      result = error.to_h
      required_members = %i[id status code title detail source meta links]

      aggregate_failures 'structure' do
        expect(result.keys).to include(*required_members)
        expect(result[:source]).to include(:pointer, :parameter)
        expect(result[:links]).to include(:about)
      end
    end
  end
end
