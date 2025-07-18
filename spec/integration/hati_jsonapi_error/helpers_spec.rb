# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HatiJsonapiError::Helpers do
  let(:dummy_class) { Dummy.dummy_class }

  let(:instance) { dummy_class.new }

  before(:all) { HatiJsonapiError::Kigen.load_errors! }

  describe '#render_error' do
    context 'with error class' do
      it 'renders error with default status' do
        instance.render_error(HatiJsonapiError::NotFound)
        parsed_json = JSON.parse(instance.rendered_json)

        aggregate_failures 'rendered error' do
          expect(instance.rendered_status).to eq(404)
          expect(parsed_json['errors'].first).to include(
            'status' => 404,
            'code' => 'not_found',
            'title' => 'Not Found'
          )
        end
      end

      it 'renders error with custom status' do
        instance.render_error(HatiJsonapiError::NotFound, status: 400)

        expect(instance.rendered_status).to eq(400)
      end

      it 'renders short version when requested' do
        instance.render_error(HatiJsonapiError::NotFound, short: true)
        parsed_json = JSON.parse(instance.rendered_json)
        err_hash = {
          'status' => 404,
          'code' => 'not_found',
          'title' => 'Not Found'
        }

        expect(parsed_json['errors'].first).to include(err_hash)
      end
    end

    context 'with error instance' do
      it 'renders error with custom attributes' do
        error = HatiJsonapiError::NotFound.new(
          title: 'Custom Title',
          detail: 'Custom Detail'
        )

        instance.render_error(error)

        parsed_json = JSON.parse(instance.rendered_json)
        err_hash = {
          'title' => 'Custom Title',
          'detail' => 'Custom Detail'
        }

        expect(parsed_json['errors'].first).to include(err_hash)
      end
    end

    context 'with invalid error' do
      it 'raises ArgumentError for non-BaseError class' do
        message = 'Error must be a BaseError class or instance'

        expect { instance.render_error(StandardError) }.to raise_error(ArgumentError, message)
      end

      it 'raises ArgumentError for non-BaseError instance' do
        message = 'Error must be a BaseError class or instance'

        expect { instance.render_error(StandardError.new) }.to raise_error(ArgumentError, message)
      end
    end
  end

  describe '#handle_error' do
    before do
      HatiJsonapiError::Registry.error_map = {
        StandardError => HatiJsonapiError::InternalServerError,
        ArgumentError => :bad_request
      }
      HatiJsonapiError::Registry.fallback = HatiJsonapiError::InternalServerError
    end

    it 'handles BaseError directly' do
      error = HatiJsonapiError::NotFound.new
      instance.handle_error(error)

      parsed_json = JSON.parse(instance.rendered_json)
      err_hash = { 'code' => 'not_found' }

      aggregate_failures 'rendered error' do
        expect(instance.rendered_status).to eq(404)
        expect(parsed_json['errors'].first).to include(err_hash)
      end
    end

    it 'maps standard errors to API errors' do
      instance.handle_error(StandardError.new)
      parsed_json = JSON.parse(instance.rendered_json)
      err_hash = { 'code' => 'internal_server_error' }

      aggregate_failures 'rendered error' do
        expect(instance.rendered_status).to eq(500)
        expect(parsed_json['errors'].first).to include(err_hash)
      end
    end

    it 'maps errors using symbol codes' do
      instance.handle_error(ArgumentError.new)
      parsed_json = JSON.parse(instance.rendered_json)
      err_hash = { 'code' => 'bad_request' }

      aggregate_failures 'rendered error' do
        expect(instance.rendered_status).to eq(400)
        expect(parsed_json['errors'].first).to include(err_hash)
      end
    end

    it 'raises error when no mapping found and no fallback set' do
      HatiJsonapiError::Registry.instance_variable_set(:@error_map, {})
      HatiJsonapiError::Registry.instance_variable_set(:@fallback, nil)

      message = 'Used handle_error(HatiJsonapiError::Helpers ) but no mapping found! No default unexpected error set'

      expect { instance.handle_error(StandardError.new) }.to raise_error(message)
    end
  end

  describe HatiJsonapiError::Helpers::ApiErr do
    subject(:api_err) { described_class.new }

    before { HatiJsonapiError::Kigen.load_errors! }

    it 'returns error class by status code' do
      expect(api_err[404]).to eq(HatiJsonapiError::NotFound)
    end

    it 'returns error class by symbol' do
      expect(api_err[:not_found]).to eq(HatiJsonapiError::NotFound)
    end

    it 'raises error for unknown code' do
      message = 'Error unknown not found'

      expect { api_err[:unknown] }.to raise_error(message)
    end

    it 'raises error when Kigen not loaded' do
      allow(HatiJsonapiError::Kigen).to receive(:loaded?).and_return(false)
      message = 'HatiJsonapiError::Kigen not loaded'

      expect { api_err[404] }.to raise_error(message)
    end
  end
end
