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
      class Image < WarehouseModel
        OS = Struct.new(:name, :version, :arch)

        @bucket_name = 'images'

        def initialize(obj)
          super
          @xml_body = Nokogiri::XML obj.body
        end

        # This can now return nil
        def template_xml
          unless @template_xml
            begin
              # if an image is directly associated with template, use this
              if @template
                @template_xml = Template.find(@template).xml_body
              else
                @template_xml = Nokogiri::XML image_builds.first.target_images.first.target_template.body
              end
            rescue
              @template_xml = nil
            end
          end
          @template_xml
        end

        def latest_pushed_build
          ImageBuild.find(@latest_build) if @latest_build
        end

        def latest_pushed_or_unpushed_build
          build = @latest_build ? ImageBuild.find(@latest_build) : nil
          push = @latest_unpushed ? ImageBuild.find(@latest_unpushed) : nil
          if build and push
            return push.timestamp > build.timestamp ? push : build
          end
          return build || push || nil
        end

        def image_builds
          ImageBuild.where("($image == \"" + @uuid.to_s + "\")")
        end

        # Return all Provider Images associated with this Image
        def provider_images
          provider_images = []
          image_builds.each do |b|
            provider_images = provider_images + b.provider_images
          end
          provider_images
        end

        #TODO: We should get the image fields from the object body once we have it defined.
        def name
          unless @name
            @name = @xml_body.xpath("/image/name").text
            if @name.empty?
              @name = template_xml.xpath("/template/name").text
            end
          end
          @name
        end

        def os
          unless @os
            @os = OS.new(template_xpath("/template/os/name"), template_xpath("/template/os/version"), template_xpath("/template/os/arch"))
          end
          @os
        end

        def description
          unless @description
            @description = template_xpath("/template/description")
          end
          @description
        end

        def environment
          @environment
        end

        # Delete this image and all child objects
        def delete!
          begin
            image_builds.each do |build|
              build.delete!
            end
          rescue NoMethodError
          end
          Image.delete(@uuid)
        end

        # No template is created on imported images
        def imported?
          !@template
        end

        # template_xml.xpath(PATH).text => template_xpath(PATH)
        # Rescues exceptions and returns an empty string if necessary
        def template_xpath(path)
          xml = template_xml
          xml.present? ? xml.xpath(path).text : ""
        end

        class << self
          def by_environment(environment)
            self.where("($environment == \"" + environment + "\")")
          end
        end
      end
    end
  end
end
