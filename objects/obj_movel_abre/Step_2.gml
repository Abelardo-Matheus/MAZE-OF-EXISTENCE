// feather disable GM2017
/// @desc Móvel que abre (End Step: depois do Step do jogador, que zera desenha_botao)
if (aberto || !instance_exists(obj_player)) exit;
var _p = instance_nearest(x, y, obj_player);
if (!casa_movel_perto(id, _p)) exit;          // encostado no pé do móvel (scr_casa_moveis)
_p.desenha_botao = true;                       // mostra o botão "F" em cima do jogador
if (keyboard_check_pressed(ord("F"))) casa_movel_abrir(id);
