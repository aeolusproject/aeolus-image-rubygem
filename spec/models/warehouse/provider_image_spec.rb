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
      describe ProviderImage do
        before(:each) do
          @provider_image_attributes = {
            :provider => 'provider',
            :target_image => 'target_image',
            :uuid => 'uuid',
            :other_attribute => 'other_attribute',
            :another_attribute => 'another_attribute'
          }
          @object = mock(Object, :attr_list => @provider_image_attributes.keys, :attrs => @provider_image_attributes)
          @provider_image_attributes.each do |key, value|
            @object.stub(key.to_sym, value)
          end
          @provider_image = ProviderImage.new(@object)
        end

        context "@bucket_name" do

          it "should be set correctly" do
            # accessor set in WarehouseModel
            @provider_image.class.bucket_name.should be_eql('provider_images')
          end

        end

        context "#initialize" do

          before(:each) do
            @attr_writers = [ :provider, :target_image ]
            @attr_accessors = @provider_image_attributes.keys - @attr_writers
          end

          it "should correctly set attribute writers" do
            @attr_writers.each do |writer|
              @provider_image.respond_to?(:"#{writer.to_s}=").should be_true
            end
          end

          it "should correctly set attribute accessors" do
            @attr_accessors.each do |accessor|
              @provider_image.respond_to?(:"#{accessor.to_s}").should be_true
              @provider_image.respond_to?(:"#{accessor.to_s}=").should be_true
            end
          end

          it "should set attributes to correct values" do
            @attr_accessors.each do |key|
              @provider_image.send(:"#{key.to_s}").should be_equal(@provider_image_attributes[key])
            end
          end

        end

        context "#target_image" do
          context "with @target_image present" do
            before(:each) do
              @target_image_mock = mock(TargetImage)
              TargetImage.stub(:find).and_return(@target_image_mock)
            end
            it "should call TargetImage.find with correct parameter" do
              TargetImage.should_receive(:find).with(@provider_image.instance_variable_get( :@target_image ))
              @provider_image.target_image
            end

            it "should return found TargetImage" do
              @provider_image.target_image.should be_eql(@target_image_mock)
            end
          end

          context "with @target_image absent" do
            before(:each) do
              @provider_image.instance_variable_set(:@target_image, nil)
            end
            it "should not call TargetImage.find at all" do
              TargetImage.should_not_receive(:find)
              @provider_image.target_image
            end
          end
        end

        context "#provider_name" do
          it "should return @provider" do
            @provider_image.provider_name.should be_eql(@provider_image.instance_variable_get(:@provider))
          end
        end

        context "#delete!" do
          it "should call ProviderImage.delete with @uuid" do
            ProviderImage.should_receive(:delete).with(@provider_image.instance_variable_get(:@uuid))
            @provider_image.delete!
          end
        end
      end
    end
  end
end
