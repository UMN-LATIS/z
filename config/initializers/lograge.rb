Rails.application.configure do
  config.lograge.keep_original_rails_log = true
  config.lograge.enabled = true
  config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/lograge_#{Rails.env}.log"
end

