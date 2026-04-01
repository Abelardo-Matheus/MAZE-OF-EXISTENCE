if (instance_exists(obj_player)) {
    
    // ==========================================
    // 1. VERIFICA A DISTÂNCIA (Retângulo Customizado)
    // ==========================================
    // Calcula a distância separada em X e Y usando 'abs' (valor absoluto)
    var _dist_x = abs(obj_player.x - x);
    var _dist_y = abs(obj_player.y - y);

    // Define os limites máximos baseados no tamanho real da imagem da árvore:
    // Y: Usa a altura exata da árvore (100% da sprite_height)
    var _max_y = sprite_height; 
    
    // X: Pega do centro até a borda (sprite_width / 2) e "tira um pouco" multiplicando por 0.6 (60% do tamanho)
    // Se quiser mais fino, diminua para 0.4. Se quiser mais largo, aumente para 0.8.
    var _max_x = (sprite_width / 2) * 0.6; 

    // Se o player estiver dentro desse "retângulo" invisível, faz a mágica acontecer:
    if (_dist_x < _max_x && _dist_y < _max_y) {
        
        // Verifica se está atrás (Y menor)
        if (obj_player.y < y) {
            image_alpha = 0.5; // Fica transparente
            solid = false;     // Tira a colisão
        } 
        else {
            // Está na frente
            image_alpha = 1.0; 
            
            // Devolve a colisão se o player não estiver "dentro" dela
            if (!place_meeting(x, y, obj_player)) {
                solid = true;
            }
        }
    } 
    // ==========================================
    // 2. O QUE FAZER SE O PLAYER ESTIVER LONGE
    // ==========================================
    else {
        // Se o player foi embora, garante que a árvore volte a ficar normal e sólida.
        if (image_alpha != 1.0) {
            image_alpha = 1.0;
        }
        
        if (solid == false && !place_meeting(x, y, obj_player)) {
            solid = true;
        }
    }
}