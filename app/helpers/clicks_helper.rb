module ClicksHelper
  def click_data_formatter(clicks)
    cols = [
      {
        id: '',
        label: '',
        type: 'string'
      }, {
        id: '',
        label: 'Clicks',
        type: 'number'
      }
    ]

    rows = []
    clicks.each do |click|
      rows << {
        c: [
          {
            v: click[0],
            f: nil
          }, {
            v: click[1],
            f: nil
          }
        ]
      }
    end

    { cols: cols, rows: rows }
  end

  def region_data_formatter(clicks)
    clicks.unshift %w(Country Clicks)
  end
end
