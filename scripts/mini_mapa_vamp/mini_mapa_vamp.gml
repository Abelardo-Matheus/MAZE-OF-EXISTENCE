function mini_mapa_vamp() {
    // Configurações do mini mapa
    var minimap_width = 220; // Largura do mini mapa
    var minimap_height = 200; // Altura do mini mapa
    var minimap_x = display_get_width() - minimap_width - 40; // Posição X do mini mapa na tela
    var minimap_y = display_get_height() - minimap_height - 40; // Posição Y do mini mapa na tela
    var minimap_scale = 0.005; // Escala do mini mapa (ajuste conforme necessário)
    var distancia_maxima = 100000; // Distância máxima para mostrar a estrutura no mini mapa
    var tamanho_minimo = 1; // Tamanho mínimo da bolinha (30% do tamanho normal)
    var tamanho_normal = 2; // Tamanho normal da bolinha (diâmetro)

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

            // Desenha a bolinha representando a estrutura
            draw_circle(estrutura_minimap_x, estrutura_minimap_y, tamanho_bolinha, false);
        }
    }
}