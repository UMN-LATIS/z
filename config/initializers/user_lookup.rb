# Purpose: To allow for a skeleton user lookup service to be used in test
# and development environments

# Initialization needs to be done in a to_prepare block
# so that UserLookupService and UserLookupServiceSkeleton is autoloaded
Rails.application.config.to_prepare do
  UserLookup =
    if Rails.env.test? || ENV['USER_LOOKUP_SKELETON'].present?
      UserLookupServiceSkeleton
    else
      UserLookupService
    end
end
