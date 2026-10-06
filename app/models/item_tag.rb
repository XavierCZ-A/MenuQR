class ItemTag < ApplicationRecord
  belongs_to :item, touch: true
  belongs_to :tag
end
