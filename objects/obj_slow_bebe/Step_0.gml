// Para cada instância de obj_SPERM
with (obj_colisao) {
    // Verifica se está colidindo com alguma instância de obj_slow
    if (place_meeting(x, y, obj_slow_bebe)) {
        // Reduz a velocidade
        global.current_player.current_speed = global.speed_sperm - 4;
    } else {
        // Restaura a velocidade normal
        global.current_player.current_speed = global.speed_sperm;
    }
}
