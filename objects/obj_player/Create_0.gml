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

hsp = 0;
vsp = 0;

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

wall_slide_spd = 1.6;

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
		}
	})
	.add("run", {
		step: function() {
			if (check_state.rising()) {
				state.change("rising");
				return;
			}
				
			
			move_h();
				
				
			vsp += grv;
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
			
			
			move_h();
			
			if (input_check(VERB.JUMP))
				vsp += grv;
			else
				vsp += stop_grv;
			
				
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
				
			move_h();
				
			vsp += grv;
			move_collide();
		}
	})
	.add("wall_slide", {
		enter: function() {
			vsp = wall_slide_spd;	
		},
		step: function() {
			if (check_state.idle()) {
				state.change("idle");
				return;
			}
			if (HDIR != on_wall()) {
				state.change("falling");
				return;
			}
			
			move_collide();
		}
	});

check_state = {
	idle: method(self, function() {
		return on_ground();
	}),
	run: method(self, function() {
		return HDIR != 0;
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
}
	
move_collide = function() {
	repeat (abs(hsp)) {
	    if (!place_meeting(x + sign(hsp), y, obj_wall)) {
	        x += sign(hsp);
	    } else {
	        hsp = 0;
	        break;
	    }
	}

	repeat (abs(vsp)) {
	    if (!place_meeting(x, y + sign(vsp), obj_wall)) {
	        y += sign(vsp);
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

