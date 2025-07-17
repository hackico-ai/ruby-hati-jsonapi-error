# frozen_string_literal: true

module HatiJsonapiError
  class Base
    class << self
      # class ApiErr < HatiJsonapiError::Base
      #   load_error!
      # end
      # loads all errors from API_ERROR::STATUS_MAP
      #     ApiError::NotFound # => ApiError::NotFound
      #     ApiError::BadRequest
      #     ApiError::Unauthorized
      #     ApiError::Forbidden
      #     etc.
      # makes short hand for fetching error access
      #     ApiError[:not_found] # => ApiError::NotFound
      #     ApiError[404] # => ApiError::NotFound
      def load_errors!
        API_ERROR::STATUS_MAP.each do |status, value|
          const_set(value[:code].to_s.upcase, Class.new(ApiError::Base) do
            def initialize(**)
              super(
                code: value[:code],
                message: value[:message],
                status: status,
                source: value[:source]
              )
            end
          end)

          status_klass_map[status] = err_klass
          code_klass_map[value[:code]] = err_klass
        end

        @loaded = true
      end

      # HatiJsonapiError::Base.fetch_err(400) # => HatiJsonapiError::BadRequest
      # HatiJsonapiError::Base.fetch_err(:bad_request)
      def fetch_err(err)
        return unless loaded?

        @status_klass_map[err] || @code_klass_map[err]
      end

      # HatiJsonapiError::Base[400] # => HatiJsonapiError::BadRequest
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
    end
  end
end
