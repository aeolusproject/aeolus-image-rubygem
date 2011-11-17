module Aeolus
  module Image
    module Factory
      class TargetImage < Base
        def self.status(id)
          begin
            Aeolus::Image::Factory::Builder.find(id).status
          rescue ActiveResource::ResourceNotFound
            nil
          end
        end
      end
    end
  end
end