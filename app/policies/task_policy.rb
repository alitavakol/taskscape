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
    weak_show? && ( @current_user.vip? || update? ) # only if user is vip or permitted to update a task, they can see it
  end

  def weak_show? # if true, user can show task as locked
    @task.visible? || @current_user.can_see_project?(@task.project)
  end

  def create?
    @current_user.full_access?(@task.project)
  end

  def edit?
    @current_user.admin?
  end

  # relax authorization policy, because restricted members can change x, y, r
  def weak_update?
    @current_user.admin? || @current_user.participations.include?(@task.project)
  end

  def update?
    @task.assignees.include?(@current_user) || @current_user.full_access?(@task.project)
  end

  def destroy?
    @current_user.full_access?(@task.project)
  end
end
