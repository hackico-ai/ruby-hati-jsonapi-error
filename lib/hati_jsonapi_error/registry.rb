# frozen_string_literal: true

module HatiJsonapiError
  class Registry
    class << self
      attr_writer :fallback

      def fallback
        @fallback ||= nil
      end

      def error_map
        @error_map ||= {}
      end

      # Base.loaded? # => true
      # Registry.error_map = {
      #   ActiveRecord::RecordNotFound => :not_found,
      #   ActiveRecord::RecordInvalid  => 422
      # }
      def error_map=(error_map)
        error_map.each do |_error, mapped_error|
          next if mapped_error < Base

          err = Base.fetch_err(mapped_error)
          raise "Error #{mapped_error} not found" unless err

          error_map[error] = err
        end

        @error_map = error_map
      end

      def lookup_error(error)
        error_map[error.class] || fallback
      end
    end
  end
end
