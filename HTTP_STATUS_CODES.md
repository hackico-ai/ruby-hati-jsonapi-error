# HTTP Status Codes Reference

## Client Errors (4xx)

| Status | Class Name                   | Code                            | Message                         |
| ------ | ---------------------------- | ------------------------------- | ------------------------------- |
| 400    | BadRequest                   | bad_request                     | Bad Request                     |
| 401    | Unauthorized                 | unauthorized                    | Unauthorized                    |
| 402    | PaymentRequired              | payment_required                | Payment Required                |
| 403    | Forbidden                    | forbidden                       | Forbidden                       |
| 404    | NotFound                     | not_found                       | Not Found                       |
| 405    | MethodNotAllowed             | method_not_allowed              | Method Not Allowed              |
| 406    | NotAcceptable                | not_acceptable                  | Not Acceptable                  |
| 407    | ProxyAuthenticationRequired  | proxy_authentication_required   | Proxy Authentication Required   |
| 408    | RequestTimeout               | request_timeout                 | Request Timeout                 |
| 409    | Conflict                     | conflict                        | Conflict                        |
| 410    | Gone                         | gone                            | Gone                            |
| 411    | LengthRequired               | length_required                 | Length Required                 |
| 412    | PreconditionFailed           | precondition_failed             | Precondition Failed             |
| 413    | RequestEntityTooLarge        | request_entity_too_large        | Request Entity Too Large        |
| 414    | RequestUriTooLong            | request_uri_too_long            | Request Uri Too Long            |
| 415    | UnsupportedMediaType         | unsupported_media_type          | Unsupported Media Type          |
| 416    | RequestedRangeNotSatisfiable | requested_range_not_satisfiable | Requested Range Not Satisfiable |
| 417    | ExpectationFailed            | expectation_failed              | Expectation Failed              |
| 421    | MisdirectedRequest           | misdirected_request             | Misdirected Request             |
| 422    | UnprocessableEntity          | unprocessable_entity            | Unprocessable Entity            |
| 423    | Locked                       | locked                          | Locked                          |
| 424    | FailedDependency             | failed_dependency               | Failed Dependency               |
| 425    | TooEarly                     | too_early                       | Too Early                       |
| 426    | UpgradeRequired              | upgrade_required                | Upgrade Required                |
| 428    | PreconditionRequired         | precondition_required           | Precondition Required           |
| 429    | TooManyRequests              | too_many_requests               | Too Many Requests               |
| 431    | RequestHeaderFieldsTooLarge  | request_header_fields_too_large | Request Header Fields Too Large |
| 451    | UnavailableForLegalReasons   | unavailable_for_legal_reasons   | Unavailable for Legal Reasons   |

## Server Errors (5xx)

| Status | Class Name                    | Code                            | Message                         |
| ------ | ----------------------------- | ------------------------------- | ------------------------------- |
| 500    | InternalServerError           | internal_server_error           | Internal Server Error           |
| 501    | NotImplemented                | not_implemented                 | Not Implemented                 |
| 502    | BadGateway                    | bad_gateway                     | Bad Gateway                     |
| 503    | ServiceUnavailable            | service_unavailable             | Service Unavailable             |
| 504    | GatewayTimeout                | gateway_timeout                 | Gateway Timeout                 |
| 505    | HttpVersionNotSupported       | http_version_not_supported      | HTTP Version Not Supported      |
| 506    | VariantAlsoNegotiates         | variant_also_negotiates         | Variant Also Negotiates         |
| 507    | InsufficientStorage           | insufficient_storage            | Insufficient Storage            |
| 508    | LoopDetected                  | loop_detected                   | Loop Detected                   |
| 509    | BandwidthLimitExceeded        | bandwidth_limit_exceeded        | Bandwidth Limit Exceeded        |
| 510    | NotExtended                   | not_extended                    | Not Extended                    |
| 511    | NetworkAuthenticationRequired | network_authentication_required | Network Authentication Required |

## Usage Examples

```ruby
# By status code
HatiJsonapiError::NotFound.new                    # 404
HatiJsonapiError::BadRequest.new                  # 400
HatiJsonapiError::InternalServerError.new         # 500

# By symbol
ApiErr[:not_found]                                # 404
ApiErr[:bad_request]                              # 400
ApiErr[:internal_server_error]                    # 500

# By numeric code
ApiErr[404]                                       # NotFound
ApiErr[400]                                       # BadRequest
ApiErr[500]                                       # InternalServerError
```

## Notes

- All error classes inherit from `HatiJsonapiError::BaseError`
- Each error supports custom attributes: `id`, `detail`, `meta`, `links`, `source`
- Error responses are JSON:API compliant
- Status codes follow RFC 7231 and related RFCs
