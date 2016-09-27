# controllers/url_barcodes_controller.rb
class UrlBarcodesController < ApplicationController
  def show
    url = Url.find_by(keyword: params[:url_id])
    if url.present?
      require 'barby'
      require 'barby/barcode/qr_code'
      require 'barby/outputter/png_outputter'
      barcode = Barby::QrCode.new("#{request.base_url}/#{url.keyword}")

      barcode_png = Barby::PngOutputter.new(barcode)
      barcode_png.xdim = 10

      send_data barcode_png.to_png, filename: "z-#{url.keyword}.png"
    else
      redirect_to root_path
    end
  end
end
