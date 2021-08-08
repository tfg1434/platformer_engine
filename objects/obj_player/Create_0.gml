//forgiveness mechanics!
/*
Coyote time
Input buffering - store an input for a set length of time
until it becomes valid, then execute it (use input buffering wherever you can)
All actions should have early input forgiveness and late input forgiveness

Hitbox pinching - when you are moving, base collisions off a pinched version
of the hitbox
Then, push the player up out of the wall using the normal hitbox
Can also use hitbox pinching when jumping;
- pinch it when you go up so you can go inside the wall up
- normal hitbox when falling so you can land easily
Slide over corners when you barely clip them
*/

//polish le dash (look at the source)

event_user(0);

accel_t = 0;
accel_max = 6;
accel_curve = TwerpType.in_sine;

deccel_t = 0;
deccel_max = 3;
deccel_curve = TwerpType.in_sine;

run_spd = 3;

hsp = 0;
vsp = 0;

j_height = 48;
time_to_apex = 18;
//solve for grv dynamically
grv = (2 * j_height) / power(time_to_apex, 2);
j_velocity = -abs(grv) * time_to_apex;

state = new SnowState("run")
	.add("idle", {
	
	})
	.add("run", {
		step: function() {
			if (HDIR != 0) {
				accel_t = approach(accel_t, accel_max, 1);
				deccel_t = approach(deccel_t, 0, 1);
			} else {
				accel_t = approach(accel_t, 0, 1);
				deccel_t = approach(deccel_t, deccel_max, 1);	
			}
			
			if (HDIR != 0)
				//accelerate
				hsp = twerp(accel_curve, 0, run_spd * HDIR, accel_t / accel_max);
			else
				//decellerate
				hsp = twerp(deccel_curve, run_spd * sign(hsp), 0, deccel_t / deccel_max);
		}
	});