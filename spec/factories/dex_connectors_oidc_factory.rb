FactoryGirl.define do
  factory :dex_connector_ldap, class: DexConnectorLdap do
    sequence(:name) { |n| "OIDC Server #{n}" }
    sequence(:provider_url) { |n| "http://oidc_host_#{n}.com" }

    client_id "client"
    client_secret "client_secret"
    callback_url "http://127.0.0.1:5556"
    basic_auth true
  end
end
