# frozen_string_literal: true

module HatiJsonapiError
  # class ApiController < ApplicationController
  #   rescue_from ::StandardError, with: ->(e) { handle_error(e) }
  # end

  # This module contains helper methods for rendering errors in a JSON API format.
  module Helpers
    HatiErrs = HatiJsonapiError::Errors

    def render_error(error, status: nil, short: false)
      error_instance = error.is_a?(Class) ? error.new : error

      unless error_instance.class <= HatiJsonapiError::BaseError
        msg = "Supported only explicit type of HatiJsonapiError::BaseError, got: #{error_instance.class.name}"
        raise HatiErrs::HelpersRenderError, msg
      end

      resolver = HatiJsonapiError::Resolver.new(error_instance)

      unless defined?(render)
        msg = 'Render not defined'
        raise HatiErrs::HelpersRenderError, msg
      end

      render json: resolver.to_json(short: short), status: status || resolver.status
    end

    # with_original: oneOf: [false, true, :full_trace]
    def handle_error(error, with_original: false)
      error_class = error if error.class <= HatiJsonapiError::BaseError
      error_class ||= HatiJsonapiError::Registry.lookup_error(error)

      unless error_class
        msg = 'Used handle_error but no mapping of default error set'
        raise HatiErrs::HelpersHandleError, msg
      end

      # Fix: if error_class is already an instance, use it directly, otherwise create new instance
      api_err = error_class.is_a?(Class) ? error_class.new : error_class
      if with_original
        api_err.meta = {
          original_error: error.class,
          trace: error.backtrace[0],
          message: error.message
        }
        api_err.meta.merge!(backtrace: error.backtrace.join("\n")) if with_original == :full_trace
      end

      render_error(api_err)
    end

    # shorthand for API errors
    # raise ApiErr[404] # => ApiError::NotFound
    # raise ApiErr[:not_found] # => ApiError::NotFound
    class ApiErr
      class << self
        def [](error)
          call(error)
        end

        def call(error)
          raise HatiErrs::NotLoadedError unless HatiJsonapiError::Kigen.loaded?

          err = HatiJsonapiError::Kigen.fetch_err(error)

          unless err
            msg = "Error #{error} not defined on load_errors!. Check kigen.rb and api_error/error_const.rb"
            raise HatiErrs::NotDefinedErrorClassError, msg
          end

          err
        end
      end
    end
  end
end
