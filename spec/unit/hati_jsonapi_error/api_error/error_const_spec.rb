# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError do
  describe 'Error Constants' do
    describe 'CLIENT errors' do
      it 'defines client error codes in 4xx range' do
        expect(described_class::CLIENT.keys).to all(be_between(400, 499))
      end

      it 'has correct structure for each client error' do
        described_class::CLIENT.each do |status, error|
          aggregate_failures "client error #{status}" do
            expect(error).to be_a(Hash)
            expect(error.keys).to match_array(%i[name code message])
            expect(error[:name]).to be_a(String)
            expect(error[:code]).to be_a(Symbol)
            expect(error[:message]).to be_a(String)
          end
        end
      end

      it 'includes common client errors' do
        common_errors = [400, 401, 403, 404, 422]

        common_errors.each do |status|
          expect(described_class::CLIENT).to have_key(status)
        end
      end

      it 'has consistent naming convention' do
        name_regex = /^[A-Z][a-zA-Z]+(?:[A-Z][a-zA-Z]+)*$/
        code_regex = /^[a-z_]+$/

        described_class::CLIENT.each do |_status, error|
          aggregate_failures "client error #{_status}" do
            expect(_status).to be_between(400, 499)
            expect(error).to be_a(Hash)
            expect(error.keys).to match_array(%i[name code message])

            expect(error[:name]).to match(name_regex)
            expect(error[:code]).to match(code_regex)
          end
        end
      end

      it 'has consistent code format' do
        code_regex = /^[a-z_]+$/

        described_class::CLIENT.each do |_status, error|
          expect(error[:code]).to match(code_regex)
        end
      end
    end

    describe 'SERVER errors' do
      it 'defines server error codes in 5xx range' do
        expect(described_class::SERVER.keys).to all(be_between(500, 599))
      end

      it 'has correct structure for each server error' do
        described_class::SERVER.each do |status, error|
          aggregate_failures "server error #{status}" do
            expect(error).to be_a(Hash)
            expect(error.keys).to match_array(%i[name code message])
            expect(error[:name]).to be_a(String)
            expect(error[:code]).to be_a(Symbol)
            expect(error[:message]).to be_a(String)
          end
        end
      end

      it 'includes common server errors' do
        common_errors = [500, 502, 503, 504]

        common_errors.each do |status|
          aggregate_failures "server error #{status}" do
            expect(status).to be_between(500, 599)
            expect(described_class::SERVER).to have_key(status)
          end
        end
      end

      it 'has consistent naming convention' do
        name_regex = /^[A-Z][a-zA-Z]+(?:[A-Z][a-zA-Z]+)*$/

        described_class::SERVER.each_value do |error|
          expect(error[:name]).to match(name_regex)
        end
      end

      it 'has consistent code format' do
        code_regex = /^[a-z_]+$/

        described_class::SERVER.each_value do |error|
          expect(error[:code]).to match(code_regex)
        end
      end
    end

    describe 'STATUS_MAP' do
      it 'combines CLIENT and SERVER errors' do
        # Get the original maps without any test modifications
        original_client = HatiJsonapiError::CLIENT
        original_server = HatiJsonapiError::SERVER
        expected_map = original_client.merge(original_server)

        # Compare keys and values separately since the map might have been modified
        expected_keys = expected_map.keys
        expected_values = expected_map.values

        # Filter out any test modifications (like key 999)
        actual_keys = described_class::STATUS_MAP.keys.select { |k| expected_keys.include?(k) }
        actual_values = described_class::STATUS_MAP.values_at(*expected_keys)

        aggregate_failures 'map structure' do
          expect(actual_keys).to match_array(expected_keys)
          expect(actual_values.compact).to match_array(expected_values)
        end
      end

      it 'has unique status codes' do
        status_codes = described_class::STATUS_MAP.keys

        expect(status_codes.uniq).to eq(status_codes)
      end

      it 'has unique error names' do
        error_names = described_class::STATUS_MAP.values.map { |error| error[:name] }

        expect(error_names.uniq).to eq(error_names)
      end

      it 'has unique error codes' do
        error_codes = described_class::STATUS_MAP.values.map { |error| error[:code] }

        expect(error_codes.uniq).to eq(error_codes)
      end
    end

    describe 'specific error examples' do
      it 'defines NotFound (404) correctly' do
        not_found = described_class::CLIENT[404]
        expected_attrs = {
          name: 'NotFound',
          code: :not_found,
          message: 'Not Found'
        }

        aggregate_failures 'not found error' do
          expect(not_found[:name]).to eq(expected_attrs[:name])
          expect(not_found[:code]).to eq(expected_attrs[:code])
          expect(not_found[:message]).to eq(expected_attrs[:message])
        end
      end

      it 'defines InternalServerError (500) correctly' do
        internal_error = described_class::SERVER[500]
        expected_attrs = {
          name: 'InternalServerError',
          code: :internal_server_error,
          message: 'Internal Server Error'
        }

        aggregate_failures 'internal server error' do
          expect(internal_error[:name]).to eq(expected_attrs[:name])
          expect(internal_error[:code]).to eq(expected_attrs[:code])
          expect(internal_error[:message]).to eq(expected_attrs[:message])
        end
      end

      it 'defines UnprocessableEntity (422) correctly' do
        unprocessable = described_class::CLIENT[422]

        expect(unprocessable).to eq(
          name: 'UnprocessableEntity',
          code: :unprocessable_entity,
          message: 'Unprocessable Entity'
        )
      end
    end
  end
end
