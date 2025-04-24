var distancia_player = point_distance(x, y, obj_player.x, obj_player.y);


if (distancia_player < distancia_criar) { // só spawna se o player estiver a menos de 2000 pixels
    if (inimigos_spawnados < quantidade_total) {
        spawn_timer++;

        if (spawn_timer >= tempo_entre_spawns) {
            spawn_timer = 0;
            inimigos_spawnados++;

            var angulo = random(360);
            var raio = random_range(100, spawn_radius);
            var px = x + lengthdir_x(raio, angulo);
            var py = y + lengthdir_y(raio, angulo);

            var inimigo = instance_create_depth(px, py, 0, obj_amoeba);
			inimigo.grupo_id = grupo_id;

        }
    }
}
