fall_timer = new global.wait.Waiter(30)
regen_timer = new global.wait.Waiter(90)
start_scale = 0.2
expand_time = 15
expand_spd = (1 - start_scale) / expand_time

state = new StateMachine("idle")
state.add("idle", {
	enter: function(){
		image_xscale = start_scale
		image_yscale = start_scale
		
		sprite_index = spr_wall_fall
		image_index = 0
	},
	step: function(){
		image_xscale = approach(image_xscale, 1, expand_spd)
		image_yscale = approach(image_yscale, 1, expand_spd)
		
		if (place_meeting(x, y - 1, obj_player) && image_xscale == 1){
			state_switch("stressed")
			exit
		}
	}
})
state.add("stressed", {
	enter: function(){
		sprite_index = spr_wall_fall_stressed
		image_index = 0
	},
	step: function(){
		if (global.wait.do_wait(fall_timer)){
			global.wait.reset(fall_timer)
			
			array_delete(global.solids, array_find_index(global.solids, id), 1)
			
			state_switch("fallen")
			exit
		}
	}
})
state.add("fallen", {
	enter: function(){
		sprite_index = spr_wall_fall_fallen
	},
	step: function(){
		if (global.wait.do_wait(regen_timer) && !place_meeting(x, y, obj_player)){
			global.wait.reset(regen_timer)
			array_push(global.solids, id)
			state_switch("idle")
			exit
		}
		
		if (animation_end()) image_speed = 0
	},
	leave: function(){
		image_speed = 1
	}
})

