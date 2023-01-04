# app/services/user_lookup_service_skeleton.rb

class UserLookupServiceSkeleton
  def initialize(params = nil)
    @query = params[:query] if params
    @query_type = params[:query_type] if params

    # the first record is used in capybara tests
    # once the conversion to cypress is complete, this record can be removed
    @fake_ldap_records = [{
      umndid: 'testuid',
      display: 'Ryan Doe (testinternetid@umn.edu)',
      internet_id: 'testinternetid',
      display_name: 'Ryan Doe'
    }]

    # load the fixtures from cypress into fake_ldap_records
    fixtures_path = Rails.root.join('cypress/fixtures/users')
    Dir.glob("#{fixtures_path}/*.json").each do |file|
      user_hash = JSON.parse(File.read(file))
      @fake_ldap_records << user_hash
    end
  end

  def search
    return nil unless @query.present? && @query_type.present?

    # find any record that matches the query
    @fake_ldap_records.find_all do |record|
      if @query_type == 'all'
        record[:umndid] == @query ||
          record[:internet_id] == @query ||
          record[:display_name].include?(@query)
      elsif @query_type == 'umndid'
        record[:umndid] == @query
      elsif @query_type == 'uid'
        record[:internet_id] == @query
      end
    end
  end
end
