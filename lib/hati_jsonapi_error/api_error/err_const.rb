# frozen_string_literal: true

module HatiJsonapiError
  module ApiError
    # rubocop:disable Layout/LineLength
    CLIENT = {
      400 => { name: 'BadRequest',                   code: :bad_request,                     message: 'Bad Request'                      },
      401 => { name: 'Unauthorized',                 code: :unauthorized,                    message: 'Unauthorized'                     },
      402 => { name: 'PaymentRequired',              code: :payment_required,                message: 'Payment Required'                 },
      403 => { name: 'Forbidden',                    code: :forbidden,                       message: 'Forbidden'                        },
      404 => { name: 'NotFound',                     code: :not_found,                       message: 'Not Found'                        },
      405 => { name: 'MethodNotAllowed',             code: :method_not_allowed,              message: 'Method Not Allowed'               },
      406 => { name: 'NotAcceptable',                code: :not_acceptable,                  message: 'Not Acceptable'                   },
      407 => { name: 'ProxyAuthenticationRequired',  code: :proxy_authentication_required,   message: 'Proxy Authentication Required'    },
      408 => { name: 'RequestTimeout',               code: :request_timeout,                 message: 'Request Timeout'                  },
      409 => { name: 'Conflict',                     code: :conflict,                        message: 'Conflict'                         },
      410 => { name: 'Gone',                         code: :gone,                            message: 'Gone'                             },
      411 => { name: 'LengthRequired',               code: :length_required,                 message: 'Length Required'                  },
      412 => { name: 'PreconditionFailed',           code: :precondition_failed,             message: 'Precondition Failed'              },
      413 => { name: 'RequestEntityTooLarge',        code: :request_entity_too_large,        message: 'Request Entity Too Large'         },
      414 => { name: 'RequestUriTooLong',            code: :request_uri_too_long,            message: 'Request Uri Too Long'             },
      415 => { name: 'UnsupportedMediaType',         code: :unsupported_media_type,          message: 'Unsupported Media Type'           },
      416 => { name: 'RequestedRangeNotSatisfiable', code: :requested_range_not_satisfiable, message: 'Requested Range Not Satisfiable'  },
      417 => { name: 'ExpectationFailed',            code: :expectation_failed,              message: 'Expectation Failed'               },
      421 => { name: 'MisdirectedRequest',           code: :misdirected_request,             message: 'Misdirected Request'              },
      422 => { name: 'UnprocessableEntity',          code: :unprocessable_entity,            message: 'Unprocessable Entity'             },
      423 => { name: 'Locked',                       code: :locked,                          message: 'Locked'                           },
      424 => { name: 'FailedDependency',             code: :failed_dependency,               message: 'Failed Dependency'                },
      425 => { name: 'TooEarly',                     code: :too_early,                       message: 'Too Early'                        },
      426 => { name: 'UpgradeRequired',              code: :upgrade_required,                message: 'Upgrade Required'                 },
      428 => { name: 'PreconditionRequired',         code: :precondition_required,           message: 'Precondition Required'            },
      429 => { name: 'TooManyRequests',              code: :too_many_requests,               message: 'Too Many Requests'                },
      431 => { name: 'RequestHeaderFieldsTooLarge',  code: :request_header_fields_too_large, message: 'Request Header Fields Too Large'  },
      451 => { name: 'UnavailableForLegalReasons',   code: :unavailable_for_legal_reasons,   message: 'Unavailable for Legal Reasons'    }
    }.freeze

    SERVER = {
      500 => { name: 'InternalServerError',           code: :internal_server_error,           message: 'Internal Server Error'          },
      501 => { name: 'NotImplemented',                code: :not_implemented,                 message: 'Not Implemented'                },
      502 => { name: 'BadGateway',                    code: :bad_gateway,                     message: 'Bad Gateway'                    },
      503 => { name: 'ServiceUnavailable',            code: :service_unavailable,             message: 'Service Unavailable'            },
      504 => { name: 'GatewayTimeout',                code: :gateway_timeout,                 message: 'Gateway Timeout'                },
      505 => { name: 'HttpVersionNotSupported',       code: :http_version_not_supported,      message: 'HTTP Version Not Supported'     },
      506 => { name: 'VariantAlsoNegotiates',         code: :variant_also_negotiates,         message: 'Variant Also Negotiates'        },
      507 => { name: 'InsufficientStorage',           code: :insufficient_storage,            message: 'Insufficient Storage'           },
      508 => { name: 'LoopDetected',                  code: :loop_detected,                   message: 'Loop Detected'                  },
      509 => { name: 'BandwidthLimitExceeded',        code: :bandwidth_limit_exceeded,        message: 'Bandwidth Limit Exceeded'       },
      510 => { name: 'NotExtended',                   code: :not_extended,                    message: 'Not Extended'                   },
      511 => { name: 'NetworkAuthenticationRequired', code: :network_authentication_required, message: 'Network Authentication Required' }
    }.freeze
    # rubocop:enable Layout/LineLength

    STATUS_MAP = CLIENT.merge(SERVER)
  end
end
