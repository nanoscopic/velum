require "base64"

module Velum
  # This class offers the integration between ruby and the Saltstack API.
  module Dex
    class << self
      def ldap_connectors_as_pillar
        ldap_connectors = []
        begin
          ldap_connectors = DexConnectorLdap.all.map do |con|
            {
              "type"            => "ldap",
              "id"              => con.id,
              "name"            => con.name,

              # Combine host and port since they ultimately
              #   feed into a single line of config for dex
              "server"          => "#{con.host}:#{con.port}",
              "start_tls"       => con.start_tls,
              "root_ca_data"    => Base64.encode64(con.certificate.try(:certificate) || ""),
              "bind"            => generate_bind_block(con), # Place basic bind information together
              "user"            => generate_user_block(con), # Place user stuff together
              "group"           => generate_group_block(con), # Place group stuff together
              "username_prompt" => con.username_prompt
            }
          end
        rescue ActiveRecord::StatementInvalid => e
          # Silently ignore non existence of table so that cluster can start without it
          # :nocov:
          raise e unless e.message.include? "dex_connectors_ldap' doesn't exist"
          # :nocov:
        end
        ldap_connectors
      end

      private

      def generate_user_block(con)
        user = {}
        user[:base_dn] = con.user_base_dn
        user[:filter]  = con.user_filter
        user_attr_map = user[:attr_map] = {}
        user_attr_map[:username] = con.user_attr_username
        user_attr_map[:id]       = con.user_attr_id
        user_attr_map[:email]    = con.user_attr_email
        user_attr_map[:name]     = con.user_attr_name
        user
      end

      def generate_bind_block(con)
        bind = {}
        if con.bind_anon
          bind[:anonymous] = true
        else
          bind[:anonymous] = false
          bind[:dn] = con.bind_dn
          bind[:pw] = con.bind_pw
        end
        bind
      end

      def generate_group_block(con)
        group = {}
        group[:base_dn] = con.group_base_dn
        group[:filter] = con.group_filter
        group_attr_map = group[:attr_map] = {}
        group_attr_map[:user]  = con.group_attr_user
        group_attr_map[:group] = con.group_attr_group
        group_attr_map[:name]  = con.group_attr_name
        group
      end
    end
  end
end
