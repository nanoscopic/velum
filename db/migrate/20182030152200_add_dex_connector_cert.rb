class AddDexConnectorCert < ActiveRecord::Migration
  def change
    add_column :dex_connectors_ldap, :certificate, :text, after: :group_attr_name
  end
end