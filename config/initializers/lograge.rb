Rails.application.configure do
  config.lograge.keep_original_rails_log = true
  config.lograge.enabled = true
  config.lograge.logger = ::Logger.new "#{Rails.root}/log/lograge_#{Rails.env}.log"
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    { time: Time.now }
  end
end
