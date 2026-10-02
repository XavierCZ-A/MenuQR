module ItemsHelper
  def format_price(item)
    number_to_currency(item.price, unit: "$", precision: 2)
  end
end
