class LookupUsersController < ApplicationController
  def index
    render json:
      UserLookupService.new(
        query: params[:search_terms],
        query_type: 'all' # TODO: query_type: params[:search_type]
      ).search
  end
end
