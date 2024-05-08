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
end
