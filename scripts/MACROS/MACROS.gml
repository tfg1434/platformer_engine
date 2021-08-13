//Syntax Extensions, Courtesy of Kat
#macro ignore if (true) { } else
#macro print                           \
    for (var print_value;; {           \
      show_debug_message(print_value); \
      break;                           \
    }) print_value =

//------------------------

#macro FPS game_get_speed(gamespeed_fps)
#macro WIN_W window_get_width()
#macro WIN_H window_get_height()
#macro round round_not_bankers

#macro HDIR (input_check(VERB.RIGHT) - input_check(VERB.LEFT))
#macro VDIR (input_check(VERB.UP) - input_check(VERB.DOWN))





