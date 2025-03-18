// Evento Step do obj_explosion
if (follow_player) {
    // Atualiza a posição da explosão para seguir o jogador
    x = obj_player.x;
    y = obj_player.y;
}

// Verifica se a duração acabou
if (alarm[0] == 0) {
    instance_destroy(); // Destroi a explosão quando a duração terminar
}