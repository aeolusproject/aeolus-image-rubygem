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
      class ImageBuild < WarehouseModel
        @bucket_name = 'builds'

        def self.find_all_by_image_uuid(uuid)
          self.set_warehouse_and_bucket if self.bucket.nil?
          self.bucket.objects.map do |wh_object|
            if wh_object.attr('image') == uuid
              ImageBuild.new(wh_object)
            end
          end.compact
        end

        def image
          Image.find(@image) if @image
        end

        def target_images
          TargetImage.all.select {|ti| ti.build and (ti.build.uuid == self.uuid)}
        end

        def provider_images
          targets = target_images
          ProviderImage.all.select do |pi|
            targets.include?(pi.target_image)
          end
        end

        # Deletes this image and all child objects
        def delete!
          begin
            target_images.each do |ti|
              ti.delete!
            end
          rescue NoMethodError
          end
          ImageBuild.delete(@uuid)
        end
      end
    end
  end
end
