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

event_user(0)

t = 0

hsp = 0
vsp = 0
vsp_max = 4

j_height = 48
time_to_apex = 18
//solve for grv dynamically
grv = (2 * j_height) / power(time_to_apex, 2)
j_velocity = -abs(grv) * time_to_apex
stopping_grv = grv + 0.35

can_jump_timer = 0
coyote_time = 15

//input buffering times (frames)
jump_buffer_time = 6
dash_buffer_time = 6
wall_jump_buffer = 6

accel_time = 6 //in frames
deccel_time = 3
walksp = 2.75

dashsp = 8
can_dash = false
dash_trail_timer = new global.wait.Waiter(3)
dash_dust_timer = new global.wait.Waiter(1)

wall_grv = 0.1

wall_jump_hsp = 3
wall_jump_h = 48
wall_jump_time_to_apex = 18
wall_jump_grv = (2 * wall_jump_h) / power(wall_jump_time_to_apex, 2)
wall_jump_j_vel = -abs(grv) * wall_jump_time_to_apex

wall_vsp_max = 1
wall_dust_timer = new global.wait.Waiter(3)

//squish squash uwu
xscale = 1
yscale = 1
squish_xscale_jump_rise = 0.9
squish_yscale_jump_rise = 1.25
squish_time_jump_rise = 10
squish_time_fall = 5

