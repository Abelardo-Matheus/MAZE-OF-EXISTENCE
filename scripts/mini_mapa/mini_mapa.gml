function mini_mapa_vamp() {
    // Configurações do mini mapa
    var minimap_width = 220; // Largura do mini mapa
    var minimap_height = 200; // Altura do mini mapa
    var minimap_x = display_get_width() - minimap_width - 40; // Posição X do mini mapa na tela
    var minimap_y = display_get_height() - minimap_height - 40; // Posição Y do mini mapa na tela
    var minimap_scale = 0.008; // Escala do mini mapa (ajuste conforme necessário)
    var distancia_maxima = 30000; // Distância máxima para mostrar a estrutura no mini mapa
    var tamanho_minimo = 0.6; // Tamanho mínimo da bolinha (30% do tamanho normal)
    var tamanho_normal = 1; // Tamanho normal da bolinha (diâmetro)

    // Desenha o fundo do mini mapa (retângulo preto)
    draw_set_color(c_black);
    draw_rectangle(minimap_x, minimap_y, minimap_x + minimap_width, minimap_y + minimap_height, false);

    // Desenha o jogador no centro do mini mapa
    var player_x = minimap_x + minimap_width / 2;
    var player_y = minimap_y + minimap_height / 2;
    draw_set_color(c_red);
    draw_circle(player_x, player_y, 3, false);

    // Desenha as estruturas (obj_casas) no mini mapa
    draw_set_color(c_blue);
    for (var i = 0; i < ds_list_size(global.posicoes_estruturas); i++) {
        // Obtém as coordenadas da estrutura da lista
        var estrutura_info = global.posicoes_estruturas[| i]; // Acessa a sublista [pos_x, pos_y, seed]
        var estrutura_x = estrutura_info[0]; // Posição X
        var estrutura_y = estrutura_info[1]; // Posição Y


        // Calcula a distância entre a estrutura e o jogador
        var distancia = point_distance(estrutura_x, estrutura_y, obj_player.x, obj_player.y);

        // Verifica se a estrutura está dentro da distância máxima
        if (distancia <= distancia_maxima) {
            // Calcula a posição da estrutura no mini mapa
            var estrutura_minimap_x = minimap_x + (estrutura_x - obj_player.x) * minimap_scale + minimap_width / 2;
            var estrutura_minimap_y = minimap_y + (estrutura_y - obj_player.y) * minimap_scale + minimap_height / 2;

            // Limita as coordenadas para que fiquem dentro do mini mapa
            estrutura_minimap_x = clamp(estrutura_minimap_x, minimap_x, minimap_x + minimap_width);
            estrutura_minimap_y = clamp(estrutura_minimap_y, minimap_y, minimap_y + minimap_height);

            // Calcula o tamanho da bolinha com base na distância
            var fator_tamanho = 1 - (distancia / distancia_maxima); // Fator de 0 a 1
            fator_tamanho = clamp(fator_tamanho, tamanho_minimo, 1); // Garante que o tamanho não seja menor que o mínimo
            var tamanho_bolinha = tamanho_normal * fator_tamanho;


		   draw_sprite_ext(spr_casa_mini_map, 0, estrutura_minimap_x, estrutura_minimap_y,tamanho_bolinha,tamanho_bolinha,0,c_white,0.8)
        }
    }
}



function mini_mapa_bebe(){

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

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(fnt_menu_op);



	
}