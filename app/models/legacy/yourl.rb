class Legacy::Yourl < ApplicationRecord
  establish_connection :legacy_z
  self.table_name = 'yourls_url'

  belongs_to :person, class_name: 'Legay::Person', foreign_key: :per_id
end
