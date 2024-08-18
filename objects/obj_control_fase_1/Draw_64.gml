// Define o tamanho do minimapa
var mini_map_width = 200;
var mini_map_height = 200;
var cell_size = 15; // Tamanho de cada célula no minimapa

draw_set_alpha(0.7);

// Posição do canto inferior direito da tela
var mini_map_x = display_get_width() - mini_map_width - 40;
var mini_map_y = display_get_height() - mini_map_height - 40;

// Desenhar fundo do minimapa
draw_set_color(c_black);
draw_rectangle(mini_map_x, mini_map_y, mini_map_x + mini_map_width, mini_map_y + mini_map_height, false);

// Calcular os limites para o centro do minimapa (a sala atual do jogador)
var center_x = mini_map_x + mini_map_width / 2;
var center_y = mini_map_y + mini_map_height / 2;

// Limites do minimapa para o número de células que podem ser mostradas
var max_cells_x = mini_map_width div cell_size; // Quantidade máxima de células visíveis no eixo X
var max_cells_y = mini_map_height div cell_size; // Quantidade máxima de células visíveis no eixo Y

// Desenhar cada sala no minimapa
for (var i = 0; i < array_length_1d(global.salas_geradas); i++) {
    var sala = global.salas_geradas[i];
    if (is_array(sala)) {
        var sala_x = sala[0];
        var sala_y = sala[1];
        
        // Posição da sala relativa à sala atual
        var delta_x = sala_x - global.current_sala[0];
        var delta_y = sala_y - global.current_sala[1];

        // Calcula a posição no minimapa com base na distância da sala atual
        var mini_x = center_x + (delta_x * cell_size);
        var mini_y = center_y - (delta_y * cell_size);

        // Verificar se a sala está dentro dos limites do minimapa
        if (abs(delta_x) <= max_cells_x / 2 && abs(delta_y) <= max_cells_y / 2) {
            // Verificar se essa sala contém o óvulo
            if (global.ovulo_sala_pos != undefined && global.ovulo_sala_pos[0] == sala_x && global.ovulo_sala_pos[1] == sala_y) {
                draw_set_color(c_blue); // Sala com óvulo
            }
            // Verificar se essa sala contém o templo
            else if (global.templo_sala_pos != undefined && global.templo_sala_pos[0] == sala_x && global.templo_sala_pos[1] == sala_y) {
                draw_set_color(c_yellow); // Sala com templo
            }
            else {
                draw_set_color(c_white); // Sala comum
            }

            // Desenhar a sala como um quadrado
            draw_rectangle(mini_x, mini_y, mini_x + cell_size, mini_y + cell_size, false);

            // Se for a sala atual, desenhar de uma cor diferente
            if (global.current_sala[0] == sala_x && global.current_sala[1] == sala_y) {
                draw_set_color(c_red);
                draw_rectangle(mini_x, mini_y, mini_x + cell_size, mini_y + cell_size, false);
                draw_set_color(c_white); // Voltar à cor padrão
            }
        }
    }
}

draw_set_alpha(1);

draw_set_color(c_white);
draw_set_font(fnt_menu_op);
draw_text_transformed(200, 100, "Tamanho:" + string(global.pontos), 0.5, 0.5, 0);
draw_text_transformed(200, 150, "Recorde:" + string(global.recorde), 0.5, 0.5, 0);


// === Desenhar sprite com efeito de tremor no meio da tela ===
// Verificar se o jogador está na sala 0,0
