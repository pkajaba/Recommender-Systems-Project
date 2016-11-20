require 'random_strategy'

class User < ApplicationRecord
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def recommend_joke
    strategy = RandomStrategy.new
    strategy.recommend_next(self)
  end

  has_many :ratings
  has_many :jokes, :through => :ratings
end
