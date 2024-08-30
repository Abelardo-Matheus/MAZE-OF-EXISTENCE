// Para cada instância de obj_SPERM
with (obj_SPERM) {
    // Verifica se está colidindo com alguma instância de obj_slow
    if (place_meeting(x, y, obj_slow)) {
        // Reduz a velocidade
        current_speed = global.speed_sperm - 4;
    } else {
        // Restaura a velocidade normal
        current_speed = global.speed_sperm;
    }
}
