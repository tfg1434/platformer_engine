//Syntax Extensions, Courtesy of Kat
#macro ignore if (true) { } else
#macro print                           \
    for (var print_value;; {           \
      show_debug_message(print_value); \
      break;                           \
    }) print_value =

//------------------------

#macro FPS 60
#macro WALL_SIZE 16

//Controls
#macro KEY_JUMP keyboard_check(ord("Z"))
#macro KEY_JUMP_PRESSED keyboard_check_pressed(ord("Z"))
#macro KEY_RIGHT keyboard_check(vk_right)
#macro KEY_LEFT keyboard_check(vk_left)

#macro KEY_DASH keyboard_check_pressed(ord("X"))
#macro KEY_LOOK_UP keyboard_check(vk_up)
#macro KEY_LOOK_DOWN keyboard_check(vk_down)

enum DIR{
    N = 90,
    NE = 45,
    E = 0,
    SE = 315,
    S = 270,
    SW = 225,
    W = 180,
    NW = 135
}


