// feather disable GM2017
/// @desc HUD do tutorial: tela de level up, barras de vida/XP e objetivo atual

// Tela de level up (a mesma do jogo, em LEVEL_UP.gml)
if (global.level_up) {
    gui_desenhar_level_up();
    exit;
}

// Vida, sanidade e XP (scripts/VIDA)
desenha_barra_vida();

// Objetivo atual (some enquanto há diálogo aberto)
if (instance_exists(obj_dialogo) || tutorial_step >= array_length(passos)) exit;
var _txt = passos[tutorial_step].objetivo(id);
if (_txt == "") exit;
_txt = "OBJETIVO: " + _txt;

draw_set_font(fnt_dialogos);
draw_set_halign(fa_center);
draw_set_valign(fa_top);

var _w = string_width(_txt) + 30;
var _h = string_height(_txt) + 14;
var _xx = display_get_gui_width() / 2;
var _yy = 30;

draw_set_alpha(0.7);
draw_roundrect_color_ext(_xx - _w / 2, _yy, _xx + _w / 2, _yy + _h, 12, 12, c_black, c_black, false);
draw_set_alpha(1);
draw_roundrect_color_ext(_xx - _w / 2, _yy, _xx + _w / 2, _yy + _h, 12, 12, make_color_rgb(255, 210, 63), make_color_rgb(255, 210, 63), true);
draw_set_color(c_white);
draw_text(_xx, _yy + 7, _txt);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
