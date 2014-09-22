module Doorkeeper
  module OAuth
    module Authorization
      class Token
        attr_accessor :pre_auth, :resource_owner, :token

        def initialize(pre_auth, resource_owner)
          @pre_auth       = pre_auth
          @resource_owner = resource_owner
        end

        def issue_token
          @token ||= AccessToken.find_or_create_for(
            pre_auth.client,
            resource_owner.id,
            pre_auth.scopes,
            expiration,
            false
          )
        end

        def native_redirect
          {
            controller: 'doorkeeper/token_info',
            action: :show,
            access_token: token.token
          }
        end

        def configuration
          Doorkeeper.configuration
        end

        def custom_access_token_expiration
          configuration.
            custom_access_token_expiration.
            call(pre_auth.client)
        end

        def expiration
          custom_access_token_expiration ||
            configuration.access_token_expires_in
        end
      end
    end
  end
end
