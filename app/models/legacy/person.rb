class Legacy::Person < ApplicationRecord
  establish_connection :legacy_data_center

  self.table_name = 'PERSON'

  def to_umndid
    UserLookupService.new(
                   query: self.UID,
                   query_type: 'uid' #todo query_type: params[:search_type]
               ).search.try(:first).try(:first).try(:last).try(:first)
  end

end
