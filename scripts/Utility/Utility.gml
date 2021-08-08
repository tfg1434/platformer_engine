/// @func array_create_nd(size1, size2,...)
function array_create_nd() {
    if (argument_count == 0) return 0;
    
    var _array = array_create(argument[0]),
        _args  = array_create(argument_count-1),
        _i;
        
    _i = 0; repeat(argument_count-1) {
        _args[@ _i] = argument[_i+1];
        ++_i;
    }
    
    _i = 0; repeat(argument[0]) {
        _array[@ _i] = script_execute_ext(array_create_nd, _args);
        ++_i;
    }
    
    return _array;
}

/// @func		approach(val1, val2, amount)
/// @param		{real}	 val1				Initial value
/// @param		{real}	 val2				Target value
/// @param		{real}	 amount				Increment (or Decrement)
/// @returns	{real}						Changed value
/// @author		Meseta
function approach(_val1, _val2, _inc) {
	if (_inc < 0) throw("approach: amount is negative")
	return (_val1 + clamp(_val2-_val1, -_inc, _inc));
}

///@func chance(percent)
///@param {real} percent			percentage on scale 0-1
///@returns {bool} chance			i can't think of what to write here
function chance(_percent){
	//chance(0.7) returns true 70% of time
	return _percent > random(1)
}

/// @func		animation_end()
/// @returns	{bool}						Whether sprite_index has finished animating or not
/// @author		Minty Python
function animation_end() {
	return (image_index + image_speed*sprite_get_speed(sprite_index)/(sprite_get_speed_type(sprite_index)==spritespeed_framespergameframe? 1 : game_get_speed(gamespeed_fps)) >= image_number);	
}

/// @func draw_set_text(colour, font, halign, valign)
///@param {real}			colour
///@param {real}			font
///@param {real}			halign
///@param {real}			valign
///@returns					N/A
function draw_set_text(_colour, _font, _halign, _valign){
	draw_set_colour(_colour)
	draw_set_font(_font)
	draw_set_halign(_halign)
	draw_set_valign(_valign)
}

/// @func string_wrap(string, max_width)
///@param {string} string			string to be wrapped
///@param {real} max_width			string WIDTH (not length) to wrap after
///@returns {string}				wrapped string
function str_wrap(_str, _max_width){
	var _str_len = string_length(_str)
	var _last_space = 1
	
	var _count = 1
	var _sub_str
	
	repeat (_str_len){
		_sub_str = string_copy(_str, 1, _count)
		if (string_char_at(_str, _count) == " ") _last_space = _count
		
		if (string_width(_sub_str) > _max_width){
			_str = string_delete(_str, _last_space, 1)
			_str = string_insert("\n", _str, _last_space)
		}
		_count++
	}
	return _str
}

/// @func nine_slice_box_stretched(sprite, x1, y1, x2, y2, index)
///@arg sprite
///@arg x1 left
///@arg y1 top
///@arg x2 rigt
///@arg y2 bottom
///@arg index image index
function nine_slice_box_stretched(sprite, x1, y1, x2, y2, index){
	var _size = sprite_get_width(argument0) / 3;
	var _x1 = argument1;
	var _y1 = argument2;
	var _x2 = argument3;
	var _y2 = argument4;
	var _index = argument5;
	var _w = _x2 - _x1;
	var _h = _y2 - _y1

	//MIDDLE
	draw_sprite_part_ext(argument0, _index, _size, _size, 1, 1, _x1 + _size,_y1 + _size, _w - (_size * 2), _h - (_size * 2), c_white,1);

	//CORNERS
	//TOP LEFT
	draw_sprite_part(argument0, _index, 0, 0, _size, _size, _x1, _y1);
	//TOP RIGHT
	draw_sprite_part(argument0, _index, _size * 2, 0, _size, _size, _x1 + _w - _size, _y1);
	//BOTTOM LEFT
	draw_sprite_part(argument0, _index, 0, _size * 2, _size, _size, _x1, _y1 + _h - _size);
	//BOTTOM RIGHT
	draw_sprite_part(argument0, _index, _size * 2, _size * 2, _size, _size, _x1 + _w - _size, _y1 + _h - _size);

	//EDGES
	//LEFT
	draw_sprite_part_ext(argument0, _index, 0, _size, _size, 1, _x1, _y1 + _size, 1, _h - (_size * 2), c_white, 1);
	//RIGHT
	draw_sprite_part_ext(argument0, _index, _size * 2, _size, _size, 1, _x1 + _w - _size, _y1 + _size, 1, _h - (_size * 2), c_white, 1);
	//TOP
	draw_sprite_part_ext(argument0, _index, _size, 0, 1, _size, _x1 + _size, _y1, _w - (_size * 2), 1, c_white, 1);
	//BOTTOM
	draw_sprite_part_ext(argument0, _index, _size, _size * 2, 1, _size, _x1 + _size, _y1 + _h - (_size), _w - (_size * 2), 1, c_white,1);
}

