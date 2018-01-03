class GeoClickJob
  @queue = :geo_queue

  def self.perform(url_id, client_id, timestamp)
  	ActiveRecord::Base.clear_active_connections!
  	local_url = Url.find(url_id)
  	local_url.add_geo_click!(client_id, timestamp)
  end
end
