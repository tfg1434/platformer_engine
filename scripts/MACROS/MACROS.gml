//Syntax Extensions, Courtesy of Kat
#macro ignore if (true) { } else
#macro print                           \
    for (var print_value;; {           \
      show_debug_message(print_value); \
      break;                           \
    }) print_value =

//------------------------

#macro FPS 60


//Controls
#macro KEY_JUMP keyboard_check(vk_space) || keyboard_check(ord("W"))
#macro KEY_JUMP_PRESSED keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("W"))
#macro KEY_RIGHT keyboard_check(ord("D"))
#macro KEY_LEFT keyboard_check(ord("A"))
#macro KEY_DASH keyboard_check_pressed(vk_shift)


