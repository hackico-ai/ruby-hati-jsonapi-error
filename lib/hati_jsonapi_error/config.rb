module HatiJsonapiError
  class Config
    # HatiJsonapiError::Config.configure do |config|
    #   config.load_error!
    #   config.map_errors = {
    #     ActiveRecord::RecordNotFound  => ApiError::NotFound,
    #     ActiveRecord::RecordInvalid   => ApiError::UnprocessableEntity
    #     ActiveRecord::RecordNotUnique => :conflict
    #     ActiveRecord::Unauthorized    => 401
    #   }
    #   config.use_unexpected = InternalServerError
    # end

    # TODO: preload rails rescue responses
    # - what to do about order ???order of loading is important
    # - what to do about rails app?
    # - what to do about rails app not loaded?
    # - what to do about rails app not loaded?
    class << self
      def configure
        yield self if block_given?
      end

      def use_unexpected=(fallback_error)
        HatiJsonapiError::Registry.fallback = fallback_error
      end

      def map_errors=(error_map)
        HatiJsonapiError::Registry.error_map = error_map
      end

      def error_map
        HatiJsonapiError::Registry.error_map
      end

      # TODO: check if double defintion of errors
      def load_errors!
        HatiJsonapiError::Kigen.load_errors!
      end
    end
  end
end
