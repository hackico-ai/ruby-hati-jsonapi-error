# frozen_string_literal: true

module HatiJsonapiError
  module ApiError
    class Source
      attr_accessor :pointer, :parameter, :header

      def initialize(pointer: STR, parameter: STR, header: STR)
        @pointer = pointer
        @parameter = parameter
        @header = header
      end

      def to_h
        {
          pointer: pointer,
          parameter: parameter,
          header: header
        }
      end
    end
  end
end
