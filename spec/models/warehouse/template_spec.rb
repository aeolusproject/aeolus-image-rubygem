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
      describe Template do
        let(:body) { 'body' }
        before(:each) do
          @template_attributes = {
            :attribute => 'attribute',
            :other_attribute => 'other_attribute',
            :another_attribute => 'another_attribute'
          }
          @object = mock(Object, :attr_list => @template_attributes.keys, :attrs => @template_attributes, :body => 'body')
          @template_attributes.each do |key, value|
            @object.stub(key.to_sym, value)
          end
          @template = Template.new(@object)

        end

        context "@bucket_name" do

          it "should be set correctly" do
            # accessor set in WarehouseModel
            @template.class.bucket_name.should be_eql('templates')
          end

        end

        context "#initialize" do

          before(:each) do
            @attr_writers = []
            @attr_accessors = @template_attributes.keys - @attr_writers
          end

          it "should correctly set attribute writers" do
            @attr_writers.each do |writer|
              @template.respond_to?(:"#{writer.to_s}=").should be_true
            end
          end

          it "should correctly set attribute accessors" do
            @attr_accessors.each do |accessor|
              @template.respond_to?(:"#{accessor.to_s}").should be_true
              @template.respond_to?(:"#{accessor.to_s}=").should be_true
            end
          end

          it "should set attributes to correct values" do
            @attr_accessors.each do |key|
              puts @template.send(:"#{key.to_s}")
              @template.send(:"#{key.to_s}").should be_equal(@template_attributes[key])
            end
          end

        end
      end
    end
  end
end
