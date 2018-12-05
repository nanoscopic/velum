require "velum/salt"

# Settings::AuthConfig handles settings that apply to all external auth connectors
class Settings::AuthConfigController < SettingsController
  def index
    set_instance_variables
  end

  def create
    @errors = Pillar.apply audit_params
    if @errors.empty?
      Velum::Salt.call(targets: "admin", action: "saltutil.refresh_pillar")
      Velum::Salt.apply_state(targets: "admin", state: "addons/dex")
      redirect_to settings_auth_config_index_path,
        notice: "Auth config settings successfully saved."
    else
      set_instance_variables
      render action: :index, status: :unprocessable_entity
    end
  end

  private

  def set_instance_variables
    @ldap_admin_group_name = Pillar.value(pillar: :ldap_admin_group_name) || ""
    @ldap_admin_group_dn = Pillar.value(pillar: :ldap_admin_group_dn) || ""
    #@audit_enabled = Pillar.value(pillar: :api_audit_log_enabled) || "false"
    #@maxsize = Pillar.value(pillar: :api_audit_log_maxsize) || 10
    #@maxage = Pillar.value(pillar: :api_audit_log_maxage) || 15
    #@maxbackup = Pillar.value(pillar: :api_audit_log_maxbackup) || 20
    #@policy = Pillar.value(pillar: :api_audit_log_policy) || ""
  end

  def audit_params
    ret = {}
    params.require(
      :auth_config
    ).permit(
      :ldap_admin_group_name
    #  :enabled,
    #  :maxage,
    #  :maxsize,
    #  :maxbackup,
    #  :policy
    #
    ).each do |k, v|
      if k == "ldap_admin_group_name"
        ret["ldap_admin_group_dn".to_sym] = "#{v},ou=Groups,dc=infra,dc=caasp,dc=local"
        prevName = Pillar.value(pillar: :ldap_admin_group_name)
        
        User.update_ldap_admin_group_name( prevName, v )
      end
      ret["#{k}".to_sym] = v
    end
    ret
  end
end