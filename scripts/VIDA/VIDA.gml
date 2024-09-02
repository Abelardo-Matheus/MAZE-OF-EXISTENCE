function desenha_barra_vida() {
    // Definir as dimensões da barra
    global.max_xp = 30;
    var escala_x = 3; // Escala horizontal
    var escala_y = 3; // Escala vertical
    var pos_x = global.room_width / 2 + 40; // Posição X da barra
    var pos_y = 100; // Posição Y da barra
    var largura_barra = sprite_get_width(spr_barra_vida) * escala_x; // Largura da barra escalada
    var altura_barra = sprite_get_height(spr_barra_vida) * escala_y; // Altura da barra escalada

    // Calcular o progresso baseado no valor atual (tamanho do player)
    var progresso = (global.xp - 1) / (global.max_xp - 1);

    // Definir o número de pedaços da barra
    var total_pedacos = 5;

    // Calcular a largura de cada pedaço da barra de vida
    var largura_pedaco = sprite_get_width(spr_vida) / total_pedacos;

    // Calcular a largura e altura da sprite com base na escala
    largura_pedaco = (sprite_get_width(spr_vida) / total_pedacos) * escala_x;
    var altura_sprite = sprite_get_height(spr_vida) * escala_y;

    // Verificar se o player está tocando a área da barra (mesmo parcialmente)
    var alfa = 1; // Alpha normal
    if (point_in_rectangle(global.current_player.x, global.current_player.y, pos_x - largura_barra / 2, pos_y - altura_barra / 2, pos_x + largura_barra / 2, pos_y + altura_barra / 2)) {
        alfa = 0.5; // Player está na posição da barra, reduzir alpha
    }

    // Desenhar o fundo da barra de vida com escala e alpha
    draw_sprite_ext(spr_barra_vida, 0, pos_x, pos_y, escala_x, escala_y, 0, c_white, alfa);

    // Calcular o número de pedaços completos que devem ser preenchidos
    var pedacos_preenchidos = floor(progresso * total_pedacos);

    // Desenhar cada pedaço preenchido com a escala e alpha
    for (var i = 0; i < pedacos_preenchidos; i++) {
        draw_sprite_part_ext(spr_vida, 0, i * largura_pedaco / escala_x, 0, largura_pedaco / escala_x, sprite_get_height(spr_vida),
                             pos_x + (i * largura_pedaco) - largura_barra / 2,
                             pos_y - altura_barra / 2,
                             escala_x, escala_y, c_white, alfa);
    }

    // Se houver uma parte parcial da barra para desenhar (entre dois pedaços completos)
    var restante_progresso = frac(progresso * total_pedacos);
    if (restante_progresso > 0) {
        draw_sprite_part_ext(spr_vida, 0, pedacos_preenchidos * largura_pedaco / escala_x, 0, (largura_pedaco / escala_x) * restante_progresso, sprite_get_height(spr_vida),
                             pos_x + (pedacos_preenchidos * largura_pedaco) - largura_barra / 2,
                             pos_y - altura_barra / 2,
                             escala_x, escala_y, c_white, alfa);
    }

    // Resetar o alpha para 1 depois de desenhar
    draw_set_alpha(1);
}
