# frozen_string_literal: true

module HatiJsonapiError
  # WIP: draft
  module Errors
    class HelpersHandleError < StandardError
      def initialize(message = 'Invalid Helpers:handle_error')
        super
      end
    end
  end
end
