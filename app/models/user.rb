require_relative '../logic/recommender_strategy.rb'

class User < ApplicationRecord
  has_many :ratings
  has_many :jokes, :through => :ratings
  has_many :user_prefer_categories

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)

      user.strategy = RecommenderStrategy.randomize

      user.save!
    end
  end

  def recommend_joke
    my_strategy.recommend_next()
  end

  private
  def my_strategy
    @strategy ||= RecommenderStrategy.strategy_by_number(self.strategy, user)
  end

  @strategy = nil

end
