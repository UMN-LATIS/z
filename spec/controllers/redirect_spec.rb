require 'rails_helper'

describe RedirectController do
  let(:url) { FactoryBot.create(:url) }

  describe 'GET /:keyword' do
    describe 'when url exists' do
      it 'redirects back to the referring page if url exists' do
        get :index, params: { keyword: url.keyword }
        expect(response).to redirect_to url.url
      end
    end
    describe 'when url does not exist' do
      it 'responds with a 404' do
        get :index, params: {keyword: "test404#{url.keyword}" } 
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'Click count /:keyword' do
    describe 'user agent google' do
      it 'should not count' do
        initialClicks = url.total_clicks
        @request.user_agent = "Googlebot/2.1"
        get :index, params: { keyword: url.keyword }
        newURL = Url.find(url.id)
        expect(url.total_clicks).to eq(newURL.total_clicks)
      end
    end
    describe 'user agent chrome' do
      it 'should count' do
        initialClicks = url.total_clicks
        @request.user_agent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
        get :index, params: { keyword: url.keyword }
        newURL = Url.find(url.id)
        expect(url.total_clicks).not_to eq(newURL.total_clicks)
      end
    end
  end
end
