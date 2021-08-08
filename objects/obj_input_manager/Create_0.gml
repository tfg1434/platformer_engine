//Controls
enum VERB{
	JUMP,
	RIGHT,
	LEFT,
	DASH,
	UP,
	DOWN
}

//Bind keyboard to verb
input_default_key(ord("Z"), VERB.JUMP)
input_default_key(vk_right, VERB.RIGHT)
input_default_key(vk_left, VERB.LEFT)
input_default_key(ord("X"), VERB.DASH)
input_default_key(vk_up, VERB.UP)
input_default_key(vk_down, VERB.DOWN)

input_player_source_set(INPUT_SOURCE.KEYBOARD_AND_MOUSE)


input_consume(all)
