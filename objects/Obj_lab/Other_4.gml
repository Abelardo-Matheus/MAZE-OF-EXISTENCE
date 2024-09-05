// Inicializar variáveis
randomize();
window_set_fullscreen(true);

// Obtém o índice da room atual
var current_room = room;
var room_name = room_get_name(room);

if(global.dificuldade >= 7){
global.dificuldade = 1;	
global.tamanho_lab = 128 / global.dificuldade;
}
_cell_size = global._cell_size;
tamanho_lab = global.tamanho_lab;
room_width = 1920;
room_height = 1088;


// Verifica se a largura e a altura são múltiplos de _cell_size
switch (global.dificuldade) {
    case 1:
        room_width = (room_width div tamanho_lab) * _cell_size;
        room_height = (room_height div tamanho_lab - 1) * _cell_size;
        break;
    case 2:
        room_width = (room_width div tamanho_lab - 1) * _cell_size;
        room_height = (room_height div tamanho_lab ) * _cell_size;
        break;
    case 3:
        room_width = (room_width div tamanho_lab) * _cell_size;
        room_height = (room_height div tamanho_lab) * _cell_size;
        break;
    case 4:
        room_width = (room_width div tamanho_lab - 1) * _cell_size;
        room_height = (room_height div tamanho_lab - 1) * _cell_size;
        break;
    case 5:
        room_width = (room_width div tamanho_lab - 1) * _cell_size;
        room_height = (room_height div tamanho_lab) * _cell_size;
        break;
	case 6:
        room_width = (room_width div tamanho_lab ) * _cell_size;
        room_height = (room_height div tamanho_lab) * _cell_size;
        break;
	case 10:
        room_width = (room_width div tamanho_lab - 1) * _cell_size;
        room_height = (room_height div tamanho_lab-1) * _cell_size;
        break;
	case 20:
        room_width = (room_width div tamanho_lab - 1) * _cell_size;
        room_height = (room_height div tamanho_lab) * _cell_size;
        break;
}


global.maze_width = (room_width div _cell_size) -1;
global.maze_height = (room_height div _cell_size) -1;
maze_width = global.maze_width;
maze_height = global.maze_height;
global.maze = ds_grid_create(maze_width + 2, maze_height + 2);
visited = ds_grid_create(maze_width + 2, maze_height + 2);
frontier = ds_list_create();
paths = ds_stack_create();
start_x = 1;
start_y = 1;
end_x = maze_width;
end_y = maze_height;
draw_paths = false; // Variável para controlar se devemos desenhar os caminhos
path_points = ds_list_create(); // Lista para armazenar os pontos do caminho

difficulty = 1000; // Exemplo: nível de dificuldade 5
instance_create_layer(start_x * _cell_size + 32, start_y * _cell_size + 32, "Layer_Player", obj_player);


// Inicializar o labirinto com paredes
for (var i = 0; i <= maze_width + 1; i++) {
    for (var z = 0; z <= maze_height + 1; z++) {
        ds_grid_set(global.maze, i, z, 0); // Inicializa como paredes
    }
}

// Função para verificar se as coordenadas estão dentro dos limites
function is_within_bounds(nx, ny) {
    return nx >= 0 && nx < maze_width && ny >= 0 && ny < maze_height;
}


