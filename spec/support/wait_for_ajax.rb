# spec/support/wait_for_ajax.rb
module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    # only check jQuery.active if jQuery is defined
    page.evaluate_script("typeof jQuery !== 'undefined' ? jQuery.active : 0").zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end
