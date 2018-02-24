class TaskPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @task = model
  end

  def index?
    @current_user
  end

  def show?
    self.create?
  end

  def create?
    # user can create a task in a project (supertask) only if she can see the supertask
    @current_user.admin? || (Project.exists?(@task.supertask_id) && ProjectPolicy.new(@current_user, Project.find(@task.supertask_id)).show?)
  end

  def edit?
    self.create?
  end

  def update?
    self.create?
  end

  def destroy?
    self.create?
  end

  def new?
    @current_user
  end
end
