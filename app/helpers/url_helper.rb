module UrlHelper
  def full_url(url)
    "#{request.base_url}/#{url.keyword}"
  end

  def display_long_url(url, max_length = 20)
    truncate(url, length: max_length)
  end

  def display_keyword_url(keyword, _max_length = 35)
    # "#{request.host_with_port}/#{truncate(keyword, length: max_length)}"
    "#{request.host_with_port}/#{keyword}"
  end

  def best_day_formatter(best_day)
    if best_day.blank?
      t('views.urls.show.best_day', count: 0)
    else
      t(
        'views.urls.show.best_day',
        count: best_day[1],
        date: best_day[0].strftime('%B %d %Y')
      )
    end
  end
end
