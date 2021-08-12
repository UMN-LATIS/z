# frozen_string_literal: true

require 'rails_helper'

describe 'handling user errors' do 
  it 'shows a 404 page for a url that does not exist' do
    visit '/does_not_exist'
    expect(page).to have_content('Not Found')
  end

  # Technically this should be a 400
  it 'shows 404 page if url has a bad encoding' do
    visit '/%c0'
    expect(page).to have_content('Not Found')
  end
end
