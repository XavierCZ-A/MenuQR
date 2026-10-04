class Category < ApplicationRecord
  DEFAULT_NAME = "General"

  belongs_to :restaurant, touch: true
  has_many :items, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { scope: :restaurant_id }

  normalizes :name, with: ->(name) { name.strip }

  before_create { self.position ||= restaurant.categories.maximum(:position).to_i + 1 }
  before_destroy :ensure_not_last

  private
    # The item form always needs a category to choose from.
    def ensure_not_last
      return if destroyed_by_association
      return if restaurant.categories.where.not(id: id).exists?

      errors.add(:base, "Tu menú necesita al menos una categoría")
      throw :abort
    end
end
