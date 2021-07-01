# config/initializers/time_formats.rb
Time::DATE_FORMATS[:created_on_formatted] = '%m/%d/%Y'
Time::DATE_FORMATS[:short_ordinal] = ->(time) { time.strftime("%B #{time.day.ordinalize}") }
