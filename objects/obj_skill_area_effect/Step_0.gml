if (follow_player && instance_exists(obj_player)) {
    x = obj_player.x;
    y = obj_player.y;
}

// HORDA: dano contínuo com intervalo por inimigo (HORDE_TICK_IFRAMES)
horde_hit_instance_tick(id, damage, 1, x, y);

if (duration > 0) {
    duration--;
} else {
    instance_destroy();
}
