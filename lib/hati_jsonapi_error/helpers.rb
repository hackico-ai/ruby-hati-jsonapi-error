# frozen_string_literal: true

module HatiJsonapiError
  # class ApiController < ApplicationController
  #   rescue_from ::StandardError, with: ->(e) { handle_error(e) }
  # end

  module Helpers
    def render_error(error, status: nil, short: false)
      error = ErroResolver.new(error) if error < BaseApiError

      render json: error.to_json(short: short), status: status || error.status
    end

    # add default even if not configured

    def handle_error(error)
      error_class = error if error < HatiJsonapiError::Base
      error_class ||= ErrMapper.lookup_error(error)

      raise 'No Mapping found! No default set' unless error_class

      render_error(error_class)
    end
  end
end
