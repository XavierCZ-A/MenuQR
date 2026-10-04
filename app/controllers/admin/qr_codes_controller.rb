class Admin::QrCodesController < Admin::BaseController
  def show
    # The menu URL only depends on the slug, which never changes.
    return unless stale?(etag: restaurant_url(current_restaurant.slug))

    qr_code = RQRCode::QRCode.new(restaurant_url(current_restaurant.slug))
    filename = "menu-#{current_restaurant.slug}"

    respond_to do |format|
      format.svg do
        send_data qr_code.as_svg(module_size: 8, viewbox: true, use_path: true),
          type: :svg, disposition: :inline, filename: "#{filename}.svg"
      end
      format.png do
        send_data qr_code.as_png(size: 1024).to_blob, type: :png, filename: "#{filename}.png"
      end
    end
  end
end
