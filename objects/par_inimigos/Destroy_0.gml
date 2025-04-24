var index = ds_list_find_index(global.enemy_list, id);
if (index != -1) {
    ds_list_delete(global.enemy_list, index);
}

if (instance_exists(obj_grupo_inimigos)) {
    with (obj_grupo_inimigos) {
        if (other.grupo_id == grupo_id) {
            inimigos_spawnados--;
            if (inimigos_spawnados <= 0) {
                // Remove da lista
                for (var i = 0; i < ds_list_size(global.posicoes_estruturas); i++) {
                    var info = global.posicoes_estruturas[| i];
                    if (info[3] == obj_grupo_inimigos && info[4] == grupo_id) {
                        ds_list_delete(global.posicoes_estruturas, i);
                        break;
                    }
                }
                instance_destroy(); // destrói o spawn
            }
        }
    }
}
