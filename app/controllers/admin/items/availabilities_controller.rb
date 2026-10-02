class Admin::Items::AvailabilitiesController < Admin::BaseController
  before_action :set_item

  def create
    @item.update!(available: true)
    redirect_to admin_root_path, status: :see_other
  end

  def destroy
    @item.update!(available: false)
    redirect_to admin_root_path, status: :see_other
  end

  private
    def set_item
      @item = current_restaurant.items.find(params.expect(:item_id))
    end
end
