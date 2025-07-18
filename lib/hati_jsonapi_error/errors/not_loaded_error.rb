# frozen_string_literal: true

module HatiJsonapiError
  # WIP: draft
  module Errors
    class NotLoadedError < StandardError
      def initialize(message = 'HatiJsonapiError::Kigen not loaded')
        super
      end
    end
  end
end
