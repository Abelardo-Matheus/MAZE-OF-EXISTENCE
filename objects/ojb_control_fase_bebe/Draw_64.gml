if (global.map == true) {
    var mini_map_width = 220;
    var mini_map_height = 200;
    var _cell_size = 25;  // Tamanho de cada célula no minimapa
	var sprite_size = 64;  // Tamanho da sprite (64x64)

    draw_set_alpha(0.7);

    // Posição do canto inferior direito da tela
    var mini_map_x = display_get_width() - mini_map_width - 40;
    var mini_map_y = display_get_height() - mini_map_height - 40;
	var scale_factor = _cell_size / sprite_size;
    // Desenhar fundo do minimapa
    draw_set_color(c_black);
    draw_rectangle(mini_map_x, mini_map_y, mini_map_x + mini_map_width, mini_map_y + mini_map_height, false);

    // Calcular os limites para o centro do minimapa (a sala atual do jogador)
    var center_x = mini_map_x + mini_map_width / 2;
    var center_y = mini_map_y + mini_map_height / 2;

    // Limites do minimapa para o número de células que podem ser mostradas
    var max_cells_x = mini_map_width div _cell_size;  // Quantidade máxima de células visíveis no eixo X
    var max_cells_y = mini_map_height div _cell_size;  // Quantidade máxima de células visíveis no eixo Y

    // Desenhar cada sala no minimapa
    for (var i = 0; i < array_length_1d(global.salas_geradas); i++) {
        var sala = global.salas_geradas[i];
        if (is_array(sala)) {
            var sala_x = sala[0];
            var sala_y = sala[1];

            // Posição da sala relativa à sala atual
            var delta_x = sala_x - global.current_sala[0];
            var delta_y = sala_y - global.current_sala[1];
			var delta = [sala_x - global.current_sala[0], sala_y - global.current_sala[1]];
			var dir_ind = 0;
			
			
			
            // Calcula a posição no minimapa com base na distância da sala atual
            var mini_x = center_x + (delta_x * _cell_size);
            var mini_y = center_y - (delta_y * _cell_size);

            // Verificar se a sala está dentro dos limites do minimapa
            if (abs(delta_x) <= max_cells_x / 2 && abs(delta_y) <= max_cells_y / 2) {
                var sprite_to_draw = spr_salas;  // Sala comum por padrão

                // Verificar se a sala é um templo
                var esta_no_templo = false;
                if (global.templos_salas_pos != undefined) {
                    for (var j = 0; j < array_length_1d(global.templos_salas_pos); j++) {
                        var templo_pos = global.templos_salas_pos[j];
                        if (templo_pos[0] == sala_x && templo_pos[1] == sala_y) {
                            dir_ind = 1;
                            esta_no_templo = true;
                            break;
                        }
                    }
                }

                // Verificar se a sala contém o boss
                var sala_boss = false;
				show_debug_message(global.sala_jardim)
                if (global.sala_jardim != undefined) {
                    for (var k = 0; k < array_length_1d(global.sala_jardim); k++) {
                        var boss_pos = global.sala_jardim;
                        if (boss_pos[0] == sala_x && boss_pos[1] == sala_y) {
                            dir_ind = 2;
                            sala_boss = true;
                            break;
                        }
                    }
                }

                // Desenhar a sala como um sprite
               draw_sprite_ext(sprite_to_draw, dir_ind, mini_x + _cell_size / 2, mini_y + _cell_size / 2, scale_factor, scale_factor, 0, c_white, 1);

                // Se for a sala atual, desenhar uma borda vermelha ao redor
                if (global.current_sala[0] == sala_x && global.current_sala[1] == sala_y) {
                    draw_set_color(c_red);  // Sempre vermelha para a sala atual
					draw_set_alpha(0.6)
                    draw_rectangle(mini_x+4, mini_y+4, mini_x + _cell_size-5, mini_y + _cell_size-5, false);
					draw_set_alpha(1)
                    draw_set_color(c_white);  // Voltar à cor padrão
                }
            }
        }
    }
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(fnt_menu_op);

desenha_barra_vida();
