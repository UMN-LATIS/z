# == Schema Information
#
# Table name: urls
#
#  id           :integer          not null, primary key
#  url          :string(255)
#  keyword      :string(255)
#  total_clicks :integer
#  group_id     :integer
#  modified_by  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Url, type: :model do
  subject { @url }

  before do
    @url = FactoryBot.build(:url)
  end

  it { is_expected.to be_valid }
  it { is_expected.to respond_to 'total_clicks' }
  it { is_expected.to respond_to 'group' }
  it { is_expected.to respond_to 'group_id' }
  it { is_expected.to respond_to 'keyword' }
  it { is_expected.to respond_to 'url' }
  it { is_expected.to respond_to 'modified_by' }
  it { is_expected.to respond_to 'created_at' }
  it { is_expected.to respond_to 'updated_at' }

  describe 'Versioning' do
    it 's should be enabled' do
      expect(subject).to be_versioned
    end
  end

  describe 'invalid Url' do
    describe '[keyword]' do
      describe 'already exists' do
        before do
          other_url = FactoryBot.create(:url)
          @url.keyword = other_url.keyword
        end

        it 'is not valid' do
          expect(@url).not_to be_valid
        end
      end
    end
  end

  describe 'valid url' do
    describe 'various keywords' do
      it ' dashes should be valid' do
        @url.keyword = '-'
        expect(@url).to be_valid
      end

      it ' underscores should be valid' do
        @url.keyword = '_'
        expect(@url).to be_valid
      end

      it ' number should be valid' do
        @url.keyword = '1234567890'
        expect(@url).to be_valid
      end

      it ' lowercase letters be valid' do
        @url.keyword = 'abcdefghijklmnopqrstuvwxyz'
        expect(@url).to be_valid
      end

      it ' uppercase letters should be valid' do
        @url.keyword = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        expect(@url).to be_valid
      end

      it ' anything but a-zA-Z0-9\-_ chars should not be valid' do
        %w(! @ # $ $ % ^ & * ( ) ,).each do |x|
          @url.keyword = x
          expect(@url).not_to be_valid
        end
      end
    end

    describe 'various urls' do
      it 'is valid' do
        @url.url = 'http://fun.com'
        expect(@url).to be_valid
      end

      it 'is not valid' do
        @url.url = 'Http://fun.net'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'https://fun.com'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'http://fun.com'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'Https://fun.com'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'fun.com'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'fun'
        expect(@url).to be_valid
      end

      it 'is not valid' do
        @url.url = ':'
        expect(@url).not_to be_valid
      end

      it 'is not valid' do
        @url.url = '\\'
        expect(@url).not_to be_valid
      end

      it 'is not valid' do
        @url.url = '%'
        expect(@url).not_to be_valid
      end

      # Berners-Lee, et al.         Standards Track                    [Page 36]
      #
      # RFC 3986                   URI Generic Syntax               January 2005
      #
      # 5.4.1.  Normal Examples
      #
      #       "g:h"           =  "g:h"
      #       "g"             =  "http://a/b/c/g"
      #       "./g"           =  "http://a/b/c/g"
      #       "g/"            =  "http://a/b/c/g/"
      #       "/g"            =  "http://a/g"
      #       "//g"           =  "http://g"
      #       "?y"            =  "http://a/b/c/d;p?y"
      #       "g?y"           =  "http://a/b/c/g?y"
      #       "#s"            =  "http://a/b/c/d;p?q#s"
      #       "g#s"           =  "http://a/b/c/g#s"
      #       "g?y#s"         =  "http://a/b/c/g?y#s"
      #       ";x"            =  "http://a/b/c/;x"
      #       "g;x"           =  "http://a/b/c/g;x"
      #       "g;x?y#s"       =  "http://a/b/c/g;x?y#s"
      #       ";x"              =  "http://a/b/c/d;p?q"
      #       "."             =  "http://a/b/c/"
      #       "./"            =  "http://a/b/c/"
      #       ".."            =  "http://a/b/"
      #       "../"           =  "http://a/b/"
      #       "../g"          =  "http://a/b/g"
      #       "../.."         =  "http://a/"
      #       "../../"        =  "http://a/"
      #       "../../g"       =  "http://a/g"

      it 'is valid' do
        @url.url = 'g:h'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = './g'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g/'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '/g'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '//g'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '?y'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g?y'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '#s'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g#s'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g?y#s'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = ';x'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '.'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '/'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '..'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '../'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '../g'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '../..'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '../../'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '../../g'
        expect(@url).to be_valid
      end

      # Berners-Lee, et al.         Standards Track                    [Page 36]
      #
      # RFC 3986                   URI Generic Syntax               January 2005
      #
      # 5.4.2.  Abnormal Examples
      #
      #    Although the following abnormal examples are unlikely to occur in
      #    normal practice, all URI parsers should be capable of resolving them
      #    consistently.  Each example uses the same base as that above.
      #
      #    Parsers must be careful in handling cases where there are more ".."
      #    segments in a relative-path reference than there are hierarchical
      #    levels in the base URI's path.  Note that the ".." syntax cannot be
      #    used to change the authority component of a URI.
      #
      #       "../../../g"    =  "http://a/g"
      #       "../../../../g" =  "http://a/g"

      it 'is valid' do
        @url.url = '../../../g'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '../../../../g'
        expect(@url).to be_valid
      end

      #    Similarly, parsers must remove the dot-segments "." and ".." when
      #    they are complete components of a path, but not when they are only
      #    part of a segment.
      #
      #       "/./g"          =  "http://a/g"
      #       "/../g"         =  "http://a/g"
      #       "g."            =  "http://a/b/c/g."
      #       ".g"            =  "http://a/b/c/.g"
      #       "g.."           =  "http://a/b/c/g.."
      #       "..g"           =  "http://a/b/c/..g"

      it 'is valid' do
        @url.url = '/./g'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '/../g'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g.'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '.g'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g..'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = '..g'
        expect(@url).to be_valid
      end

      #    Less likely are cases where the relative reference uses unnecessary
      #    or nonsensical forms of the "." and ".." complete path segments.
      #
      #       "./../g"        =  "http://a/b/g"
      #       "./g/."         =  "http://a/b/c/g/"
      #       "g/./h"         =  "http://a/b/c/g/h"
      #       "g/../h"        =  "http://a/b/c/h"
      #       "g;x=1/./y"     =  "http://a/b/c/g;x=1/y"
      #       "g;x=1/../y"    =  "http://a/b/c/y"
      it 'is valid' do
        @url.url = './../g'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = './g/'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g/./h'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g/../h'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g;x=1/./y'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g;x=1/../y'
        expect(@url).to be_valid
      end

      #    Some applications fail to separate the reference's query and/or
      #    fragment components from the path component before merging it with
      #    the base path and removing dot-segments.  This error is rarely
      #    noticed, as typical usage of a fragment never includes the hierarchy
      #    ("/") character and the query component is not normally used within
      #    relative references.
      #
      #       "g?y/./x"       =  "http://a/b/c/g?y/./x"
      #       "g?y/../x"      =  "http://a/b/c/g?y/../x"
      #       "g#s/./x"       =  "http://a/b/c/g#s/./x"
      #       "g#s/../x"      =  "http://a/b/c/g#s/../x"
      it 'is valid' do
        @url.url = 'g?y/./x'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g?y/../x'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g#s/./x'
        expect(@url).to be_valid
      end

      it 'is valid' do
        @url.url = 'g#s/../x'
        expect(@url).to be_valid
      end
    end
  end
end
