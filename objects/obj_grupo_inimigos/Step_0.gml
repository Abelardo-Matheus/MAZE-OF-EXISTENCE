// feather disable GM2017
depth = -y
var _distancia_player = point_distance(x, y, obj_player.x, obj_player.y);

if (_distancia_player < distancia_criar) { // só spawna se o player estiver a menos de 2000 pixels
    if (inimigos_spawnados < quantidade_total) {
        spawn_timer++;

        if (spawn_timer >= tempo_entre_spawns) {
            spawn_timer = 0;
            inimigos_spawnados++;

            var _angulo = random(360);
            var _raio = random_range(100, spawn_radius);
            var _px = x + lengthdir_x(_raio, _angulo);
            var _py = y + lengthdir_y(_raio, _angulo);

            var _inimigo = instance_create_depth(_px, _py, 0, obj_amoeba, { lvl: nivel_area }); // força da área (scr_progressao)
			_inimigo.grupo_id = grupo_id;

        }
    }
}
