# frozen_string_literal: true

module HatiJsonapiError
  module ApiError
    STR = ''
    OBJ = {}.freeze

    class Base
      attr_accessor :id, :code, :title, :detail, :status, :meta, :links, :source

      def initialize(**attrs)
        @id     = attrs[:id]     || STR
        @code   = attrs[:code]   || STR
        @title  = attrs[:title]  || STR
        @detail = attrs[:detail] || STR
        @status = attrs[:status] || STR

        @links  = attrs[:links]  ? Links.new(**attrs[:links])   : OBJ
        @source = attrs[:source] ? Source.new(**attrs[:source]) : OBJ

        @meta   = attrs[:meta] || OBJ
      end

      # NOTE: used in lib/hati_jsonapi_error/payload_adapter.rb
      def to_h
        {
          id: id,
          links: links.to_h,
          status: status,
          code: code,
          title: title,
          detail: detail,
          source: source.to_h,
          meta: meta
        }
      end

      def to_s
        to_h.to_s
      end

      def serializable_hash
        to_h
      end

      def to_json(*_args)
        serializable_hash.to_json
      end
    end
  end
end
