# frozen_string_literal: true

module HatiJsonapiError
  # WIP: draft
  module Errors
    class HelpersRenderError < StandardError
      def initialize(message = 'Invalid Helpers:render_error')
        super
      end
    end
  end
end
