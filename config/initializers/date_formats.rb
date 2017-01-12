# config/initializers/time_formats.rb
Time::DATE_FORMATS[:created_on_formatted] = "%B %d, %Y at %l:%M%P"
Time::DATE_FORMATS[:short_ordinal] = lambda { |time| time.strftime("%B #{time.day.ordinalize}") }