state = new StateMachine("idle")
state.add("idle", {
	enter: function(){
		hsp = 0
		vsp = 0
		xscale = 1
		yscale = 1
		
		image_index = 0
	},
	step: function(){
		var _hdir = input_check(VERB.RIGHT) - input_check(VERB.LEFT)
		if (_hdir != 0){
			state_switch("walk")
			return
		}
		
		if (check_jump()){
			state_switch("rising")
			return
		}
		
		if (!on_ground()){
			state_switch("falling")
			return
		}
		else can_dash = true
		
		if (check_dash()){
			state_switch("dash")
			return
		}
		
		move_n_collide()
	}
})
state.add("walk", {
	enter: function(){
		image_index = 0
	},
	step: function(){
		var _hdir = input_check(VERB.RIGHT) - input_check(VERB.LEFT)
		if (_hdir == 0 && hsp == 0){
			state_switch("idle")
			return
		}
		
		if (_hdir != 0) image_xscale = _hdir
		walk()
		
		if (check_jump()){
			state_switch("rising")
			return
		}
		
		if (!on_ground()){
			state_switch("falling")
			return
		}
		else can_dash = true
		
		if (check_dash()){
			state_switch("dash")
			return
		}
		
		mask_index = spr_player_walk_pinched
		move_n_collide()
		mask_index = spr_player_idle
		while (place_meeting_array(x, y, global.solids)) y--
	}
})
state.add("rising", {
	enter: function(){
		t = 0
		
		vsp = j_velocity
		
		xscale = 1
		yscale = 1
	},
	step: function(){
		t++
		
		xscale = lerp(1, squish_xscale_jump_rise, t / squish_time_jump_rise)
		yscale = lerp(1, squish_yscale_jump_rise, t / squish_time_jump_rise)
		
		var _hdir = input_check(VERB.RIGHT) - input_check(VERB.LEFT)
		if (_hdir != 0) image_xscale = _hdir
		
		walk()
		
		//if rising and not pressing jump
		if (!input_check(VERB.JUMP)){
			vsp += stopping_grv
			if (vsp > vsp_max) vsp = vsp_max
		} 
		else{
			vsp += grv
			if (vsp > vsp_max) vsp = vsp_max
		}
		
		if (vsp >= 0){
			state_switch("falling")
			return
		}
		
		if (on_wall() != 0 && input_check_pressed(VERB.JUMP)){
			state_switch("wall_jump")
			input_consume(VERB.JUMP)
			move_n_collide()
			return
		}
		
		if (check_dash()){
			state_switch("dash")
			return
		}
		
		mask_index = spr_player_jump_pinched
		move_n_collide()
		mask_index = spr_player_idle
		while (place_meeting_array(x, y, global.solids)) y--
	}
})
state.add("falling", {
	enter: function(){
		t = 0
		
		start_xscale = xscale
		start_yscale = yscale
		
		image_index = 0
	},
	step: function(){
		if (xscale != 1 || yscale != 1){
			t++
		}
		
		xscale = lerp(start_xscale, 1, t / squish_time_fall)
		yscale = lerp(start_yscale, 1, t / squish_time_fall)
		
		//Coyote time
		if (state.get_previous() == "walk" || state.get_previous() == "idle"){
			if (++can_jump_timer < coyote_time && input_check_pressed(VERB.UP)){
				state_switch("rising")
				return
			}
		}
		
		var _hdir = input_check(VERB.RIGHT) - input_check(VERB.LEFT)
		if (_hdir != 0) image_xscale = _hdir
		
		walk()
		
		vsp += grv
		if (vsp > vsp_max) vsp = vsp_max
		
		if (on_ground()){
			can_dash = true
			
			if (_hdir == 0){
				state_switch("idle")
				return
			}
			else{
				state_switch("walk")
				return
			}
		}
		
		if (check_dash()){
			state_switch("dash")
			return
		}
		
		if (on_wall() != 0){
			if (input_check_pressed(VERB.JUMP)){
				state_switch("wall_jump")
				input_consume(VERB.JUMP)
				move_n_collide()
				return
			}
			if (_hdir == on_wall()){
				state_switch("wall_slide")
				return
			}
		}
		
		mask_index = spr_player_jump_pinched
		move_n_collide()
		mask_index = spr_player_idle
		while (place_meeting_array(x, y, global.solids)) y--
	},
	leave: function(){
		can_jump_timer = 0
		t = 0
	}
})
state.add("dash", {
	//should swap the timer out with an animation end
	//give it a very small hitbox so that you can avoid enemies and sail pass walls
	enter: function(){
		image_index = 0
		can_dash = false
		apply_dash(dir(), dashsp)
		temp_timer = new global.wait.Waiter(11)
	},
	step: function(){
		if (global.wait.do_wait(dash_trail_timer)){
			global.wait.reset(dash_trail_timer)
			instance_create_layer(x, y, "Instances", obj_dash_trail)
		}
		
		if (global.wait.do_wait(dash_dust_timer)){
			global.wait.reset(dash_dust_timer)
			
			//with (instance_create_layer(x + random_range(-sprite_width / 2, sprite_width / 2), y + random_range(-sprite_height / 2, sprite_height / 2), "Instances", obj_dash_dust)){
			with (instance_create_layer(x + random_range(-sprite_width / 2, sprite_width / 2), y - random(sprite_height), "Instances", obj_dash_dust)){
				hspeed = random_range(-0.1, 0.1)
				vspeed = random_range(-0.1, 0.1)
			}
		}
		
		if (global.wait.do_wait(temp_timer)){
			hsp = clamp(hsp, -walksp, walksp)
			if (vsp != 0) vsp = -vsp_max
			
			if (on_ground()){
				state_switch("walk")
				return
			}
			else{
				state_switch("falling")
				return
			}
		}
		
		move_n_collide()
	}
})
state.add("wall_slide", {
	enter: function(){
		image_index = 0
		if (state.get_previous() == "wall_jump") vsp = 0
	},
	step: function(){
		if (input_check_pressed(VERB.JUMP, 0, wall_jump_buffer)){
			state_switch("wall_jump")
			input_consume(VERB.JUMP)
			move_n_collide()
			return
		}
		if (on_ground()){
			can_dash = true
			state_switch("idle")
			return
		}
		if (on_wall() == 0){
			state_switch("falling")
			return
		}
		image_xscale = on_wall()
		
		var _hdir = input_check(VERB.RIGHT) - input_check(VERB.LEFT)
		
		if (on_wall() == _hdir && on_wall() != 0){
			vsp += wall_grv
			if (vsp > wall_vsp_max) vsp = wall_vsp_max
			
			//--particle effects--
			var _side = on_wall() == 1 ? bbox_right : bbox_left
			
			if (vsp > 0){
				if (global.wait.do_wait(wall_dust_timer)){
					global.wait.reset(wall_dust_timer)
					
					with (instance_create_layer(_side, y - random(sprite_height), "Instances", obj_dust)){
						hspeed = other.on_wall() * random_range(0.4, 0.6)
					}
				}
			}
			//--------------------
		}
		else{
			state_switch("falling")
		}
		
		move_n_collide()
	}
})
state.add("wall_jump", {
	enter: function(){
		//wall_jump_timer = new global.wait.Waiter(20)
		
		hsp = -on_wall() * wall_jump_hsp
		vsp = wall_jump_j_vel
		
		var _side = on_wall() == 1 ? bbox_right : bbox_left
		
		repeat(10){
			with (instance_create_layer(_side, bbox_bottom, "Instances", obj_dust)){
				hspeed = random_range(-other.on_wall() * 0.5, other.on_wall() * 0.1)
				vspeed = random_range(-0.2, 0.2)
			}
		}
	},
	step: function(){
		vsp += wall_jump_grv
		
		move_n_collide()
		
		if (on_wall() != 0){
			state_switch("wall_slide")
			return
		}
		
		if (vsp >= 0){
			state_switch("falling")
			return
		}
		
		if (on_ground()){
			state_switch("walk")
			return
		}
		
		//if (global.wait.do_wait(wall_jump_timer) && !on_ground()){
		//	global.wait.once(wall_jump_timer)
		//	state_switch("falling")
		//	return
		//}
		//else if (global.wait.do_wait(wall_jump_timer) && on_ground()){
		//	state_switch("walk")
		//	return
		//}
	}
})
/**/