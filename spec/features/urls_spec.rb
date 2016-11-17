require 'rails_helper'

describe 'urls show page' do
  let(:keyword) { 'testkeyword' }
  let(:url) { 'http://www.google.com' }
  let(:created_at) { Time.now - 1.day }

  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)

    @url = FactoryGirl.create(
      :url,
      group: @user.context_group,
      keyword: keyword,
      url: url,
      created_at: created_at
    )
    # add 10 clicks to yesterday
    10.times do
      @url.clicks << Click.create(
        country_code: 'US',
        created_at: Time.now - 1.day
      )
      @url.total_clicks += 1
      @url.save
    end

    # add 5 clicks to today
    5.times do
      @url.clicks << Click.create(
          country_code: 'US',
          created_at: Time.now
      )
      @url.total_clicks += 1
      @url.save
    end

    visit url_path(@url.keyword)
  end

  it 'should display long url' do
    expect(page).to have_content url
  end

  it 'should display short url' do
    expect(page).to have_content keyword
  end

  it 'should display created date' do
    expect(page).to have_content created_at.strftime('%B %d, %Y at %I:%M%p')
  end

  it 'should display best day' do
    expect(page).to have_content '10 hits'
  end

  it 'should display the total clicks' do
    expect(page).to have_content '15 hits'
  end

  it 'should display the qr code' do
    require 'barby'
    require 'barby/barcode/qr_code'
    require 'barby/outputter/svg_outputter'

#    barcode = Barby::QrCode.new(view_context.full_url(@url))
    barcode = Barby::QrCode.new(@url.url)
    barcode_svg = Barby::SvgOutputter.new(barcode)
    barcode_svg.xdim = 5


     p barcode_svg.to_svg.html_safe
    p "and"
    p "thids"

    p page.html

    expect(page.html).to include(barcode_svg.to_svg.html_safe)
  end

  describe 'downloading qr code' do
    before { find('.js-qrcode-download').click }

    it 'should be a png type' do
      expect(page.response_headers['Content-Type']).to eq('image/png')
    end

    it 'should not be blank' do
      expect(page.body).to_not be_blank
    end
  end
end
describe 'urls index page' do
  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)
  end

  describe 'creating new url', js: true do
    let(:url) { 'http://www.google.com' }
    let(:keyword) { 'goog' }
    before do
      visit urls_path
      find('.js-new-url-url').set url
      find('.js-new-url-keyword').set keyword
    end
    describe 'with valid information' do
      describe 'when both fields are filled in' do
        it 'should save upon clicking Create' do
          expect do
            find('.js-url-submit').click
            wait_for_ajax
          end.to change(Url, :count).by(1)
        end
      end
      describe 'when the keyword is blank' do
        before { find('#url_keyword').set '' }
        it 'should save upon clicking Create' do
          expect do
            find('.js-url-submit').click
            wait_for_ajax
          end.to change(Url, :count).by(1)
        end
      end
      describe 'missing http/https' do
        before { find('#url_url').set 'google.com' }
        it 'should save upon clicking Create' do
          expect do
            find('.js-url-submit').click
            wait_for_ajax
          end.to change(Url, :count).by(1)
        end
      end
    end
    describe 'with invalid information' do
      describe '[keyword]' do
        describe 'already taken' do
          before do
            @other_url = FactoryGirl.create(:url)
            find('#url_keyword').set @other_url.keyword
          end
          it 'should not save upon clicking Create' do
            expect do
              find('.js-url-submit').click
              wait_for_ajax
            end.to change(Url, :count).by(0)
          end

          it 'should display an error' do
            find('.js-url-submit').click
            wait_for_ajax
            expect(page).to have_content('taken')
          end
        end
      end
    end
  end

  describe 'with an existing url' do
    let(:new_url) { 'http://www.facebook.com' }
    let(:new_keyword) { 'face' }
    before do
      @url = FactoryGirl.create(:url, group: @user.context_group)
      visit urls_path
    end

    describe 'page content' do
      it 'should display the url\'s url' do
        expect(page).to have_content @url.url
      end
      it 'should display the url\'s keyword' do
        expect(page).to have_content @url.keyword
      end
      it 'should display the url\'s click count' do
        expect(page).to have_css('td', text: @url.total_clicks)
      end
      it 'should display an edit button' do
        expect(page).to have_content 'Edit'
      end
      it 'should display a delete button' do
        expect(page).to have_content 'Delete'
      end
    end

    describe 'when editing existing url', js: true do
      before { find('.edit-url').click }

      describe 'with new valid content' do
        it 'should update the url in the db' do
          find('table #url_url').set new_url
          find('table .js-url-submit').click
          wait_for_ajax
          expect(@url.reload.url).to eq(new_url)
        end
        it 'should update the keyword in the db' do
          find('table #url_keyword').set new_keyword
          find('table .js-url-submit').click
          wait_for_ajax
          expect(@url.reload.keyword).to eq(new_keyword)
        end
      end
    end

    describe 'when deleting existing url', js: true do
      describe 'clicking delete' do
        it 'should delete the url' do
          expect do
            find('.delete-url').click
            click_button "Confirm"
            wait_for_ajax
          end.to change(Url, :count).by(-1)
        end
      end
    end

    describe 'when attempting to edit someone elses url' do
      before do
        @new_user = FactoryGirl.create(:user)
        @new_url = FactoryGirl.create(:url, group: @new_user.context_group)
        visit "urls/#{@new_url.id}/edit"
      end
      describe 'page content' do
        it 'should display the not authorized message' do
          expect(page).to have_content 'You are not authorized to perform this action.'
        end
      end
    end

  end
end
