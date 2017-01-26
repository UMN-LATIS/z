class Legacy::Yourl < ApplicationRecord

  self.table_name = 'yourls_url'

  belongs_to :person, class_name: "Legacy::Person", foreign_key: :per_id
end
