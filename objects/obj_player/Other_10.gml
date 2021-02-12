///@desc METHOD EVENT
///@func move_n_collide()
move_n_collide = function(){
	if (place_meeting(x + hsp, y, obj_wall)){
		while (!place_meeting(x + sign(hsp), y, obj_wall)) x += sign(hsp)
		hsp = 0
	}
	x += hsp
	if (place_meeting(x, y + vsp, obj_wall)){
		while (!place_meeting(x, y + sign(vsp), obj_wall)) y += sign(vsp)
		vsp = 0
	}
	y += vsp
}

///@func change_hsp(hdir, accel, deccel)
change_hsp = function(_hdir, _accel_spd, _deccel_spd){
	if (KEY_RIGHT ^ KEY_LEFT){
		hsp = approach(hsp, _hdir * walksp, _accel_spd)
	}
	else hsp = approach(hsp, 0, _deccel_spd)
}

///@func on_ground()
on_ground = function(){
	return place_meeting(x, y + 1, obj_wall)
}

///@func apply_dash(enum dir, spd)
apply_dash = function(_dir, _spd){
	hsp = lengthdir_x(_spd, _dir)
	vsp = lengthdir_y(_spd, _dir)
}

///@func on_wall
on_wall = function(){
	return place_meeting(x + 1, y, obj_wall) - place_meeting(x - 1, y, obj_wall)
}

///@func can_jump()
can_jump = function(){
	return on_ground() && KEY_JUMP_PRESSED
}