//forgiveness mechanics!
/*
Coyote time
Input buffering - store an input for a set length of time
until it becomes valid, then execute it (use input buffering wherever you can)
All actions should have early input forgiveness and late input forgiveness

Hitbox pinching - when you are moving, base collisions off a pinched version
of the hitbox
Then, push the player up out of the wall using the normal hitbox
Can also use hitbox pinching when jumping;
- pinch it when you go up so you can go inside the wall up
- normal hitbox when falling so you can land easily
Slide over corners when you barely clip them
*/

//polish le dash (look at the source)

event_user(0);

run_accel_t = 0;
run_accel_t_max = 6;
run_accel_curve = TwerpType.in_sine;

run_deccel_t = 0;
run_deccel_t_max = 3;
run_deccel_curve = TwerpType.in_sine;
run_spd = 3;
air_fric = 0.65; //acceldeccel gets multiplied by this in air

max_fall = 3.5; //max gravity speed

hsp = 0;
vsp = 0;
hfrac = 0;
vfrac = 0;

var calc_j = function(_h, _t) {
	var ret = {};
	ret.grv = (2 * _h) / power(_t, 2);
	ret.vel = -abs(ret.grv) * _t;
	return ret;
}
//not necessarily accurate
//if you can figure out a way to make it accurate
//make an issue
var max_j_height = 2.5 * sprite_height;
var max_time_to_apex = 15;
var calc_max = calc_j(max_j_height, max_time_to_apex);
grv = calc_max.grv;
j_vel = calc_max.vel;
stop_grv = grv + 0.75; //https://youtu.be/hG9SzQxaCm8?list=LL&t=1066

climb_spd = -0.85;
climb_start_spd = -0.55;
climb_down_spd = 1.6;
climb_down_start_spd = 1.2; 
climb_up_t = 0;
climb_up_t_max = 10;
climb_down_t = 0;
climb_down_t_max = 10;
climb_up_curve = TwerpType.in_sine;
climb_down_curve = TwerpType.in_sine;

climb_slip_spd = 0.6;

climb_hop_hsp = 0.85;
climb_hop_vsp = -3.2;
climb_hop_wait_h = 0;
climb_hop_wait_hsp = 0;

wall_slide_max = 70;
wall_slide_t = 0;
wall_slide_start_spd = 1.3;
wall_slide_curve = TwerpType.in_cubic;

wall_jump_hsp = run_spd;

hand_off = 6; //difference between bbox bottom and hands


common_jump = function() {
	move_h();
	update_facing();
			
	if (input_check(VERB.JUMP))
		apply_grv();
	else
		apply_grv(stop_grv);
}

