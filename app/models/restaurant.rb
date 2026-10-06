class Restaurant < ApplicationRecord
  IMAGES = %i[ logo banner ].freeze
  # Slugs are menu subdomains, so they can't take names the app or DNS need.
  RESERVED_SLUGS = %w[ www app admin api dashboard mail email smtp imap pop ftp cdn static assets blog help ayuda soporte status ].freeze

  has_one_attached :logo, dependent: :purge_later do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 160, 160 ], format: :webp
  end
  has_one_attached :banner, dependent: :purge_later do |attachable|
    attachable.variant :wide, resize_to_limit: [ 1600, 900 ], format: :webp
  end

  # Marcadas desde el formulario de configuración; se borran al guardar.
  attribute :remove_logo, :boolean, default: false
  attribute :remove_banner, :boolean, default: false

  belongs_to :user
  has_many :categories, dependent: :destroy
  has_many :items, through: :categories
  has_many :tags, -> { order(:id) }, dependent: :destroy

  normalizes :name, :description, :address, :hours, with: ->(value) { value.strip.presence }

  validates :name, presence: true, length: { maximum: 60 }
  validates :description, length: { maximum: 280 }
  validates :address, :hours, length: { maximum: 80 }
  validates :slug, presence: true, if: :name?
  validate :user_within_restaurant_limit, on: :create
  validate :acceptable_images

  before_validation :generate_slug, on: :create
  before_save :remove_flagged_images
  after_create :create_default_category, :create_default_tags

  private
    def acceptable_images
      IMAGES.each do |name|
        blob = public_send(name).blob
        next unless blob

        errors.add(name, "debe ser JPG, PNG o WebP") unless Item::IMAGE_TYPES.include?(blob.content_type)
        errors.add(name, "es muy pesado (máximo 10 MB)") if blob.byte_size > Item::MAX_IMAGE_SIZE
      end
    end

    # Si en el mismo envío se sube una imagen nueva, gana la nueva.
    def remove_flagged_images
      IMAGES.each do |name|
        public_send("#{name}=", nil) if public_send("remove_#{name}") && !attachment_changes.key?(name.to_s)
      end
    end

    def create_default_category
      categories.create!(name: Category::DEFAULT_NAME)
    end

    def create_default_tags
      Tag::DEFAULT_NAMES.each { |name| tags.create!(name: name) }
    end

    def user_within_restaurant_limit
      return unless user

      if user.restaurants.count >= User::MAX_RESTAURANTS
        errors.add(:base, "Has alcanzado el límite de restaurantes permitidos")
      end
    end

    def generate_slug
      return if slug.present?
      return if name.blank?

      base_slug = name.parameterize.presence || "restaurante"
      candidate = base_slug
      counter = 2

      while RESERVED_SLUGS.include?(candidate) || Restaurant.exists?(slug: candidate)
        candidate = "#{base_slug}-#{counter}"
        counter += 1
      end

      self.slug = candidate
    end
end
