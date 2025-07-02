# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiErr do
  describe '.merge_error_map' do
    it 'merges a new error mapping into the existing error map' do
      initial_map = ApiErr.error_map
      ApiErr.merge_error_map do |map|
        map.merge!(403 => ForbiddenError)
      end

      expect(ApiErr.error_map).to include(initial_map)
      expect(ApiErr.error_map).to include(403 => ForbiddenError)
    end
  end
end
