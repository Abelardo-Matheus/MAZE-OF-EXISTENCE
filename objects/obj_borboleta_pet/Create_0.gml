// feather disable GM2017
/// @description Inicializa Borboleta
// Variáveis que serão sobrescritas pelo script gerenciador (scr_borboleta)
damage = 0;
velocidade = 0;
pollen_radius = 0;
wander_radius = 0;
pollen_chance = 0;
escala_base = 0.5 * sprite_ajuste(sprite_index); // sprite refeito em 64x64
image_xscale = escala_base;
image_yscale = escala_base;
// Variáveis internas de movimento
target_x = x;
target_y = y;
timer_state = 0; // Tempo para definir nova posição