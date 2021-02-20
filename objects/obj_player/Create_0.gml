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

state = new StateMachine("idle")
state.add("idle", {
	enter: function(){
		hsp = 0
		vsp = 0
		
		image_index = 0
	},
	step: function(){
		var _hdir = input_check(VERB.RIGHT) - input_check(VERB.LEFT)
		if (_hdir != 0){
			state_switch("walk")
			exit
		}
		
		if (check_jump()){
			state_switch("rising")
			exit
		}
		
		if (!on_ground()){
			state_switch("falling")
			exit
		}
		else can_dash = true
		
		if (check_dash()){
			state_switch("dash")
			exit
		}
		
		move_n_collide()
	}
})
state.add("walk", {
	enter: function(){
		image_index = 0
		
		accel_spd = walksp / accel_time
		deccel_spd = walksp / deccel_time
	},
	step: function(){
		var _hdir = input_check(VERB.RIGHT) - input_check(VERB.LEFT)
		if (_hdir == 0 && hsp == 0){
			state_switch("idle")
			exit
		}
		
		if (_hdir != 0) image_xscale = _hdir
		walk()
		
		if (check_jump()){
			state_switch("rising")
			exit
		}
		
		if (!on_ground()){
			state_switch("falling")
			exit
		}
		else can_dash = true
		
		if (check_dash()){
			state_switch("dash")
			exit
		}
		
		mask_index = spr_player_walk_pinched
		move_n_collide()
		mask_index = spr_player_idle
		while (place_meeting_array(x, y, global.solids)) y--
	}
})
state.add("rising", {
	enter: function(){
		vsp = j_velocity
		
		accel_spd = walksp / accel_time
		deccel_spd = walksp / deccel_time
	},
	step: function(){
		//if (place_meeting(x, y + vsp, obj_wall)) mask_index = spr_player_jump_pinched
		
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
			exit
		}
		
		if (on_wall() != 0 && input_check_pressed(VERB.JUMP)){
			state_switch("wall_jump")
			input_consume(VERB.JUMP)
			move_n_collide()
			exit
		}
		
		if (check_dash()){
			state_switch("dash")
			exit
		}
		
		mask_index = spr_player_jump_pinched
		move_n_collide()
		mask_index = spr_player_idle
		while (place_meeting_array(x, y, global.solids)) y--
	}
})
state.add("falling", {
	enter: function(){
		image_index = 0
		
		accel_spd = walksp / accel_time
		deccel_spd = walksp / deccel_time
		
		//mask_index = spr_player_idle
		//var _wall = instance_place(x, y, obj_wall)
		//if (_wall != noone){
		//	var _side = sign((_wall.x + sprite_get_width(spr_wall) / 2) - x) //1 = left, -1 = right
		//	while (place_meeting(x, y, obj_wall)) x -= _side
		//}
	},
	step: function(){
		//Coyote time
		if (state.get_previous() == "walk" || state.get_previous() == "idle"){
			if (++can_jump_timer < coyote_time && input_check_pressed(VERB.UP)){
				state_switch("rising")
				exit
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
				exit
			}
			else{
				state_switch("walk")
				exit
			}
		}
		
		if (check_dash()){
			state_switch("dash")
			exit
		}
		
		if (on_wall() != 0){
			if (input_check_pressed(VERB.JUMP)){
				state_switch("wall_jump")
				input_consume(VERB.JUMP)
				move_n_collide()
				exit
			}
			if (_hdir == on_wall()){
				state_switch("wall_slide")
				exit
			}
		}
		
		mask_index = spr_player_jump_pinched
		move_n_collide()
		mask_index = spr_player_idle
		while (place_meeting_array(x, y, global.solids)) y--
	},
	leave: function(){
		can_jump_timer = 0
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
			
			with (instance_create_layer(x + random_range(-sprite_width / 2, sprite_width / 2), y + random_range(-sprite_height / 2, sprite_height / 2), "Instances", obj_dash_dust)){
				hspeed = random_range(-0.1, 0.1)
				vspeed = random_range(-0.1, 0.1)
			}
		}
		
		if (global.wait.do_wait(temp_timer)){
			hsp = clamp(hsp, -walksp, walksp)
			if (vsp != 0) vsp = -vsp_max
			
			if (on_ground()){
				state_switch("walk")
				exit
			}
			else{
				state_switch("falling")
				exit
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
			exit
		}
		if (on_ground()){
			can_dash = true
			state_switch("idle")
			exit
		}
		if (on_wall() == 0){
			state_switch("falling")
			exit
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
					
					with (instance_create_layer(_side, y + random_range(-sprite_height / 2, sprite_height / 2), "Instances", obj_dust)){
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
			exit
		}
		
		if (vsp >= 0){
			state_switch("falling")
			exit
		}
		
		if (on_ground()){
			state_switch("walk")
			exit
		}
		
		//if (global.wait.do_wait(wall_jump_timer) && !on_ground()){
		//	global.wait.once(wall_jump_timer)
		//	state_switch("falling")
		//	exit
		//}
		//else if (global.wait.do_wait(wall_jump_timer) && on_ground()){
		//	state_switch("walk")
		//	exit
		//}
	}
})
/**/