class MembershipsController < ApplicationController
  before_action :set_membership, only: [:show, :destroy]

  # GET /memberships/1
  # GET /memberships/1.json
  def show
    authorize @membership
    respond_to :json
  end

  # POST /memberships
  # POST /memberships.json
  def create
    @membership = Membership.new(membership_params)
    @membership.creator = current_user
    authorize @membership

    respond_to do |format|
      if @membership.save
        format.json { render :show, status: :created, location: @membership }
      else
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.json
  def destroy
    authorize @membership

    @membership.destroy

    respond_to do |format|
      format.html { redirect_to memberships_url, notice: 'Membership was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_membership
      @membership = Membership.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def membership_params
      params.require(:membership).permit(:project_id, :member_id, :creator_id)
    end
end
