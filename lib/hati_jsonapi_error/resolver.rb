# frozen_string_literal: true

module HatiJsonapiError
  # This class is used to resolve errors and serialize them to a JSON API format.
  class Resolver
    attr_reader :errors, :serializer

    def initialize(api_error, serializer: PoroSerializer)
      @errors = error_arr(api_error)
      @serializer = serializer.new(errors)
    end

    def status
      errors.first.status
    end

    def to_json(*_args)
      serializer.serialize_to_json
    end

    private

    def error_arr(api_error)
      api_error.is_a?(Array) ? api_error : [api_error]
    end
  end
end
