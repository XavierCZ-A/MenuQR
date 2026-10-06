class Tag < ApplicationRecord
  DEFAULT_NAMES = [ "⭐ Recomendado", "✨ Nuevo", "🌶️ Picante", "🌱 Vegetariano" ].freeze

  belongs_to :restaurant, touch: true
  has_many :item_tags, dependent: :destroy
  has_many :items, through: :item_tags

  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, length: { maximum: 20 }, uniqueness: { scope: :restaurant_id }
end
