/// @description Insert description here
// You can write your code in this editor
// Desenha o sprite da instância normalmente
draw_self();
var _fx_tint = fx_create("_filter_tintfilter");
fx_set_parameter(_fx_tint, "g_TintCol", [1, 0, 0, 1]);
layer_set_fx("EffectLayer", _fx_tint);











