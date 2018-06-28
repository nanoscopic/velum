# Settings::DexConnectorOidcsController is responsible to manage requests
# related to OIDC connectors.
class Settings::DexConnectorOidcsController < SettingsController
  before_action :set_data_holder, except: [:index, :new, :create]
  
  def index
    @oidc_connectors = DexConnectorOidc.all
  end

  def new
    @data_holder = data_holder_type.new
  end

  def edit
  end
  
  def create
    @data_holder = data_holder_type.new
    
    ActiveRecord::Base.transaction do
      @data_holder.save!
    end
    
    redirect_to settings_dex_connector_oidcs_path, notice: "#{@data_holder.class} was successfully created."
  rescue ActiveRecord::RecordInvalid
    render action: :new, status: :unprocessable_entity
  end
  
  def destroy
    redirect_to settings_dex_connector_oidc_path,
                notice: "OIDC Connector was successfully removed."
  end
  
  def update
    ActiveRecord::Base.transaction do
      @data_holder.update_attributes!(data_holder_update_params)
    end

    redirect_to [:settings, @data_holder],
                notice: "#{@data_holder.class} was successfully updated."
  rescue ActiveRecord::RecordInvalid
    render action: :edit, status: :unprocessable_entity
  end

  protected

  def data_holder_type
    DexConnectorOidc
  end

  def data_holder_params
    oidc_connector_params
  end

  def data_holder_update_params
    oidc_connector_params
  end
  
  private

  def certificate_param
    oidc_connector_params
  end
  
  def oidc_connector_params
    params.require(:dex_connector_oidc).permit(:name, :provider_url, :client_id,
                                               :client_secret, :callback_url, :basic_auth)
  end
  
  def set_data_holder
    @data_holder = data_holder_type.find(params[:id])
  end
end
