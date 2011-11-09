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
      describe ImageBuild do
        before(:each) do
          @image_build_attributes = {
            :image => 'image',
            :uuid => 'uuid',
            :template => 'template',
            :other_attribute => 'other_attribute',
            :another_attribute => 'another_attribute'
          }
          @object = mock(Object, :attr_list => @image_build_attributes.keys, :attrs => @image_build_attributes)
          @image_build_attributes.each do |key, value|
            @object.stub(key.to_sym, value)
          end
          @image_build = ImageBuild.new(@object)


          @target_image_mock_with_no_build = mock(TargetImage, :build => nil)
          @target_image_mock_with_correct_build = mock(TargetImage, :build => @image_build)
          @other_target_image_mock_with_correct_build = mock(TargetImage, :build => @image_build)

          @other_image_build_attributes = @image_build_attributes.merge(:uuid => 'other_uuid')
          @other_object = mock(Object, :attr_list => @other_image_build_attributes.keys, :attrs => @other_image_build_attributes)
          @other_image_build_attributes.each do |key, value|
            @other_object.stub(key.to_sym, value)
          end
          @other_image_build = ImageBuild.new(@other_object)

          @target_image_mock_with_other_image_build = mock(TargetImage, :build => @other_image_build)

          @all_target_images = [ @target_image_mock_with_no_build, @target_image_mock_with_correct_build, @other_target_image_mock_with_correct_build, @target_image_mock_with_other_image_build ]

          @correct_target_images = [ @target_image_mock_with_correct_build, @other_target_image_mock_with_correct_build ]

          @first_target_image_provider_images = []
          3.times do
            @first_target_image_provider_images << mock(ProviderImage, :target_image => @target_image_mock_with_correct_build)
          end

          @second_target_image_provider_images = []
          3.times do
            @second_target_image_provider_images << mock(ProviderImage, :target_image => @other_target_image_mock_with_correct_build)
          end

          @incorrect_target_image_provider_images = []
          3.times do
            @incorrect_target_image_provider_images << mock(ProviderImage, :target_image => @target_image_mock_with_other_image_build)
          end

          @correct_provider_images = @first_target_image_provider_images + @second_target_image_provider_images
          @incorrect_provider_images = @incorrect_target_image_provider_images
          @all_provider_images = @correct_provider_images + @incorrect_provider_images

        end

        context "@bucket_name" do

          it "should be set correctly" do
            # accessor set in WarehouseModel
            @image_build.class.bucket_name.should be_eql('builds')
          end

        end

        context "#initialize" do

          before(:each) do
            @attr_writers = [ :image ]
            @attr_accessors = @image_build_attributes.keys - @attr_writers
          end

          it "should correctly set attribute writers" do
            @attr_writers.each do |writer|
              @image_build.respond_to?(:"#{writer.to_s}=").should be_true
            end
          end

          it "should correctly set attribute accessors" do
            @attr_accessors.each do |accessor|
              @image_build.respond_to?(:"#{accessor.to_s}").should be_true
              @image_build.respond_to?(:"#{accessor.to_s}=").should be_true
            end
          end

          it "should set attributes to correct values" do
            @attr_accessors.each do |key|
              @image_build.send(:"#{key.to_s}").should be_equal(@image_build_attributes[key])
            end
          end

        end

        #TODO: implement this test
        context ".find_all_by_image_uuid" do

        end

        context "#image" do
          context "with @image present" do
            before(:each) do
              @image_mock = mock(Image)
              Image.stub(:find).and_return(@image_mock)
            end
            it "should call Image.find with correct parameter" do
              Image.should_receive(:find).with(@image_build.instance_variable_get( :@image ))
              @image_build.image
            end

            it "should return found Image" do
              @image_build.image.should be_eql(@image_mock)
            end
          end

          context "with @image absent" do
            before(:each) do
              @image_build.instance_variable_set(:@image, nil)
            end
            it "should not call Image.find at all" do
              Image.should_not_receive(:find)
              @image_build.image
            end
          end
        end

        context "#target_images" do
          before(:each) do
            TargetImage.stub(:all).and_return(@all_target_images)
          end

          context "should return collection" do
            it "with correct target image" do
              @image_build.target_images.should include(@target_image_mock_with_correct_build)
            end
            it "with other correct target image" do
              @image_build.target_images.should include(@other_target_image_mock_with_correct_build)
            end
            it "without target image with other build" do
              @image_build.target_images.should_not include(@target_image_mock_with_other_image_build)
            end
            it "without target image without build" do
              @image_build.target_images.should_not include(@target_image_mock_with_no_build)
            end
          end
        end


        context "#provider_images" do
          before(:each) do
            @image_build.stub(:target_images).and_return(@correct_target_images)
            ProviderImage.stub(:all).and_return(@all_provider_images)
          end

          context "should return collection" do
            it "with correct provider images" do
              @correct_provider_images.each do |provider_image|
                @image_build.provider_images.should include(provider_image)
              end
            end
            it "without provider image with other target image" do
              @incorrect_provider_images.each do |provider_image|
                @image_build.provider_images.should_not include(provider_image)
              end
            end
          end
        end

        context "#delete!" do

          before(:each) do
            @correct_target_images.each{|ti| ti.stub(:delete!)}
            @image_build.stub(:target_images).and_return(@correct_target_images)
            ImageBuild.stub(:delete)
          end
          it "should delete all associated provider images" do
            @correct_target_images.each{|ti| ti.should_receive(:delete!)}
            @image_build.delete!
          end
          it "should call TargetImage.delete with @uuid" do
            ImageBuild.should_receive(:delete).with(@image_build.instance_variable_get(:@uuid))
            @image_build.delete!
          end

        end
      end
    end
  end
end
