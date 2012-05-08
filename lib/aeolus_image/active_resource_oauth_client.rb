# Copyright (c) 2011 Red Hat, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial
# portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


require 'oauth'

# Monkey-patch ActiveResource to allow us to merge our OAuth headers in.
# Portions of the below are taken from Active Resource which is MIT licensed;
# hence this whole file is being licensed under the MIT License to err on the side of safety.
module ActiveResourceOAuthClient
  ActiveResource::Connection.class_eval do
    def request_with_oauth(method, path, *arguments)
      @oauth_config = Aeolus::Image::Factory::Base.config || {}
      # Take care to fall back to the standard request method if we don't have full OAuth credentials
      unless use_oauth_for_url?("#{site.scheme}://#{site.host}:#{site.port}#{path}")
        return request_without_oauth(method, path, *arguments)
      end
      result = ActiveSupport::Notifications.instrument("request.active_resource") do |payload|
        payload[:method] = method
        payload[:request_uri] = "#{site.scheme}://#{site.host}:#{site.port}#{path}"
        oauth_consumer = OAuth::Consumer.new(
          @oauth_config[:consumer_key],
          @oauth_config[:consumer_secret],
          :site => @oauth_config[:site] )
        token = OAuth::AccessToken.new(oauth_consumer)
        base_request = oauth_consumer.create_signed_request(method, path, token, {}, *arguments)
        payload[:result] = http.request(base_request)
      end
      # Error-handling code from OAuth
      # http://wiki.oauth.net/w/page/12238543/ProblemReporting
      auth_header = result.to_hash['www-authenticate']
      problem_header = auth_header ? auth_header.select{|h| h =~ /^OAuth /}.select{|h| h =~ /oauth_problem/}.first : nil
      if auth_header && problem_header
        params = OAuth::Helper.parse_header(problem_header)
        raise OAuth::Problem.new(params.delete("oauth_problem"), result, params)
      end
      # Error-handling code from ActiveResource
      handle_response(result)
      rescue Timeout::Error => e
        raise TimeoutError.new(e.message)
      rescue OpenSSL::SSL::SSLError => e
        raise SSLError.new(e.message)
    end

    # Currently, only Factory calls should use OAuth -- extend as needed
    def use_oauth_for_url?(url)
      Aeolus::Image::Factory::Base.use_oauth? and
        url.include?(Aeolus::Image::Factory::Base.config[:site])
    end

    alias_method_chain :request, :oauth

  end
end
