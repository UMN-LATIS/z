# controllers/url_barcodes_controller.rb
require 'barby'
require 'barby/barcode/qr_code'
require 'barby/outputter/png_outputter'
require 'barby/outputter/svg_outputter'

class UrlBarcodesController < ApplicationController
  def show
    @url = Url.find_by(keyword: params[:url_id])
    return redirect_to root_path if @url.blank?

    authorize @url
    format = (params[:format] || 'png').downcase

    # validate format
    return head :bad_request unless %w[png svg].include?(format)

    data = generate_qrcode(@url, format)

    send_data data, type: mime_type(format), filename: "z-#{@url.keyword}.#{format}"
  end

  private

  def generate_qrcode(url, format)
    qrcode = Barby::QrCode.new(view_context.full_url(url))

    case format
    when 'svg'
      outputter = Barby::SvgOutputter.new(qrcode)
      outputter.xdim = 10
      outputter.background = 'transparent'
      outputter.to_svg
    else
      outputter = Barby::PngOutputter.new(qrcode)
      outputter.xdim = 10
      outputter.to_png
    end
  end

  def mime_type(format)
    types = { png: 'image/png', svg: 'image/svg+xml' }
    types[format.to_sym]
  end
end
