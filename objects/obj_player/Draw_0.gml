// feather disable GM2017
/// @desc Renderização do Jogador e Interface
/// [O QUE]: Desenha a sombra, o sprite do jogador, a arma atual e o botão de interação.
/// [COMO] :
/// 1. Desenha sombra fixa abaixo do player.
/// 2. Desenha o próprio player (draw_self).
/// 3. Se 'desenha_arma' for true, desenha o sprite da arma correspondente ao 'global.armamento'.
/// 4. Se 'desenha_botao' for true, desenha o ícone piscando acima da cabeça.

// 1. Sombra
draw_sprite_ext(spr_sombra, 0, x, y + 15, 0.8, 0.8, 0, c_white, 1);

// 2. Player (sprites de ataque refeitos em 64x64 usam o fator de ajuste)
var _aj = sprite_ajuste(sprite_index);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * _aj, image_yscale * _aj, image_angle, image_blend, image_alpha);

// 3 e 4 (arma e botão de interação) ficam no Draw End: sempre por cima dos móveis
