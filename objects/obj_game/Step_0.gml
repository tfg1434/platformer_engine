if (prev_window_size.w != WIN_W || prev_window_size.h != WIN_H){
	//Call the window resize event for all instances.
	with (all) {
		event_perform(ev_draw, 65);
	}
}


prev_window_size.w = WIN_W
prev_window_size.h = WIN_H


