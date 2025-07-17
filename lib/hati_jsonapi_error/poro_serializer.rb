# frozen_string_literal: true

module HatiJsonapiError
  class PoroSerializer
    SHORT_KEYS = %i[status title detail source].freeze

    def initialize(error)
      @errors = normalized_errors(error)
    end

    def serialize_to_json(short: false)
      serializable_hash(short: short).to_json
    end

    def serializable_hash(short: false)
      if short
        { errors: errors.map { |error| error.to_h.slice(*SHORT_KEYS) } }
      else
        { errors: errors.map(&:to_h) }
      end
    end

    private

    attr_reader :errors

    def normalized_errors(error)
      error.is_a?(Array) ? error : [error]
    end
  end
end
