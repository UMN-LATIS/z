class ErrorsController < ApplicationController
  def not_found
    render status: 404, :formats => [:html]
  end

  def internal_server_error
    render status: 500
  end
end
