///@desc METHOD EVENT
///@func move_n_collide()
move_n_collide = function(){
	// if (place_meeting(x + hsp, y, obj_wall)){
	// 	while (!place_meeting(x + sign(hsp), y, obj_wall)) x += sign(hsp)
	// 	hsp = 0
	// }
	// x += hsp
	// if (place_meeting(x, y + vsp, obj_wall)){
	// 	while (!place_meeting(x, y + sign(vsp), obj_wall)) y += sign(vsp)
	// 	vsp = 0
	// }
	// y += vsp
	
	repeat(abs(hsp)) {
		if (!place_meeting(x + sign(hsp), y, obj_wall)) {
	        x += sign(hsp);
	    } else {
	        hsp = 0;
	        break;
	    }
	}
	
	repeat(abs(vsp)) {
	    if (!place_meeting(x, y + sign(vsp), obj_wall)) {
	        y += sign(vsp);
	    } else {
	        vsp = 0;
	        break;
	    }
	}
}

///@func change_hsp(hdir, accel, deccel)
change_hsp = function(_hdir, _accel_spd, _deccel_spd){
	if (input_check(VERB.RIGHT) ^ input_check(VERB.LEFT)){
		hsp = approach(hsp, _hdir * walksp, _accel_spd)
	}
	else hsp = approach(hsp, 0, _deccel_spd)
}

///@func on_ground()
on_ground = function(){
	return place_meeting(x, y + 1, obj_wall)
}

///@func apply_dash(dir, spd)
apply_dash = function(_dir, _spd){
	hsp = lengthdir_x(_spd, _dir)
	vsp = lengthdir_y(_spd, _dir)
}

///@func on_wall
on_wall = function(){
	return place_meeting(x + 1, y, obj_wall) - place_meeting(x - 1, y, obj_wall)
}

///@func check_jump()
check_jump = function(){
	return on_ground() && input_check_pressed(VERB.JUMP, 0, jump_buffer_time)
}

///@func check_dash()
check_dash = function(){
	return can_dash && input_check_pressed(VERB.DASH, 0, dash_buffer_time)
}

///@func dir()
dir = function(){
	//REMEMBER: ENUMS ARE INT64!!!!
	var _dir = point_direction(0, 0, input_check(VERB.RIGHT) - input_check(VERB.LEFT), input_check(VERB.DOWN) - input_check(VERB.UP))
	if (!input_check([VERB.RIGHT, VERB.LEFT, VERB.UP, VERB.DOWN])) _dir = image_xscale == 1 ? 0 : 180
	return _dir
}
