module Aeolus
  module Image
    module Factory
      class Builder < Base
        ACTIVE_STATES = ['FAILED', 'COMPLETED']

        def find_active_build(build_id, target)
          builders.find {|b| !ACTIVE_STATES.include?(b.status) && b.operation == 'build' && b.build_id == build_id}
        end

        def find_active_push(target_image_id, provider, account)
          builders.find {|b| !ACTIVE_STATES.include?(b.status) && b.operation == 'push' && b.target_image_id == target_image_id &&
                              b.provider == provider && b.provider_account_identifier == account}
        end
      end
    end
  end
end
