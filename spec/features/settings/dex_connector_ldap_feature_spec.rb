require "rails_helper"

# rubocop:disable RSpec/ExampleLength
# run in order to fix an issue with the `new_cert` test.
describe "Feature: LDAP connector settings", js: true do
  let!(:user) { create(:user) }
  let!(:dex_connector_ldap) { create(:dex_connector_ldap) }
  let!(:dex_connector_ldap2) { create(:dex_connector_ldap) }
  let!(:dex_connector_ldap3) { create(:dex_connector_ldap) }
  let(:admin_cert) { create(:certificate) }
  let(:admin_cert_text) { admin_cert.certificate.strip }
  let(:admin_cert_file) { to_file_fixture(admin_cert.certificate) }

  before do
    setup_done
    login_as user, scope: :user
  end

  describe "#index" do
    before do
      visit settings_dex_connector_ldaps_path
    end

    it "allows a user to delete an ldap connector" do
      expect(page).to have_content(dex_connector_ldap.name)
      accept_alert do
        find(".dex_connector_ldap#{dex_connector_ldap.id} .delete-btn").click
      end

      expect(page).to have_content("LDAP Connector was successfully removed.")
      expect(page).not_to have_content(dex_connector_ldap.name)
    end

    it "allows a user to go to an ldap connector's details page" do
      click_link(dex_connector_ldap.name)

      expect(page).to have_current_path(settings_dex_connector_ldap_path(dex_connector_ldap))
    end

    it "allows an user to go to an ldap connector's edit page" do
      find(".dex_connector_ldap#{dex_connector_ldap.id} .edit-btn").click

      expect(page).to have_current_path(edit_settings_dex_connector_ldap_path(dex_connector_ldap))
    end

    it "allows a user to go to the new ldap connector page" do
      click_link("Add LDAP connector")

      expect(page).to have_current_path(new_settings_dex_connector_ldap_path)
    end

    it "lists all the ldap connectors" do
      expect(page).to have_content(dex_connector_ldap.name)
      expect(page).to have_content(dex_connector_ldap2.name)
      expect(page).to have_content(dex_connector_ldap3.name)
    end
  end

  describe "#new" do
    before do
      visit new_settings_dex_connector_ldap_path
    end

    it "allows a user to create an ldap connector (w/ certificate)" do
      fill_in id: "dex_connector_ldap_name", with: "openldap"
      fill_in "Host", with: "ldaptest.com"
      fill_in "Port", with: "1234"
      fill_in "Identifying User Attribute", with: "pass"
      attach_file "Certificate", admin_cert_file.path
      fill_in id: "dex_connector_ldap_bind_dn", with: "cn=admin,dc=ldaptest,dc=com"
      fill_in id: "dex_connector_ldap_bind_pw", with: "pass"
      fill_in id: "dex_connector_ldap_user_attr_username", with: "username"
      fill_in id: "dex_connector_ldap_user_attr_email", with: "email@email.com"
      fill_in id: "dex_connector_ldap_user_attr_name", with: "name"
      fill_in id: "dex_connector_ldap_group_attr_name", with: "name"
      fill_in id: "dex_connector_ldap_group_base_dn", with: "bdn"
      fill_in id: "dex_connector_ldap_user_base_dn", with: "bdn"
      fill_in id: "dex_connector_ldap_user_filter", with: "filter"
      fill_in id: "dex_connector_ldap_group_filter", with: "filter"
      fill_in id: "dex_connector_ldap_group_attr_user", with: "user"
      fill_in id: "dex_connector_ldap_group_attr_group", with: "group"
      fill_in id: "dex_connector_ldap_user_attr_id", with: "uid"

      page.execute_script("$('#ldap_conn_save').removeProp('disabled')")
      click_button("Save")
      last_ldap_connector = DexConnectorLdap.last
      expect(page).to have_content(admin_cert_text)
      expect(page).to have_content("DexConnectorLdap was successfully created.")
      expect(page).to have_current_path(settings_dex_connector_ldap_path(last_ldap_connector))
    end

    it "shows an error message if model validation fails" do
      fill_in "Port", with: "AAA"
      attach_file "Certificate", admin_cert_file.path
      fill_in "Password", with: "pass"
      fill_in "Identifying User Attribute", with: "pass"
      fill_in id: "dex_connector_ldap_bind_dn", with: "cn=admin,dc=ldaptest,dc=com"
      fill_in id: "dex_connector_ldap_bind_pw", with: "pass"

      page.execute_script("$('#ldap_conn_save').removeProp('disabled')")
      click_button("Save")
      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Host can't be blank")
      expect(page).to have_content("Port is not a number")
    end

  end

  describe "#edit" do
    before do
      visit edit_settings_dex_connector_ldap_path(dex_connector_ldap)
    end

    it "allows a user to edit an ldap connector" do
      fill_in "Port", with: 626
      attach_file "Certificate", admin_cert_file.path
      page.execute_script("$('#ldap_conn_save').removeProp('disabled')")
      click_button("Save")

      expect(page).to have_content("DexConnectorLdap was successfully updated.")
    end

    it "shows an error message if model validation fails" do
      fill_in "Port", with: "AAA"
      attach_file "Certificate", admin_cert_file.path
      page.execute_script("$('#ldap_conn_save').removeProp('disabled')")
      click_button("Save")

      expect(page).to have_content("Port is not a number")
    end
  end

  # rubocop:disable RSpec/ExpectInHook
  describe "#new_save_disabled_by_change" do
    before do
      visit new_settings_dex_connector_ldap_path
      expect(page).to have_button("Save", disabled: true)

      # Test that we can enable the button
      page.execute_script("$('#ldap_conn_save').removeProp('disabled')")
      expect(page).to have_button("Save", disabled: false)
    end

    it "allows change of start_tls" do
      find("#dex_connector_ldap_start_tls_true_label").click
    end

    it "allows change of bind_anon" do
      find("#dex_connector_ldap_bind_anon_true_label").click
    end

    it "allows change of host" do
      fill_in "Host", with: "AAA"
    end

    it "allows change of port" do
      fill_in "Port", with: "AAA"
    end

    it "allows change certificate" do
      attach_file "Certificate", admin_cert_file.path
    end

    it "allows change of bind dn" do
      fill_in "dex_connector_ldap_bind_dn", with: "AAA"
    end

    it "allows change of password" do
      fill_in "dex_connector_ldap_bind_pw", with: "AAA"
    end

    it "allows change of user base dn" do
      fill_in "dex_connector_ldap_user_base_dn", with: "AAA"
    end

    it "allows change of user filter" do
      fill_in "dex_connector_ldap_user_filter", with: "AAA"
    end

    after do
      expect(page).to have_button("Save", disabled: true)
    end
  end
  # rubocop:enable RSpec/ExpectInHook

  describe "#show" do
    before do
      visit settings_dex_connector_ldap_path(dex_connector_ldap)
    end

    it "allows a user to delete an ldap connector" do
      accept_alert do
        click_on("Delete")
      end

      expect(page).not_to have_content(dex_connector_ldap.name)
      expect(page).to have_content("LDAP Connector was successfully removed.")
      expect(page).to have_current_path(settings_dex_connector_ldaps_path)
    end

    it "allows a user to go to an ldap connector's edit page" do
      click_on("Edit")

      expect(page).to have_current_path(edit_settings_dex_connector_ldap_path(dex_connector_ldap))
    end
  end
end
# rubocop:enable RSpec/ExampleLength
