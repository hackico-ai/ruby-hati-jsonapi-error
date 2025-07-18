# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::Kigen do
  before(:all) { described_class.load_errors! }

  describe '.load_errors!' do
    context 'when testing loading behavior' do
      before do
        err_attrs = { name: 'TestError500', code: :test_error500, message: 'Test Error' }

        allow(HatiJsonapiError).to receive(:const_defined?).with('TestError500').and_return(false)
        allow(HatiJsonapiError::STATUS_MAP).to receive(:each).and_yield(500, err_attrs)
      end

      it 'loads error classes from STATUS_MAP' do
        aggregate_failures 'error classes' do
          expect(HatiJsonapiError::NotFound).to be < HatiJsonapiError::BaseError
          expect(HatiJsonapiError::BadRequest).to be < HatiJsonapiError::BaseError
          expect(HatiJsonapiError::InternalServerError).to be < HatiJsonapiError::BaseError
        end
      end

      it 'sets loaded flag when called' do
        described_class.instance_variable_set(:@loaded, false)

        expect { described_class.load_errors! }.to change(described_class, :loaded?).from(false).to(true)
      end

      it 'skips loading if already loaded' do
        described_class.instance_variable_set(:@loaded, true)
        allow(HatiJsonapiError).to receive(:const_set)

        described_class.load_errors!

        expect(HatiJsonapiError).not_to have_received(:const_set)
      end
    end
  end

  describe '.fetch_err' do
    it 'returns error class by status code' do
      error_class = described_class.fetch_err(404)

      aggregate_failures 'error class' do
        expect(error_class).to be_a(Class)
        expect(error_class).to be < HatiJsonapiError::BaseError
        expect(error_class.new.status).to eq(404)
      end
    end

    it 'returns error class by symbol code' do
      error_class = described_class.fetch_err(:not_found)

      aggregate_failures 'error class' do
        expect(error_class).to be_a(Class)
        expect(error_class).to be < HatiJsonapiError::BaseError
        expect(error_class.new.code).to eq(:not_found)
      end
    end

    it 'returns nil for unknown error' do
      expect(described_class.fetch_err(:unknown)).to be_nil
    end

    context 'when not loaded' do
      it 'returns nil' do
        original_loaded = described_class.loaded?
        original_status_map = described_class.status_klass_map.dup
        original_code_map = described_class.code_klass_map.dup

        begin
          described_class.instance_variable_set(:@loaded, false)
          expect(described_class.fetch_err(404)).to be_nil
        ensure
          # Restore state
          described_class.instance_variable_set(:@loaded, original_loaded)
          described_class.instance_variable_set(:@status_klass_map, original_status_map)
          described_class.instance_variable_set(:@code_klass_map, original_code_map)
        end
      end
    end
  end

  describe '.[]' do
    it 'delegates to fetch_err' do
      allow(described_class).to receive(:fetch_err)

      described_class[404]

      expect(described_class).to have_received(:fetch_err).with(404)
    end
  end

  describe 'generated error classes' do
    it 'creates error with correct defaults' do
      error = HatiJsonapiError::NotFound.new

      aggregate_failures 'default attributes' do
        expect(error.code).to eq(:not_found)
        expect(error.to_h[:title]).to eq('Not Found')
        expect(error.status).to eq(404)
      end
    end

    it 'allows overriding defaults' do
      error = HatiJsonapiError::NotFound.new(title: 'Custom title')

      aggregate_failures 'custom attributes' do
        expect(error.to_h[:title]).to eq('Custom title')
        expect(error.status).to eq(404)
        expect(error.code).to eq(:not_found)
      end
    end
  end
end
