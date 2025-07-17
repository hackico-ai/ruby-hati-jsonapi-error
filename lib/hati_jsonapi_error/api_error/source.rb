# frozen_string_literal: true

module HatiJsonapiError
  # This class is used to build the source object for the error response.
  class Source
    STR = ''

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