// Função Algoritmo de Prim para gerar o labirinto
// Função Algoritmo de Prim para gerar o labirinto
function prim_algorithm() {
    ds_grid_set(global.maze, start_x, start_y, 1);
    ds_stack_push(paths, start_x);
    ds_stack_push(paths, start_y);
    ds_list_add(path_points, [start_x, start_y]);

    var directions = [[1, 0], [0, 1], [-1, 0], [0, -1]];

    for (var i = 0; i < 4; i++) {
        var dx = directions[i][0];
        var dy = directions[i][1];
        var nx = start_x + dx;
        var ny = start_y + dy;
        if (is_within_bounds(nx, ny)) {
            if (ds_grid_get(global.maze, nx, ny) == 0) {
                ds_list_add(frontier, [nx, ny, start_x, start_y]);
            }
        }
    }

    while (ds_list_size(frontier) > 0) {
        var wall_index = irandom(ds_list_size(frontier) - 1);
        var wall = ds_list_find_value(frontier, wall_index);
        ds_list_delete(frontier, wall_index);

        var wx = wall[0];
        var wy = wall[1];
        var px = wall[2];
        var py = wall[3];

        var opposite_x = wx + (wx - px);
        var opposite_y = wy + (wy - py);

        if (is_within_bounds(opposite_x, opposite_y)) {
            if (ds_grid_get(global.maze, opposite_x, opposite_y) == 0) {
                ds_grid_set(global.maze, wx, wy, 1);
                ds_grid_set(global.maze, opposite_x, opposite_y, 1);

                for (var j = 0; j < 4; j++) {
                    var dx = directions[j][0];
                    var dy = directions[j][1];
                    var nx = opposite_x + dx;
                    var ny = opposite_y + dy;
                    if (is_within_bounds(nx, ny)) {
                        if (ds_grid_get(global.maze, nx, ny) == 0) {
                            ds_list_add(frontier, [nx, ny, opposite_x, opposite_y]);
                        }
                    }
                }

                ds_stack_push(paths, opposite_x);
                ds_stack_push(paths, opposite_y);
                ds_list_add(path_points, [opposite_x, opposite_y]);
            }
        }
    }
}

// Adicionar Conexões Aleatórias

function verifica_novo_caminho_mais_rapido(start_x, start_y, end_x, end_y, caminho_atual) {
    // Função para encontrar o caminho mais curto usando uma busca em largura (similar ao acha_caminho)
    var novo_caminho = acha_caminho(start_x, start_y, end_x, end_y);

    // Verificar se o novo caminho foi encontrado
    if (novo_caminho != undefined) {
        var comprimento_novo_caminho = array_length_1d(novo_caminho);
        var comprimento_caminho_atual = array_length_1d(caminho_atual);

        // Comparar os comprimentos dos caminhos
        if (comprimento_novo_caminho < comprimento_caminho_atual) {
            show_debug_message("Novo caminho mais curto encontrado!");
            return novo_caminho;
        } else {
            show_debug_message("Nenhum caminho mais curto encontrado. Mantendo o caminho atual.");
            return caminho_atual;
        }
    } else {
        show_debug_message("Nenhum novo caminho encontrado.");
        return caminho_atual; // Retorna o caminho atual se nenhum novo caminho foi encontrado
    }
}

// Função para desenhar o labirinto
function draw_maze_obj_lab() {
    for (var i = 0; i <= maze_width + 1; i++) {
        for (var z = 0; z <= maze_height + 1; z++) {
            if (ds_grid_get(global.maze, i, z) == 0) {
                var has_top = (z > 0 && ds_grid_get(global.maze, i, z - 1) == 0);
                var has_bottom = (z < maze_height && ds_grid_get(global.maze, i, z + 1) == 0);

                var scale_x = _cell_size / sprite_get_width(spr_parede);
                var scale_y = _cell_size / sprite_get_height(spr_parede);

                if (has_bottom) {
                    draw_sprite_ext(spr_parede_cima, 0, i * _cell_size, z * _cell_size, scale_x, scale_y, 0, c_white, 1);
                } else if (has_top && has_bottom) {
                    draw_sprite_ext(spr_parede_cima, 0, i * _cell_size, z * _cell_size, scale_x, scale_y, 0, c_white, 1);
                } else {
                    draw_sprite_ext(spr_parede, 0, i * _cell_size, z * _cell_size, scale_x, scale_y, 0, c_white, 1);
                }
            } else {
                var scale_x = _cell_size / sprite_get_width(spr_chao);
                var scale_y = _cell_size / sprite_get_height(spr_chao);
                draw_sprite_ext(spr_chao, 0, i * _cell_size, z * _cell_size, scale_x, scale_y, 0, c_white, 1);
            }
        }
    }
    var scale_x = _cell_size / sprite_get_width(spr_start);
    var scale_y = _cell_size / sprite_get_height(spr_start);
    draw_sprite_ext(spr_start, 0, start_x * _cell_size, start_y * _cell_size, scale_x, scale_y, 0, c_white, 1);

    scale_x = _cell_size / sprite_get_width(spr_end);
    scale_y = _cell_size / sprite_get_height(spr_end);
    draw_sprite_ext(spr_end, 0, end_x * _cell_size -64 , end_y * _cell_size -64  , scale_x, scale_y, 0, c_white, 1);
}

