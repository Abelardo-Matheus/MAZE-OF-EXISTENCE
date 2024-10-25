
if(seguidor){
if (!instance_exists(target)) {
    // Se o alvo não existir mais, destrói o projétil
    instance_destroy();
} else {
    // Ajusta a direção do projétil para seguir o alvo
    var dir = point_direction(x, y, target.x, target.y);
    direction = dir;

    // Move o projétil na direção do alvo
    motion_add(direction, speed);

    // Checa a colisão com o jogador (ou outro alvo)
    if (place_meeting(x, y, target)) {
        // Aplica o dano ao jogador
        with (target) {
            global.vida -= other.damage;  // Supondo que o jogador tenha uma variável `vida`
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