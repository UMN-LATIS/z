module UrlHelper
  def full_url(url)
    "#{request.base_url}/#{url.keyword}"
  end

  def display_long_url(url, max_length=20)
    if url.length > max_length
      return truncate(url, length: max_length)
    else
      url
    end
  end

  def display_keyword_url(keyword, max_length=35)
    if keyword.length > max_length
      return "#{request.base_url}/#{truncate(keyword, length: max_length)}"
    else
      return "#{request.base_url}/#{keyword}"
    end
  end

  def best_day_formatter(best_day)
    if best_day.blank?
      t('helpers.url_has_never_been_clicked')
    else
      "#{pluralize(best_day[1], 'hits')} " \
      "on #{best_day[0].strftime('%B %d %Y')}."
    end
  end
end
