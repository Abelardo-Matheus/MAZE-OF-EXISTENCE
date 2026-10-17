// feather disable GM2017
/// @desc obj_horde — Draw GUI
/// [O QUE]: Números de dano da horda (mesmo visual do obj_dano, sem criar instâncias) e debug.

var _cam = view_camera[0];
var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
var _sx = display_get_gui_width()  / camera_get_view_width(_cam);
var _sy = display_get_gui_height() / camera_get_view_height(_cam);
var _fonte_atual = -1;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var _p = 0; _p < HORDE_POPUP_MAX; _p++) {
    if (pop_a[_p] <= 0) continue;
    var _f = (pop_crit[_p] && fnt_crit != -1) ? fnt_crit : fnt_dano;
    if (_f != _fonte_atual) { draw_set_font(_f); _fonte_atual = _f; }
    draw_set_alpha(pop_a[_p]);
    draw_set_color(pop_c[_p]);
    // feather ignore GM2043
    draw_text_colour_outline((pop_x[_p] - _vx) * _sx, (pop_y[_p] - _vy) * _sy,
                             string(round(pop_v[_p])), 4, c_black, 8, 100, 100);
}
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

rondas_desenhar_gui(); // aviso "NOITE X - RONDA Y" / "ELITE!" (scr_rondas_noite)

if (HORDE_DEBUG) {
    draw_text(8, 120, "Horda: " + string(alive) + "  Gemas: " + string(gem_count) + "  FPS real: " + string(floor(fps_real)) + "  [F9: +500]");
}
