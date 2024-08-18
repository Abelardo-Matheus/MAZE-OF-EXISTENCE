function desenha_barra_vida(){
    // Desenhar o fundo da barra de vida
    draw_sprite(spr_barra_vida, 0, 200, 200);

    // Calcular o progresso baseado no valor atual (tamanho do player)
    var progresso = (global.tamanho_player - 1) / (global.tamanho_player_max - 1);

    // Definir o número de pedaços da barra
    var total_pedacos = 20;
    
    // Calcular a largura de cada pedaço da barra de vida
    var largura_pedaco = sprite_get_width(spr_vida) / total_pedacos;

    // Calcular o número de pedaços completos que devem ser preenchidos
    var pedacos_preenchidos = floor(progresso * total_pedacos);

    // Desenhar cada pedaço preenchido
    for (var i = 0; i < pedacos_preenchidos; i++) {
		
        draw_sprite_part(spr_vida, 0, i * largura_pedaco, 0, largura_pedaco, sprite_get_height(spr_vida) , 200 + (i * largura_pedaco), 200);
    }

    // Se houver uma parte parcial da barra para desenhar (entre dois pedaços completos)
    var restante_progresso = frac(progresso * total_pedacos);
    if (restante_progresso > 0) {
        draw_sprite_part(spr_vida, 0, pedacos_preenchidos * largura_pedaco, 0, largura_pedaco * restante_progresso, sprite_get_height(spr_vida) , 200 + (pedacos_preenchidos * largura_pedaco), 200);
    }
}
