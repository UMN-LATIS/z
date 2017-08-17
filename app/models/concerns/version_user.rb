module VersionUser
  extend ActiveSupport::Concern

  module ClassMethods
    def version_user(version)
      version.whodunnit.nil? ? 'N/A' : User.find(version.whodunnit).internet_id
    end
  end
end
