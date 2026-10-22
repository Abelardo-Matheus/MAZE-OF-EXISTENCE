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

// Efeito de dano (player_sinal_dano): flash de cor nos 8 primeiros frames, depois pisca
var _cor = c_white;
var _alfa = 1;
if (!variable_instance_exists(id, "dano_visual")) { dano_visual = 0; dano_visual_total = 1; dano_cor = c_red; } // filhos com Create próprio
if (dano_visual > 0) {
    var _passou = dano_visual_total - dano_visual;
    if (_passou < 8) _cor = dano_cor;
    else _alfa = ((_passou div 5) mod 2 == 0) ? 1 : 0.3;
    dano_visual--;
}
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * _aj, image_yscale * _aj, image_angle, _cor, _alfa);

// 3 e 4 (arma e botão de interação) ficam no Draw End: sempre por cima dos móveis
