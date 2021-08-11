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

accel_t = 0;
accel_max = 6;
accel_curve = TwerpType.in_sine;

deccel_t = 0;
deccel_max = 3;
deccel_curve = TwerpType.in_sine;

run_spd = 3;
max_grv = 3.5; //max gravity speed

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

wall_slide_spd = 1.6; //actually climbdown speed

climb_spd = -0.85;

climb_hop_hsp = 0.7;
climb_hop_vsp = -2.0;

state = new SnowState("idle")
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
		}
	})
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
	.add("rising", {
		enter: function() {
			vsp = j_vel;	
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
			
			
			move_h();
			update_facing();
			
			if (input_check(VERB.JUMP))
				apply_grv();
			else
				apply_grv(stop_grv);
			
				
			move_collide();
		}
	})
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
	.add("wall_slide", {
		enter: function() {
			vsp = wall_slide_spd;	
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
			
			
			update_facing(HDIR);
			
			
			move_collide();
		}
	})
	.add("climb", {
		step: function() {			
			if (!place_meeting(x + image_xscale, y, obj_wall)) {
				if (vsp < 0) {
					state.change("climb_hop");
					return;
				}
			}
			
			
			if (check_state.idle() && !input_check(VERB.CLIMB)) {
				state.change("idle");
				return;
			}
			if (on_wall() == 0 || !input_check(VERB.CLIMB)) {
				state.change("falling");
				return;
			}
			if (input_check(VERB.DOWN)) {
				state.change("wall_slide");
				return;
			}
			
			
			vsp = 0;
			if (input_check(VERB.UP))
				vsp = climb_spd;
				
			
			
			update_facing(HDIR);
				
				
			move_collide();
		}
	})
	.add("climb_hop", {
		enter: function() {
			hsp = (place_meeting(x + 1, y + 1, obj_wall) - place_meeting(x - 1, y + 1, obj_wall)) * climb_hop_hsp;
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
			
			vsp += grv;
			
			move_collide();
		}
	});

check_state = {
	idle: method(self, function() {
		return on_ground() && HDIR == 0;
	}),
	run: method(self, function() {
		return on_ground () && HDIR != 0;
	}),
	rising: method(self, function() {
		return input_check_pressed(VERB.JUMP());
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

move_h = function() {
	if (HDIR != 0) {
		accel_t = approach(accel_t, accel_max, 1);
		deccel_t = approach(deccel_t, 0, 1);
	} else {
		accel_t = approach(accel_t, 0, 1);
		deccel_t = approach(deccel_t, deccel_max, 1);	
	}
			
	if (HDIR != 0)
		//accelerate
		hsp = twerp(accel_curve, 0, run_spd * HDIR, accel_t / accel_max);
	else
		//decellerate
		hsp = twerp(deccel_curve, run_spd * sign(hsp), 0, deccel_t / deccel_max);	
}

on_wall = function() {
	return place_meeting(x + 1, y, obj_wall) - place_meeting(x - 1, y, obj_wall);
}

///@func apply_grv(inc)
apply_grv = function(_inc = grv) {
	if (!on_ground()) 
		vsp = approach(vsp, max_grv, _inc);
}

update_facing = function(_to=hsp) {
	if (_to != 0) image_xscale = sign(_to);
}
