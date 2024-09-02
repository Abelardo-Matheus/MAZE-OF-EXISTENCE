var moving = false;
// Variável para controlar a velocidade do player
var current_speed = global.speed_player;
var current_image_speed = 1; // Velocidade padrão da animação

// Se a tecla Shift estiver pressionada, reduz a velocidade
if (keyboard_check(vk_shift)) {
    current_speed = global.speed_player * 0.5; // Reduz a velocidade do player
    current_image_speed = 0.3; // Reduz a velocidade da animação (ajuste conforme necessário)
} else {
    current_image_speed = 1; // Volta à velocidade normal da animação
}

// Controle de movimento
var h_move = 0;
var v_move = 0;

if (keyboard_check(vk_left) || keyboard_check(ord("A"))) {
    h_move = -current_speed;
	sprite_index = spr_player_esquerda;
        moving = true;
} else if (keyboard_check(vk_right) || keyboard_check(ord("D"))) {
    h_move = current_speed;
	sprite_index = spr_player_direita;
        moving = true;
}

if (keyboard_check(vk_up) || keyboard_check(ord("W"))) {
    v_move = -current_speed;
	 sprite_index = spr_player_cima;
        moving = true;
} else if (keyboard_check(vk_down) || keyboard_check(ord("S"))) {
    v_move = current_speed;
	sprite_index = spr_player_baixo;
        moving = true;
}

// Atualiza a posição do player
x += h_move;
y += v_move;

// Atualiza a animação do player se ele estiver se movendo
if (moving) {
	
	image_speed = current_image_speed; // Define a velocidade da animação baseada na velocidade atual
	show_debug_message(image_speed);
} else {
    image_speed = 0; // Para a animação do player
    image_index = 0; // Opcional: redefine para o primeiro quadro da animação
}





if (keyboard_check_pressed(vk_space) && bombs > 0) {
    bombs -= 1;

    var player_x = floor(x / global.cell_size);
    var player_y = floor(y / global.cell_size);

    var directions = [[0, -1], [0, 1], [-1, 0], [1, 0]]; // Direções de cima, baixo, esquerda e direita

    for (var i = 0; i < array_length_1d(directions); i++) {
        var dx = directions[i][0];
        var dy = directions[i][1];
        var nx = player_x + dx;
        var ny = player_y + dy;
  
        if (nx > 0 && nx < global.maze_width && ny > 0 && ny < global.maze_height) {
            var grid_value = ds_grid_get(global.maze, nx, ny);
            show_debug_message("Grid Value at NX: " + string(nx) + ", NY: " + string(ny) + " is " + string(grid_value));

            if (grid_value == 0) {
                show_debug_message("Wall detected at NX: " + string(nx) + ", NY: " + string(ny) + ". Attempting to destroy.");
                ds_grid_set(global.maze, nx, ny, 1);

                var wall_instance = instance_position(nx * global.cell_size + global.cell_size / 2, ny * global.cell_size + global.cell_size / 2, obj_wall);
                
                if (wall_instance != noone) {
                    show_debug_message("Wall destroyed at NX: " + string(nx) + ", NY: " + string(ny));
                    
                    with (wall_instance) {
                        instance_destroy();
                    }

                    instance_create_layer(nx * global.cell_size, ny * global.cell_size, "Instances", obj_floor);
                    instance_create_layer(nx * global.cell_size + global.cell_size / 2, ny * global.cell_size + global.cell_size / 2, "Layer_Player", obj_explosion);

                    // Verifica as paredes ao redor da parede destruída
                    var adj_directions = [[0, -1], [0, 1], [-1, 0], [1, 0]]; // Cima, baixo, esquerda, direita
                    
                    for (var j = 0; j < array_length_1d(adj_directions); j++) {
                        var adj_dx = adj_directions[j][0];
                        var adj_dy = adj_directions[j][1];
                        var adj_nx = nx + adj_dx;
                        var adj_ny = ny + adj_dy;

                        // Verifica se a parede adjacente está dentro dos limites
                        if (adj_nx > 0 && adj_nx < global.maze_width && adj_ny > 0 && adj_ny < global.maze_height) {
                            var adj_wall_instance = instance_position(adj_nx * global.cell_size + global.cell_size / 2, adj_ny * global.cell_size + global.cell_size / 2, obj_wall);
                            if (adj_wall_instance != noone) {
                                
                                // Verificar se não há paredes coladas embaixo (verifica a posição imediatamente abaixo)
                                var below_adj_ny = adj_ny + 1; // Verificar a parede imediatamente abaixo
                                if (below_adj_ny < global.maze_height) {
                                    var below_adj_wall_instance = instance_position(adj_nx * global.cell_size + global.cell_size / 2, below_adj_ny * global.cell_size + global.cell_size / 2, obj_wall);

                                    // Se não houver parede embaixo, troca a sprite para spr_parede_cima
                                    if (below_adj_wall_instance == noone) {
                                        with (adj_wall_instance) {
                                            sprite_index = spr_parede;
                                        }
                                        show_debug_message("Adjacent wall at NX: " + string(adj_nx) + ", NY: " + string(adj_ny) + " has been changed to spr_parede_cima.");
                                    }
                                }
                            }
                        }
                    }
                } else {
                    show_debug_message("Wall instance not found at NX: " + string(nx) + ", NY: " + string(ny));
                }
            } else {
                show_debug_message("No wall to destroy at NX: " + string(nx) + ", NY: " + string(ny));
            }
        } else {
            show_debug_message("Position out of bounds - NX: " + string(nx) + ", NY: " + string(ny));
        }
    }
}
