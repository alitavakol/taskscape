json.merge!(
  membership.attributes.slice('id', 'member_id', 'project_id')
  .merge membership.member.attributes.slice('name', 'email')
)
