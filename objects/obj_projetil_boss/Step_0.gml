// feather disable GM1041
// feather disable GM1049
// feather disable GM2017
// feather disable GM1063
// --- Bosses da infância (scr_boss_infancia) ---
if (espera > 0) {
    espera -= 1;
    if (espera <= 0) { direction = point_direction(x, y, alvo_x, alvo_y); speed = spd_apos; }
}
if (gira == -1) image_angle = direction; else if (gira > 0) image_angle += gira;
if (vida_frames > 0) {
    vida_frames -= 1;
    if (vida_frames <= 0) { instance_destroy(); exit; }
}

if(real(seguidor)){
// feather disable once GM1041
if (!instance_exists(target)) {
    // Se o alvo não existir mais, destrói o projétil
    instance_destroy();
} else {
    // Ajusta a direção do projétil para seguir o alvo
    var _dir = point_direction(x, y, target.x, target.y);
    direction = _dir;

    // Move o projétil na direção do alvo
    motion_add(direction, speed);

    // Checa a colisão com o jogador (ou outro alvo)
	var _target_inst = target;
	if (is_string(target)) _target_inst = asset_get_index(target);
	
    if (place_meeting(x, y, _target_inst)) {
        // Aplica o dano ao jogador
        var _dmg = damage;
        with (_target_inst) {
            global.vida -= _dmg;  // Supondo que o jogador tenha uma variável `vida`
        }

        // Destrói o projétil ao atingir o alvo
        instance_destroy();
    }
}

// Limita a velocidade máxima do projétil (opcional)
if (speed > max_speed) {
    speed = max_speed;
}

// Destrói o projétil se sair fora da room
if (x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
}
}