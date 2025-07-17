# frozen_string_literal: true

module HatiJsonapiError
  # This class is used to load all errors from STATUS_MAP in api_error/error_const.rb
  class Kigen
    class << self
      # loads all errors from STATUS_MAP in api_error/error_const.rb
      #     HatiJsonapiError::NotFound
      #     HatiJsonapiError::BadRequest
      #     HatiJsonapiError::Unauthorized
      #     HatiJsonapiError::Forbidden
      #     etc.
      def load_errors!
        return if loaded?

        HatiJsonapiError::STATUS_MAP.each do |status, value|
          next if HatiJsonapiError.const_defined?(value[:name])

          err_klass = create_error_class(status, value)

          status_klass_map[status] = err_klass
          code_klass_map[value[:code]] = err_klass
        end

        @loaded = true
      end

      # HatiJsonapiError::Kigen.fetch_err(400) # => HatiJsonapiError::BadRequest
      # HatiJsonapiError::Kigen.fetch_err(:bad_request)
      def fetch_err(err)
        return unless loaded?

        status_klass_map[err] || code_klass_map[err]
      end

      # HatiJsonapiError::Kigen[400] # => HatiJsonapiError::BadRequest
      def [](err)
        fetch_err(err)
      end

      def loaded?
        @loaded
      end

      def status_klass_map
        @status_klass_map ||= {}
      end

      def code_klass_map
        @code_klass_map ||= {}
      end

      private

      def create_error_class(status, value)
        HatiJsonapiError.const_set(value[:name], Class.new(HatiJsonapiError::BaseError) do
          define_method :initialize do |**attrs|
            defaults = {
              code: value[:code],
              message: value[:message],
              title: value[:message],
              status: status
            }
            super(**defaults.merge(attrs))
          end
        end)
      end
    end
  end
end
