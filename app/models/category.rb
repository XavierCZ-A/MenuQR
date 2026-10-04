class Category < ApplicationRecord
  DEFAULT_NAME = "General"

  belongs_to :restaurant, touch: true
  has_many :items, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :restaurant_id }

  normalizes :name, with: ->(name) { name.strip }

  before_create { self.position ||= restaurant.categories.maximum(:position).to_i + 1 }
end
