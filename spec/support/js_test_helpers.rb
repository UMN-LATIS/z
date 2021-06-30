# Test helpers that use javascript
module JSTestHelpers

  # Uses javascript to select an element and set the attribute.
  # 
  # An alternative to capybara's find and set methods.
  # Only selects the first element that matches.
  #
  #   js_set_attr("#my-hidden-input", "type", "text")
  def js_set_attr(selector, attr_name, attr_value)
    js = "document" \
      ".querySelector('#{selector}')" \
      ".setAttribute('#{attr_name}','#{attr_value}')"
    page.execute_script(js)
  end

  # uses JS to make a hidden input visible
  def js_make_input_visible(input_selector)
    js_set_attr(input_selector, "type", "text")
  end
end

RSpec.configure do |config|
  config.include JSTestHelpers, type: :feature
end
