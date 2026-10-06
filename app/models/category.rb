class Category < ApplicationRecord
  DEFAULT_NAME = "General"

  belongs_to :restaurant, touch: true
  # Declarado antes del has_many para que corra antes de que se borren los items.
  before_destroy :ensure_no_items
  has_many :items, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { scope: :restaurant_id }

  normalizes :name, with: ->(name) { name.strip }

  before_create { self.position ||= restaurant.categories.maximum(:position).to_i + 1 }
  before_destroy :ensure_not_last

  private
    # Desde el panel no se borra una categoría con platillos; en la cascada
    # de Restaurant/User sí, porque sus platillos se van con ella.
    def ensure_no_items
      return if destroyed_by_association
      return unless items.exists?

      errors.add(:base, "No se puede eliminar porque existen platillos relacionados")
      throw :abort
    end

    # The item form always needs a category to choose from.
    def ensure_not_last
      return if destroyed_by_association
      return if restaurant.categories.where.not(id: id).exists?

      errors.add(:base, "Tu menú necesita al menos una categoría")
      throw :abort
    end
end
