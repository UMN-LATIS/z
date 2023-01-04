UserLookup =
  if Rails.env.test? || ENV['USER_LOOKUP_SKELETON'].present?
    UserLookupServiceSkeleton
  else
    UserLookupService
  end
