module Aeolus
  module Image
    module Factory
      class ProviderImage < Base
        def self.status(id)
          Aeolus::Image::Factory::Builder.find(id).status
        end
      end
    end
  end
end
