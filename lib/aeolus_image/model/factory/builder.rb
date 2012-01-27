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
      class Builder < Base
        ACTIVE_STATES = ['FAILED', 'COMPLETED']

        def find_active_build(build_id, target)
          builders.find {|b| !ACTIVE_STATES.include?(b.status) && b.operation == 'build' && b.build_id == build_id && b.target == target}
        end

        def find_active_build_by_imageid(image_id, target)
          builders.find {|b| !ACTIVE_STATES.include?(b.status) && b.operation == 'build' && b.image_id == image_id && b.target == target}
        end

        def find_active_push(target_image_id, provider, account)
          builders.find {|b| !ACTIVE_STATES.include?(b.status) && b.operation == 'push' && b.target_image_id == target_image_id &&
                              b.provider == provider && b.provider_account_identifier == account}
        end
      end
    end
  end
end
