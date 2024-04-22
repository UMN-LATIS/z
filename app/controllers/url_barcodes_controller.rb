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
    qrcode = RQRCode::QRCode.new(view_context.full_url(url))

    case format
    when 'svg'
      qrcode.as_svg(viewbox: true)
    else
      qrcode.as_png(size: 300, border_modules: 1)
    end
  end

  def mime_type(format)
    types = { png: 'image/png', svg: 'image/svg+xml' }
    types[format.to_sym]
  end
end
