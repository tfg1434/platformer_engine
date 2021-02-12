state.step()

if (on_ground()) can_dash = true

if (KEY_RIGHT) dir = DIR.E
if (KEY_LEFT) dir = DIR.W
if (KEY_LOOK_UP) dir = DIR.N
if (KEY_LOOK_DOWN) dir = DIR.S
if (KEY_RIGHT && KEY_LOOK_UP) dir = DIR.NE
if (KEY_LEFT && KEY_LOOK_UP) dir = DIR.NW
if (KEY_RIGHT && KEY_LOOK_DOWN) dir = DIR.SE
if (KEY_LEFT && KEY_LOOK_DOWN) dir = DIR.SW

if !(KEY_RIGHT || KEY_LEFT || KEY_LOOK_UP || KEY_LOOK_DOWN) dir = image_xscale == 1 ? DIR.E : DIR.W