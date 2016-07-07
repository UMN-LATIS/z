require 'rails_helper'

describe RedirectController do

  let (:url) { FactoryGirl.create(:url) }
  describe "GET /:keyword" do
    describe 'url exists'do
      it "redirects back to the referring page" do
        get :index, keyword: url.keyword
        response.should redirect_to url.url
      end
    end
    describe 'url does not exist'do
      it "redirects back to the root path" do
        get :index, keyword: "5#{url.keyword}"
        response.should redirect_to root_path
      end
    end
  end
end
