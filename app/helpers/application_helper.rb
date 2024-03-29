module ApplicationHelper
  # Return true if a user is logged in through shibboleth.
  def logged_in?
    #    if current_agent.blank? or current_agent.internet_id == "anonymous"
    #      false
    #    else
    #      true
    #    end
    false
  end

  def bootstrap_class_for(flash_type)
    { success: "alert-success", error: "alert-danger", alert: "alert-warning",
      notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(_opts = {})
    flash.each do |msg_type, message|
      concat(tag.div(message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
               concat tag.button('x', class: "close", data: { dismiss: 'alert' })
               concat message
             end)
    end
    nil
  end
end
