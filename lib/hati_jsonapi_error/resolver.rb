# frozen_string_literal: true

module HatiJsonapiError
  class ErroResolver
    attr_reader :api_error, :use_status

    def initialize(api_error, use_status: nil)
      @api_error = api_error
      @use_status = use_status
    end

    # force to use status || use first if collection
    # TODO: think about composed if collection || or check if uniq amoung list???
    def status
      return use_status if use_status

      errors.first.status
    end

    def errors
      @errors ||= collection? ? map_collection : map_single
    end

    def to_h
      { errors: errors }
    end

    def to_json(*_args)
      to_h.to_json
    end

    private

    def map_single
      [ErroResolver.new(api_error)]
    end

    def map_collection
      api_error.map { |e| ErroResolver.new(e) }
    end

    def collection?
      api_error.is_a?(Array)
    end
  end
end
