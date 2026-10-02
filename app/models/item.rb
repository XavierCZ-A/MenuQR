class Item < ApplicationRecord
  belongs_to :category

  validates :name, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }

  def price
    price_cents && price_cents / 100.0
  end

  def price=(value)
    self.price_cents = value.present? ? (value.to_d * 100).round : nil
  end
end
