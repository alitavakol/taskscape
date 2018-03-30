result = json.merge!(
  project.attributes.slice('id', 'archived', 'title', 'description', 'visibility')
  .merge(
    memberships: project.memberships.map { |membership| 
      membership.attributes.slice('id', 'member_id')
      .merge membership.member.attributes.slice('name', 'email')
      .merge(
        avatar: membership.member.avatar.url(:thumb),
        invitation_accepted: !membership.member.invited_to_sign_up? || membership.member.invitation_accepted?,
        editable: MembershipPolicy.new(@current_user, membership).destroy?
      )
    },

    tasks: project.tasks.map { |task| 
      task.attributes.slice('id', 'status', 'urgency', 'archived', 'x', 'y', 'color', 'effort', 'title', 'supertask_id', 'description', 'visibility', 'importance', 'due_date')
      .merge(
        assignments: task.assignments.map { |assignment| 
          assignment.attributes.slice('id', 'assignee_id')
          .merge assignment.assignee.attributes.slice('name')
          .merge avatar: assignment.assignee.avatar.url(:thumb)
        },
        editable: TaskPolicy.new(@current_user, task).update?
      )
    },

    editable: policy(project).update? # inform client-side code whether project attributes can be edited by current user or not
  )
)

# include supertask id only if user can see the supertask
if project.supertask_id && policy(project.superproject).show?
  result.merge! superproject: {id: project.superproject.id, title: project.superproject.title}
end

result