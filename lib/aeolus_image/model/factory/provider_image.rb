module Aeolus
  module Image
    module Factory
      class ProviderImage < Base
        def self.status(id)
          Aeolus::Image::Factory::Builder.find(id).status
        end

        def save
          post(post_url)
        end

        def post_url
          "images/" + @attributes['image_id'] + "/builds/" + @attributes['build_id'] + "/target_images/" + @attributes['target_image_id'] + "/provider_images"
        end

        def custom_method_new_element_url(method_name, options = {})
          self.class.prefix(prefix_options) + post_url
        end
      end
    end
  end
end