// Função para criar bombas em locais aleatórios de chão


// Função para criar instâncias de parede
function create_wall_instances() {
    for (var i = 0; i <= maze_width + 1; i++) {
        for (var z = 0; z <= maze_height + 1; z++) {
            if (ds_grid_get(global.maze, i, z) == 0) {
                var has_top = (z > 0 && ds_grid_get(global.maze, i, z - 1) == 0);
                var has_bottom = (z < maze_height && ds_grid_get(global.maze, i, z + 1) == 0);

               
				 if (has_bottom) {
                    var wall_instance = instance_create_layer(i * _cell_size, z * _cell_size, "instances", obj_wall);
                    wall_instance.sprite_index = spr_parede_cima;
                } else if (has_top && has_bottom) {
                   var wall_instance = instance_create_layer(i * _cell_size, z * _cell_size, "instances", obj_wall);
                    wall_instance.sprite_index = spr_parede_cima;
                }else {
                    instance_create_layer(i * _cell_size, z * _cell_size, "instances", obj_wall);
                }
            } else {
               instance_create_layer(i * _cell_size, z * _cell_size, "instances", obj_floor);
            }
        }
    }

    instance_create_layer(start_x * _cell_size, start_y * _cell_size, "Top_Layer", obj_start);
    instance_create_layer(end_x * _cell_size -64  , end_y * _cell_size  -64 , "Top_Layer", obj_end);
}



// Função para desenhar o caminho

function remove_dead_ends(difficulty) {
    var directions = [[1, 0], [0, 1], [-1, 0], [0, -1]];
    var dead_ends = [];

    // Identificar todos os becos sem saída
    for (var i = 1; i < maze_width - 1; i++) {
        for (var j = 1; j < maze_height - 1; j++) {
            if (ds_grid_get(global.maze, i, j) == 1) {
                var open_sides = 0;

                for (var d = 0; d < 4; d++) {
                    var nx = i + directions[d][0];
                    var ny = j + directions[d][1];

                    if (is_within_bounds(nx, ny) && ds_grid_get(global.maze, nx, ny) == 1) {
                        open_sides++;
                    }
                }

                // Se há apenas uma abertura, é um beco sem saída
                if (open_sides == 1) {
                    array_push(dead_ends, [i, j]);
                }
            }
        }
    }

    // Quebrar as paredes dos becos sem saída de acordo com a dificuldade
    for (var k = 0; k < array_length_1d(dead_ends); k++) {
        if (k >= difficulty) {
            break;  // Limitar a quantidade de becos sem saída com base na dificuldade
        }

        var dead_end = dead_ends[k];
        var dx, dy;
        
        // Tentar encontrar uma parede adjacente para quebrar
        for (var d = 0; d < 4; d++) {
            dx = dead_end[0] + directions[d][0];
            dy = dead_end[1] + directions[d][1];

            if (is_within_bounds(dx, dy) && ds_grid_get(global.maze, dx, dy) == 0) {
                ds_grid_set(global.maze, dx, dy, 1);  // Quebra a parede
                break;
            }
        }
    }
}


// Chamar o algoritmo de Prim
prim_algorithm();

remove_dead_ends(difficulty);
create_wall_instances();
for (var i = 0; i < global.dificuldade+1; i++) {
    create_random_enemy();
}
if(global.dificuldade == 2){
create_random_enemy_folow();
}

// Criar bombas aleatórias
for (var i = 0; i < 10; i++) {
    create_random_bomb();
}
