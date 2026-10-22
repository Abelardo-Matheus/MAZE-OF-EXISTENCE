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

    // Mantém o mesmo estado de desenho que a versão antiga deixava
    // (outros objetos de GUI desenham depois e dependem dele)
    draw_set_font(fnt_status);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);
    draw_set_alpha(1);
}

/// @desc Estamina como uma bolinha (anel) ao lado do player: 360° cheia -> 0° vazia.
///       Chamar no Draw End do obj_player. Some devagar quando enche; cansado = vermelho pulsando.
function desenha_estamina_bolinha() {
    var _pct = clamp(global.estamina / max(1, global.max_estamina), 0, 1);
    var _cansado = variable_global_exists("cansado") && global.cansado;
    // filhos do obj_player com Create próprio (ex.: obj_player_tutorial) não criam a variável
    if (!variable_instance_exists(id, "estamina_alfa")) estamina_alfa = 0;

    // aparece quando gasta, some ~1 s depois de encher
    if (_pct < 1 || _cansado) estamina_alfa = min(1, estamina_alfa + 0.15);
    else                      estamina_alfa = max(0, estamina_alfa - 0.03);
    if (estamina_alfa <= 0) exit;

    var _cx = x + 28;          // ao lado direito do player
    var _cy = y - 36;
    var _ro = 10;              // raio de fora
    var _ri = 6;               // raio de dentro (anel)
    var _a  = estamina_alfa;

    // cor: verde (cheia) -> amarelo -> vermelho (vazia); cansado pisca vermelho
    var _cor = (_pct > 0.5) ? merge_color(c_yellow, make_color_rgb(90, 220, 90), (_pct - 0.5) * 2)
                            : merge_color(c_red, c_yellow, _pct * 2);
    if (_cansado) _cor = merge_color(c_red, make_color_rgb(120, 0, 0), 0.5 + 0.5 * sin(current_time * 0.012));

    // fundo
    draw_set_alpha(_a * 0.6);
    draw_set_color(c_black);
    draw_circle(_cx, _cy, _ro + 2, false);
    draw_set_alpha(_a * 0.35);
    draw_set_color(_cansado ? make_color_rgb(90, 0, 0) : c_dkgray);
    draw_circle(_cx, _cy, _ro, false);

    // arco: começa no topo e vai no sentido horário (360° = cheia, 0° = vazia)
    if (_pct > 0) {
        var _ang = 360 * _pct;
        var _n = max(2, ceil(36 * _pct));
        draw_primitive_begin(pr_trianglestrip);
        for (var _i = 0; _i <= _n; _i++) {
            var _d = 90 - _ang * (_i / _n);
            draw_vertex_color(_cx + lengthdir_x(_ro, _d), _cy + lengthdir_y(_ro, _d), _cor, _a);
            draw_vertex_color(_cx + lengthdir_x(_ri, _d), _cy + lengthdir_y(_ri, _d), _cor, _a);
        }
        draw_primitive_end();
    }

    // miolo escuro (deixa o anel bem visível)
    draw_set_alpha(_a * 0.8);
    draw_set_color(c_black);
    draw_circle(_cx, _cy, _ri - 1, false);

    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// @desc Força do vento (0..100) e direção no topo da tela, embaixo do relógio (Draw GUI)
function desenha_vento_hud() {
    if (!variable_global_exists("vento") || !is_struct(global.vento)) exit;
    var _f = vento_forca_100();
    var _txt = "Vento " + string(_f) + (global.vento.dir > 0 ? " >>" : " <<");
    var _cor = (_f > VENTO_LIMIAR_EMPURRAO) ? make_color_rgb(255, 170, 80) : make_color_rgb(200, 230, 255);
    draw_set_font(fnt_status);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(_cor); // cor do texto (o contorno é preto)
    draw_text_colour_outline_escalado(display_get_gui_width() / 2, 58, _txt, 3, c_black, 7, 30, 400, 1, 1);
    // evento de clima (Chuva, Tempestade!, Nevasca!, FURACÃO!...)
    var _ev = clima_nome();
    if (_ev != "") {
        var _pisca = (global.clima.evento == "furacao" && (current_time div 300) mod 2 == 0);
        draw_set_color(_pisca ? c_red : make_color_rgb(255, 230, 120));
        draw_text_colour_outline_escalado(display_get_gui_width() / 2, 90, _ev, 3, c_black, 7, 30, 400, 1, 1);
    }
    draw_set_color(c_white);
    draw_set_halign(fa_left);
}
