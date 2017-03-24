class Legacy::Click < ApplicationRecord
  establish_connection :legacy_z
  self.table_name = 'yourls_log'
end
