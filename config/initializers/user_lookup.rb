UserLookup =
  if Rails.env.test? && ENV['CYPRESS'].blank?
    UserLookupServiceSkeleton
  else
    UserLookupService
  end
