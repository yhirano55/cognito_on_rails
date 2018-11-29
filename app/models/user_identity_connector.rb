class UserIdentityConnector
  class UnknownProviderError < StandardError; end

  IDENTITY_POOL_ID = Rails.application.credentials.aws[:identity_pool_id]
  REGION = Rails.application.credentials.aws[:region]

  def initialize(user:, omniauth:)
    @logins = user&.logins || {}
    @omniauth = omniauth
  end

  def connect_or_create
    case @omniauth[:provider]
    when 'facebook'
      @logins['graph.facebook.com'] = @omniauth.dig(:credentials, :token)
    when 'twitter'
      @logins['api.twitter.com'] = [@omniauth.dig(:credentials, :token), @omniauth.dig(:credentials, :secret)].join(';')
    else
      raise UnknownProviderError
    end

    res = client.get_id(identity_pool_id: IDENTITY_POOL_ID, logins: @logins)

    ActiveRecord::Base.transaction do
      user = User.find_or_create_by!(identity: res.identity_id)
      user.update_credentials_from(@logins)
      user
    end

    # NOTE: How to get AWS access token for authorized user
    # res = client.get_credentials_for_identity(identity_pool_id: IDENTITY_POOL_ID, logins: @logins)
    # res.identity_id
    # res.credentials
    # res.response_meta_data
  end

  private

  def client
    @client ||= Aws::CognitoIdentity::Client.new(region: REGION)
  end
end
