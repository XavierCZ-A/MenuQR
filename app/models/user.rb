class User < ApplicationRecord
  MAX_RESTAURANTS = 1

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :restaurants, dependent: :destroy

  accepts_nested_attributes_for :restaurants, limit: MAX_RESTAURANTS

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, allow_nil: true, length: { minimum: 8 }, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+\z/, message: "debe incluir al menos una letra mayúscula, una letra minúscula y un número" }


  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
