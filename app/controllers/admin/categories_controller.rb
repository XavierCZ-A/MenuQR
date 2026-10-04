class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: %i[ update destroy ]

  def index
    @new_category = Category.new
    load_categories
  end

  def create
    @new_category = current_restaurant.categories.new(category_params)

    if @new_category.save
      redirect_to admin_categories_path, notice: "Categoría creada."
    else
      load_categories
      render :index, status: :unprocessable_content
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: "Categoría actualizada.", status: :see_other
    else
      @failed_category = @category
      @new_category = Category.new
      load_categories
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    if @category.destroy
      redirect_to admin_categories_path, notice: "Categoría eliminada.", status: :see_other
    else
      redirect_to admin_categories_path, alert: @category.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def update_order
    ids = params.expect(category_ids: []).map(&:to_i)
    categories = current_restaurant.categories.where(id: ids).index_by(&:id)

    Category.transaction do
      ids.each.with_index(1) { |id, position| categories[id]&.update!(position: position) }
    end

    head :no_content
  end

  private
    def set_category
      @category = current_restaurant.categories.find(params.expect(:id))
    end

    def category_params
      params.expect(category: [ :name ])
    end

    def load_categories
      @categories = current_restaurant.categories.left_joins(:items).group(:id).order(:position)
        .select("categories.*, COUNT(items.id) AS items_count")
    end
end
