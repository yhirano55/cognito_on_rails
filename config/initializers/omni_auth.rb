Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :facebook,
    Rails.application.credentials.facebook[:api_key],
    Rails.application.credentials.facebook[:api_secret]
  )

  provider(
    :github,
    Rails.application.credentials.github[:api_key],
    Rails.application.credentials.github[:api_secret]
  )

  provider(
    :twitter,
    Rails.application.credentials.twitter[:api_key],
    Rails.application.credentials.twitter[:api_secret]
  )
end
