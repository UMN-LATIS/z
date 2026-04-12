namespace :clicks do
  # Usage:
  #   bin/rails "clicks:seed_perf[10000]"
  #   bin/rails "clicks:seed_perf[1000000,bigone]"
  #
  # Bulk-inserts COUNT Click rows against a single URL (created if missing),
  # distributed uniformly at random across the last 5 years. Intended for
  # exercising the /urls/:keyword.json stats endpoint and UrlStatsPage at
  # medium (~1-10k) and large (~1-10m) scales.
  #
  # Uses insert_all in BATCH_SIZE-row batches so memory stays flat and the
  # insert path skips ActiveRecord callbacks/validations. On a local MySQL
  # this lands around 50-100k rows/sec; 10m rows takes a few minutes.
  desc 'Seed clicks for stats-page perf testing: clicks:seed_perf[count,keyword]'
  task :seed_perf, %i[count keyword] => :environment do |_, args|
    count = (args[:count] || 10_000).to_i
    keyword = args[:keyword] || 'perf'
    batch_size = 10_000
    countries = %w[US CA GB DE FR JP IN BR MX AU CN RU KR IT ES]

    group = Group.first || Group.create!(name: 'perf-seed')
    url = Url.find_or_create_by!(keyword: keyword) do |u|
      u.url = "https://example.com/#{keyword}"
      u.group = group
    end
    url_id = url.id

    start_epoch = 5.years.ago.to_i
    range_seconds = Time.current.to_i - start_epoch

    puts "Seeding #{count} clicks on url '#{keyword}' (id=#{url_id})..."
    started_at = Time.current
    inserted = 0

    while inserted < count
      this_batch = [batch_size, count - inserted].min
      rows = Array.new(this_batch) do
        ts = Time.at(start_epoch + rand(range_seconds)).utc
        {
          url_id: url_id,
          country_code: countries.sample,
          created_at: ts,
          updated_at: ts
        }
      end
      Click.insert_all(rows)
      inserted += this_batch

      elapsed = Time.current - started_at
      rate = inserted / elapsed
      remaining = count - inserted
      eta = remaining.positive? ? (remaining / rate).round : 0
      pct = (inserted * 100.0 / count).round(1)
      puts "  #{inserted}/#{count} (#{pct}%)  #{rate.round} rows/s  ETA #{eta}s"
    end

    total = Click.where(url_id: url_id).count
    Url.where(id: url_id).update_all(total_clicks: total)
    puts "Done in #{(Time.current - started_at).round(1)}s. " \
         "url '#{keyword}' now has #{total} total clicks."
  end
end
