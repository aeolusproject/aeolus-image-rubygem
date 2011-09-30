module Aeolus
  module Image
    module Factory
      class TargetImage < Base
        def self.status(id)
          Aeolus::Image::Factory::Builder.find(id).status
        end
      end
    end
  end
end