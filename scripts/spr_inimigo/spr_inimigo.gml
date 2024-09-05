// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_recalculate_path() {
    // Obtém as coordenadas do jogador em termos de grid
    var player_x = obj_player.x div global._cell_size;
    var player_y = obj_player.y div global._cell_size;

    // Obtém as coordenadas do inimigo em termos de grid
    var enemy_x = x div global._cell_size;
    var enemy_y = y div global._cell_size;

    // Calcula o novo caminho usando A*
    ds_list_destroy(path); // Destrói o caminho antigo
    path = scr_astar_path(enemy_x, enemy_y, player_x, player_y);

    // Reinicia o ponto de caminho
    next_point = 0;

    // Se o caminho estiver vazio, não faz nada
    if (ds_list_size(path) > 0) {
        var point = ds_list_find_value(path, next_point);
        target_x = point[0] * global._cell_size;
        target_y = point[1] * global._cell_size;
    }
}


function create_random_enemy_folow() {
    var enemy_x, enemy_y;

    // Buscar a instância de obj_lab
    var lab = instance_find(Obj_lab, 0);

    // Verifica se a referência ao obj_lab foi definida corretamente
    if (lab != noone) {
        do {
            // Gera coordenadas aleatórias dentro dos limites do labirinto
            enemy_x = irandom(lab._maze_width - 1) + 1;
            enemy_y = irandom(lab._maze_height - 1) + 1;
        } until (ds_grid_get(global._maze, enemy_x, enemy_y) == 1); // Continua até encontrar um local de chão

        // Cria o inimigo no local encontrado
        instance_create_layer(enemy_x * lab._cell_size, enemy_y * lab._cell_size, "Top_layer", obj_enemy_folow);
    }
}


function scr_enemy_random_move() {

    // Cria uma lista de direções possíveis
    var directions = ds_list_create();
    ds_list_add(directions, [0, -1]); // Para cima
    ds_list_add(directions, [0, 1]);  // Para baixo
    ds_list_add(directions, [-1, 0]); // Para a esquerda
    ds_list_add(directions, [1, 0]);  // Para a direita

    // Tente encontrar uma direção válida
    var valid_direction_found = false;
    while (!valid_direction_found && ds_list_size(directions) > 0) {
        // Escolhe uma direção aleatória
        var index = irandom(ds_list_size(directions) - 1);
        directio = ds_list_find_value(directions, index);

        // Calcula a nova posição na grade
        var new_x = (x div global._cell_size) + directio[0];
        var new_y = (y div global._cell_size) + directio[1];

        // Verifica se a nova posição não é uma parede
        if (ds_grid_get(global._maze, new_x, new_y) == 1) { // 1 significa chão
            target_x = new_x * global._cell_size;
            target_y = new_y * global._cell_size;
            is_moving = true;
            valid_direction_found = true;
        } else {
            // Remove a direção inválida
            ds_list_delete(directions, index);
        }
    }

    // Se nenhuma direção válida foi encontrada, para de se mover
    if (!valid_direction_found) {
        is_moving = false;
    }

    // Destrói a lista de direções
    ds_list_destroy(directions);
}

