// feather disable GM2017
/// @desc obj_horde — Draw
/// [O QUE]: Desenha gemas, sombras, corpos e barras de vida da horda.
/// [COMO] : Culling na câmera. Os corpos são desenhados na ordem do hash espacial (linha a linha),
///          o que já dá o efeito de depth = -y entre eles sem ordenar nada. O fog do flash
///          só é ligado/desligado quando o estado muda, preservando o batching.

var _x0 = cam_x - 64, _y0 = cam_y - 64;
var _x1 = cam_x + cam_w + 64, _y1 = cam_y + cam_h + 64;
var _tsec = current_time / 1000;
var _tms  = current_time;
var _i, _k, _px, _py, _t, _esc, _bob, _sw, _alpha;

// --- Gemas de XP ---
if (gem_count > 0 && gem_sprite != -1) {
    var _gsub = paused ? 0 : _tsec * 10;
    for (_k = 0; _k < gem_count; _k++) {
        _px = gem_x[_k]; _py = gem_y[_k];
        if (_px < _x0 || _py < _y0 || _px > _x1 || _py > _y1) continue;
        draw_sprite_ext(gem_sprite, _gsub, _px, _py, 3, 3, 0, c_white, 1);
    }
}

if (alive <= 0) exit;

// --- Sombras (um batch só) ---
for (_k = 0; _k < grid_total; _k++) {
    _i = grid_items[_k];
    if (_i >= alive) continue;
    _px = ex[_i]; _py = ey[_i];
    if (_px < _x0 || _py < _y0 || _px > _x1 || _py > _y1) continue;
    _t = types[etype[_i]];
    _sw = (_t.sombra * _t.escala) / 50;
    if (_t.voa) draw_sprite_ext(spr_sombra, 0, _px, _py, _sw * 0.8, _sw * 0.6, 0, c_white, 0.45);
    else        draw_sprite_ext(spr_sombra, 0, _px, _py, _sw,       _sw * 0.8, 0, c_white, 0.7);
}

// --- Corpos (ordem do hash = ordenado por linha) ---
var _fog = false;
for (_k = 0; _k < grid_total; _k++) {
    _i = grid_items[_k];
    if (_i >= alive) continue;
    _px = ex[_i]; _py = ey[_i];
    if (_px < _x0 || _py < _y0 || _px > _x1 || _py > _y1) continue;
    _t = types[etype[_i]];

    var _flash = (estun[_i] > 0);
    if (_flash != _fog) { _fog = _flash; gpu_set_fog(_fog, c_white, 0, 0); }

    _bob = _t.voa ? sin(_tms * 0.005 + ephase[_i]) * 2 : 0;
    _alpha = (_t.transp < 1) ? _t.transp + 0.15 * sin(_tms * 0.004 + ephase[_i]) : 1;
    _esc = _t.escala;
    draw_sprite_ext(_t.sprite, paused ? 0 : _tsec * _t.anim_fps + ephase[_i], _px, _py + _bob,
                    (horde_px < _px) ? -_esc : _esc, _esc, 0, c_white, _alpha);
}
if (_fog) gpu_set_fog(false, c_white, 0, 0);

// --- Barras de vida (só de quem levou dano recentemente) ---
var _hs = 3;
var _hw = sprite_get_width(spr_hud_vida_inimigo) * _hs;
for (_k = 0; _k < grid_total; _k++) {
    _i = grid_items[_k];
    if (_i >= alive || ehpbar[_i] <= 0) continue;
    _px = ex[_i]; _py = ey[_i];
    if (_px < _x0 || _py < _y0 || _px > _x1 || _py > _y1) continue;
    _t = types[etype[_i]];
    var _hx = _px - _hw / 2;
    var _hy = _py + _t.topo - 10;
    draw_sprite_ext(spr_hud_vida_inimigo, 0, _hx, _hy, _hs, _hs, 0, c_white, 1);
    draw_sprite_ext(spr_vida_, 0, _hx, _hy, max(0, ehp[_i] / ehpmax[_i]) * _hs, _hs, 0, c_white, 1);
}