state = new SnowState("idle")
	#region idle
	.add("idle", {
		step: function() {
			if (check_state.run()) {
				state.change("run");
				return;
			}
			if (check_state.rising()) {
				state.change("rising");
				return;
			}
			if (check_state.climb()) {
				state.change("climb");
				return;
			}
			if (!on_ground()) {
				state.change("falling");
				return;
			}
			
			move_h();
		}
	})
	#endregion
	#region run
	.add("run", {
		step: function() {
			if (check_state.wall_slide()) {
				state.change("wall_slide");
				return;
			}
			if (check_state.rising()) {
				state.change("rising");
				return;
			}
			if (check_state.climb()) {
				state.change("climb");
				return;
			}
			if (check_state.idle()) {
				state.change("idle");
				return;
			}
				
			
			move_h();
			update_facing();
				
				
			apply_grv();
			move_collide();
		}
	})
	#endregion
	#region rising
	.add("rising", {
		enter: function() {
			do_jump();
		},
		step: function() {
			if (check_state.falling()) {
				state.change("falling");
				return;
			}
			if (check_state.climb()) {
				state.change("climb");
				return;
			}
			
			
			common_jump();
			
				
			move_collide();
		}
	})
	#endregion
	#region falling
	.add("falling", {
		step: function() {
			if (check_state.wall_slide()) {
				state.change("wall_slide");
				return;
			}
			if (check_state.run()) {
				state.change("run");
				return;
			}
			if (check_state.idle()) {
				state.change("idle");
				return;
			}
			if (check_state.climb()) {
				state.change("climb");
				return;
			}
				
			move_h();
			update_facing();
				
			apply_grv();
			move_collide();
		}
	})
	#endregion
	#region wall_slide
	.add("wall_slide", {
		enter: function() {
			wall_slide_t = 0;
			vsp = wall_slide_start_spd;
		},
		step: function() {
			if (check_state.idle() || on_ground()) {
				state.change("idle");
				return;
			}
			if (HDIR != on_wall() && !input_check(VERB.DOWN)) {
				state.change("falling");
				return;
			}
			if (check_state.climb() && !input_check(VERB.DOWN)) {
				state.change("climb");
				return;
			}
			if (on_wall() == 0) {
				state.change("falling");
				return;
			}
			
			vsp = twerp(wall_slide_curve, wall_slide_start_spd, 
				max_fall, wall_slide_t / wall_slide_max);
			wall_slide_t++;
			
			
			update_facing(HDIR);
			
			
			move_collide();
		},
		leave: function() {
			wall_slide_t = 0;
		}
	})
	#endregion
	#region climb
	.add("climb", {
		enter: function() {
			update_facing(on_wall());
			vsp = climb_start_spd;
			climb_up_t = 0;
		},
		step: function() {
			if (check_state.climb_hop()) {
				state.change("climb_hop");
				return;
			}
			if (check_state.climb_still() || on_ceil()) {
				state.change("climb_still");
				return;
			}
			if (check_state.climb_down()) {
				state.change("climb_down");
				return;
			}
			if (!input_check(VERB.CLIMB)) {
				state.change("falling");
				return;
			}
			if (check_state.climb_jump()) {
				state.change("climb_jump");
				return;
			}
			
			
			if (not_check_hands())
				vsp = climb_slip_spd;
			else {
				vsp = twerp(climb_up_curve, climb_start_spd, 
					climb_spd, climb_up_t / climb_up_t_max);
				climb_up_t++;
			}
			
			
				
				
			move_collide();
		},
		leave: function() {
			climb_up_t = 0;	
		},
	})
	#endregion
	#region climb_still
	.add("climb_still", {
		step: function() {
			if (!input_check(VERB.CLIMB)) {
				if (check_state.wall_slide()) {
					state.change("wall_slide");
					return;
				}
				if (check_state.falling()) {
					state.change("falling");
					return;
				}
				
				state.change("idle");
				return;
			}
			if (input_check(VERB.UP) && !on_ceil()) {
				state.change("climb");
				return;
			}
			if (input_check(VERB.DOWN) && !on_ground()) {
				state.change("climb_down");
				return;
			}
			if (check_state.climb_jump()) {
				state.change("climb_jump");
				return;
			}
			
			
			update_facing(HDIR != 0 ? HDIR : on_wall());
		}
	})
	#endregion
	#region climb_down
	.add("climb_down", {
		enter: function() {
			climb_down_t = 0;
			update_facing(on_wall());
			vsp = climb_down_start_spd;
		},
		step: function() {
			if (on_ground()) {
				state.change("climb_still");
				return;
			}
			if (check_state.climb() && !input_check(VERB.DOWN)) {
				state.change("climb");
				return;
			}
			if (!input_check(VERB.CLIMB)) {
				state.change("falling");
				return;
			}
			if (check_state.climb_jump()) {
				state.change("climb_jump");
				return;
			}
			
			
			vsp = twerp(climb_down_curve, climb_down_start_spd, 
				climb_down_spd, climb_down_t / climb_down_t_max);
			climb_down_t++;
			
			
			move_collide();
		},
		leave: function() {
			climb_down_t = 0;
		},
	})
	#endregion
	#region climb_hop
	.add("climb_hop", {
		enter: function() {
			climb_hop_wait_h = on_wall();
			climb_hop_wait_hsp = on_wall() * climb_hop_hsp;
			vsp = climb_hop_vsp;
		},
		step: function() {
			if (check_state.idle()) {
				state.change("idle");
				return;
			}
			if (check_state.run()) {
				state.change("run");	
			}
			
			if (climb_hop_wait_h != 0) {
				if (sign(hsp) == -climb_hop_wait_h || vsp > 0)
					climb_hop_wait_h = 0;
				else if (!place_meeting(x + climb_hop_wait_h, y, obj_wall)) {
					hsp = climb_hop_wait_hsp;
					climb_hop_wait_h = 0;
				}
			}
			
			
			vsp += grv;
			
			move_collide();
		}
	})
	#endregion
	#region climb_jump
	.add_child("rising", "climb_jump", {
		step: function() {
			if (vsp >= 0) {
				if (input_check(VERB.CLIMB) && on_wall() != 0) {
					state.change("climb_still");
					return;
				}
				
				state.change("falling");
				return;
			}
			
			
			common_jump();
			
			move_collide();
		}
	});
	#endregion

