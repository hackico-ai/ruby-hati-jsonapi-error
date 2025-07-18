# frozen_string_literal: true

require 'hati_jsonapi_error/version'

# errors
require 'hati_jsonapi_error/errors/helpers_handle_error'
require 'hati_jsonapi_error/errors/helpers_render_error'
require 'hati_jsonapi_error/errors/not_defined_error_class_error'
require 'hati_jsonapi_error/errors/not_loaded_error'

# api_error/*
require 'hati_jsonapi_error/api_error/base_error'
require 'hati_jsonapi_error/api_error/error_const'
require 'hati_jsonapi_error/api_error/links'
require 'hati_jsonapi_error/api_error/source'

# logic
require 'hati_jsonapi_error/config'
require 'hati_jsonapi_error/kigen'
require 'hati_jsonapi_error/helpers'
require 'hati_jsonapi_error/poro_serializer'
require 'hati_jsonapi_error/registry'
require 'hati_jsonapi_error/resolver'
