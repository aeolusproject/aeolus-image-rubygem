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
    def self.import(provider_name, deltacloud_driver, image_id, account_id, environment, xml=nil)
      xml ||= "<image><name>#{image_id}</name></image>"
      image = Factory::Image.new(
        :target_name => deltacloud_driver,
        :provider_name => provider_name,
        :target_identifier => image_id,
        :image_descriptor => xml
      )
      image.save!
      # Set the provider_account_id on the image
      iwhd_image = Warehouse::Image.find(image.id)
      iwhd_image.set_attr("environment", environment)
     # Set the account on the provider image
      # This assumes (as is currently correct) that there will only be one provider image for imported images
      pimg = iwhd_image.provider_images.first
      pimg.set_attr('provider_account_identifier', account_id)
      image
    end
  end
end
