# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  identity   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_identity  (identity) UNIQUE
#

class User < ApplicationRecord
  validates :identity, presence: true, uniqueness: true

  has_many :credentials, dependent: :delete_all

  def logins
    Hash[credentials.map(&:login)]
  end

  def update_credentials_from(logins)
    logins.each do |domain, token|
      credentials.find_or_initialize_by(domain: domain).tap do |credential|
        credential.token = token
        credential.save!
      end
    end
  end
end
