class UserIdentityConnector
  class UnknownProviderError < StandardError; end

  def initialize(user:, omniauth:)
    @user = user
    @omniauth = omniauth
  end

  def connect_or_create
    ActiveRecord::Base.transaction do
      user = User.find_or_create_by!(identity: identity_id)
      user.update_credentials_from(logins)
      user
    end
  end

  private

  attr_reader :user, :omniauth

  def client
    @client ||= Aws::CognitoIdentity::Client.new(region: Rails.application.credentials.aws[:region])
  end

  def identity_id
    response = client.get_id(identity_pool_id: Rails.application.credentials.aws[:identity_pool_id], logins: logins)
    response.identity_id
  end

  def logins
    @logins ||=
      (user&.logins || {}).tap do |hash|
        case omniauth[:provider]
        when 'facebook'
          hash['graph.facebook.com'] = omniauth.dig(:credentials, :token)
        when 'twitter'
          hash['api.twitter.com'] = [omniauth.dig(:credentials, :token), omniauth.dig(:credentials, :secret)].join(';')
        else
          raise UnknownProviderError
        end
      end
  end
end
