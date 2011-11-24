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

        def image
          Image.find(@image) if @image
        end

        def target_images
          TargetImage.where("($build == \"" + @uuid.to_s + "\")")
        end

        # Convenience Method to get all provider images for this build
        def provider_images
          provider_images = []
          target_images.each do |t|
            provider_images = provider_images + t.provider_images
          end
          provider_images
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
