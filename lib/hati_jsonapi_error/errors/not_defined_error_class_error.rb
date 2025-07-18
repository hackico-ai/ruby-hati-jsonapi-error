# frozen_string_literal: true

module HatiJsonapiError
  # WIP: draft
  module Errors
    class NotDefinedErrorClassError < StandardError
      def initialize(message = 'Error class not defined')
        super
      end
    end
  end
end
