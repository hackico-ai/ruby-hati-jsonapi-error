# frozen_string_literal: true

module HatiJsonapiError
  # class ApiController < ApplicationController
  #   rescue_from ::StandardError, with: ->(e) { handle_error(e) }
  # end

  # This module contains helper methods for rendering errors in a JSON API format.
  module Helpers
    def render_error(error, status: nil, short: false)
      error_instance = error.is_a?(Class) ? error.new : error

      unless error_instance.class <= HatiJsonapiError::BaseError
        raise ArgumentError, 'Error must be a BaseError class or instance'
      end

      resolver = HatiJsonapiError::Resolver.new(error_instance)
      raise 'Render not defined' unless defined?(render)

      render json: resolver.to_json(short: short), status: status || resolver.status
    end

    # add default even if not configured
    def handle_error(error)
      error_class = error if error.class <= HatiJsonapiError::BaseError
      error_class ||= HatiJsonapiError::Registry.lookup_error(error)

      unless error_class
        raise 'Used handle_error(HatiJsonapiError::Helpers ) but no mapping found! No default unexpected error set'
      end

      render_error(error_class)
    end

    # shorthand for API errors
    # raise ApiErr[404] # => ApiError::NotFound
    # raise ApiErr[:not_found] # => ApiError::NotFound
    class ApiErr
      def [](error)
        call(error)
      end

      def call(error)
        raise 'HatiJsonapiError::Kigen not loaded' unless HatiJsonapiError::Kigen.loaded?

        HatiJsonapiError::Kigen.fetch_err(error) || raise("Error #{error} not found")
      end
    end
  end
end
