# frozen_string_literal: true

module HatiJsonapiError
  module Helpers
    def render_error(error, status: 500)
      error = ErroResolver.new(error) if error < BaseApiError

      render json: error.to_json, status: error.status
    end
  end
end
