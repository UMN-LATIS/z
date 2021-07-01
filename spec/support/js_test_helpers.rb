# Test helpers that use javascript
module JSTestHelpers

  # Uses javascript to select an element and set the attribute.
  # 
  # An alternative to capybara's find and set methods.
  # Only selects the first element that matches.
  #
  #   js_set_attr("#my-hidden-input", "type", "text")

  # uses JS to make a hidden input visible
  def js_make_input_visible(input_selector)
    js = "
    let ready = (fn) => (document.readyState !== 'loading') 
    ? fn()
    : document.addEventListener('DOMContentLoaded', fn)
    
    ready(() => 
        document
          .querySelector('#{selector}')
          .setAttribute('type','text')
      )"
    execute_script(js)
  end

  def js_make_all_inputs_visible()
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
