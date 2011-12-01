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
require 'vcr'
require 'oauth'
require File.join(File.dirname(__FILE__), '../lib', 'aeolus_image')


VCR.config do |config|
  config.cassette_library_dir = 'spec/vcr/cassettes'
  config.stub_with :webmock
  config.allow_http_connections_when_no_cassette = true
end

ActiveResource::Connection.class_eval do
  def request(method, path, *args)
    # We want to add :body, but not :headers because they're too fickle with OAuth
    VCR.use_cassette('oauth', :record => :new_episodes, :match_requests_on => [:method, :uri, :body]) do
      request_with_oauth(method, path, *args)
    end
  end
end
