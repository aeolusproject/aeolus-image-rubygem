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
      describe Image do
        let(:body) { 'body' }
        before(:each) do
          @image_attributes = {
            :latest_build => 'latest_build',
            :uuid => 'uuid',
            :body => body,
            :other_attribute => 'other_attribute',
            :another_attribute => 'another_attribute'
          }
          @object = mock(Object, :attr_list => @image_attributes.keys, :attrs => @image_attributes)
          @image_attributes.each do |key, value|
            @object.stub(key.to_sym, value)
          end
          @image = Image.new(@object)

        end

        context "@bucket_name" do

          it "should be set correctly" do
            # accessor set in WarehouseModel
            @image.class.bucket_name.should be_eql('images')
          end

        end

        context "#initialize" do

          before(:each) do
            @attr_writers = [ :latest_build ]
            @attr_accessors = @image_attributes.keys - @attr_writers
          end

          it "should correctly set attribute writers" do
            @attr_writers.each do |writer|
              @image.respond_to?(:"#{writer.to_s}=").should be_true
            end
          end

          it "should correctly set attribute accessors" do
            @attr_accessors.each do |accessor|
              @image.respond_to?(:"#{accessor.to_s}").should be_true
              @image.respond_to?(:"#{accessor.to_s}=").should be_true
            end
          end

          #it "should set attributes to correct values" do
          #  @attr_accessors.each do |key|
          #    @image.send(:"#{key.to_s}").should be_equal(@image_attributes[key])
          #  end
          #end

        end

        context "#template_xml" do

          before(:each) do
            @body = "<template><item>X</item></template>"
            @template_xml = Nokogiri::XML(@body)

            @empty_body = "<template></template>"
            @empty_tempalte_xml = Nokogiri::XML(@empty_body)
          end

          context "with correct associated objects" do

            before(:each) do
              @target_template = mock(Template, :body => @template_xml.to_s)
              @target_image = [ mock(TargetImage, :target_template => @target_template) ]
              @image_builds = [ mock(ImageBuild, :target_images => @target_image) ]
              @image.stub(:image_builds).and_return(@image_builds)
            end

            # TODO: There shoud be a way to test equality of Nokogiri::XML documents better than string comparison
            it "should return correct template" do
              @image.template_xml.to_s.should be_eql(@template_xml.to_s)
            end

          end

          context "with incorect associated object" do

            before(:each) do
              @image.stub(:image_builds).and_return(nil)
            end

            # TODO: There shoud be a way to test equality of Nokogiri::XML documents better than string comparison
            it "should return empty template" do
              @image.template_xml.to_s.should be_eql(@empty_tempalte_xml.to_s)
            end
          end
        end

        context "#name" do
          subject { @image.name }
          context "with /image/name text value defined in body" do
            let(:body) { "<image><name>image-name-string</name></image>" }
            before(:each) do
              @image.instance_variable_set(:@xml_body, Nokogiri::XML(body))
            end

            it "should return /image/name text value" do
              puts subject
              should be_eql('image-name-string')
            end
          end

          context "without /image/name text value defined in body" do
            before(:each) do
              @image.stub(:template_xml).and_return(Nokogiri::XML(template_xml))
            end
            context "with /template/name text value from template_xml" do
              let(:template_xml) { "<template><name>template-name-string</name></template>" }
              it "should return /template/name text value" do
                should be_eql('template-name-string')
              end
            end

            context "without /template/name text value from template_xml" do
              let(:template_xml) { "<template></template>" }
              it "should return empty string" do
                should be_eql("")
              end
            end
          end
        end

        context "#os" do
          subject { @image.os }
          let(:template_xml) { "<template><os><name>template-os-name</name><version>template-os-version</version><arch>template-os-arch</arch></os></template>" }
          before(:each) do
            @image.stub(:template_xml).and_return(Nokogiri::XML(template_xml))
          end

          it "should return correct OS struct" do
            subject.name.should be_eql("template-os-name")
            subject.version.should be_eql("template-os-version")
            subject.arch.should be_eql("template-os-arch")
          end
        end

        context "#description" do

          subject { @image.description }
          let(:template_xml) { "<template><description>template-description-string</description></template>" }

          before(:each) do
            @image.stub(:template_xml).and_return(Nokogiri::XML(template_xml))
          end

          it "should return /template/description text value from template_xml" do
            should be_eql("template-description-string")
          end

        end

        context "#latest_pushed_build" do

          context "with @latest_build present" do
            before(:each) do
              @latest_build_mock = mock(ImageBuild)
              ImageBuild.stub(:find).and_return(@latest_build_mock)
            end
            it "should call ImageBuild.find with correct parameter" do
              ImageBuild.should_receive(:find).with(@image.instance_variable_get( :@latest_build ))
              @image.latest_pushed_build
            end

            it "should return found ImageBuild" do
              @image.latest_pushed_build.should be_eql(@latest_build_mock)
            end
          end

          context "with @latest_build absent" do
            before(:each) do
              @image.instance_variable_set(:@latest_build, nil)
            end
            it "should not call ImageBuild.find at all" do
              ImageBuild.should_not_receive(:find)
              @image.latest_pushed_build
            end
          end
        end

        context "#image_builds" do

          before(:each) do
            ImageBuild.stub(:find_all_by_image_uuid)
          end

          it "should call ImageBuild.find_all_by_image_uuid with @uuid" do
            ImageBuild.should_receive(:find_all_by_image_uuid).with(@image.instance_variable_get(:@uuid))
            @image.image_builds
          end

        end

        context "#delete!" do

          before(:each) do
            @image_builds = [ mock(ImageBuild) ]
            @image_builds.each{|ib| ib.stub(:delete!)}
            @image.stub(:image_builds).and_return(@image_builds)
            Image.stub(:delete)
          end

          it "should delete all associated image builds" do
            @image_builds.each{|im| im.should_receive(:delete!)}
            @image.delete!
          end

          it "should call Image.delete with @uuid" do
            Image.should_receive(:delete).with(@image.instance_variable_get(:@uuid))
            @image.delete!
          end

        end

      end
    end
  end
end
