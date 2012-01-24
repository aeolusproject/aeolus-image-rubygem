#
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
#
module Aeolus
  module Image
    module Factory
      class TargetImage < Base
        attr_accessor :target

        def self.status(id)
          begin
            builder = Aeolus::Image::Factory::Builder.find(id)
            if builder.operation == "build"
              builder.status
            else
              nil
            end
          rescue ActiveResource::ResourceNotFound
            nil
          end
        end

        def target
          begin
            @target = @target.nil? ? Aeolus::Image::Factory::Builder.find(id).target : @target
          rescue ActiveResource::ResourceNotFound
            nil
          end
        end
      end
    end
  end
end
