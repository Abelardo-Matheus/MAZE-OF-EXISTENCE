if (global.level_up == true) {
    alarm[0]++;
    exit;
}
if (keyboard_check_pressed(vk_enter)) {
    level_up();
}

if (keyboard_check_pressed(ord("Y"))) {
	global.sair = true;
    room_goto(Fase_vamp);
}







