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
      describe TargetImage do
        before(:each) do
          @target_image_attributes = {
            :build => 'build',
            :uuid => 'uuid',
            :template => 'template',
            :other_attribute => 'other_attribute',
            :another_attribute => 'another_attribute'
          }
          @object = mock(Object, :attr_list => @target_image_attributes.keys, :attrs => @target_image_attributes)
          @target_image_attributes.each do |key, value|
            @object.stub(key.to_sym, value)
          end
          @target_image = TargetImage.new(@object)


          @provider_image_mock_with_no_target_image = mock(ProviderImage, :target_image => nil)
          @provider_image_mock_with_correct_target_image = mock(ProviderImage, :target_image => @target_image)
          @other_provider_image_mock_with_correct_target_image = mock(ProviderImage, :target_image => @target_image)

          @other_target_image_attributes = @target_image_attributes.merge(:uuid => 'other_uuid')
          @other_object = mock(Object, :attr_list => @other_target_image_attributes.keys, :attrs => @other_target_image_attributes)
          @other_target_image_attributes.each do |key, value|
            @other_object.stub(key.to_sym, value)
          end
          @other_target_image = TargetImage.new(@other_object)
          @provider_image_mock_with_other_target_image = mock(ProviderImage, :target_image => @other_target_image)

          @all_provider_images = [ @provider_image_mock_with_correct_target_image, @other_provider_image_mock_with_correct_target_image, @provider_image_mock_with_other_target_image, @provider_image_mock_with_no_target_image ]

          @correct_provider_images = [ @provider_image_mock_with_correct_target_image, @other_provider_image_mock_with_correct_target_image ]

        end

        context "@bucket_name" do

          it "should be set correctly" do
            # accessor set in WarehouseModel
            @target_image.class.bucket_name.should be_eql('target_images')
          end

        end

        context "#initialize" do

          before(:each) do
            @attr_writers = [ :build ]
            @attr_accessors = @target_image_attributes.keys - @attr_writers
          end

          it "should correctly set attribute writers" do
            @attr_writers.each do |writer|
              @target_image.respond_to?(:"#{writer.to_s}=").should be_true
            end
          end

          it "should correctly set attribute accessors" do
            @attr_accessors.each do |accessor|
              @target_image.respond_to?(:"#{accessor.to_s}").should be_true
              @target_image.respond_to?(:"#{accessor.to_s}=").should be_true
            end
          end

          it "should set attributes to correct values" do
            @attr_accessors.each do |key|
              @target_image.send(:"#{key.to_s}").should be_equal(@target_image_attributes[key])
            end
          end

        end

        context "#build" do
          context "with @build present" do
            before(:each) do
              @image_build_mock = mock(ImageBuild)
              ImageBuild.stub(:find).and_return(@image_build_mock)
            end
            it "should call TargetImage.find with correct parameter" do
              ImageBuild.should_receive(:find).with(@target_image.instance_variable_get( :@build ))
              @target_image.build
            end

            it "should return found TargetImage" do
              @target_image.build.should be_eql(@image_build_mock)
            end
          end

          context "with @build absent" do
            before(:each) do
              @target_image.instance_variable_set(:@build, nil)
            end
            it "should not call TargetImage.find at all" do
              ImageBuild.should_not_receive(:find)
              @target_image.build
            end
          end
        end

        context "#provider_images" do
          before(:each) do
            ProviderImage.stub(:all).and_return(@all_provider_images)
          end

          context "should return collection" do
            it "with correct provider image" do
              @target_image.provider_images.should include(@provider_image_mock_with_correct_target_image)
            end
            it "with other correct provider image" do
              @target_image.provider_images.should include(@other_provider_image_mock_with_correct_target_image)
            end
            it "without provider image with other target image" do
              @target_image.provider_images.should_not include(@provider_image_mock_with_other_target_image)
            end
            it "without provider image without target image" do
              @target_image.provider_images.should_not include(@provider_image_mock_with_no_target_image)
            end
          end
        end

        context "#template" do
          context "with @template present" do
            before(:each) do
              @template_mock = mock(Template)
              Template.stub(:find).and_return(@template_mock)
            end
            it "should call Template.find with correct parameter" do
              Template.should_receive(:find).with(@target_image.instance_variable_get( :@template ))
              @target_image.target_template
            end

            it "should return found Template" do
              @target_image.target_template.should be_eql(@template_mock)
            end
          end

          context "with @template absent" do
            before(:each) do
              @target_image.instance_variable_set(:@template, nil)
            end
            it "should not call Template.find at all" do
              Template.should_not_receive(:find)
              @target_image.target_template
            end
          end
        end

        context "#delete!" do

          before(:each) do
            @correct_provider_images.each{|pi| pi.stub(:delete!)}
            @target_image.stub(:provider_images).and_return(@correct_provider_images)
            TargetImage.stub(:delete)
          end
          it "should delete all associated provider images" do
            @correct_provider_images.each{|pi| pi.should_receive(:delete!)}
            @target_image.delete!
          end
          it "should call TargetImage.delete with @uuid" do
            TargetImage.should_receive(:delete).with(@target_image.instance_variable_get(:@uuid))
            @target_image.delete!
          end

        end
      end
    end
  end
end
