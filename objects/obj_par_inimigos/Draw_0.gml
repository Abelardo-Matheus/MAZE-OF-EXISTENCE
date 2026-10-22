// feather disable GM2017
/// @description Desenho (Draw)

// --- Desenha a Sombra (Sempre atrás) ---
// Note que usei image_xscale/2 e image_yscale/2 para a sombra seguir a direção do corpo
draw_sprite_ext(spr_sombra, image_index, x+1, y+16/2, image_xscale/2, escala/2, 0, c_white, 1);

// --- Desenha o Personagem ---
// Cor pela força (IA_INIMIGOS -> inimigo_cor_atual): mais forte = vermelho mais escuro
var _cor = inimigo_cor_atual();
if (hit == true) gpu_set_fog(true, c_white, 0, 0); // Efeito de Flash Branco
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, _cor, image_alpha);
if (hit == true) gpu_set_fog(false, c_white, 0, 0);

// Barra de vida: inimigo_desenhar_hud() no Draw End (obj_par_inimigos)