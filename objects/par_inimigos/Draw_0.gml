/// @description Desenho (Draw)

// --- Desenha a Sombra (Sempre atrás) ---
// Note que usei image_xscale/2 e image_yscale/2 para a sombra seguir a direção do corpo
draw_sprite_ext(spr_sombra, image_index, x+1, y+16/2, image_xscale/2, escala/2, 0, c_white, 1);

// --- Desenha o Personagem ---
if (hit == true) {
    // Efeito de Flash Branco
    gpu_set_fog(true, c_white, 0, 0);
    draw_self(); // Agora desenha com o xscale correto definido no Step
    gpu_set_fog(false, c_white, 0, 0);
} else {
    // Desenho normal
    draw_self();
}

// --- Desenha HUD de Vida (Sempre na frente) ---
if (alarm[2] >= 0) {
    var _sprw = sprite_get_width(spr_hud_vida_inimigo) / 2 * escala;
    var _hud_y = y - (12 * escala);

    draw_sprite_ext(spr_hud_vida_inimigo, 0, x - _sprw, _hud_y, escala, escala, 0, c_white, 1);
    
    // Barra de vida (escala horizontal baseada na porcentagem de vida)
    var _porcentagem_vida = (vida / max_vida) * escala;
    draw_sprite_ext(spr_vida_, 0, x - _sprw, _hud_y, _porcentagem_vida, escala, 0, c_white, 1);
}