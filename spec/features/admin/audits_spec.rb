require 'rails_helper'

describe 'as a non-admin user' do
  before do
    @user = FactoryBot.create(:user)
    @audit = FactoryBot.create(:audit, whodunnit: @user.id)
    sign_in(@user)
    visit admin_audits_path
  end

  it 'displays an access violation' do
    expect(page).to have_content 'You are not authorized to perform this action.'
  end
end

describe 'as a valid admin user' do
  before do
    @admin = FactoryBot.create(:admin)
    sign_in(@admin)
    visit admin_audits_path
  end

  it 'displays the audit title' do
    expect(page).to have_content 'Audit Log'
  end

  it 'displays Audited Item col header' do
    expect(page).to have_content 'Item'
  end

  it 'displays Audited Action col header' do
    expect(page).to have_content 'Last Action'
  end

  it 'displays Whodunnit col header' do
    expect(page).to have_content 'Whodunnit'
  end

  it 'displays When col header' do
    expect(page).to have_content 'Change History'
  end

  it 'displays When col header' do
    expect(page).to have_content 'As Of'
  end
end
