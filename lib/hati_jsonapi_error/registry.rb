# frozen_string_literal: true

module HatiJsonapiError
  # This class is used to register errors and provide a fallback error.
  class Registry
    class << self
      def fallback=(err)
        @fallback = loaded_error?(err) ? err : fetch_error(err)
      end

      def fallback
        @fallback ||= nil
      end

      # Base.loaded? # => true
      # Registry.error_map = {
      #   ActiveRecord::RecordNotFound => :not_found,
      #   ActiveRecord::RecordInvalid  => 422
      # }
      def error_map=(error_map)
        error_map.each do |error, mapped_error|
          next if loaded_error?(mapped_error)

          error_map[error] = fetch_error(mapped_error)
        end

        @error_map = error_map
      end

      def error_map
        @error_map ||= {}
      end

      def lookup_error(error)
        error_map[error.class] || fallback
      end

      private

      def loaded_error?(error)
        error.is_a?(Class) && error <= HatiJsonapiError::BaseError
      end

      def fetch_error(error)
        err = HatiJsonapiError::Kigen.fetch_err(error)
        unless err
          msg = "Error #{error} definition not found in lib/hati_jsonapi_error/api_error/error_const.rb"
          raise HatiJsonapiError::Errors::NotDefinedErrorClassError, msg
        end

        err
      end
    end
  end
end
