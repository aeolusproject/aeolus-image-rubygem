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

describe Aeolus::Image::Factory::Builder do
  VCR::Cassette.new 'builder', :record => :new_episodes, :match_requests_on => [:method, :uri, :body]
  it "should get builder object" do
    Aeolus::Image::Factory::Base.config = {
      :site => 'http://127.0.0.1:8075/imagefactory'
    }
    builder = Aeolus::Image::Factory::Builder.first
    builder.builders.should_not be_empty
    build = builder.builders.first
    builder.find_active_build(build.build_id, build.target).should_not be_nil
    builder.find_active_build(build.build_id, 'invalid_target').should be_nil
  end
end
