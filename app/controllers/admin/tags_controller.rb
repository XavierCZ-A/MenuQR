class Admin::TagsController < Admin::BaseController
  before_action :set_tag, only: %i[ update destroy ]

  def index
    @new_tag = Tag.new
    load_tags
  end

  def create
    @new_tag = current_restaurant.tags.new(tag_params)

    if @new_tag.save
      redirect_to admin_tags_path, notice: "Etiqueta creada."
    else
      load_tags
      render :index, status: :unprocessable_content
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to admin_tags_path, notice: "Etiqueta actualizada.", status: :see_other
    else
      @failed_tag = @tag
      @new_tag = Tag.new
      load_tags
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    @tag.destroy!
    redirect_to admin_tags_path, notice: "Etiqueta eliminada.", status: :see_other
  end

  private
    def set_tag
      @tag = current_restaurant.tags.find(params.expect(:id))
    end

    def tag_params
      params.expect(tag: [ :name ])
    end

    def load_tags
      @tags = current_restaurant.tags.left_joins(:item_tags).group(:id)
        .select("tags.*, COUNT(item_tags.id) AS items_count")
    end
end
