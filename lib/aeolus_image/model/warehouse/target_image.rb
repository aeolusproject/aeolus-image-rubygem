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
      class TargetImage < WarehouseModel
        @bucket_name = 'target_images'

        def build
          ImageBuild.find(@build) if @build
        end

        def provider_images
          ProviderImage.where("($target_image == \"" + @uuid.to_s + "\")")
        end

        def target_template
          Template.find(@template) if @template
        end

        # Deletes this targetimage and all child objects
        def delete!
          begin
            provider_images.each do |pi|
              pi.delete!
            end
          rescue NoMethodError
          end
          TargetImage.delete(@uuid)
        end
      end
    end
  end
end
