# ruby-hati-jsonapi-error

Standardized JSON: API-compliant error responses made easy for your Web API

```ruby

class ApiOperation < HatiOperation::Base
  ApiErr = HatiJsonapiError::Map # decorfates fulll || or resolver
  # {
  #   title: I18n.t('api.errors.forbidden.title'),
  #   status: 403,
  #   detail: I18n.t('api.errors.forbidden.detail'),
  #   source: { pointer: '/request/headers/authorization' }
  # }

  # ApiErrExt = HatiJsonapiError::MapExt[:ext]
  ApiErrExt = HatiJsonapiError::MapExt
  # {
  #   id: id,
  #   links:  {
  #     about: about,
  #     type: type
  #   },
  #   status: status,
  #   code: code,
  #   title: title,
  #   detail: detail,
  #   source:  {
  #     about: about,
  #     type: type
  #   },
  #   meta: meta
  # }
end

class Withdrawal::Operation::Create < ApiOperation
  def call(raw_params)
    params = step MyApiContract.call(raw_params), err: ApiErr.call(422)
    withdrawal = step WithdrawalService.call(params[:acc]), err: ApiErr.cal(409)
    transfer = step ProcessTransferService.call(withdrawal), err: ApiErr.call(503)

    Success(transfer.meta)
  end
end
```
