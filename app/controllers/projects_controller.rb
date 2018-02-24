class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    authorize Project

    case current_user.role
    when 'user'
      # select publicly visible projects
      public_projects = Project.where(visibility: Project.visibilities[:public_project])

      # select projects that this user is a member of, 
      # and are top-level (having no parent project),
      # or those not-top-level tasks that user is a member of, but not a member of their parent project
      user_projects = current_user.projects.select { |p| p.private_project? && !current_user.project_ids.include?(p.supertask_id) }

      @projects = user_projects + public_projects

    when 'vip'
      # select all top-level tasks (projects)
      @projects = Project.where(supertask_id: nil)

    when 'admin'
      # select all top-level tasks (projects)
      @projects = Project.where(supertask_id: nil)
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    authorize @project

    respond_to do |format|
      format.json
      format.html { redirect_to project_path(@project, format: :json) }
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    @project.creator = current_user
    authorize @project

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    authorize @project

    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    authorize @project

    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:title, :description, :visibility, :status, :due_date, :creator_id, :archived)
    end
end
