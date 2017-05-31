UserLookup =
  if Rails.env.test?
    UserLookupServiceSkeleton
  else
    UserLookupService
  end
