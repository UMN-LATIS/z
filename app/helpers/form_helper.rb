module FormHelper
  def form_for_url_admin(admin_view, url, &block)
      if admin_view
        form_for [:admin, url], html: { class: 'form-inline url', remote: true }, &block
      else
        form_for url, html: { class: 'form-inline url', remote: true }, &block
      end
  end

  def form_for_transfer_admin(admin_view, transfer_request, &block)
      if admin_view
        form_for [:admin, transfer_request], html: { remote: true }, &block
      else
        form_for transfer_request, html: { remote: true }, &block
      end
  end
end
