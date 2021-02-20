if (global.wait.do_wait(till_decay_timer)) image_alpha -= fade_rate

if (image_alpha == 0) instance_destroy()
