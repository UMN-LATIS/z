class LookupUsersController < ApplicationController
  def index
    render json:
      UserLookup.new(
        query: params[:search_terms],
        query_type: 'all' # TODO: query_type: params[:search_type]
      ).search
  end
end
