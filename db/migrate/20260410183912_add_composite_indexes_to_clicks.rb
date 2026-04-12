class AddCompositeIndexesToClicks < ActiveRecord::Migration[8.1]
  # Composite indexes for the URL analytics page.
  #
  # (url_id, created_at): speeds up the time-series queries (24h / 7d / 30d /
  # year / 5y tabs) by letting MySQL do a narrow range scan on an already-
  # filtered-and-sorted index instead of scanning all clicks for a url.
  #
  # (url_id, country_code): covering index for the country map/pie query.
  # Turns a ~44s query into ~1s on a url with 7M clicks by letting MySQL do
  # an index-only scan (never touches the actual row data).
  #
  # The existing index_clicks_on_url_id is now redundant with (url_id, ...)
  # composites — MySQL can use either composite as a url_id-only index — so
  # drop it to save write overhead.
  def change
    add_index :clicks, [:url_id, :created_at]
    add_index :clicks, [:url_id, :country_code]
    remove_index :clicks, :url_id
  end
end
