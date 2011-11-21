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
      describe WarehouseModel do
        subject { @warehouse_model }
        before(:each) do
          @warehouse_model_attributes = {
            :attribute => 'attribute',
            :other_attribute => 'other_attribute',
          }
          @object = mock(Object, :attr_list => @warehouse_model_attributes.keys, :attrs => @warehouse_model_attributes, :body => 'body')
          @warehouse_model_attributes.each do |key, value|
            @object.stub(key.to_sym, value)
          end
          @warehouse_model = WarehouseModel.new(@object)
        end

        context "#==" do
          let(:other_object) { mock(Object, :attr_list => other_warehouse_attributes.keys, :attrs => other_warehouse_attributes, :body => 'body') }
          let(:other_warehouse_model) { WarehouseModel.new(other_object) }

          context "when other object has the same instance variables list" do
            context "with the same values" do
              let(:other_warehouse_attributes) { @warehouse_model_attributes }
              it { subject.==(other_warehouse_model).should be_true }
            end

            context "with different values" do
              let(:other_warehouse_attributes) { @warehouse_model_attributes.merge(:attribute => 'other_value') }
              it { subject.==(other_warehouse_model).should be_false }
            end
          end

          context "when other object has different instance variables list" do
            let(:other_warehouse_attributes) { @warehouse_model_attributes.merge(:another_attribute => 'another_attribute') }

            it { subject.==(other_warehouse_model).should be_false }

          end
        end

        # cannot be tested - method returns uuid
        # which may be created by initialize method in child of WarehouseModel
        context "#id"

        context ".set_warehouse_and_bucket" do

          it "should set warehouse" do
            pending
          end

          it "should set bucket" do
            pending
          end
        end

        context ".bucket_objects" do

          context "when bucket is not present" do

            it "should set warehouse and bucket" do
              pending
            end
          end
        end

        context ".first" do

          before(:each) do
            WarehouseModel.stub(:bucket_objects).and_return(bucket_objects)
          end

        end

      end
    end
  end
end
