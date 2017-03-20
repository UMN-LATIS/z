require 'rails_helper'

describe 'as a non-admin user' do
  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)
    visit admin_audits_path
  end
  it 'should display an access violation' do
    expect(page).to have_content 'You are not authorized to perform this action.'
  end

end

describe 'as a valid admin user' do
  before do
    @admin = FactoryGirl.create(:admin)
    sign_in(@admin)
    visit admin_audits_path
  end

  it 'should display the audit title' do
    expect(page).to have_content 'Audits'
  end

  it 'should display  Audited Item col header' do
    expect(page).to have_content 'Audited Item'
  end

  it 'should display  Audited Action col header' do
    expect(page).to have_content 'Audited Action'
  end

  it 'should display  Whodunnit col header' do
    expect(page).to have_content 'Whodunnit'
  end

  it 'should display  When col header' do
    expect(page).to have_content 'When'
  end
end
