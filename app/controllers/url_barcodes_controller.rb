# controllers/url_barcodes_controller.rb
class UrlBarcodesController < ApplicationController
  def show
    url_record = Url.find_by(keyword: params[:url_id])

    # If no URL is found, redirect to home
    if url_record.nil?
      redirect_to root_path
      return
    end

    authorize url_record
    url = "#{request.base_url}/#{url_record.keyword}"
    qrcode = RQRCode::QRCode.new(url)

    # Convert the QR Code to PNG
    png = qrcode.as_png(size: 400)

    # Convert the PNG data to an image object
    image = MiniMagick::Image.read(png.to_s)

    # Load the logo and scale it to a suitable size
    logo_path = Rails.root.join("app/assets/images/M_blk.png")
    logo = MiniMagick::Image.open(logo_path)
    logo.resize "100x100"

    # Overlay the logo in the center of the QR code
    result = image.composite(logo, "png") do |c|
      c.gravity "Center"
    end

    # Send the image as response
    send_data result.to_blob, type: "image/png", disposition: "attachment", filename: "z-#{url_record.keyword}.png"
  end
end
