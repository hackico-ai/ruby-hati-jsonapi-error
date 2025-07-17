# frozen_string_literal: true

module HatiJsonapiError
  # This is the base error class for all errors in the HatiJsonapiError gem.
  class BaseError < ::StandardError
    STR = ''
    OBJ = {}.freeze

    attr_accessor :id, :code, :title, :detail, :status, :meta, :links, :source

    def initialize(**attrs)
      @id     = attrs[:id]     || STR
      @code   = attrs[:code]   || STR
      @title  = attrs[:title]  || STR
      @detail = attrs[:detail] || STR
      @status = attrs[:status] || STR

      @links  = build_links(attrs[:links])
      @source = build_source(attrs[:source])
      @meta   = attrs[:meta] || OBJ

      super(error_message)
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

    private

    def build_links(links_attrs)
      links_attrs ? Links.new(**links_attrs) : OBJ
    end

    def build_source(source_attrs)
      source_attrs ? Source.new(**source_attrs) : OBJ
    end

    def error_message
      @detail.empty? ? @title : @detail
    end
  end
end
