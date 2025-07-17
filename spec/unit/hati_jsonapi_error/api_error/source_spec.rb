# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::Source do
  describe 'constants' do
    it 'defines STR as empty string' do
      expect(described_class::STR).to eq('')
    end
  end

  describe '#initialize' do
    context 'with all attributes' do
      subject(:source) do
        described_class.new(
          pointer: '/data/attributes/email',
          parameter: 'email',
          header: 'Authorization'
        )
      end

      it 'sets all attributes correctly' do
        aggregate_failures 'attributes' do
          expect(source.pointer).to eq('/data/attributes/email')
          expect(source.parameter).to eq('email')
          expect(source.header).to eq('Authorization')
        end
      end
    end

    context 'with no attributes' do
      subject(:source) { described_class.new }

      it 'sets default values' do
        aggregate_failures 'defaults' do
          expect(source.pointer).to eq('')
          expect(source.parameter).to eq('')
          expect(source.header).to eq('')
        end
      end
    end

    context 'with partial attributes' do
      it 'sets pointer and defaults others' do
        source = described_class.new(pointer: '/data/attributes/email')

        aggregate_failures 'partial pointer' do
          expect(source.pointer).to eq('/data/attributes/email')
          expect(source.parameter).to eq('')
          expect(source.header).to eq('')
        end
      end

      it 'sets parameter and defaults others' do
        source = described_class.new(parameter: 'email')

        aggregate_failures 'partial parameter' do
          expect(source.pointer).to eq('')
          expect(source.parameter).to eq('email')
          expect(source.header).to eq('')
        end
      end

      it 'sets header and defaults others' do
        source = described_class.new(header: 'Authorization')

        aggregate_failures 'partial header' do
          expect(source.pointer).to eq('')
          expect(source.parameter).to eq('')
          expect(source.header).to eq('Authorization')
        end
      end
    end
  end

  describe '#to_h' do
    it 'returns hash with all attributes' do
      source = described_class.new(
        pointer: '/data/attributes/email',
        parameter: 'email',
        header: 'Authorization'
      )

      expect(source.to_h).to eq(
        pointer: '/data/attributes/email',
        parameter: 'email',
        header: 'Authorization'
      )
    end

    it 'returns hash with default values when no attributes set' do
      source = described_class.new

      expect(source.to_h).to eq(
        pointer: '',
        parameter: '',
        header: ''
      )
    end

    it 'returns hash with partial attributes' do
      source = described_class.new(pointer: '/data/attributes/email')

      expect(source.to_h).to eq(
        pointer: '/data/attributes/email',
        parameter: '',
        header: ''
      )
    end
  end

  describe 'attribute accessors' do
    subject(:source) { described_class.new }

    it 'allows setting pointer' do
      source.pointer = '/data/attributes/email'
      expect(source.pointer).to eq('/data/attributes/email')
    end

    it 'allows setting parameter' do
      source.parameter = 'email'
      expect(source.parameter).to eq('email')
    end

    it 'allows setting header' do
      source.header = 'Authorization'
      expect(source.header).to eq('Authorization')
    end

    it 'reflects attribute changes in to_h' do
      source.pointer = '/data/attributes/email'
      source.parameter = 'email'
      source.header = 'Authorization'

      expect(source.to_h).to eq(
        pointer: '/data/attributes/email',
        parameter: 'email',
        header: 'Authorization'
      )
    end
  end

  describe 'JSON:API compliance' do
    it 'follows JSON:API source object structure' do
      source = described_class.new(
        pointer: '/data/attributes/email',
        parameter: 'email',
        header: 'Authorization'
      )
      result = source.to_h

      aggregate_failures 'structure' do
        expect(result.keys).to match_array(%i[pointer parameter header])
        expect(result[:pointer]).to be_a(String)
        expect(result[:parameter]).to be_a(String)
        expect(result[:header]).to be_a(String)
      end
    end

    it 'uses JSON pointer format for pointer attribute' do
      source = described_class.new(pointer: '/data/attributes/email')

      aggregate_failures 'pointer format' do
        expect(source.pointer).to start_with('/')
        expect(source.pointer).not_to end_with('/')
        # Replace be_present with !empty? for standard Ruby
        expect(source.pointer.split('/')[1..]).to all(satisfy { |part| !part.empty? })
      end
    end
  end
end
