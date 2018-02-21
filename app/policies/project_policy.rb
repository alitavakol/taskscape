class ProjectPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @project = model
  end

  def index?
    @current_user
  end

  def show?
    @project.members.include?(@current_user) || @current_user.admin?
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
