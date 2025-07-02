module HatiJsonapiError
  class BaseApiError
    attr_accessor :code, :message, :status, :source

    def initialize(code:, message:, status:, source: {})
      @code = code
      @message = message
      @status = status
      @source = source
    end

    def serializable_hash
      {
        status: status.to_s,
        title: title,
        detail: detail,
        source: source
      }
    end

    def to_h
      serializable_hash
    end

    def to_s
      serializable_hash.to_s
    end

    def to_json(*_args)
      serializable_hash.to_json
    end
  end
end
