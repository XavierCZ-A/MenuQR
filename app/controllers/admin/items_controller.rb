class Admin::ItemsController < Admin::BaseController
  before_action :set_item, only: %i[ edit update destroy ]
  before_action :set_categories, only: %i[ new create edit update ]

  def new
    @item = Item.new(category: @categories.find_by(name: Category::DEFAULT_NAME))
  end

  def edit
  end

  def create
    @item = Item.new(item_params)
    if save_with_category(@item)
      redirect_to admin_root_path, notice: "Platillo agregado."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @item.assign_attributes(item_params)
    if save_with_category(@item)
      redirect_to admin_root_path, notice: "Platillo actualizado.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @item.destroy!
    redirect_to admin_root_path, notice: "Platillo eliminado.", status: :see_other
  end

  private
    def set_item
      @item = current_restaurant.items.find(params.expect(:id))
    end

    def set_categories
      @categories = current_restaurant.categories.order(:position)
    end

    def item_params
      params.expect(item: [ :name, :description, :price, :available, images: [] ])
    end

    # Uses the typed new category if present, otherwise the selected one.
    # Both are scoped to the current restaurant so a forged category_id can't leak across restaurants.
    def save_with_category(item)
      new_category_name = params.dig(:item, :new_category_name).to_s.strip

      Item.transaction do
        item.category =
          if new_category_name.present?
            current_restaurant.categories.find_or_create_by!(name: new_category_name)
          else
            @categories.find_by(id: params.dig(:item, :category_id))
          end

        item.save || raise(ActiveRecord::Rollback)
      end
    rescue ActiveRecord::RecordInvalid => error
      error.record.errors.each { |category_error| item.errors.add(:category, category_error.message) }
      false
    end
end
