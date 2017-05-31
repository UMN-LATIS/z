class Legacy::Person < ApplicationRecord
  establish_connection :legacy_data_center

  self.table_name = 'PERSON'

  def to_umndid
    UserLookup.new(
      query: self.UID,
      query_type: 'uid'
    ).search.try(:first).try(:first).try(:last)
  end
end
