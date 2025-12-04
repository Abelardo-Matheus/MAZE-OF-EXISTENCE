function desenhar_sombra() {
    // --- Configuração Inicial ---
    var _alpha_sombra = 0;
    
    // Pega as dimensões e offset para calcular os cantos corretamente
    var _spr_w = sprite_get_width(sprite_index);
    var _spr_h = sprite_get_height(sprite_index);
    var _x_off = sprite_get_xoffset(sprite_index);
    var _y_off = sprite_get_yoffset(sprite_index);

    // Configura a GPU para desenhar silhueta (pinta tudo de preto)
    gpu_set_fog(true, c_black, 0, 0);

    // --- 1. Sombra Solar (Dia) ---
    if (global.day_night_cycle.is_day) {
        var _ciclo = global.day_night_cycle.current_cycle; // 0 a 1
        
        // Intensidade: Sombra forte ao meio-dia, fraca no amanhecer/entardecer
        var _altura_sol = sin(_ciclo * pi); 
        _alpha_sombra = lerp(0.2, 0.6, _altura_sol);

        // Cálculo do ângulo e comprimento da sombra
        // Sol nasce na esquerda (0) e se põe na direita (180), sombra vai ao contrário
        var _angulo_sombra = 180 * (1 - _ciclo); 
        
        // Quanto mais baixo o sol, mais longa a sombra
        var _comprimento = 40 * (1 - _altura_sol); 
        
        // --- Cálculo dos 4 pontos para distorção (Shear) ---
        // Deslocamento X baseado na posição do sol
        var _shift_x = lengthdir_x(_comprimento, _angulo_sombra);
        
        // Coordenadas base (Pés do personagem)
        var _x1 = x - _x_off + _shift_x;     // Topo Esquerdo (distorcido)
        var _y1 = y - _y_off + _spr_h;       // Topo vai para o chão
        var _x2 = x - _x_off + _spr_w + _shift_x; // Topo Direito (distorcido)
        var _y2 = y - _y_off + _spr_h;       // Topo vai para o chão
        
        var _x3 = x - _x_off + _spr_w;       // Base Direita (fixa)
        var _y3 = y - _y_off + _spr_h;       
        var _x4 = x - _x_off;                // Base Esquerda (fixa)
        var _y4 = y - _y_off + _spr_h;       

        // Desenha a sombra distorcida
        draw_set_alpha(_alpha_sombra);
        draw_sprite_pos(
            sprite_index, image_index,
            _x1, _y1, // Topo Esq (agora projetado no chão)
            _x2, _y2, // Topo Dir (agora projetado no chão)
            _x3, _y3, // Base Dir
            _x4, _y4, // Base Esq
            1
        );
        draw_set_alpha(1);
    } 
    // --- 2. Sombra Noturna / Padrão ---
    else {
        // Sombra oval simples embaixo do pé
        _alpha_sombra = 0.4;
        
        draw_sprite_ext(
            sprite_index,
            image_index,
            x, 
            y + 2, // Leve deslocamento para baixo para não sobrepor o pé
            1,     // Escala X
            -0.5,  // Escala Y (negativo para inverter, 0.5 para achatar)
            0,
            c_black, // O fog já deixa preto, mas reforçamos aqui
            _alpha_sombra
        );
    }

    // --- Limpeza ---
    // Desliga o Fog para não pintar o resto do jogo de preto
    gpu_set_fog(false, c_white, 0, 0);
}