#region ============ 
#endregion

#region check_state
check_state = {
	idle: method(self, function() {
		return on_ground() && HDIR == 0;
	}),
	run: method(self, function() {
		return on_ground() && HDIR != 0;
	}),
	rising: method(self, function() {
		return input_check_pressed(VERB.JUMP);
	}),
	falling: method(self, function() {
		return vsp > 0;
	}),
	wall_slide: method(self, function() {
		return HDIR != 0 && HDIR == on_wall();
	}),
	climb: method(self, function() {
		return on_wall() != 0 && input_check(VERB.CLIMB);
	}),
	climb_still: method(self, function() {
		return on_wall() != 0 && input_check(VERB.CLIMB) 
			&& VDIR == 0 && check_hands();
	}),
	climb_down: method(self, function() {
		return input_check(VERB.DOWN) && !on_ground();
	}),
	climb_hop: method(self, function() {
		return not_check_hands() && vsp < 0 && VDIR == 1;
	}),
	climb_jump: method(self, function() {
		return input_check_pressed(VERB.JUMP);
	}),
	wall_jump: method(self, function() {
		var climb_wall_jump = on_wall() != 0 
			&& input_check(VERB.CLIMB) && HDIR == -on_wall();
	}),
}
#endregion
	
///@func do_jump({ hsp=0 ; vsp=j_vel })
do_jump = function(_args={ hsp: 0, vsp: j_vel, }) {
	hsp += _args.hsp * image_xscale;
	vsp = _args.vsp;
}

///@func not_check_hands(add_y=0)
not_check_hands = function(_add_y=0) {
	return !check_hands(_add_y);
}

///@func check_hands(add_y=0)
check_hands = function(_add_y=0) {
	var facing = on_wall();
	if (facing == 0)
		throw "can't call check_hands when not on wall";
	return place_meeting(x + facing, y - hand_off + _add_y, obj_wall);
}

move_collide = function() {
	hfrac += hsp;
	vfrac += vsp;
	var hsp_new = round(hfrac);
	var vsp_new = round(vfrac);
	hfrac -= hsp_new;
	vfrac -= vsp_new;
	
	repeat (abs(hsp_new)) {
	    if (!place_meeting(x + sign(hsp_new), y, obj_wall)) {
	        x += sign(hsp_new);
	    } else {
	        hsp = 0;
	        break;
	    }
	}

	repeat (abs(vsp_new)) {
	    if (!place_meeting(x, y + sign(vsp_new), obj_wall)) {
	        y += sign(vsp_new);
	    } else {
	        vsp = 0;
	        break;
	    }
	}
}

on_ground = function() {
	return place_meeting(x, y + 1, obj_wall);	
}

on_ceil = function() {
	return place_meeting(x, y - 1, obj_wall);
}

move_h = function() {
	static prev_hdir = 0;
	
	var mult = on_ground() ? 1 : air_fric;
	
	if (HDIR != 0) {
		if (HDIR == -prev_hdir) {
			run_accel_t = 0;
			run_deccel_t = 0;
		}
		
		run_accel_t = approach(run_accel_t, run_accel_t_max, mult);
		run_deccel_t = approach(run_deccel_t, 0, mult);
	} else {
		run_accel_t = approach(run_accel_t, 0, mult);
		run_deccel_t = approach(run_deccel_t, run_deccel_t_max, mult);	
	}
			
	if (HDIR != 0)
		//accelerate
		hsp = twerp(run_accel_curve, 0, run_spd * HDIR, run_accel_t / run_accel_t_max);
	else
		//decellerate
		hsp = twerp(run_deccel_curve, run_spd * sign(hsp), 0, run_deccel_t / run_deccel_t_max);
		
	prev_hdir = HDIR;
}

on_wall = function() {
	return place_meeting(x + 1, y, obj_wall) - place_meeting(x - 1, y, obj_wall);
}

on_corner = function() {
	return place_meeting(x + 1, y + 1, obj_wall) - place_meeting(x - 1, y + 1, obj_wall);
}

///@func apply_grv(inc)
apply_grv = function(_inc = grv) {
	if (!on_ground()) 
		vsp = approach(vsp, max_fall, _inc);
}

update_facing = function(_to=hsp) {
	if (_to != 0) image_xscale = sign(_to);
}
