// feather disable GM2017
// --- Sombra ---
var _esc = abs(image_xscale);
var _sw = (sombra_largura * _esc) / 50;
var _bob = voa ? sin(current_time * 0.005 + fase_voo) * 2 : 0;
draw_sprite_ext(spr_sombra, 0, x, y, _sw * (voa ? 0.8 : 1), _sw * (voa ? 0.6 : 0.8), 0, c_white, voa ? 0.45 : 0.7);

// --- Corpo (flash branco quando toma dano) ---
if (hit) gpu_set_fog(true, c_white, 0, 0);
draw_sprite_ext(sprite_index, image_index, x, y + _bob, image_xscale, image_yscale, 0, image_blend, image_alpha);
if (hit) gpu_set_fog(false, c_white, 0, 0);

// --- "!" quando avista o jogador ---
if (alerta > 0) {
    var _ax = x;
    var _ay = bbox_top - 14 + _bob - min(4, (40 - alerta));
    draw_set_color(c_black);
    draw_rectangle(_ax - 3, _ay - 1, _ax + 3, _ay + 15, false);
    draw_set_color(c_yellow);
    draw_rectangle(_ax - 1, _ay, _ax + 1, _ay + 8, false);
    draw_rectangle(_ax - 1, _ay + 11, _ax + 1, _ay + 13, false);
    draw_set_color(c_white);
}

// --- Barra de vida ---
if (alarm[2] >= 0) {
    var _hs = 3;
    var _w = sprite_get_width(spr_hud_vida_inimigo) * _hs;
    var _hx = x - _w / 2;
    var _hy = bbox_top - 10 + _bob;
    draw_sprite_ext(spr_hud_vida_inimigo, 0, _hx, _hy, _hs, _hs, 0, c_white, 1);
    draw_sprite_ext(spr_vida_, 0, _hx, _hy, max(0, vida / max_vida) * _hs, _hs, 0, c_white, 1);
}
