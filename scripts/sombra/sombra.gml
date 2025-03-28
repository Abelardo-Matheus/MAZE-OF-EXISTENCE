function sombra() {
    // Variáveis da sombra
    var sombra_alpha = 0;
    var base_x = x;
    var base_y = y + sprite_height/2; // Base fixa
    
    // 1. Sombra solar (ciclo dia/noite)
    if (global.day_night_cycle.is_day) {
        var ciclo = global.day_night_cycle.current_cycle;
        var angulo_sol = 180 * ciclo; // Ângulo do sol
        
        // Intensidade baseada na altura do sol
        var altura_sol = sin(ciclo * pi);
        sombra_alpha = lerp(0.1, 0.7, altura_sol);
        
        // Calcula o deslocamento do topo
        var deslocamento = 30 * (1 - altura_sol);
        var topo_x = base_x + lengthdir_x(deslocamento, (angulo_sol + 180) % 360);
        var topo_y = base_y - sprite_height * lerp(0.8, 1.2, altura_sol);
        
        // Calcula a distorção necessária
        var shear_x = (topo_x - base_x) / sprite_height;
        var scale_y = (base_y - topo_y) / sprite_height;
        
        // Desenha a sombra com transformação personalizada
        gpu_set_blendmode(bm_add);
        draw_sprite_general(
            sprite_index,
            image_index,
            base_x, base_y,
			sprite_width,sprite_height, // Posição da base
            1, scale_y,     // Escala (largura normal, altura ajustada)
            0,              // Sem rotação
            shear_x, 0,     // Distorção horizontal
            c_black, c_black, c_black, c_black, // Todas cores pretas
            sombra_alpha    // Transparência
        );
        gpu_set_blendmode(bm_normal);
        
        return;
    }
    
    // 2. Sombra noturna/estrutura (padrão)
    if (sombra_alpha > 0.05) {
        draw_sprite_ext(
            sprite_index,
            image_index,
            base_x,
            base_y,
            1,
            -0.5, // Pequeno achatamento vertical
            0,
            c_black,
            sombra_alpha
        );
    }
}