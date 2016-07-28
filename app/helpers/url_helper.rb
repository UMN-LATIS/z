module UrlHelper
  def full_url(url)
    "#{request.base_url}/#{url.keyword}"
  end

  def best_day_formatter(best_day)
    if best_day.blank?
      'This URL has never been clicked.'
    else
      "#{pluralize(best_day[1], 'hits')} " \
      "on #{best_day[0].strftime('%B %d %Y')}."
    end
  end
end
