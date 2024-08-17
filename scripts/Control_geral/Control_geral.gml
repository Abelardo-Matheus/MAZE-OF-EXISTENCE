global.full = false;
global.speed_player = 7;
global.dificuldade = 1;
global.tamanho_lab = 128 / global.dificuldade;
global.cell_size = 64;

function is_within_bounds(nx, ny) {
    return nx >= 0 && nx < maze_width && ny >= 0 && ny < maze_height;
}




function verifica_novo_caminho_mais_rapido(start_x, start_y, end_x, end_y, caminho_atual) {
    // Função para encontrar o caminho mais curto usando uma busca em largura (similar ao acha_caminho)
    var novo_caminho = acha_caminho(start_x, start_y, end_x, end_y);

    // Verificar se o novo caminho foi encontrado
    if (novo_caminho != undefined) {
        var comprimento_novo_caminho = array_length_1d(novo_caminho);
        var comprimento_caminho_atual = array_length_1d(caminho_atual);

        // Comparar os comprimentos dos caminhos
        if (comprimento_novo_caminho < comprimento_caminho_atual) {

            return novo_caminho;
        } else {

            return caminho_atual;
        }
    } else {

        return caminho_atual; // Retorna o caminho atual se nenhum novo caminho foi encontrado
    }
}

// Função para desenhar o labirinto
function draw_maze(maze_width, maze_height, maze, cell_size, spr1_parede, spr2_parede_cima, spr2_chao) {
    for (var i = 0; i <= maze_width + 1; i++) {
        for (var z = 0; z <= maze_height + 1; z++) {
            if (ds_grid_get(maze, i, z) == 0) {
                var has_top = (z > 0 && ds_grid_get(maze, i, z - 1) == 0);
                var has_bottom = (z < maze_height && ds_grid_get(maze, i, z + 1) == 0);

                var scale_x = cell_size / sprite_get_width(spr1_parede);
                var scale_y = cell_size / sprite_get_height(spr1_parede);

                if (has_bottom) {
                    draw_sprite_ext(spr2_parede_cima, 0, i * cell_size, z * cell_size, scale_x, scale_y, 0, c_white, 1);
                } else if (has_top && has_bottom) {
                    draw_sprite_ext(spr2_parede_cima, 0, i * cell_size, z * cell_size, scale_x, scale_y, 0, c_white, 1);
                } else {
                    draw_sprite_ext(spr1_parede, 0, i * cell_size, z * cell_size, scale_x, scale_y, 0, c_white, 1);
                }
            } else {
                var scale_x = cell_size / sprite_get_width(spr2_chao);
                var scale_y = cell_size / sprite_get_height(spr2_chao);
                
                // Gera uma rotação aleatória (0, 90, 180, 270 graus)
                var random_rotation = choose(0, 90, 180, 270);

                draw_sprite_ext(spr2_chao, 0, i * cell_size+32, z * cell_size+32, scale_x, scale_y, random_rotation, c_white, 1);
            }
        }
    }
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


