# frozen_string_literal: true

# NOTE: helper names follow convention 'support_<module_name>_<helper_name>'

module Dummy
  def self.dummy_class
    @dummy_class ||= Class.new do
      include HatiJsonapiError::Helpers

      attr_reader :rendered_json, :rendered_status

      def render(json:, status:)
        @rendered_json = json
        @rendered_status = status
      end
    end
  end
end
