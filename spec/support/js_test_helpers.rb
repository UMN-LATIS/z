# Test helpers that use javascript
module JSTestHelpers
  # uses JS to make a all hidden inputs visible on the page
  def js_make_all_inputs_visible
    js = "
      let ready = (fn) => (document.readyState !== 'loading')
        ? fn()
        : document.addEventListener('DOMContentLoaded', fn)

      ready(() =>
        document
          .querySelectorAll('input[type=hidden]')
          .forEach(input => input.setAttribute('type','text'))

      )"
    execute_script(js)
  end
end

RSpec.configure do |config|
  config.include JSTestHelpers, type: :feature
end
