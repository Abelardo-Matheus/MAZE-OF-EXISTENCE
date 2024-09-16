
with (obj_colisao) {
    // Verifica se a colisão está acontecendo
    var colidindo = place_meeting(x, y, obj_slow_bebe);
    // Se o estado de colisão mudou
    if (colidindo && !global.in_slow) {
       obj_player.current_speed = global.speed_player - 4;
       global.in_slow = true;
    } else if (!colidindo && global.in_slow) {
        // Restaura a velocidade quando sai da colisão
        obj_player.current_speed = global.speed_player;
        global.in_slow = false;
    }
}
