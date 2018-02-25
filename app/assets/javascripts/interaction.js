// allow more than one interaction at a time
interact.maxInteractions(Infinity);

// target elements with the "draggable" class
interact('.draggable').draggable({
	// allow dragging of multple elements at the same time
	max: Infinity,
	inertia: false,

	onstart: function (e) {
		dragging_view = $(e.target).data('view_object');
		dragging_view.on_drag_start();

		// var svg = $(e.target).closest('svg')[0];

		// v = svg.getAttribute('viewBox').split(' ');
		// x = parseFloat(v[0]);
		// y = parseFloat(v[1]);
		// w = parseFloat(v[2]);
		// h = parseFloat(v[3]);

		// var r = svg.getBoundingClientRect();
		// drag_scale = w / (r.right - r.left);
	},

	// call this function on every dragmove e
	onmove: function (e) {
		// dragging_view.on_drag(e.dx * drag_scale, e.dy * drag_scale);
		dragging_view.on_drag(e.dx, e.dy);
	},

	// call this function on every dragend e
	onend: function (e) {
		dragging_view.on_drag_end();
	}
});
