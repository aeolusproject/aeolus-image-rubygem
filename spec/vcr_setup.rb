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
