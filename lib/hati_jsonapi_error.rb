# frozen_string_literal: true

require 'hati_jsonapi_error/version'

# api_error/*
require 'hati_jsonapi_error/api_error/base_error'
require 'hati_jsonapi_error/api_error/error_const'
require 'hati_jsonapi_error/api_error/links'
require 'hati_jsonapi_error/api_error/source'

# logic
require 'hati_jsonapi_error/config'
require 'hati_jsonapi_error/kigen'
require 'hati_jsonapi_error/helpers' # TODO: move to api_error/helpers.rb
require 'hati_jsonapi_error/poro_serializer'
require 'hati_jsonapi_error/registry'
require 'hati_jsonapi_error/resolver'
