// Obter a instância do player e sua posição
player = instance_find(obj_player, 0);
if (player != noone) {
    var player_x = player.x div global._cell_size;
    var player_y = player.y div global._cell_size;
}
// Obter a posição do inimigo
var enemy_x = x div global._cell_size;
var enemy_y = y div global._cell_size;

if (path != undefined && ds_list_size(path) > 0) {
    var next_step = ds_list_find_value(path, 0); // Obtenha o próximo passo
    var next_x = next_step[0] * global._cell_size + global._cell_size / 2;
    var next_y = next_step[1] * global._cell_size + global._cell_size / 2;

    // Mover o inimigo para o próximo passo
    var move_speed = 4; // Ajuste a velocidade conforme necessário
    move_towards_point(next_x, next_y, move_speed);

    // Se o inimigo chegou ao próximo passo, remova esse passo do caminho
    if (point_distance(x, y, next_x, next_y) < move_speed) {
        ds_list_delete(path, 0);
    }
} else {
    // Se o caminho estiver vazio ou não existir, recalcular o caminho
    var caminho_array = acha_caminho(enemy_x, enemy_y, player_x, player_y);
    if (caminho_array != undefined) {
        path = ds_list_create();
        for (var i = 0; i < array_length_1d(caminho_array); i++) {
            ds_list_add(path, caminho_array[i]);
        }
    }
}
