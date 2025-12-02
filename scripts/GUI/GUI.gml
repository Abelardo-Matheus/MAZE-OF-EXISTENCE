function relogio() {
    var relogio_x = global.room_width / 2;
    var relogio_y = 120;
    var tamanho_ponteiro = 32; // Tamanho do ponteiro
    
    // Desenha o relógio base
    draw_sprite_ext(spr_relogio, 0, relogio_x, relogio_y, 1, 1, 0, c_white, 1);
    
    // Calcula o ângulo baseado no global.timer
    var segundos_por_volta = global.day_night_cycle.day_duration + global.day_night_cycle.night_duration; // Tempo para uma volta completa (ajuste conforme necessário)
    var angulo_por_segundo = 360 / segundos_por_volta;
    var angulo_ponteiro = 180 - (global.timer * angulo_por_segundo); // Sentido horário
    
    // Desenha o ponteiro
	draw_set_color(c_red);
	draw_circle(relogio_x,relogio_y,4,false);
    draw_ponteiro(relogio_x, relogio_y, angulo_ponteiro, tamanho_ponteiro);
}

function draw_ponteiro(x, y, angle, length) {
    // Calcula a extremidade do ponteiro
    var dir_x = lengthdir_x(length, angle);
    var dir_y = lengthdir_y(length, angle);
    
    // Define a base da seta (80% do comprimento para não sobrepor totalmente a linha)
    var base_x = x + dir_x * 0.9;
    var base_y = y + dir_y * 0.9;
    var tip_x = x + dir_x;
    var tip_y = y + dir_y;
    
    // Desenha a linha principal (mais grossa)
    draw_line_width_color(x, y, base_x, base_y, 3, c_red, c_red);
    

    draw_triangles(tip_x, tip_y, angle, 8); // 6 = tamanho da seta
	
}
function draw_triangles(tip_x, tip_y, angle, size) {
    // Ângulos para os pontos laterais do triângulo
    var angle_left = angle + 150; // 150° para abrir a seta
    var angle_right = angle - 150;
    
    // Calcula os pontos do triângulo
    var left_x = tip_x + lengthdir_x(size, angle_left);
    var left_y = tip_y + lengthdir_y(size, angle_left);
    var right_x = tip_x + lengthdir_x(size, angle_right);
    var right_y = tip_y + lengthdir_y(size, angle_right);
    
    // Desenha o triângulo (preenchido)
    draw_primitive_begin(pr_trianglelist);
    draw_vertex_color(tip_x, tip_y, c_black, 1);       // Ponta
    draw_vertex_color(left_x, left_y, c_black, 1);     // Esquerda
    draw_vertex_color(right_x, right_y, c_black, 1);   // Direita
    draw_primitive_end();
}
function mini_mapa_vamp() {
    var minimap_width, minimap_height, minimap_x, minimap_y, minimap_scale, distancia_maxima;

    if (keyboard_check_pressed(ord("M"))) {
        global.minimap_expandido = !global.minimap_expandido;
    }

    if (global.minimap_expandido) {
        minimap_width = 1000;
        minimap_height = 800;
        minimap_x = (display_get_width() - minimap_width) / 2;
        minimap_y = (display_get_height() - minimap_height) / 2;
        minimap_scale = 0.02;
        distancia_maxima = 30000;
    } else {
        minimap_width = 220;
        minimap_height = 200;
        minimap_x = display_get_width() - minimap_width - 40;
        minimap_y = display_get_height() - minimap_height - 40;
        minimap_scale = 0.008;
        distancia_maxima = 14000;
    }

    var tamanho_minimo = 0.6;
    var tamanho_normal = 1;
    var cor_marrom = make_color_rgb(174, 91, 28);

    draw_set_color(c_black);
    draw_rectangle(minimap_x - 4, minimap_y - 4, minimap_x + minimap_width + 4, minimap_y + minimap_height + 4, false);

    draw_set_color(cor_marrom);
    draw_rectangle(minimap_x, minimap_y, minimap_x + minimap_width, minimap_y + minimap_height, false);

    var player_x = minimap_x + minimap_width / 2;
    var player_y = minimap_y + minimap_height / 2;

    draw_set_color(c_blue);
    draw_circle(player_x, player_y, 3, false);

    var mouse_x_minimap = device_mouse_x_to_gui(0);
    var mouse_y_minimap = device_mouse_y_to_gui(0);
    var estrutura_hover_info = undefined;

    // Percorre todas as listas globais de entidades no mini mapa
    var listas = [global.posicoes_estruturas, global.posicoes_grupos_inimigos];

    for (var l = 0; l < array_length(listas); l++) {
        var lista = listas[l];

        for (var i = 0; i < ds_list_size(lista); i++) {
            var estrutura_info = lista[| i];
            var estrutura_x = estrutura_info[0];
            var estrutura_y = estrutura_info[1];
            var sprite_minimap = estrutura_info[4];
            var nome = estrutura_info[5];

            var distancia = point_distance(estrutura_x, estrutura_y, obj_player.x, obj_player.y);

            if (distancia <= distancia_maxima) {
                var estrutura_minimap_x = minimap_x + (estrutura_x - obj_player.x) * minimap_scale + minimap_width / 2;
                var estrutura_minimap_y = minimap_y + (estrutura_y - obj_player.y) * minimap_scale + minimap_height / 2;

                estrutura_minimap_x = clamp(estrutura_minimap_x, minimap_x, minimap_x + minimap_width);
                estrutura_minimap_y = clamp(estrutura_minimap_y, minimap_y, minimap_y + minimap_height);

                var fator_tamanho = 1 - (distancia / distancia_maxima);
                fator_tamanho = clamp(fator_tamanho, tamanho_minimo, 1);
                var tamanho_bolinha = tamanho_normal * fator_tamanho;

                var is_hover = point_distance(mouse_x_minimap, mouse_y_minimap, estrutura_minimap_x, estrutura_minimap_y) < tamanho_bolinha * 20;
                if (is_hover) {
                    estrutura_hover_info = nome;
                    tamanho_bolinha *= 2.5;
                }

                if (sprite_minimap != noone) {
                    draw_sprite_ext(sprite_minimap, 0, estrutura_minimap_x, estrutura_minimap_y, tamanho_bolinha, tamanho_bolinha, 0, c_white, 0.8);
                } else {
                    draw_set_color(c_red);
                    var piscar_alpha = 0.5 + 0.5 * sin(current_time / 200);
                    draw_set_alpha(piscar_alpha);
                    draw_circle(estrutura_minimap_x, estrutura_minimap_y, 6, false);
                    draw_set_alpha(1);
                }
            }
        }
    }

    if (estrutura_hover_info != undefined) {
        draw_set_color(c_white);
        draw_text(mouse_x_minimap + 10, mouse_y_minimap, estrutura_hover_info);
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
	
    for (var i = 0; i < array_length(global.salas_geradas); i++) {
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