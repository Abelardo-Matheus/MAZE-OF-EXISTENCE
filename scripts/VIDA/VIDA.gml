// feather disable GM2017
/// @desc Desenha o HUD de status (Vida, Sanidade e XP) alinhado ao quadro spr_barra_vida.
/// [COMO]: Todas as posições são calculadas a partir do canto superior esquerdo do quadro,
///         usando os "slots" internos do sprite (em pixels do sprite) multiplicados pela escala.
///         As barras de preenchimento usam draw_sprite_part_ext para cortar a largura sem distorcer o formato.
function desenha_barra_vida() {
    var _s    = 3;   // Escala do HUD (pixel art)
    var _alfa = 1;

    // --- Canto superior esquerdo do quadro (em coordenadas GUI) ---
    var _fx = 24;
    var _fy = 72;

    // --- Porcentagens (protegidas contra divisão por zero) ---
    var _vida_pct = clamp(global.vida / max(1, global.vida_max), 0, 1);
    var _san_pct  = clamp(global.sanidade / max(1, global.max_sanidade), 0, 1);
    var _xp_pct   = clamp(global.xp / max(1, global.max_xp), 0, 1);

    // --- Slots internos do quadro spr_barra_vida (pixels do sprite) ---
    var _slot_vida_x = 16, _slot_vida_y = 3;   // barra superior (vida)
    var _slot_san_x  = 6,  _slot_san_y  = 19;  // barra inferior (sanidade)

    // 1. Vida
    var _vw = sprite_get_width(spr_vida);
    var _vh = sprite_get_height(spr_vida);
    if (_vida_pct > 0) {
        draw_sprite_part_ext(spr_vida, 0, 0, 0, max(1, round(_vw * _vida_pct)), _vh,
            _fx + _slot_vida_x * _s, _fy + _slot_vida_y * _s, _s, _s, c_white, _alfa);
    }

    // 2. Sanidade
    var _sw = sprite_get_width(spr_sanidade);
    var _sh = sprite_get_height(spr_sanidade);
    if (_san_pct > 0) {
        draw_sprite_part_ext(spr_sanidade, 0, 0, 0, max(1, round(_sw * _san_pct)), _sh,
            _fx + _slot_san_x * _s, _fy + _slot_san_y * _s, _s, _s, c_white, _alfa);
    }

    // 3. Quadro (desenhado por cima das barras)
    draw_sprite_ext(spr_barra_vida, 0,
        _fx + sprite_get_xoffset(spr_barra_vida) * _s,
        _fy + sprite_get_yoffset(spr_barra_vida) * _s,
        _s, _s, 0, c_white, _alfa);

    // 4. XP — alinhada com a barra inferior do quadro (colunas 3..177 do sprite)
    var _xp_x  = _fx + 3 * _s;
    var _xp_y  = _fy + sprite_get_height(spr_barra_vida) * _s + 8;
    var _xp_w  = 175 * _s;
    var _xp_xs = _xp_w / sprite_get_width(spr_hud_xp);
    var _xp_ys = 2;
    var _xp_in = 3; // borda interna do spr_hud_xp (pixels)

    if (_xp_pct > 0) {
        draw_sprite_ext(spr_hud_barra_xp, 0,
            _xp_x + _xp_in * _xp_xs - sprite_get_xoffset(spr_hud_barra_xp) * _xp_xs,
            _xp_y + _xp_in * _xp_ys - sprite_get_yoffset(spr_hud_barra_xp) * _xp_ys,
            _xp_xs * _xp_pct, _xp_ys, 0, c_white, _alfa);
    }
    draw_sprite_ext(spr_hud_xp, 0,
        _xp_x + sprite_get_xoffset(spr_hud_xp) * _xp_xs,
        _xp_y + sprite_get_yoffset(spr_hud_xp) * _xp_ys,
        _xp_xs, _xp_ys, 0, c_white, _alfa);

    draw_set_alpha(1);
}
