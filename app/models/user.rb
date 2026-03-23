class User < ApplicationRecord
  # :recoverable を除外（action_mailer スキップのため）
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  validates :account_balance, numericality: { greater_than: 0 }, allow_nil: true
  validates :risk_percent, numericality: { greater_than: 0, less_than_or_equal_to: 100 }, allow_nil: true
end
