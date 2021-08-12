# frozen_string_literal: true

require 'rails_helper'

describe 'Not Found' do
  it 'shows Not Found for a url that does not exist' do
    visit '/does_not_exist'
    expect(page).to have_content('Not Found')
  end

  it 'shows Not Found if url has a bad encoding in the path' do
    visit '/%c0'
    expect(page).to have_content('Not Found')
  end

  it 'shows Not Found if query string has malformed parameter' do
    visit '/?alsdkjflakjdf%$$$)$%'
    expect(page).to have_content('Not Found')
  end
end