///@func str_split(string, delimiter)
///@author YellowAfterLife
function str_split(s, d){
    if (0) return argument[0]
    var r = []
    var p = string_pos(d, s), o = 1;
    var dl = string_length(d);
    if (dl) while (p) {
        array_push(r, string_copy(s, o, p - o));
        o = p + dl;
        p = string_pos_ext(d, s, o);
    }
    array_push(r, string_delete(s, 1, o - 1));
    return r;
}

function wave(from, to, duration, offset){
	//Wave(from, to, duration, offset)
 
	// Returns a value that will wave back and forth between [from-to] over [duration] seconds
	// Examples
	//      image_angle = Wave(-45,45,1,0)  -> rock back and forth 90 degrees in a second
	//      x = Wave(-10,10,0.25,0)         -> move left and right quickly
 
	// Or here is a fun one! Make an object be all squishy!! ^u^
	//      image_xscale = Wave(0.5, 2.0, 1.0, 0.0)
	//      image_yscale = Wave(2.0, 0.5, 1.0, 0.0)
 
	a4 = (argument1 - argument0) * 0.5;
	return argument0 + a4 + sin((((current_time * 0.001) + argument2 * argument3) / argument2) * (pi*2)) * a4;
}

/// @func frames_to_ms(frames)
function frames_to_ms(_f){
	return 1000 * _f / FPS
}

///@func round_not_bankers(val)
function round_not_bankers(_val){
	var num = _val div 1
	return _val mod 1 >= 0.5 ? num + 1 : num
}

///@func strpolate(string)
//function strpolate(_str) {
//	while (true) {
//		var open_brace = string_pos("{", _str);
//		if (open_brace == -1) return _str;
		
//		var close_brace = string_pos("}", _str);
//		var key = slice(_str, open_brace + 1, close_brace - 1);
//		var lexeme = "{" + key + "}";
		
//		_str = string_replace(_str, lexeme, string(self[$ key]));
//	}
//}

function slice(value, from, to, step){
///@description slice(value,[from],[to],[step])

static string_concat  = function(string, value)	 { return string+value }
static ds_list_concat = function(ds_list, value) { ds_list_add(ds_list, value); return ds_list }

static list = ds_list_create()

var _is_string = is_string(value)
var _is_array = is_array(value)
var _is_ds_list = is_real(value)

var output
var len
var access
var concat

//bleck
if _is_string		
{
	output = ""
	len = string_length(value)
	access = string_char_at
	concat = string_concat
}
else if _is_array	
{
	output = list
	len = array_length(value)
	access = array_get
	concat = ds_list_concat
}
else if _is_ds_list
{
	output = list
	len = ds_list_size(value)
	access = ds_list_find_value
	concat = ds_list_concat
}
else throw "Attempting to slice unsupported datatype"

if is_undefined(from)	from = _is_string
if is_undefined(to)		to = len+_is_string
if is_undefined(step)	step = 1

else if step == 0 throw "Step cannot be zero"

var dir = sign(step) != -1

var _from = ((sign(from) == -1) ? (len+from+1+_is_string) : from)
var _to	= ((sign(to) == -1) ? (len+to+1+_is_string) : to) - (step < -1 or not (_is_string or dir))

show_debug_message(_from)
show_debug_message(_to)

if not dir // kinda prefer this to adding to the control statements, they're already so unreadable
{
	var _ = _from // eugh
	_from = _to
	_to = _
}

var output

if step == 1 and not _is_ds_list // Basically the same as the copy functions, so we can just use those
{
	if _is_string
	{
		output = string_copy(value, _from, _to-_from)
	}
	else //if _is_array
	{
		output = array_create(min(_to-_from, len))
		array_copy(output, 0, value, _from, _to-_from)
	}
}
else 
{
	var item_count = 0
	
	for(var i = _from; (dir) ? (i <= _to-1) : (i >= _to); i += step)
	{	
		output = concat(output, access(value, i))
		item_count ++
	}

	if _is_array or _is_ds_list
	{
		output = array_create(item_count)
		
		for(var i = 0; i <= item_count-1; i++)
		{
			output[@ i] = list[| i]
		}
		ds_list_clear(list)
	}
}

return output
}
