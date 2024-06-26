require 'rails_helper'

describe '[API: URLs]', type: :api do
  describe 'adding urls' do
    let(:user) { FactoryBot.create(:user) }
    let(:existing_url) { FactoryBot.create(:url) }
    let(:random_key) { "#{user.secret_key}012345" }
    let(:secret_key) { user.secret_key }
    let(:url1_url) { 'example.com' }
    let(:url2_url) { 'example.com/example' }
    let(:url2_keyword) { 'ex' }
    let(:url3_url) { 'example.com/example' }

    let(:random_key) { "#{user.secret_key}012345" }
    let(:existing_url) { FactoryBot.create(:url) }

    it 'lets you add urls' do
      # Basic, singular URL
      payload = {
        urls: [
          { url: url1_url }
        ]
      }

      token = JWT.encode payload, secret_key, 'HS256'

      header 'Authorization', "#{user.uid}:#{token}"
      post '/api/v1/urls'

      expect(last_response.status).to be(200)
      results = JSON.parse(last_response.body)
      expect(results.first['result']['status']).to eq('success')

      # Multiple URLs, one with a keyword, one with a collection name
      collection = FactoryBot.create(:group)
      collection.users << user
      payload = {
        urls: [
          { url: url3_url, collection: collection.name },
          { url: url2_url, keyword: url2_keyword }
        ]
      }

      token = JWT.encode payload, secret_key, 'HS256'

      header 'Authorization', "#{user.uid}:#{token}"
      post '/api/v1/urls'

      expect(last_response.status).to be(200)
      results = JSON.parse(last_response.body)
      results.each do |result|
        expect(result['result']['status']).to eq('success')
      end
    end

    it 'does not let you add URLs' do
      # Taken keyword
      payload = {
        urls: [
          { url: url1_url, keyword: existing_url.keyword }
        ]
      }

      token = JWT.encode payload, secret_key, 'HS256'

      header 'Authorization', "#{user.uid}:#{token}"
      post '/api/v1/urls'

      expect(last_response.status).to be(200)
      results = JSON.parse(last_response.body)
      expect(results.first['result']['status']).to eq('error')

      # No URL
      payload = {
        urls: [
          { url: '' }
        ]
      }

      token = JWT.encode payload, secret_key, 'HS256'

      header 'Authorization', "#{user.uid}:#{token}"
      post '/api/v1/urls'

      expect(last_response.status).to be(200)
      results = JSON.parse(last_response.body)
      expect(results.first['result']['status']).to eq('error')
    end

    it 'rejects incorrect auth payloads' do
      # No username
      payload = {
        urls: [
          { url: url1_url }
        ]
      }

      token = JWT.encode payload, secret_key, 'HS256'

      header 'Authorization', token
      post '/api/v1/urls'

      expect(last_response.status).to be(401)

      # Incorrect secret key
      payload = {
        urls: [
          { url: url1_url }
        ]
      }

      token = JWT.encode payload, random_key, 'HS256'

      header 'Authorization', "#{user.uid}:#{token}"
      post '/api/v1/urls'

      expect(last_response.status).to be(401)
    end

    it 'does not permit users to create urls for other users' do
      mallory = create(:user, { uid: 'mallory' })
      alice = create(:user, { uid: 'alice' })

      # mallory creates a URL for alice
      payload = { urls: [{ url: url1_url }] }

      # and then signs it with her own (mallory's) secret key
      token = JWT.encode payload, mallory.secret_key, 'HS256'

      # but then tries to use alice's uid to create
      # urls on her behalf
      header 'Authorization', "#{alice.uid}:#{token}"
      post '/api/v1/urls'

      expect(last_response.status).to be(401)
    end
  end

  describe 'GET /api/v1/urls/:keyword' do
    let(:user) { create(:user) }
    let(:existing_url) { create(:url, group_id: user.default_group_id, keyword: 'unique-keyword', url: 'http://example.com') }
    let(:token) { JWT.encode({ access_id: user.uid }, user.secret_key, 'HS256') }

    before do
      header 'Authorization', "#{user.uid}:#{token}"
    end

    it 'successfully retrieves a URL by keyword' do
      get "/api/v1/urls/#{existing_url.keyword}"

      expect(last_response.status).to eq(200)
      result = JSON.parse(last_response.body)
      expect(result['status']).to eq('success')
      expect(result['message']['url']).to eq(existing_url.url)
      expect(result['message']['keyword']).to eq(existing_url.keyword)
    end

    it 'returns a 404 when the URL does not exist' do
      get "/api/v1/urls/nonexistent-keyword"
      expect(last_response.status).to eq(404)
      result = JSON.parse(last_response.body)
      expect(result['status']).to eq('error')
      expect(result['message']).to eq('URL not found')
    end

    it 'returns an error with unauthorized access' do
      header 'Authorization', 'invalid-token'
      get "/api/v1/urls/#{existing_url.keyword}"
      expect(last_response.status).to eq(401)
    end

    it 'forbids access to urls that dont belong to a users group' do
      new_user = create(:user)
      new_url = create(:url, { group_id: new_user.default_group_id, keyword: 'new-keyword' })
      get "/api/v1/urls/#{new_url.keyword}"
      expect(last_response.status).to eq(403)
    end
  end

  describe 'PUT /api/v1/urls/:keyword' do
    let(:user) { create(:user) }
    let(:existing_url) { create(:url, group_id: user.default_group_id, keyword: 'unique-keyword', url: 'http://example.com') }

    it 'updates a URL' do
      new_url = 'http://example.org'

      payload = { url: new_url, keyword: existing_url.keyword }
      token = JWT.encode payload, user.secret_key, 'HS256'

      header 'Authorization', "#{user.uid}:#{token}"

      put "/api/v1/urls/#{existing_url.keyword}"
      expect(last_response.status).to eq(200)
      result = JSON.parse(last_response.body)

      expect(result['status']).to eq('success')
      expect(result['message']['url']).to eq(payload[:url])
      expect(result['message']['keyword']).to eq(payload[:keyword])
    end

    it 'returns a 404 when the URL does not exist' do
      new_url = 'http://example.org'

      payload = { url: new_url, keyword: 'nonexistent-keyword' }
      token = JWT.encode payload, user.secret_key, 'HS256'

      header 'Authorization', "#{user.uid}:#{token}"

      put "/api/v1/urls/#{payload[:keyword]}"
      expect(last_response.status).to eq(404)
      result = JSON.parse(last_response.body)
      expect(result['status']).to eq('error')
      expect(result['message']).to eq('URL not found')
    end

    it 'forbids updated to urls that dont belong to a users group' do
      mallory = create(:user)

      payload = { url: "http://malloryisthebest.com", keyword: existing_url.keyword }

      token = JWT.encode payload, mallory.secret_key, 'HS256'

      header 'Authorization', "#{mallory.uid}:#{token}"

      put "/api/v1/urls/#{existing_url.keyword}"

      expect(last_response.status).to eq(403)

      # verify that the keyword is not updated
      url = Url.find(existing_url.id)
      expect(url.keyword).to eq(existing_url.keyword)
      expect(url.url).to eq(existing_url.url)
    end

    it 'requires a valid token' do
      payload = { url: "http://malloryisthebest.com", keyword: existing_url.keyword }

      put "/api/v1/urls/#{existing_url.keyword}", params: payload

      expect(last_response.status).to eq(401)

      # verify that the keyword is not updated
      url = Url.find(existing_url.id)
      expect(url.keyword).to eq(existing_url.keyword)
      expect(url.url).to eq(existing_url.url)
    end

    it 'does not permit keyword updates' do
      new_keyword = 'new-keyword'

      payload = { url: existing_url.url, keyword: new_keyword }
      token = JWT.encode payload, user.secret_key, 'HS256'

      header 'Authorization', "#{user.uid}:#{token}"

      put "/api/v1/urls/#{existing_url.keyword}"
      expect(last_response.status).to eq(400)
      result = JSON.parse(last_response.body)

      expect(result['status']).to eq('error')
      expect(result['message']).to eq('Cannot change keyword')

      # verify that the keyword is not updated
      url = Url.find(existing_url.id)
      expect(url.keyword).to eq(existing_url.keyword)
      expect(url.url).to eq(existing_url.url)
    end
  end
end
