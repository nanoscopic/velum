require "velum/salt"
# SaltController holds methods for triggering updates of nodes
class SaltController < ApplicationController
  skip_before_action :redirect_to_setup

  def update
    Orchestration.run kind: :upgrade

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :ok }
    end
  end

  def accept_minion
    Velum::Salt.accept_minion(minion_id: minion_id_param)

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :ok }
    end
  end

  def remove_minion
    Minion.mark_pending_removal(minion_ids: minion_id_param)
    Velum::Salt.remove_minion(minion_id: minion_id_param)

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :ok }
    end
  end

  def reject_minion
    Velum::Salt.reject_minion(minion_id: minion_id_param)

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :ok }
    end
  end

  def minion_id_param
    params.require(:minion_id)
  end
end
