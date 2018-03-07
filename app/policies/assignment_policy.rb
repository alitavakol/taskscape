class AssignmentPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @assignment = model
  end

  def index?
    @current_user
  end

  def new?
    @current_user
  end

  def show?
    self.create?
  end

  def update?
    self.create? && self.destroy?
  end

  def create?
    # user can assign someone to do the referenced task only if she can view the supertask (project) that this task is in
    ProjectPolicy.new(@current_user, Task.find(@assignment.task_id).supertask).show?
  end

  def destroy?
    self.create?
  end
end
