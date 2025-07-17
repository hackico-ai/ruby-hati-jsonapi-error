# frozen_string_literal: true

module HatiJsonapiError
  # This class is used to build the links object for the error response.
  class Links
    STR = ''

    attr_accessor :about, :type

    def initialize(about: STR, type: STR)
      @about = about
      @type = type
    end

    def to_h
      {
        about: about,
        type: type
      }
    end
  end
end
