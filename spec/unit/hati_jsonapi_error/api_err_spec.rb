# frozen_string_literal: true

require 'spec_helper'

# TODO: move to api_error/helpers_spec.rb
RSpec.describe HatiJsonapiError::Helpers::ApiErr do
  describe '.[]' do
    it 'returns the error class for a given error code' do
      expect(HatiJsonapiError::Helpers::ApiErr[:not_found]).to eq(HatiJsonapiError::ApiError::NotFound)
    end
  end
end
