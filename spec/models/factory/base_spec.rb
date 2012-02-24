#
#   Copyright 2011 Red Hat, Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
require 'spec_helper'
require 'timecop'

describe Aeolus::Image::Factory::Base do

  before(:each) do
    Timecop.travel(Time.local(2011, 10, 17, 13, 38, 20))
  end

  after(:each) do
    Timecop.return
  end

  it "should not use_oauth? if configuration is missing" do
    Aeolus::Image::Factory::Base.config = {
      :site => 'http://127.0.0.1:8075/imagefactory'
    }
    Aeolus::Image::Factory::Base.use_oauth?.should be_false
  end

  it "should use_oauth? if configuration is present" do
    Aeolus::Image::Factory::Base.config = {
      :site => 'http://127.0.0.1:8075/imagefactory',
      :consumer_key => 'something',
      :consumer_secret => 'anything'
    }
    Aeolus::Image::Factory::Base.use_oauth?.should be_true
  end

  context do
    use_vcr_cassette "oauth_success_valid"

    it "should succeed with valid OAuth credentials" do
      Aeolus::Image::Factory::Base.config = {
        :site => 'http://127.0.0.1:8075/imagefactory',
        :consumer_key => 'mock-key',
        :consumer_secret => 'mock-secret'
      }
      template = "<template>\n  <name>f14jeos</name>\n  <os>\n    <name>Fedora</name>\n    <version>14</version>\n    <arch>x86_64</arch>\n    <install type='url'>\n      <url>http://download.fedoraproject.org/pub/fedora/linux/releases/14/Fedora/x86_64/os/</url>\n    </install>\n  </os>\n  <description>Fedora 14</description>\n</template>\n"
      img = Aeolus::Image::Factory::Image.new(:targets => 'ec2', :template => template)
      img.save!.should be_true
    end
  end

  context do
    use_vcr_cassette "oauth_fail_invalid"

    it "should fail with invalid OAuth credentials" do
      Aeolus::Image::Factory::Base.config = {
        :site => 'http://127.0.0.1:8075/imagefactory',
        :consumer_key => 'mock-key',
        :consumer_secret => 'wrong-secret'
      }
      template = "<template>\n  <name>f14jeos</name>\n  <os>\n    <name>Fedora 2</name>\n    <version>14</version>\n    <arch>x86_64</arch>\n    <install type='url'>\n      <url>http://download.fedoraproject.org/pub/fedora/linux/releases/14/Fedora/x86_64/os/</url>\n    </install>\n  </os>\n  <description>Fedora 14</description>\n</template>\n"
      img = Aeolus::Image::Factory::Image.new(:targets => 'ec2', :template => template)
      lambda {
        img.save!
      }.should raise_error(ActiveResource::UnauthorizedAccess)
    end
  end

  context do
    use_vcr_cassette "oauth_fail_no"

    it "should fail with no OAuth credentials" do
      Aeolus::Image::Factory::Base.config = {
        :site => 'http://127.0.0.1:8075/imagefactory'
      }
      template = "<template>\n  <name>f14jeos</name>\n  <os>\n    <name>Fedora 3</name>\n    <version>14</version>\n    <arch>x86_64</arch>\n    <install type='url'>\n      <url>http://download.fedoraproject.org/pub/fedora/linux/releases/14/Fedora/x86_64/os/</url>\n    </install>\n  </os>\n  <description>Fedora 14</description>\n</template>\n"
      img = Aeolus::Image::Factory::Image.new(:targets => 'ec2', :template => template)
      # ServerError is actually not what _should_ be returned, but a bug means that's what we get at the moment.
      # When the bug is fixed, we need to update to test for that.
      lambda {
        img.save!.should be_false
      }.should raise_error(ActiveResource::ServerError)
    end
  end

end
