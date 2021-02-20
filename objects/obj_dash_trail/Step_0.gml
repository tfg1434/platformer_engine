image_xscale = wave(0.85, 1, 5, 0)
image_yscale = wave(0.85, 1, 5, 0)

if (global.wait.do_wait(till_decay_timer)) image_alpha -= fade_rate

if (image_alpha == 0) instance_destroy()
