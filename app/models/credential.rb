# == Schema Information
#
# Table name: credentials
#
#  id         :integer          not null, primary key
#  domain     :string           not null
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_credentials_on_user_id_and_domain  (user_id,domain) UNIQUE
#

class Credential < ApplicationRecord
  class UnknownProviderError; end

  belongs_to :user

  validates :token, presence: true
  validates :domain, presence: true, uniqueness: { scope: :user_id }

  def login
    [domain, token]
  end
end
