module FormHelper
  def form_for_admin(admin_view, url, &block)
      if admin_view
        form_for [:admin, url], html: { class: 'form-inline url', remote: true }, &block
      else
        form_for url, html: { class: 'form-inline url', remote: true }, &block
      end
  end
end
