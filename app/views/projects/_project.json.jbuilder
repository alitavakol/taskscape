json.merge! project.attrs_recursive
	.merge(editable: policy(project).update?) # inform client-side code whether project attributes can be edited by current user or not
