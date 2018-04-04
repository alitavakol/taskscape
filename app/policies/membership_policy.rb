class MembershipPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @membership = model
  end

  def index?
    @current_user
  end

  def new?
    @current_user
  end

  def create?
    # user can create membership only if she can edit referenced project
    ProjectPolicy.new(@current_user, Project.find(@membership.project_id)).update?
  end

  def destroy?
    @current_user.id != @membership.member_id && self.create?
  end
end
