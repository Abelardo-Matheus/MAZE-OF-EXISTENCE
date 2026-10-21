// feather disable GM2017
/// @desc Sombra, humano e balão de fala

// Sombra nos pés
if (sprite_exists(spr_sombra)) draw_sprite_ext(spr_sombra, 0, x, y - 1, 0.9, 0.8, 0, c_white, 0.55);

// Corpo
draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, c_white, 1);

// Balão de fala
if (balao_timer > 0 && balao_texto != "") {
    var _a = min(1, balao_timer / 20);
    var _esc = 0.32;                                   // fnt_dialogos é grande; reduz no mundo
    draw_set_font(fnt_dialogos);
    var _tw = string_width(balao_texto) * _esc;
    var _th = string_height("Ag") * _esc;
    var _pad = 5;
    var _bx1 = x - _tw / 2 - _pad, _bx2 = x + _tw / 2 + _pad;
    var _by2 = y - 108, _by1 = _by2 - _th - _pad * 2;

    draw_set_alpha(_a);
    draw_set_color(make_color_rgb(52, 32, 26));
    draw_roundrect_ext(_bx1 - 1, _by1 - 1, _bx2 + 1, _by2 + 1, 8, 8, false);
    draw_triangle(x - 5, _by2, x + 5, _by2, x, _by2 + 7, false);
    draw_set_color(make_color_rgb(255, 250, 238));
    draw_roundrect_ext(_bx1, _by1, _bx2, _by2, 7, 7, false);
    draw_triangle(x - 4, _by2 - 1, x + 4, _by2 - 1, x, _by2 + 5, false);

    draw_set_color(make_color_rgb(72, 46, 34));
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text_transformed(x, (_by1 + _by2) / 2, balao_texto, _esc, _esc, 0);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
