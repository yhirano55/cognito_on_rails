class UserIdentityConnector
  class UnknownProviderError < StandardError; end

  ACCESS_KEY_ID = Rails.application.credentials.aws[:access_key_id]
  SECRET_ACCESS_KEY = Rails.application.credentials.aws[:secret_access_key]
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
      # res = client.get_id(identity_pool_id: IDENTITY_POOL_ID, logins: @logins)
      res = client.get_open_id_token_for_developer_identity(identity_pool_id: IDENTITY_POOL_ID, logins: @logins)
    when 'github'
      @logins['github.com'] = Digest::SHA512.hexdigest("#{IDENTITY_POOL_ID}:#{@omniauth.dig(:uuid)}")
      res = client.get_open_id_token_for_developer_identity(identity_pool_id: IDENTITY_POOL_ID, logins: @logins)
    when 'twitter'
      @logins['api.twitter.com'] = [@omniauth.dig(:credentials, :token), @omniauth.dig(:credentials, :secret)].join(';')
      # res = client.get_id(identity_pool_id: IDENTITY_POOL_ID, logins: @logins)
      res = client.get_open_id_token_for_developer_identity(identity_pool_id: IDENTITY_POOL_ID, logins: @logins)
    else
      raise UnknownProviderError
    end

    ActiveRecord::Base.transaction do
      user = User.find_or_create_by!(identity: res.identity_id)
      user.update_credentials_from(@logins)
      user
    end
  end

  private

  def client
    @client ||= Aws::CognitoIdentity::Client.new(
      region: REGION,
      access_key_id: ACCESS_KEY_ID,
      secret_access_key: SECRET_ACCESS_KEY,
    )
  end
end
