# frozen_string_literal: true

module HatiJsonapiError
  class Base
    def self.load_error!
      @error_map = {}
      @klass_map = {}

      API_ERROR::STATUS_MAP.each_value do |status, value|
        const_set(value[:code].to_s.upcase, Class.new(Base) do
          def initialize(**)
            super(
              code: value[:code],
              message: value[:message],
              status: status,
              source: value[:source]
            )
          end
        end)

        @status_klass_map[status] = err_klass
        @code_klass_map[value[:code]] = err_klass
      end
    end

    # Base.load_error!

    # or call
    def fetch_err(err)
      @status_klass_map[err] || @code_klass_map[err]
    end
  end
end
