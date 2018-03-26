class ProjectPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @project = model
  end

  def index?
    @current_user
  end

  # user can see the project only if she is a member of that project, or she can see its super-project at some level
  def show?
    @project.members.include?(@current_user) || (@project.supertask_id && ProjectPolicy.new(@current_user, @project.superproject).show?) || @project.public_project? || @current_user.admin? || @current_user.vip?
  end

  def create?
    @current_user
  end

  def edit?
    @current_user.admin? || @current_user == @project.creator
  end

  def update?
    @current_user.admin? || @current_user == @project.creator
  end

  def destroy?
    @current_user.admin? || @current_user == @project.creator
  end

  def new?
    @current_user
  end
end
