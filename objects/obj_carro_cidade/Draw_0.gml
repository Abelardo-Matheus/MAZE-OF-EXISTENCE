// feather disable GM2017
// sprite com o giro da curva (vis_ang); fora da curva é igual ao draw_self
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, vis_ang, image_blend, image_alpha);

// Balão: "Bi-bi!" quando o jogador fica parado na frente, ou reclamação quando ele atravessa
if (balao > 0) {
    var _t = balao_texto;
    var _esc = 0.32;
    draw_set_font(fnt_dialogos);
    var _tw = string_width(_t) * _esc, _th = string_height("Ag") * _esc;
    var _bx = x, _by2 = y - ((vis_dir == 0 || vis_dir == 3) ? alto_v : alto_h) - 6, _by1 = _by2 - _th - 10;
    draw_set_alpha(min(1, balao / 15));
    draw_set_color(make_color_rgb(52, 32, 26));
    draw_roundrect_ext(_bx - _tw / 2 - 6, _by1 - 1, _bx + _tw / 2 + 6, _by2 + 1, 8, 8, false);
    draw_set_color(make_color_rgb(255, 250, 238));
    draw_roundrect_ext(_bx - _tw / 2 - 5, _by1, _bx + _tw / 2 + 5, _by2, 7, 7, false);
    draw_set_color(make_color_rgb(200, 60, 50));
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text_transformed(_bx, (_by1 + _by2) / 2, _t, _esc, _esc, 0);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_alpha(1); draw_set_color(c_white);
}
