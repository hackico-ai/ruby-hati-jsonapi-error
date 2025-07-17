# frozen_string_literal: true

module HatiJsonapiError
  module ApiError
    class Links
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
end
