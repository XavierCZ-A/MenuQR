class Item < ApplicationRecord
  MAX_IMAGES = 2
  MAX_IMAGE_SIZE = 10.megabytes
  IMAGE_TYPES = %w[ image/jpeg image/png image/webp ].freeze

  has_many_attached :images, dependent: :purge_later do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 160, 160 ], format: :webp
    attachable.variant :card, resize_to_fill: [ 800, 600 ], format: :webp
  end

  belongs_to :category, touch: true
  has_many :item_tags, dependent: :destroy
  has_many :tags, -> { order(:id) }, through: :item_tags

  validates :name, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }
  validate :image_count_within_limits
  validate :acceptable_images

  def price
    price_cents && price_cents / 100.0
  end

  def price=(value)
    self.price_cents = value.present? ? (value.to_d * 100).round : nil
  end

  private
    def image_count_within_limits
      if images.length > MAX_IMAGES
        errors.add(:images, "Máximo #{MAX_IMAGES} imágenes por platillo")
      elsif new_record? && images.empty?
        errors.add(:images, "Debes subir al menos 1 imagen")
      end
    end

    def acceptable_images
      images.each do |image|
        if image.blob.byte_size > MAX_IMAGE_SIZE
          errors.add(:images, "#{image.filename} es muy pesada (máximo 10 MB)")
        end

        unless image.blob.content_type.in?(IMAGE_TYPES)
          errors.add(:images, "#{image.filename} debe ser JPG, PNG o WebP")
        end
      end
    end
end
