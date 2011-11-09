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

require 'spec_helper'

module Aeolus
  module Image
    module Warehouse
      describe BucketObject do
        let(:connection) { 'connection' }
        let(:key) { 'key' }
        let(:bucket) { mock(Bucket, :name => 'bucket_name') }

        subject { BucketObject.new( connection, key, bucket ) }

        context "#initialize" do

          it "should set instance varibales correctly" do
            subject.instance_variable_get(:@connection).should be_eql(connection)
            subject.instance_variable_get(:@key).should be_eql(key)
            subject.instance_variable_get(:@bucket).should be_eql(bucket)
            subject.instance_variable_get(:@path).should be_eql('/bucket_name/key')
          end
        end

        context ".create" do

          pending

        end

        context "#body" do

          let(:connection_hash) { { :plain => true } }

          it "should call @connection.do_request with correct parameters" do
            subject.instance_variable_get(:@connection).should_receive(:do_request).with(subject.instance_variable_get(:@path), connection_hash )
            subject.body
          end
        end

        context "#set_body" do

          let(:body) { 'body' }
          let(:connection_hash) { { :content => body, :method => :put } }

          it "should call @connection.do_request with correct parameters" do
            subject.instance_variable_get(:@connection).should_receive(:do_request).with(subject.instance_variable_get(:@path), connection_hash )
            subject.set_body(body)
          end

        end

        context "#attr_list" do

          let(:connection_hash) { { :content => 'op=parts', :method => :post } }
          let(:do_request_result) { Nokogiri::XML(do_request_result_string) }
          let(:do_request_result_string) { "<object></object>" }
          before(:each) do
            subject.instance_variable_get(:@connection).stub(:do_request).and_return(do_request_result)
          end

          it "should call @connection.do_request with correct parameters" do
            subject.instance_variable_get(:@connection).should_receive(:do_request).with( subject.instance_variable_get(:@path), connection_hash )
            subject.attr_list
          end

          context "when @connection.do_request returns good data" do
            let(:do_request_result_string) { "<object><object_attr name='name_1'>value_1</object_attr><object_attr name='name_2'>value_2</object_attr></object>" }

            it "should return correct values" do
              subject.attr_list.should be_eql(["name_1", "name_2"])
            end
          end

          context "when @connection.do_request returns bad data" do
            let(:do_request_result_string) { "<object>/<object>" }

            it "should return correct values" do
              subject.attr_list.should_not be_eql(["name_1", "name_2"])
              subject.attr_list.should be_eql([])
            end
          end
        end

        context "#attrs" do

          let(:attrs) { { 'attr1' => 'val1', 'attr2' => 'val2', 'attr_empty' => '', 'attr_nil' => nil, 'attr-dash' => 'dash' } }
          let(:attr_list_without_dash) { attrs.keys - ['attr-dash'] }
          let(:attr_list_with_dash) { attrs.keys - attr_list_without_dash }
          let(:attr_list) { attr_list_with_dash + attr_list_without_dash }
          let(:connection_hash) { { :plain => true } }
          before(:each) do
            attrs.each do |key, value|
              subject.instance_variable_get(:@connection).stub(:do_request).with( "#{subject.instance_variable_get(:@path)}/#{key}", connection_hash ).and_return(value)
            end
          end

          it "should call @connection.do_request for each attribute without dash" do
            attr_list_without_dash.each do |attr|
              subject.instance_variable_get(:@connection).should_receive(:do_request).with( "#{subject.instance_variable_get(:@path)}/#{attr}", connection_hash )
            end
            attr_list_with_dash.each do |attr|
              subject.instance_variable_get(:@connection).should_not_receive(:do_request).with( "#{subject.instance_variable_get(:@path)}/#{attr}", connection_hash )
            end
            subject.attrs( attr_list )
          end

          it "should return correct values" do
            subject.attrs(attr_list).should be_eql(attrs.except(*attr_list_with_dash))
          end

        end

        context "#attr" do

          let(:good_attribute_name) { "good_name" }
          let(:good_attribute_value) { "good_value" }
          let(:bad_attribute_name) { "bad_name" }
          before(:each) do
            subject.stub(:attrs).and_return( { good_attribute_name => good_attribute_value } )
          end

          context "when passed good name of attribute" do
            it "should return correct value" do
              subject.attr(good_attribute_name).should be_eql(good_attribute_value)
            end
          end

          context "when passed bad name of attribute" do
            it "should return nil" do
              subject.attr(bad_attribute_name).should be_nil
            end
          end

          context "when passed nil as name of attribute" do
            it "should return nil" do
              subject.attr(nil).should be_nil
            end
          end

        end

        context "#set_attrs" do

          let(:attrs_hash) { { :attr1 => 'value1', :attr2 => 'value2' } }
          before(:each) do
            subject.stub(:set_attr)
          end
          it "should call set_attr with correct parameters for each attribute" do
            attrs_hash.each do |key, value|
              subject.should_receive(:set_attr).with(key, value)
            end
            subject.set_attrs(attrs_hash)
          end

        end

        context "#set_attr" do

          let(:name) { 'name' }
          let(:content) { 'content' }
          let(:connection_hash) { { :method => :put, :content => content } }
          it "should call @connection.do_request with correct parameters" do
            subject.instance_variable_get(:@connection).should_receive(:do_request).with("#{subject.instance_variable_get(:@path)}/#{name}", connection_hash )
            subject.set_attr(name, content)
          end
        end

        context "#delete!" do

          let(:connection_hash) { { :method => :delete } }
          before(:each) do
            subject.instance_variable_get(:@connection).stub(:do_request)
          end
          it "should call @connection.do_request with correct parameters" do
            subject.instance_variable_get(:@connection).should_receive(:do_request).with(subject.instance_variable_get(:@path), connection_hash )
            subject.delete!
          end

        end
      end

      describe Bucket do

        subject { bucket }
        let(:name) { 'bucket_name' }
        let(:do_request_result_string) { "<object>/<object>" }
        let(:do_request_result) { Nokogiri::XML(do_request_result_string) }
        let(:connection) { mock(Object, :do_request => do_request_result) }
        let(:bucket) { Bucket.new(name, connection) }
        context "#initialize" do

          it "should set instance variables correctly" do
            subject.instance_variable_get(:@name).should be_eql(name)
            subject.instance_variable_get(:@connection).should be_eql(connection)
          end
        end

        context "#to_s" do

          it "should return correct string" do
            subject.to_s.should be_eql("Bucket: #{name}")
          end

        end

        context "#object_names" do
          let(:connection_path) { "/#{name}" }
          let(:do_request_result_string) { "<objects><object><key>name1</key></object><object><key>name2</key></object></objects>" }

          it "should call @connection.do_request with correct parameters" do
            connection.should_receive(:do_request).with(connection_path)
            subject.object_names
          end

          it "should return array of object names" do
            puts subject.object_names
            subject.object_names.should be_eql(['name1', 'name2'])
          end

        end

        context "#objects" do
          let(:object_names) { %w{ name1 name2 } }
          let(:mock_object) { mock(BucketObject) }
          before(:each) do
            subject.stub(:object_names).and_return(object_names)
            subject.stub(:object).and_return( mock_object )
          end

          it "should return BucketObject for each object name" do
            subject.objects.should be_eql([mock_object, mock_object])
          end
        end

        context "#object" do

          let(:object_name) { 'object_name' }
          let(:mock_object) { mock(BucketObject) }
          before(:each) do
            BucketObject.stub(:new).and_return(mock_object)
          end
          it "should call BucketObject.new with correct parameters" do
            BucketObject.should_receive(:new).with(connection, object_name, subject)
            subject.object(object_name)
          end

          it "should return new BucketObject" do
            subject.object(object_name).should be_eql(mock_object)
          end

        end

        context "#create_object" do

          let(:object_name) { 'object_name' }
          let(:object_body) { 'object_body' }
          let(:object_attrs) { { :attr1 => 'value1', :attr2 => 'value2' } }
          let(:mock_object) { mock(BucketObject) }
          before(:each) do
            BucketObject.stub(:create).and_return(mock_object)
          end
          it "should call BucketObject.create with correct parameters" do
            BucketObject.should_receive(:create).with(connection, object_name, subject, object_body, object_attrs)
            subject.create_object(object_name, object_body, object_attrs)
          end

          it "should return new BucketObject" do
            subject.create_object(object_name, object_body, object_attrs).should be_eql(mock_object)
          end

        end

        context "#include?" do

          let(:object_names) { %w{ name1 name2 } }
          before(:each) do
            subject.stub(:object_names).and_return(object_names)
          end

          context "when passed key of existing object" do
            it { subject.include?('name1').should be_true }
          end
          context "when passed key of nonexisting object" do
            it { subject.include?('name3').should be_false }
          end

        end
      end

      describe Connection do
        subject { connection }

        let(:uri) { 'uri' }
        let(:connection) { Connection.new(uri) }
        context "#initialize" do

          it "should set up instance variables correctly" do
            subject.instance_variable_get(:@uri).should be_eql(uri)
          end

        end

        context "#do_request" do
          let(:path) { 'path' }
          let(:opts) { { :method => 'method', :content => 'content', :plain => false, :headers => {} } }
          let(:result) { 'result' }
          let(:xml_result) { Nokogiri::XML(result) }

          before(:each) do
            RestClient::Request.stub(:execute).and_return(result)
          end

          context "with meaningful parameters" do

            it "should call RestClient::Request.execute with correct parameters" do
              RestClient::Request.should_receive(:execute).with(:method => opts[:method], :url => uri + path, :payload => opts[:content], :headers => opts[:headers])
              subject.do_request(path, opts)
            end
          end
          context "with no parameters" do

            it "should call RestClient::Request.execute with meaningful defaults" do
              RestClient::Request.should_receive(:execute).with(:method => :get, :url => uri + '', :payload => '', :headers => {})
              subject.do_request()
            end
          end

          context "with opts[:plain] = true" do
            let(:opts) { { :method => 'method', :content => 'content', :plain => true, :headers => {} } }
            it "should return plain result" do
              subject.do_request(path, opts).should be_eql(result)
            end
          end

          context "with opts[:plain] = false" do
            let(:opts) { { :method => 'method', :content => 'content', :plain => false, :headers => {} } }
            it "should return plain result" do
              subject.do_request(path, opts).to_s.should be_eql(xml_result.to_s)
              subject.do_request(path, opts).class.should be_eql(xml_result.class)
            end
          end
        end

        describe Client do

          subject { client }
          let(:client) { Client.new(uri) }
          let(:uri) { 'uri' }
          let(:connection) { mock(Object, :do_request => do_request_result) }
          let(:do_request_result) { Nokogiri::XML(do_request_result_string) }
          let(:do_request_result_string) { "<object>/<object>" }
          before(:each) do
            Connection.stub(:new).and_return(connection)
          end

          context "#initialize" do

            it "should set instance variables correctly" do
              subject.instance_variable_get(:@connection).should be_eql(connection)
            end

          end

          context "#create_bucket" do
            let(:bucket) { mock(Bucket) }
            let(:bucket_name) { 'bucket_name' }
            let(:path) { "/#{bucket_name}" }
            let(:connection_hash) { { :method => :put } }
            before(:each) do
              Bucket.stub(:new).and_return(bucket)
            end

            it "should call @connection.do_request with correct parameters" do
              connection.should_receive(:do_request).with(path, connection_hash)
              subject.create_bucket(bucket_name)
            end

            it "should return Bucket object" do
              subject.create_bucket(bucket_name).should be_eql(bucket)
            end

          end

          context "#bucket" do
            let(:bucket) { mock(Bucket) }
            let(:bucket_name) { 'bucket_name' }
            before(:each) do
              Bucket.stub(:new).and_return(bucket)
            end

            it "should return Bucket object" do
              subject.create_bucket(bucket_name).should be_eql(bucket)
            end

          end

          context "#buckets" do
            let(:bucket_names) { %w{ bucket1 bucket2 bucket3 } }
            let(:do_request_result_string) { "<api>#{bucket_names.map{|bn| "<link rel='bucket' href='#{bn}'/>"}}</api>" }
            it "should return array of bucket names" do
              subject.buckets.should be_eql(bucket_names)
            end

          end

          context "#get_iwhd_version" do
            let(:iwhd_version) { 'iwhd_version' }
            let(:do_request_result_string) { "<api service='image_warehouse' version='#{iwhd_version}'></api>" }
            it "should return iwhd version value" do
              subject.get_iwhd_version.should be_eql(iwhd_version)
            end

          end

          context "#query" do
            let(:bucket_name) { 'bucket_name' }
            let(:path) { "/#{bucket_name}/_query" }
            let(:query_string) { "query_string" }
            let(:connection_hash) { { :method => :post, :content => query_string } }

            it "should call @connection.do_request with correct parameters" do

              connection.should_receive(:do_request).with(path, connection_hash)
              subject.query(bucket_name, query_string)
            end

          end
        end
      end
    end
  end
end
