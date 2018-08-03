# Model that represents a dex authentication connector for OIDC
class DexConnectorOidc < ActiveRecord::Base
  self.table_name = "dex_connectors_oidc"
end
