class Restaurant < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :slug, presence: true
  validate :user_within_restaurant_limit

  before_validation :generate_slug, on: :create

  private
    def user_within_restaurant_limit
      return unless user

      if user.restaurants.count >= User::MAX_RESTAURANTS
        errors.add(:base, "Has alcanzado el límite de restaurantes permitidos")
      end
    end

    def generate_slug
      return if slug.present?
      return if name.blank?

      base_slug = slugify(name)
      candidate = base_slug
      counter = 2

      while Restaurant.exists?(slug: candidate)
        candidate = "#{base_slug}-#{counter}"
        counter += 1
      end

      self.slug = candidate
    end

    def slugify(text)
      text.to_s
          .downcase
          .strip
          .gsub(/[áàäâã]/, "a")
          .gsub(/[éèëê]/, "e")
          .gsub(/[íìïî]/, "i")
          .gsub(/[óòöôõ]/, "o")
          .gsub(/[úùüû]/, "u")
          .gsub(/ñ/, "n")
          .gsub(/\s+/, "-")
          .gsub(/[^\w\-]/, "")
          .gsub(/\-\-+/, "-")
    end
end
