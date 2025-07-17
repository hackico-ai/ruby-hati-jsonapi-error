# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::Links do
  describe 'constants' do
    it 'defines STR as empty string' do
      expect(described_class::STR).to eq('')
    end
  end

  describe '#initialize' do
    context 'with all attributes' do
      subject(:links) do
        described_class.new(
          about: 'https://example.com/errors/not_found',
          type: 'error_documentation'
        )
      end

      it 'sets all attributes correctly' do
        aggregate_failures 'attributes' do
          expect(links.about).to eq('https://example.com/errors/not_found')
          expect(links.type).to eq('error_documentation')
        end
      end
    end

    context 'with no attributes' do
      subject(:links) { described_class.new }

      it 'sets default values' do
        aggregate_failures 'defaults' do
          expect(links.about).to eq('')
          expect(links.type).to eq('')
        end
      end
    end

    context 'with partial attributes' do
      it 'sets about and defaults type' do
        links = described_class.new(about: 'https://example.com/errors/not_found')

        aggregate_failures 'partial about' do
          expect(links.about).to eq('https://example.com/errors/not_found')
          expect(links.type).to eq('')
        end
      end

      it 'sets type and defaults about' do
        links = described_class.new(type: 'error_documentation')

        aggregate_failures 'partial type' do
          expect(links.about).to eq('')
          expect(links.type).to eq('error_documentation')
        end
      end
    end
  end

  describe '#to_h' do
    it 'returns hash with all attributes' do
      links = described_class.new(
        about: 'https://example.com/errors/not_found',
        type: 'error_documentation'
      )

      expect(links.to_h).to eq(
        about: 'https://example.com/errors/not_found',
        type: 'error_documentation'
      )
    end

    it 'returns hash with default values when no attributes set' do
      links = described_class.new

      expect(links.to_h).to eq(
        about: '',
        type: ''
      )
    end

    it 'returns hash with partial attributes' do
      links = described_class.new(about: 'https://example.com/errors/not_found')

      expect(links.to_h).to eq(
        about: 'https://example.com/errors/not_found',
        type: ''
      )
    end
  end

  describe 'attribute accessors' do
    subject(:links) { described_class.new }

    it 'allows setting about' do
      links.about = 'https://example.com/errors/not_found'
      expect(links.about).to eq('https://example.com/errors/not_found')
    end

    it 'allows setting type' do
      links.type = 'error_documentation'
      expect(links.type).to eq('error_documentation')
    end

    it 'reflects attribute changes in to_h' do
      links.about = 'https://example.com/errors/not_found'
      links.type = 'error_documentation'

      expect(links.to_h).to eq(
        about: 'https://example.com/errors/not_found',
        type: 'error_documentation'
      )
    end
  end

  describe 'JSON:API compliance' do
    it 'follows JSON:API links object structure' do
      links = described_class.new(
        about: 'https://example.com/errors/not_found',
        type: 'error_documentation'
      )
      result = links.to_h

      aggregate_failures 'structure' do
        expect(result.keys).to match_array(%i[about type])
        expect(result[:about]).to be_a(String)
        expect(result[:type]).to be_a(String)
      end
    end
  end
end
