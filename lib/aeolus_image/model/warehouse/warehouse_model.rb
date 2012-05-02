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

module Aeolus
  module Image
    module Warehouse
      class BucketObjectNotFound < Exception;end
      class BucketNotFound < Exception;end

      class WarehouseModel
        attr_writer :body

        def initialize(obj)
          @obj = obj
          @attrs = obj.attrs(obj.attr_list)
          @attrs.each do |k,v|
            self.class.send(:attr_writer, k.to_sym) unless respond_to?(:"#{k}=")
            self.class.send(:attr_reader, k.to_sym) unless respond_to?(k.to_sym)
            send(:"#{k}=", v)
          end
        end

        def body
          @obj.body
        end

        def ==(other_obj)
          # If the objects have different instance variables defined, they're definitely not ==
          return false unless instance_variables.sort == other_obj.instance_variables.sort
          # Otherwise, ensure that they're all the same
          instance_variables.each do |iv|
            next if iv == "@obj" || iv == :@obj
            return false unless other_obj.instance_variable_get(iv) == instance_variable_get(iv)
            return false unless other_obj.body == body
          end
          # They have the same instance variables and values, so they're equal
          true
        end

        def id
          uuid
        end

        # Returns the bucket object represending this object
        def bucket_object
          @obj
        end

        # Set (and immediately update) an attribute on the object
        # TODO: It might be nicer to offer a .save! that iterates over each attribute
        # and calls this, to better match ActiveResource
        def set_attr(key, value)
          bucket_object.set_attr(key, value)
        end


        class << self
          attr_accessor :warehouse, :bucket, :bucket_name

          def set_warehouse_and_bucket
            begin
              @@config ||= load_config
              self.warehouse = Warehouse::Client.new(@@config[:iwhd][:url])
              self.bucket = self.warehouse.bucket(@bucket_name)
            rescue
              raise BucketNotFound
            end
          end

          def bucket_objects
            self.set_warehouse_and_bucket if self.bucket.nil?

            begin
              self.bucket.objects
            rescue RestClient::ResourceNotFound
              []
            end
          end

          def first
            obj = bucket_objects.first
            obj ? self.new(obj) : nil
          end

          def last
            obj = bucket_objects.last
            obj ? self.new(obj) : nil
          end

          def all
            bucket_objects.map do |wh_object|
                self.new(wh_object)
            end
          end

          def find(uuid)
            self.set_warehouse_and_bucket if self.bucket.nil?
            begin
              if self.bucket.include?(uuid)
                self.new(self.bucket.object(uuid))
              else
                nil
              end
            rescue RestClient::ResourceNotFound
              nil
            end
          end

          def where(query_string)
            begin
              self.set_warehouse_and_bucket if self.bucket.nil?
              self.warehouse.query(@bucket_name, query_string).xpath('/objects/object').map do |obj|
                self.new(self.bucket.object(obj.at_xpath('./key/text()').to_s))
              end
            rescue RestClient::ResourceNotFound
              []
            end
          end

          def delete(uuid)
            self.set_warehouse_and_bucket if self.bucket.nil?
            begin
              if self.bucket.include?(uuid)
                self.bucket.object(uuid).delete!
              else
                false
              end
            rescue RestClient::ResourceNotFound
              false
            end
          end

          def config
            defined?(@@config) ? @@config : nil
          end

          def config=(conf)
            @@config = conf
          end

          def use_oauth?
            !!oauth_consumer_key && !!oauth_consumer_secret
          end

          def oauth_consumer_key
            config[:iwhd][:oauth][:consumer_key] rescue nil
          end

          def oauth_consumer_secret
            config[:iwhd][:oauth][:consumer_secret] rescue nil
          end

          def iwhd_url
            config[:iwhd][:url]
          end

          def create!(key, body, attributes)
            self.set_warehouse_and_bucket if self.bucket.nil?
            unless self.warehouse.buckets.include?(self.bucket.name)
              self.bucket = self.warehouse.create_bucket(self.bucket.name)
            end
            obj = self.bucket.create_object(key, body, attributes)
            self.new(obj)
          end

          protected

          # Copy over entirely too much code to load the config file
          def load_config
            # TODO - Is this always the case? We should probably have /etc/aeolus-cli or something too?
            # Or allow Rails to override this
            @config_location ||= "~/.aeolus-cli"
            begin
              file_str = read_file(@config_location)
              if is_file?(@config_location) && !file_str.include?(":url")
                lines = File.readlines(File.expand_path(@config_location)).map do |line|
                  "#" + line
                end
                File.open(File.expand_path(@config_location), 'w') do |file|
                  file.puts lines
                end
                write_file
              end
              write_file unless is_file?(@config_location)
              YAML::load(File.open(File.expand_path(@config_location)))
            rescue Errno::ENOENT
              #TODO: Create a custom exception to wrap CLI Exceptions
              raise "Unable to locate or write configuration file: \"" + @config_location + "\""
            end
          end

          def write_file
            example = File.read(File.expand_path(File.dirname(__FILE__) + "/../../examples/aeolus-cli"))
            File.open(File.expand_path(@config_location), 'a+') do |f|
              f.write(example)
            end
          end

          def read_file(path)
            begin
              full_path = File.expand_path(path)
              if is_file?(path)
                File.read(full_path)
              else
                return nil
              end
            rescue
              nil
            end
          end

          def is_file?(path)
            full_path = File.expand_path(path)
            if File.exist?(full_path) && !File.directory?(full_path)
              return true
            end
            false
          end

        end

      end
    end
  end
end
