// feather disable GM2017
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

// Barra de vida: inimigo_desenhar_hud() no Draw End (obj_par_inimigos)