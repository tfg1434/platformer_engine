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

event_user(0)

hsp = 0
vsp = 0
vsp_max = 4
dir = 0

j_height = 48
time_to_apex = 18
j_damping = 0.8
//solve for grv dynamically
grv = (2 * j_height) / power(time_to_apex, 2)
j_velocity = -abs(grv) * time_to_apex
stopping_grv = grv + 0.45
can_jump_timer = 0
coyote_time = 15

accel_time = 6 //in frames
deccel_time = 3
walksp = 3

dashsp = 10
dash_deccel_time = 5
can_dash = false

wall_grv = 0.1
wall_jump_hsp = 5
wall_jump_vsp = 5
wall_vsp_max = 1
wall_climb_vsp = 4
wall_climb_accel = 5//in frames

state = new StateMachine("idle")
state.add("idle", {
	enter: function(){
		hsp = 0
		vsp = 0
		
		image_index = 0
	},
	step: function(){
		var _hdir = KEY_RIGHT - KEY_LEFT
		if (_hdir != 0){
			state_switch("walk")
			return
		}
		
		if (KEY_JUMP && can_jump()){
			state_switch("rising")
			return
		}
		
		if (!on_ground()){
			state_switch("falling")
			return
		}
		
		if (KEY_DASH && can_dash){
			state_switch("dash")
			return
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
		var _hdir = KEY_RIGHT - KEY_LEFT
		if (_hdir == 0 && hsp == 0){
			state_switch("idle")
			return
		}
		
		if (_hdir != 0) image_xscale = _hdir
		change_hsp(_hdir, accel_spd, deccel_spd)
		
		if (KEY_JUMP && can_jump()){
			state_switch("rising")
			return
		}
		
		if (!on_ground()){
			state_switch("falling")
			return
		}
		
		if (KEY_DASH && can_dash){
			state_switch("dash")
			return
		}
		
		//mask_index = spr_player_walk_pinched
		move_n_collide()
		//mask_index = spr_player_idle
		//while (place_meeting(x, y, obj_wall)) y--
	}
})
state.add("rising", {
	enter: function(){
		vsp += j_velocity
		
		accel_spd = walksp / accel_time
		deccel_spd = walksp / deccel_time
	},
	step: function(){
		//if (place_meeting(x, y + vsp, obj_wall)) mask_index = spr_player_jump_pinched
		
		var _hdir = KEY_RIGHT - KEY_LEFT
		if (_hdir != 0) image_xscale = _hdir
		
		change_hsp(_hdir, accel_spd, deccel_spd)
		
		//if rising and not pressing jump
		if (!KEY_JUMP){
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
			
			if (on_wall != 0){
				state_switch("wall_slide")
				return
			}
		}
		
		if (KEY_DASH && can_dash){
			state_switch("dash")
			return
		}
		
		move_n_collide()
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
			if (++can_jump_timer < coyote_time && KEY_JUMP_PRESSED){
				state_switch("rising")
				return
			}
		}
		
		var _hdir = KEY_RIGHT - KEY_LEFT
		if (_hdir != 0) image_xscale = _hdir
		
		change_hsp(_hdir, accel_spd, deccel_spd)
		
		vsp += grv
		if (vsp > vsp_max) vsp = vsp_max
		
		if (on_ground()){
			if (_hdir == 0){
				state_switch("idle")
				return
			}
			else{
				state_switch("walk")
				return
			}
		}
		
		if (KEY_DASH && can_dash){
			state_switch("dash")
			return
		}
		
		if (on_wall() != 0){
			state_switch("wall_slide")
			return
		}
		
		move_n_collide()
	},
	leave: function(){
		can_jump_timer = 0
	}
})
state.add("dash", {
	//should swap the timer out with an animation end
	enter: function(){
		image_index = 0
		can_dash = false
		apply_dash(dir, dashsp)
		temp_timer = new global.wait.Waiter(8)
	},
	step: function(){
		if (global.wait.do_wait(temp_timer)){
			hsp = 0
			vsp = 0
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
		vsp = 0
	},
	step: function(){
		if (KEY_JUMP_PRESSED){
			state_switch("wall_jump")
			move_n_collide()
			return
		}
		if (on_ground()){
			state_switch("idle")
			return
		}
		if (on_wall() == 0){
			state_switch("falling")
			return
		}
		image_xscale = on_wall()
		
		var _hdir = KEY_RIGHT - KEY_LEFT
		if (on_wall() == _hdir && on_wall() != 0){
			vsp += wall_grv
			if (vsp > wall_vsp_max) vsp = wall_vsp_max
		}
		else{
			vsp += grv
			if (vsp > vsp_max) vsp = vsp_max
		}
		
		move_n_collide()
	}
})
state.add("wall_jump", {
	enter: function(){
		hsp = -on_wall() * wall_jump_hsp
		vsp = -wall_jump_vsp
		
		jump_timer = new global.wait.Waiter(10)
	},
	step: function(){
		if (on_wall() != 0){
			state_switch("wall_slide")
			return
		}
		
		if (global.wait.do_wait(jump_timer) && !on_ground()){
			global.wait.once(jump_timer)
			vsp *= 0.3
			state_switch("falling")
			return
		}
		else if (global.wait.do_wait(jump_timer) && on_ground()){
			state_switch("walk")
			return
		}
		
		move_n_collide()
	}
})
