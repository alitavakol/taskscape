result = json.merge! project.attrs_recursive.merge(
	editable: policy(project).update? # inform client-side code whether project attributes can be edited by current user or not
)

# include supertask id only if user can see the supertask
if project.supertask_id && policy(project.superproject).show?
	result.merge! superproject: {id: project.superproject.id, title: project.superproject.title}
end

result