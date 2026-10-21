// feather disable GM2017
/// @desc Desenho do inventário (layout em obj_inventario Create)
if (!is_open) {
    // Mensagem rápida aparece mesmo com o inventário fechado (ex.: "Mochila cheia!")
    if (msg_timer > 0 && msg_texto != "") {
        draw_set_font(fnt_descricao); draw_set_halign(fa_center); draw_set_valign(fa_top);
        draw_set_alpha(min(1, msg_timer / 30));
        ui_text(display_get_gui_width() / 2, 60, msg_texto, msg_cor, 1);
        draw_set_alpha(1); draw_set_halign(fa_left);
    }
    // Mesmo com a mochila fechada, o painel do baú (abre com E perto dele) continua desenhado
    // mais abaixo neste evento — por isso NÃO damos exit aqui quando há um baú aberto.
    if (!instance_exists(global.bau_aberto)) exit;
}

if (is_open) {

calcular_layout();
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _grid = global.grid_itens;
var _s = scale;

draw_set_font(fnt_descricao);
var _fh = max(1, string_height("Ag"));
/// escala de texto para uma altura em pixels do sprite
var _te = function(_px_sprite, _fh_, _s_) { return (_px_sprite * _s_) / _fh_; };

// ============================================================================
// 1. FUNDO + MOLDURA
// ============================================================================
draw_set_alpha(0.7); draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1); draw_set_color(c_white);
draw_sprite_ext(spr_iinventario, 0, inventory_x, inventory_y, _s, _s, 0, c_white, 1);

// ============================================================================
// 2. SLOTS (mochila + equipamentos)
// ============================================================================
var _n_slots = ds_grid_height(_grid);
for (var _i = 0; _i < _n_slots; _i++) {
    var _r  = slot_rect(_i);
    var _cx = (_r[0] + _r[2]) / 2;
    var _cy = (_r[1] + _r[3]) / 2;

    // Espaço de equipamento ocupado: cobre a silhueta (espada/escudo/bota) do fundo
    if (_i >= total_slots && _grid[# INFOS.ITEM, _i] != -1 && !(drag_ativo && _i == drag_slot)) {
        draw_set_color(make_color_rgb(211, 191, 169));
        draw_rectangle(_r[0], _r[1], _r[2] - 1, _r[3] - 1, false);
        draw_set_color(c_white);
    }

    // destaque: selecionado (oficina) e hover
    if (_i == selected_slot) {
        draw_set_color(make_color_rgb(255, 210, 60)); draw_set_alpha(0.35);
        draw_rectangle(_r[0], _r[1], _r[2], _r[3], false);
        draw_set_alpha(1);
        for (var _k = 0; _k < 2 * _s; _k++) draw_rectangle(_r[0] + _k, _r[1] + _k, _r[2] - _k, _r[3] - _k, true);
        draw_set_color(c_white);
    }
    if (_i == hover_slot) {
        draw_sprite_ext(spr_selecionado, 0, _cx - sprite_get_width(spr_selecionado) * _s / 2, _cy - sprite_get_height(spr_selecionado) * _s / 2, _s, _s, 0, c_white, 1);
    }

    var _id = _grid[# INFOS.ITEM, _i];
    if (_id == -1) continue;

    var _spr = _grid[# INFOS.SPRITE, _i];
    var _idx = _grid[# INFOS.IMAGE_IND, _i];
    var _qtd = _grid[# INFOS.QUANTIDADE, _i];
    var _alpha = (drag_ativo && _i == drag_slot) ? 0.3 : 1;
    var _is = _s * 0.9;

    if (sprite_exists(_spr)) {
        draw_sprite_ext(_spr, _idx, _cx - sprite_get_width(_spr) * _is / 2 + sprite_get_xoffset(_spr) * _is,
                        _cy - sprite_get_height(_spr) * _is / 2 + sprite_get_yoffset(_spr) * _is, _is, _is, 0, c_white, _alpha);
    }

    var _d = item_db(_id);
    // borda da raridade (fininha, embaixo)
    if (!is_undefined(_d) && _d.raridade != "comum") {
        draw_set_color(item_raridade(_d.raridade).cor); draw_set_alpha(0.9 * _alpha);
        draw_rectangle(_r[0] + _s, _r[3] - 2 * _s, _r[2] - _s, _r[3] - _s, false);
        draw_set_alpha(1); draw_set_color(c_white);
    }
    // nível (canto superior esquerdo)
    if (!is_undefined(_d) && item_tipo_e_equipamento(_d.tipo)) {
        var _nv = _grid[# INFOS.NIVEL, _i];
        if (_nv > 1) {
            draw_set_halign(fa_left); draw_set_valign(fa_top);
            ui_text(_r[0] + 2 * _s, _r[1] + 1 * _s, "Nv" + string(_nv), make_color_rgb(255, 220, 90), _te(8, _fh, _s));
        }
        // bolinhas das passivas (canto inferior esquerdo)
        var _pas = _grid[# INFOS.PASSIVAS, _i];
        var _bx = _r[0] + 4 * _s;
        if (_d.inata != "") { draw_set_color(c_black); draw_circle(_bx, _r[3] - 5 * _s, 2.2 * _s, false); draw_set_color(global.passivas_db[$ _d.inata].cor); draw_circle(_bx, _r[3] - 5 * _s, 1.5 * _s, false); _bx += 5 * _s; }
        if (is_array(_pas)) {
            for (var _p = 0; _p < array_length(_pas); _p++) {
                var _pd = global.passivas_db[$ _pas[_p]];
                if (is_undefined(_pd)) continue;
                draw_set_color(c_black); draw_circle(_bx, _r[3] - 5 * _s, 2.2 * _s, false);
                draw_set_color(_pd.cor); draw_circle(_bx, _r[3] - 5 * _s, 1.5 * _s, false);
                _bx += 5 * _s;
            }
        }
        draw_set_color(c_white);
    }
    // quantidade (canto inferior direito)
    if (_qtd > 1) {
        draw_set_halign(fa_right); draw_set_valign(fa_bottom);
        ui_text(_r[2] - 2 * _s, _r[3] - 1 * _s, string(_qtd), c_white, _te(9, _fh, _s));
    }
}
draw_set_halign(fa_left); draw_set_valign(fa_top);

// ============================================================================
// 3. STATUS (boneco, nível, vida, XP e atributos)
// ============================================================================
var _st = lay_status;
var _S1x = ux(_st[0]), _S1y = uy(_st[1]), _S2x = ux(_st[2] + 1), _S2y = uy(_st[3] + 1);
var _tx_esc = make_color_rgb(250, 241, 224);

// Fundo: "céu" quente em degradê em cima, chão de madeira clara embaixo
draw_rectangle_colour(_S1x, _S1y, _S2x, uy(_st[1] + 68), make_color_rgb(255, 240, 214), make_color_rgb(255, 240, 214), make_color_rgb(232, 210, 178), make_color_rgb(232, 210, 178), false);
draw_set_color(ui_cor("papel2")); draw_rectangle(_S1x, uy(_st[1] + 68), _S2x, _S2y, false);
draw_set_color(ui_cor("borda2")); draw_rectangle(_S1x, uy(_st[1] + 68), _S2x, uy(_st[1] + 68) + max(1, _s * .6), false);
draw_set_color(c_white);

// Halo + sombra + boneco
var _pcx = ux((_st[0] + _st[2]) / 2);
draw_set_alpha(0.45); draw_set_color(c_white); draw_circle(_pcx, uy(_st[1] + 34), 27 * _s, false);
draw_set_alpha(0.25); draw_circle(_pcx, uy(_st[1] + 34), 34 * _s, false);
draw_set_alpha(0.28); draw_set_color(ui_cor("escuro"));
draw_ellipse(_pcx - 17 * _s, uy(_st[1] + 58), _pcx + 17 * _s, uy(_st[1] + 64), false);
draw_set_alpha(1); draw_set_color(c_white);
var _ps = _s * 1.3;
var _py = uy(_st[1] + 3) + 31 * _ps;            // origem do sprite do player (19,31)
var _img_p = instance_exists(obj_player) ? obj_player.image_index : 0;
if (sprite_exists(spr_player_baixo_parado)) draw_sprite_ext(spr_player_baixo_parado, _img_p, _pcx, _py, _ps, _ps, 0, c_white, 1);

// Medalha de nível (canto superior esquerdo)
var _mx0 = ux(_st[0] + 13), _my0 = uy(_st[1] + 13);
draw_set_color(ui_cor("escuro"));                 draw_circle(_mx0, _my0, 11 * _s, false);
draw_set_color(make_color_rgb(214, 140, 20));     draw_circle(_mx0, _my0, 10 * _s, false);
draw_set_color(ui_cor("ouro"));                   draw_circle(_mx0 - .5 * _s, _my0 - .5 * _s, 8.4 * _s, false);
draw_set_color(make_color_rgb(255, 236, 150));    draw_circle(_mx0 - 3 * _s, _my0 - 3 * _s, 2.4 * _s, false);
draw_set_halign(fa_center); draw_set_valign(fa_middle);
ui_text(_mx0, _my0 - 3.2 * _s, "NV", make_color_rgb(120, 70, 20), _te(5.5, _fh, _s), make_color_rgb(255, 230, 140));
ui_text(_mx0, _my0 + 2.6 * _s, string(global.level_player), c_white, _te(9, _fh, _s), make_color_rgb(140, 80, 10));
draw_set_halign(fa_left); draw_set_valign(fa_top);

// Buffs ativos (pílulas no canto superior direito)
if (variable_global_exists("buffs_ativos")) {
    var _byy = uy(_st[1] + 3);
    for (var _b = 0; _b < array_length(global.buffs_ativos) && _b < 4; _b++) {
        var _bf = global.buffs_ativos[_b];
        var _inf = item_stat_info(_bf.stat);
        var _seg = ceil(_bf.timer / game_get_speed(gamespeed_fps));
        var _txt_b = "+" + item_num_str(_bf.valor) + _inf.sufixo + " " + string(_seg) + "s";
        var _ts_b = _te(6, _fh, _s);
        var _hb = 9 * _s;
        var _wb = string_width(_txt_b) * _ts_b + _hb * 1.9;
        var _bx = _S2x - 3 * _s - _wb;
        ui_rrect(_bx, _byy, _bx + _wb, _byy + _hb, _hb / 2, ui_cor("escuro"), 0.75);
        ui_icon_item(ui_icone_stat(_bf.stat), _bx + _hb * 0.55, _byy + _hb / 2, _hb * 1.1);
        draw_set_valign(fa_middle);
        ui_text(_bx + _hb * 1.15, _byy + _hb / 2, _txt_b, _inf.cor, _ts_b);
        draw_set_valign(fa_top);
        _byy += _hb + 2 * _s;
    }
}

// Barras de vida e XP
var _bx1 = ux(_st[0] + 16), _bx2 = ux(_st[2] - 4);
var _vida_pct = global.vida / max(1, global.vida_max);
ui_icon_item("ad_coracao", ux(_st[0] + 8), uy(_st[1] + 77), 15 * _s);
ui_bar(_bx1, uy(_st[1] + 72), _bx2, uy(_st[1] + 82), _vida_pct, make_color_rgb(230, 70, 70));
draw_set_halign(fa_center); draw_set_valign(fa_middle);
ui_text((_bx1 + _bx2) / 2, uy(_st[1] + 77), string(round(global.vida)) + " / " + string(round(global.vida_max)), c_white, _te(6.5, _fh, _s), make_color_rgb(90, 20, 20));
draw_set_halign(fa_left); draw_set_valign(fa_top);

var _xp = variable_global_exists("xp") ? global.xp : 0;
var _xpmax = variable_global_exists("max_xp") ? max(1, global.max_xp) : max(1, global.level_player * 100);
draw_set_valign(fa_middle);
ui_text(ux(_st[0] + 3), uy(_st[1] + 89), "XP", make_color_rgb(70, 140, 222), _te(6, _fh, _s), _tx_esc);
draw_set_valign(fa_top);
ui_bar(_bx1, uy(_st[1] + 86), _bx2, uy(_st[1] + 92), _xp / _xpmax, make_color_rgb(80, 160, 240));

// Atributos: 4 chips com ícone
var _e = variable_global_exists("equip_stats") ? global.equip_stats : equip_stats_zero();
var _atk = variable_global_exists("ataque_sem_crit") ? global.ataque_sem_crit : global.ataque;
var _chips = [
    ["dano",   "Ataque",  item_num_str(_atk),                              make_color_rgb(200, 60, 50)],
    ["defesa", "Defesa",  item_num_str(global.armadura_bebe),              make_color_rgb(50, 110, 200)],
    ["vel",    "Veloc.",  item_num_str(global.speed_player),               make_color_rgb(190, 130, 10)],
    ["crit",   "Crítico", item_num_str(global.level_player + _e.crit) + "%", make_color_rgb(200, 120, 0)]
];
var _cw = (_st[2] - _st[0] - 8) / 2;
for (var _k = 0; _k < 4; _k++) {
    var _cx1 = _st[0] + 3 + (_k mod 2) * (_cw + 2);
    var _cy1 = _st[1] + 97 + (_k div 2) * 23;
    var _X1 = ux(_cx1), _Y1 = uy(_cy1), _X2 = ux(_cx1 + _cw), _Y2 = uy(_cy1 + 21);
    ui_card(_X1, _Y1, _X2, _Y2, 4 * _s, ui_cor("chip"), ui_cor("borda2"), max(1, _s * .8), false);
    // ícone num círculo
    draw_set_color(merge_color(_chips[_k][3], c_white, 0.75)); draw_circle(_X1 + 10.5 * _s, (_Y1 + _Y2) / 2, 7.5 * _s, false);
    ui_icon_item(ui_icone_stat(_chips[_k][0]), _X1 + 10.5 * _s, (_Y1 + _Y2) / 2, 17 * _s);
    ui_text(_X1 + 20 * _s, _Y1 + 2 * _s, _chips[_k][1], ui_cor("texto2"), _te(5.5, _fh, _s), _tx_esc);
    ui_text_fit(_X1 + 20 * _s, _Y1 + 8.5 * _s, _chips[_k][2], _chips[_k][3], _te(9.5, _fh, _s), _X2 - _X1 - 22 * _s);
}

// Extras das passivas (pílulas)
var _ex = [];
if (_e.vida > 0)       array_push(_ex, ["vida", "+" + item_num_str(_e.vida) + " Vida"]);
if (_e.regen > 0)      array_push(_ex, ["regen", item_num_str(_e.regen) + "/s"]);
if (_e.vampirismo > 0) array_push(_ex, ["vampirismo", item_num_str(_e.vampirismo) + "%"]);
if (_e.esquiva > 0)    array_push(_ex, ["esquiva", item_num_str(min(60, _e.esquiva)) + "%"]);
if (_e.dano_pct > 0)   array_push(_ex, ["dano_pct", "+" + item_num_str(_e.dano_pct) + "%"]);
if (_e.crit_dano > 0)  array_push(_ex, ["crit_dano", "+" + item_num_str(_e.crit_dano) + "%"]);
if (_e.mata_fantasma)  array_push(_ex, ["", "Caça-Fantasma"]);
var _exx = ux(_st[0] + 3);
var _exy = uy(_st[1] + 144);
var _exh = 9.5 * _s;
var _exts = _te(5.8, _fh, _s);
if (array_length(_ex) == 0) {
    ui_text(_exx, _exy + 1 * _s, "Cole adesivos nos equipamentos para ganhar bônus!", ui_cor("texto2"), _te(5.2, _fh, _s), _tx_esc);
}
for (var _k = 0; _k < array_length(_ex); _k++) {
    var _wq = string_width(_ex[_k][1]) * _exts + _exh * (_ex[_k][0] != "" ? 1.9 : 0.9);
    if (_exx + _wq > _S2x - 2 * _s) break;
    ui_rrect(_exx, _exy, _exx + _wq, _exy + _exh, _exh / 2, ui_cor("escuro"), 0.8);
    var _tx0 = _exx + _exh * 0.45;
    if (_ex[_k][0] != "") { ui_icon_item(ui_icone_stat(_ex[_k][0]), _exx + _exh * 0.6, _exy + _exh / 2, _exh * 1.15); _tx0 = _exx + _exh * 1.2; }
    draw_set_valign(fa_middle);
    ui_text(_tx0, _exy + _exh / 2, _ex[_k][1], make_color_rgb(255, 225, 160), _exts);
    draw_set_valign(fa_top);
    _exx += _wq + 2 * _s;
}

// ============================================================================
// 4. MOEDAS (caixinha pequena)
// ============================================================================
var _mo = lay_moedas;
var _mcy = uy((_mo[1] + _mo[3]) / 2);
draw_set_color(c_black); draw_circle(ux(_mo[0] + 9), _mcy, 6 * _s, false);
draw_set_color(make_color_rgb(255, 200, 40)); draw_circle(ux(_mo[0] + 9), _mcy, 5 * _s, false);
draw_set_color(make_color_rgb(255, 235, 140)); draw_circle(ux(_mo[0] + 8), _mcy - 1 * _s, 2.2 * _s, false);
draw_set_color(c_white);
draw_set_valign(fa_middle);
ui_text_fit(ux(_mo[0] + 18), _mcy, string(global.moedas), make_color_rgb(255, 220, 90), _te(10, _fh, _s), (_mo[2] - _mo[0] - 21) * _s);
draw_set_valign(fa_top);

// ============================================================================
// 5. OFICINA (item selecionado: nome, atributos, adesivos, MELHORAR / USAR)
// ============================================================================
var _of = lay_oficina;
var _tx_cl = make_color_rgb(250, 241, 224);
ui_card(ux(_of[0]), uy(_of[1]), ux(_of[2] + 1), uy(_of[3] + 1), 4 * _s, ui_cor("papel"), ui_cor("borda2"), max(1, _s * .8), false);
ui_tab(ux(_of[0] + 5), uy(_of[1] - 13), 12 * _s, "OFICINA", make_color_rgb(204, 120, 50), _te(8, _fh, _s));

var _sel_id = (selected_slot != -1) ? _grid[# INFOS.ITEM, selected_slot] : -1;
var _sel_d  = item_db(_sel_id);
var _ox = _of[0] + 4, _oy = _of[1] + 4;

if (is_undefined(_sel_d)) {
    // ---------- Vazio: dicas de controle ----------
    draw_set_halign(fa_center);
    ui_text(ux((_of[0] + _of[2]) / 2), uy(_oy + 1), "Clique num item para abrir aqui", ui_cor("texto"), _te(7.5, _fh, _s), _tx_cl);
    draw_set_halign(fa_left);
    var _dicas = [
        ["Arrastar",  "mover, equipar ou colar adesivo"],
        ["Dir. / E",  "usar ou equipar"],
        ["U",         "melhorar o item selecionado"],
        ["F",         "soltar no chão"],
        ["Roda",      "rolar a lista de craft"]
    ];
    var _ts_k = _te(6, _fh, _s);
    for (var _k = 0; _k < array_length(_dicas); _k++) {
        var _yy0 = uy(_oy + 14 + _k * 14.5);
        var _wk = ui_pill(ux(_ox + 4), _yy0, 10 * _s, _dicas[_k][0], ui_cor("borda"), c_white, _ts_k);
        draw_set_valign(fa_middle);
        ui_text_fit(ux(_ox + 4) + _wk + 4 * _s, _yy0 + 5 * _s, _dicas[_k][1], ui_cor("texto"), _te(6.5, _fh, _s), ux(_of[2] - 4) - (ux(_ox + 4) + _wk + 4 * _s));
        draw_set_valign(fa_top);
    }
} else {
    var _rar = item_raridade(_sel_d.raridade);
    var _equip = item_tipo_e_equipamento(_sel_d.tipo);
    var _nv = _grid[# INFOS.NIVEL, selected_slot];

    // ---------- Cabeçalho: ícone com moldura da raridade + nome ----------
    var _ix1 = ux(_ox), _iy1 = uy(_oy), _ix2 = ux(_ox + 27), _iy2 = uy(_oy + 27);
    ui_card(_ix1, _iy1, _ix2, _iy2, 4 * _s, merge_color(_rar.cor, ui_cor("papel"), 0.72), merge_color(_rar.cor, c_black, 0.35), max(1, _s), true);
    draw_set_alpha(0.35); draw_set_color(c_white); draw_circle((_ix1 + _ix2) / 2, (_iy1 + _iy2) / 2, 9 * _s, false); draw_set_alpha(1);
    ui_icon(_sel_d.spr, _sel_d.img, (_ix1 + _ix2) / 2, (_iy1 + _iy2) / 2, 30 * _s);

    var _nx = _ox + 31;
    var _nome_w = _equip ? (_of[2] - 50 - _nx) : (_of[2] - 4 - _nx);
    ui_text_fit(ux(_nx), uy(_oy), _sel_d.nome, _rar.cor, _te(9.5, _fh, _s), _nome_w * _s);
    var _ts_p = _te(5.6, _fh, _s);
    var _wp = ui_pill(ux(_nx), uy(_oy + 13), 9 * _s, item_tipo_nome(_sel_d.tipo), ui_cor("borda"), c_white, _ts_p);
    ui_pill(ux(_nx) + _wp + 2 * _s, uy(_oy + 13), 9 * _s, _rar.nome, merge_color(_rar.cor, c_black, 0.2), c_white, _ts_p, merge_color(_rar.cor, c_black, 0.7));

    if (_equip) {
        // estrelas de nível (canto direito)
        for (var _k = 0; _k < ITEM_NIVEL_MAX; _k++) {
            draw_estrela(ux(_of[2] - 42 + _k * 9), uy(_oy + 4), 3.6 * _s, (_k < _nv) ? ui_cor("ouro") : make_color_rgb(170, 150, 128));
        }
        draw_set_halign(fa_right);
        ui_text(ux(_of[2] - 4), uy(_oy + 10), "Nv " + string(_nv) + "/" + string(ITEM_NIVEL_MAX), make_color_rgb(170, 110, 20), _te(6, _fh, _s), _tx_cl);
        draw_set_halign(fa_left);

        // ---------- Atributos (agora > próximo nível) ----------
        var _sx = ux(_ox);
        var _sy = uy(_oy + 30);
        var _ord = ["dano", "defesa", "vel", "vida", "crit"];
        var _ts_s = _te(6.2, _fh, _s);
        var _hs = 11 * _s;
        for (var _k = 0; _k < array_length(_ord); _k++) {
            var _v = item_stat(_sel_id, _ord[_k], _nv);
            if (_v == 0) continue;
            var _inf = item_stat_info(_ord[_k]);
            var _t1 = (_v > 0 ? "+" : "") + item_num_str(_v) + _inf.sufixo;
            var _t2 = (_nv < ITEM_NIVEL_MAX && _v > 0) ? "> " + item_num_str(item_stat(_sel_id, _ord[_k], _nv + 1)) + _inf.sufixo : "";
            var _wc = _hs * 1.15 + (string_width(_t1) + (_t2 != "" ? string_width(" " + _t2) : 0)) * _ts_s + _hs * 0.4;
            if (_sx + _wc > ux(_of[2] - 3)) break;
            ui_rrect(_sx, _sy, _sx + _wc, _sy + _hs, _hs / 2, ui_cor("chip"));
            ui_icon_item(ui_icone_stat(_ord[_k]), _sx + _hs * 0.6, _sy + _hs / 2, _hs * 1.1);
            draw_set_valign(fa_middle);
            var _tx1 = _sx + _hs * 1.15;
            ui_text(_tx1, _sy + _hs / 2, _t1, merge_color(_inf.cor, c_black, 0.25), _ts_s, ui_cor("escuro"));
            if (_t2 != "") ui_text(_tx1 + string_width(_t1 + " ") * _ts_s, _sy + _hs / 2, _t2, make_color_rgb(110, 230, 100), _ts_s, ui_cor("escuro"));
            draw_set_valign(fa_top);
            _sx += _wc + 2 * _s;
        }

        // ---------- Adesivos ----------
        var _ay = _oy + 45;
        draw_set_valign(fa_middle);
        ui_text(ux(_ox), uy(_ay + 7), "Adesivos", ui_cor("texto"), _te(6.5, _fh, _s), _tx_cl);
        draw_set_valign(fa_top);
        var _slots = item_slots_passiva(_nv);
        var _pas = _grid[# INFOS.PASSIVAS, selected_slot];
        var _np = is_array(_pas) ? array_length(_pas) : 0;
        for (var _k = 0; _k < 3; _k++) {
            var _scx = ux(_ox + 43 + _k * 17), _scy = uy(_ay + 7);
            ui_socket(_scx, _scy, 6.5 * _s, _k < _slots);
            if (_k < _np) {
                var _pd = global.passivas_db[$ _pas[_k]];
                if (!is_undefined(_pd)) ui_icon_item(_pd.adesivo, _scx, _scy, 17 * _s);
            } else if (_k >= _slots) {
                draw_set_halign(fa_center); draw_set_valign(fa_middle);
                ui_text(_scx, _scy, (_k == 1 ? "Nv3" : "Nv5"), make_color_rgb(235, 225, 215), _te(5, _fh, _s));
                draw_set_halign(fa_left); draw_set_valign(fa_top);
            } else {
                draw_set_halign(fa_center); draw_set_valign(fa_middle);
                ui_text(_scx, _scy, "+", make_color_rgb(250, 240, 225), _te(8, _fh, _s), make_color_rgb(150, 125, 100));
                draw_set_halign(fa_left); draw_set_valign(fa_top);
            }
        }
        if (_sel_d.inata != "") {
            var _pi = global.passivas_db[$ _sel_d.inata];
            var _ix = ux(_ox + 95);
            var _hw = ux(_of[2] - 3) - _ix;
            ui_rrect(_ix, uy(_ay + 2), _ix + _hw, uy(_ay + 12), 5 * _s, make_color_rgb(255, 228, 150));
            ui_icon_item(_pi.adesivo, _ix + 5 * _s, uy(_ay + 7), 12 * _s);
            draw_set_valign(fa_middle);
            ui_text_fit(_ix + 11 * _s, uy(_ay + 7), _pi.nome, make_color_rgb(140, 80, 10), _te(6, _fh, _s), _hw - 13 * _s);
            draw_set_valign(fa_top);
        }

        // ---------- Custo + MELHORAR ----------
        var _c = item_upgrade_custo(selected_slot);
        var _b = lay_btn_up;
        if (_c.maximo) {
            ui_pill(ux(_ox), uy(_b[1] + 2), 12 * _s, "NÍVEL MÁXIMO!", ui_cor("ouro"), c_white, _te(7, _fh, _s), make_color_rgb(150, 90, 10));
            ui_button(ux(_b[0]), uy(_b[1]), ux(_b[2]), uy(_b[3]), "MÁX", false, ui_cor("ouro"), _te(7.5, _fh, _s), _mx, _my);
        } else {
            var _tem_m = global.moedas >= _c.moedas;
            var _qpo = inventory_count_item("po_estrela");
            var _tem_p = _qpo >= _c.po;
            var _cy = uy(_b[1] + 8);
            var _ts_c = _te(7, _fh, _s);
            var _x0 = ux(_ox);
            ui_rrect(_x0, _cy - 6 * _s, ux(_b[0] - 3), _cy + 6 * _s, 6 * _s, ui_cor("papel2"));
            ui_moeda(_x0 + 6 * _s, _cy, 4 * _s);
            draw_set_valign(fa_middle);
            ui_text(_x0 + 12 * _s, _cy, string(_c.moedas), _tem_m ? make_color_rgb(255, 215, 90) : make_color_rgb(255, 110, 100), _ts_c, ui_cor("escuro"));
            var _x1p = _x0 + 12 * _s + string_width(string(_c.moedas)) * _ts_c + 7 * _s;
            ui_icon_item("po_estrela", _x1p + 5 * _s, _cy, 13 * _s);
            ui_text(_x1p + 11 * _s, _cy, string(_qpo) + "/" + string(_c.po), _tem_p ? make_color_rgb(200, 160, 255) : make_color_rgb(255, 110, 100), _ts_c, ui_cor("escuro"));
            draw_set_valign(fa_top);
            ui_button(ux(_b[0]), uy(_b[1]), ux(_b[2]), uy(_b[3]), "MELHORAR", _tem_m && _tem_p, make_color_rgb(240, 160, 30), _te(7, _fh, _s), _mx, _my);
        }
    } else {
        // ---------- Consumível / material / adesivo ----------
        var _info = [];
        if (_sel_d.tipo == "uso") {
            var _cura = item_stat(_sel_id, "cura", 1);
            if (_cura > 0) array_push(_info, ["vida", "+" + string(_cura) + " Vida", make_color_rgb(120, 240, 140)]);
            for (var _k = 0; _k < array_length(_sel_d.buffs); _k++) {
                var _bf = _sel_d.buffs[_k];
                var _inf = item_stat_info(_bf.stat);
                array_push(_info, [_bf.stat, "+" + item_num_str(_bf.valor) + _inf.sufixo + " " + string(_bf.seg) + "s", _inf.cor]);
            }
        } else if (_sel_d.tipo == "adesivo") {
            var _pd = global.passivas_db[$ _sel_d.passiva_adesivo];
            array_push(_info, [_pd.stat == "mata_fantasma" ? "" : _pd.stat, _pd.nome, _pd.cor]);
        }
        var _sx = ux(_ox);
        var _sy = uy(_oy + 30);
        var _hs = 11 * _s;
        var _ts_s = _te(6.2, _fh, _s);
        for (var _k = 0; _k < array_length(_info); _k++) {
            var _wc = _hs * 1.2 + string_width(_info[_k][1]) * _ts_s + _hs * 0.4;
            if (_sx + _wc > ux(_of[2] - 3)) break;
            ui_rrect(_sx, _sy, _sx + _wc, _sy + _hs, _hs / 2, ui_cor("escuro"), 0.85);
            if (_info[_k][0] != "") ui_icon_item(ui_icone_stat(_info[_k][0]), _sx + _hs * 0.6, _sy + _hs / 2, _hs * 1.1);
            draw_set_valign(fa_middle);
            ui_text(_sx + _hs * 1.2, _sy + _hs / 2, _info[_k][1], _info[_k][2], _ts_s);
            draw_set_valign(fa_top);
            _sx += _wc + 2 * _s;
        }
        var _dy = (array_length(_info) > 0) ? _oy + 44 : _oy + 31;
        var _ts_d = _te(6.5, _fh, _s);
        draw_set_color(ui_cor("texto"));
        draw_text_ext_transformed(ux(_ox), uy(_dy), _sel_d.desc, _fh * 1.05, (_of[2] - _of[0] - 10) * _s / _ts_d, _ts_d, _ts_d, 0);
        draw_set_color(c_white);

        var _b = lay_btn_up;
        ui_pill(ux(_ox), uy(_b[1] + 2), 12 * _s, "x" + string(_grid[# INFOS.QUANTIDADE, selected_slot]) + " na mochila", ui_cor("borda"), c_white, _te(6.5, _fh, _s));
        if (_sel_d.tipo == "uso") {
            ui_button(ux(_b[0]), uy(_b[1]), ux(_b[2]), uy(_b[3]), "USAR", true, make_color_rgb(80, 175, 70), _te(7.5, _fh, _s), _mx, _my);
        } else if (_sel_d.tipo == "adesivo") {
            draw_set_halign(fa_right);
            ui_text(ux(_b[2]), uy(_b[1] + 3), "Arraste até um equipamento", ui_cor("texto2"), _te(5.8, _fh, _s), _tx_cl);
            draw_set_halign(fa_left);
        }
    }
}

// ============================================================================
// 6. CRAFT (cards com scroll — receitas prontas primeiro)
// ============================================================================
var _n_rec = array_length(craft_ordem);
var _cr = lay_craft;
var _tx_cl = make_color_rgb(250, 241, 224);
ui_card(ux(_cr[0]), uy(_cr[1]), ux(_cr[2] + 1), uy(_cr[3] + 1), 4 * _s, ui_cor("papel2"), ui_cor("borda2"), max(1, _s * .8), false);
var _wt = ui_tab(ux(_cr[0] + 5), uy(_cr[1] - 13), 12 * _s, "CRAFT", make_color_rgb(70, 150, 70), _te(8, _fh, _s));
var _prontas = ds_list_size(crafts_disponiveis);
ui_pill(ux(_cr[0] + 5) + _wt + 3 * _s, uy(_cr[1] - 11), 9 * _s, string(_prontas) + " prontas  de " + string(_n_rec),
        _prontas > 0 ? make_color_rgb(82, 176, 72) : ui_cor("borda"), c_white, _te(6, _fh, _s));

for (var _l = 0; _l < craft_linhas; _l++) {
    var _ri = craft_scroll + _l;
    if (_ri >= _n_rec) break;
    var _rec = global.receitas_craft[craft_ordem[_ri]];
    var _rd  = item_db(_rec.resultado);
    var _ok  = player_has_all_ingredients(_rec);
    var _row = craft_row_rect(_l);
    var _rar = item_raridade(_rd.raridade);
    var _hov = (hover_craft == _l);

    // card da linha
    var _fill = _ok ? ui_cor("chip") : make_color_rgb(214, 198, 176);
    if (_hov) _fill = merge_color(_fill, c_white, 0.3);
    ui_card(_row[0], _row[1] + 1 * _s, _row[2], _row[3] - 1 * _s, 4 * _s, _fill, _ok ? make_color_rgb(96, 150, 70) : ui_cor("borda2"), max(1, _s * .8), _hov);

    // ícone com moldura da raridade
    var _rh = _row[3] - _row[1];
    var _isz = _rh - 6 * _s;
    var _ix1 = _row[0] + 3 * _s, _iy1 = _row[1] + 3 * _s;
    ui_rrect(_ix1, _iy1, _ix1 + _isz, _iy1 + _isz, 3 * _s, merge_color(_rar.cor, c_black, 0.35));
    ui_rrect(_ix1 + _s, _iy1 + _s, _ix1 + _isz - _s, _iy1 + _isz - _s, 2 * _s, merge_color(_rar.cor, ui_cor("papel"), 0.7));
    ui_icon(_rd.spr, _rd.img, _ix1 + _isz / 2, _iy1 + _isz / 2, _isz * 1.12, _ok ? 1 : 0.6);
    if (_rec.qtd_resultado > 1) {
        draw_set_halign(fa_right); draw_set_valign(fa_bottom);
        ui_text(_ix1 + _isz - 1 * _s, _iy1 + _isz, "x" + string(_rec.qtd_resultado), c_white, _te(6, _fh, _s));
        draw_set_halign(fa_left); draw_set_valign(fa_top);
    }

    // nome
    var _btn = craft_btn_rect(_l);
    var _nx = _ix1 + _isz + 4 * _s;
    ui_text_fit(_nx, _row[1] + 3 * _s, _rd.nome, _rar.cor, _te(7.5, _fh, _s), _btn[0] - _nx - 3 * _s);

    // ingredientes (pílulas ícone + tem/precisa)
    var _px = _nx;
    var _py = _row[1] + 14 * _s;
    var _ph = 10 * _s;
    var _ts_i = _te(6, _fh, _s);
    for (var _j = 0; _j < array_length(_rec.ingredientes); _j++) {
        var _req = _rec.ingredientes[_j];
        var _tem = inventory_count_item(_req.item);
        var _bom = _tem >= _req.qtd;
        var _txt_q = string(min(_tem, 99)) + "/" + string(_req.qtd);
        var _wq = _ph * 1.05 + string_width(_txt_q) * _ts_i + _ph * 0.35;
        if (_px + _wq > _btn[0] - 2 * _s) {
            draw_set_valign(fa_middle);
            ui_text(_px, _py + _ph / 2, "...", ui_cor("texto2"), _ts_i, _tx_cl);
            draw_set_valign(fa_top);
            break;
        }
        ui_rrect(_px, _py, _px + _wq, _py + _ph, _ph / 2, _bom ? make_color_rgb(206, 236, 190) : make_color_rgb(250, 208, 198));
        ui_icon_item(_req.item, _px + _ph * 0.55, _py + _ph / 2, _ph * 1.2);
        draw_set_valign(fa_middle);
        ui_text(_px + _ph * 1.05, _py + _ph / 2, _txt_q, _bom ? make_color_rgb(40, 130, 40) : make_color_rgb(200, 50, 40), _ts_i, _bom ? make_color_rgb(230, 248, 220) : make_color_rgb(255, 232, 226));
        draw_set_valign(fa_top);
        _px += _wq + 2 * _s;
    }

    // botão CRIAR
    ui_button(_btn[0], _btn[1], _btn[2], _btn[3], "CRIAR", _ok, make_color_rgb(80, 175, 70), _te(7, _fh, _s), _mx, _my);
}

// barra de rolagem
if (_n_rec > craft_linhas) {
    var _sx1 = ux(_cr[2] - 6), _sx2 = ux(_cr[2] - 2);
    var _sy1 = uy(_cr[1] + 3), _sy2 = uy(_cr[3] - 3);
    ui_rrect(_sx1, _sy1, _sx2, _sy2, 2 * _s, make_color_rgb(170, 140, 110));
    var _th = max(8 * _s, (_sy2 - _sy1) * craft_linhas / _n_rec);
    var _tp = _sy1 + (_sy2 - _sy1 - _th) * (craft_scroll / max(1, _n_rec - craft_linhas));
    ui_rrect(_sx1, _tp, _sx2, _tp + _th, 2 * _s, ui_cor("borda"));
    ui_rrect(_sx1 + _s * .6, _tp + _s, _sx1 + (_sx2 - _sx1) * 0.5, _tp + _th - _s, _s, c_white, 0.25);
}

// ============================================================================
// 7. ITEM ARRASTADO
// ============================================================================
if (drag_ativo && drag_slot != -1 && _grid[# INFOS.ITEM, drag_slot] != -1) {
    var _dspr = _grid[# INFOS.SPRITE, drag_slot];
    if (sprite_exists(_dspr)) draw_sprite_ext(_dspr, _grid[# INFOS.IMAGE_IND, drag_slot], _mx - sprite_get_width(_dspr) * _s / 2, _my - sprite_get_height(_dspr) * _s / 2, _s, _s, 0, c_white, 0.85);
}

// ============================================================================
// 8. TOOLTIP (ao passar o mouse em cima)
// ============================================================================
var _tip = undefined;
if (!drag_ativo) {
    if (hover_slot != -1 && _grid[# INFOS.ITEM, hover_slot] != -1) {
        var _hid = _grid[# INFOS.ITEM, hover_slot];
        if (!is_undefined(item_db(_hid))) {
            _tip = item_tooltip_linhas(_hid, _grid[# INFOS.NIVEL, hover_slot], _grid[# INFOS.PASSIVAS, hover_slot],
                                       _grid[# INFOS.QUANTIDADE, hover_slot], inventory_slot_e_equip(hover_slot) ? "equipado" : "mochila");
        } else {
            _tip = [ { t: string(_grid[# INFOS.NOME, hover_slot]), c: c_white, s: 1.25 },
                     { t: string(_grid[# INFOS.DESCRICAO, hover_slot]), c: make_color_rgb(230, 220, 205), s: 0.9, wrap: true } ];
        }
    } else if (hover_craft != -1) {
        var _rec_h = global.receitas_craft[craft_ordem[craft_scroll + hover_craft]];
        _tip = item_tooltip_linhas(_rec_h.resultado, 1, [], _rec_h.qtd_resultado, "craft");
    }
}

if (!is_undefined(_tip)) {
    var _base = _te(9.5, _fh, _s);        // escala de texto base do tooltip
    var _pad  = 6 * _s;
    var _maxw = 170 * _s;
    // mede
    var _tw = 0, _th = 0;
    for (var _k = 0; _k < array_length(_tip); _k++) {
        var _ln = _tip[_k];
        var _sc = _base * _ln.s;
        var _w, _h;
        if (variable_struct_exists(_ln, "wrap")) {
            _w = min(_maxw, string_width_ext(_ln.t, -1, _maxw / _sc) * _sc);
            _h = string_height_ext(_ln.t, -1, _maxw / _sc) * _sc;
        } else {
            _w = string_width(_ln.t) * _sc;
            if (variable_struct_exists(_ln, "estrelas")) _w += ITEM_NIVEL_MAX * 9 * _s + 6 * _s;
            _h = _fh * _sc;
        }
        _tw = max(_tw, _w);
        _th += _h + 1.5 * _s;
    }
    var _bw = _tw + _pad * 2, _bh = _th + _pad * 2;
    var _tx = _mx + 14 * _s, _ty = _my + 10 * _s;
    if (_tx + _bw > _gw - 4) _tx = _mx - _bw - 10 * _s;
    if (_ty + _bh > _gh - 4) _ty = _gh - 4 - _bh;
    _tx = max(4, _tx); _ty = max(4, _ty);

    // caixa
    draw_set_alpha(0.93); draw_set_color(make_color_rgb(40, 24, 20));
    draw_roundrect_ext(_tx, _ty, _tx + _bw, _ty + _bh, 6 * _s, 6 * _s, false);
    draw_set_alpha(1);
    var _cor_borda = make_color_rgb(230, 150, 40);
    var _d_tip = (hover_slot != -1) ? item_db(_grid[# INFOS.ITEM, hover_slot]) : undefined;
    if (!is_undefined(_d_tip)) _cor_borda = item_raridade(_d_tip.raridade).cor;
    draw_set_color(_cor_borda);
    for (var _k = 0; _k < max(1, _s); _k++) draw_roundrect_ext(_tx + _k, _ty + _k, _tx + _bw - _k, _ty + _bh - _k, 6 * _s, 6 * _s, true);

    // linhas
    var _yy = _ty + _pad;
    for (var _k = 0; _k < array_length(_tip); _k++) {
        var _ln = _tip[_k];
        var _sc = _base * _ln.s;
        if (variable_struct_exists(_ln, "wrap")) {
            draw_set_color(_ln.c);
            draw_text_ext_transformed(_tx + _pad, _yy, _ln.t, -1, _maxw / _sc, _sc, _sc, 0);
            _yy += string_height_ext(_ln.t, -1, _maxw / _sc) * _sc + 1.5 * _s;
        } else {
            ui_text(_tx + _pad, _yy, _ln.t, _ln.c, _sc);
            if (variable_struct_exists(_ln, "estrelas")) {
                var _sx0 = _tx + _pad + string_width(_ln.t) * _sc + 8 * _s;
                for (var _q = 0; _q < ITEM_NIVEL_MAX; _q++) {
                    draw_estrela(_sx0 + _q * 9 * _s, _yy + _fh * _sc / 2, 3.4 * _s, (_q < _ln.estrelas) ? make_color_rgb(255, 210, 50) : make_color_rgb(90, 80, 70));
                }
            }
            _yy += _fh * _sc + 1.5 * _s;
        }
        // linha separadora depois do cabeçalho
        if (_k == 1) { draw_set_color(make_color_rgb(110, 80, 60)); draw_line(_tx + _pad, _yy, _tx + _bw - _pad, _yy); _yy += 1.5 * _s; }
    }
    draw_set_color(c_white);
}

// ============================================================================
// 9. MENSAGEM RÁPIDA
// ============================================================================
if (msg_timer > 0 && msg_texto != "") {
    draw_set_halign(fa_center); draw_set_valign(fa_top);
    draw_set_alpha(min(1, msg_timer / 30));
    var _my_msg = inventory_y + inventory_h + 6 * _s;
    if (_my_msg + _fh * _te(10, _fh, _s) > _gh) _my_msg = 8;
    ui_text(_gw / 2, _my_msg, msg_texto, msg_cor, _te(10, _fh, _s));
    draw_set_alpha(1);
    draw_set_halign(fa_left);
}

} // fim do "if (is_open)" — painel completo da mochila

// ============================================================================
// 10. PAINEL DO BAÚ ABERTO (E perto de um obj_bau_jogador) — ver itens_geral.gml
//     Desenhado aqui (não no próprio baú) pra ficar sempre em GUI, do lado da mochila,
//     independente da mochila completa estar aberta ou não.
// ============================================================================
if (instance_exists(global.bau_aberto)) {
    var _bau = global.bau_aberto;
    var _gx_m = device_mouse_x_to_gui(0);
    var _gy_m = device_mouse_y_to_gui(0);

    var _cols  = 6;
    var _tam   = 56;
    var _pad   = 6;
    var _bw2   = _cols * (_tam + _pad) + 40;
    var _linhas_bau = ceil(_bau.slots / _cols);
    var _bag   = inventory_bag_slots();
    var _linhas_bag = ceil(_bag / _cols);

    // Painel do baú à direita da tela; a mochila (quando aberta) fica no lugar normal dela
    var _px = display_get_gui_width() - _bw2 - 20;
    var _py = 160;

    draw_set_font(fnt_status);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_alpha(0.85); draw_set_color(c_black);
    draw_rectangle(_px - 20, _py - 40, _px + _bw2 - 20, _py + (_linhas_bau + _linhas_bag) * (_tam + _pad) + 70, false);
    draw_set_alpha(1); draw_set_color(c_white);
    draw_text(_px, _py - 35, "Baú (" + string(_bau.slots) + " espaços) — E fecha");

    for (var _i = 0; _i < _bau.slots; _i++) {
        var _col = _i mod _cols, _lin = _i div _cols;
        var _sx = _px + _col * (_tam + _pad);
        var _sy = _py + _lin * (_tam + _pad);

        draw_set_color(c_gray);
        draw_rectangle(_sx, _sy, _sx + _tam, _sy + _tam, true);

        var _item = _bau.grid[# INFOS.ITEM, _i];
        if (_item != -1) {
            draw_sprite_ext(_bau.grid[# INFOS.SPRITE, _i], _bau.grid[# INFOS.IMAGE_IND, _i], _sx + _tam / 2, _sy + _tam / 2, 2, 2, 0, c_white, 1);
            var _q = _bau.grid[# INFOS.QUANTIDADE, _i];
            if (_q > 1) {
                draw_set_halign(fa_right); draw_set_valign(fa_bottom); draw_set_color(c_yellow);
                draw_text(_sx + _tam - 2, _sy + _tam - 2, string(_q));
                draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
            }
        }

        if (point_in_rectangle(_gx_m, _gy_m, _sx, _sy, _sx + _tam, _sy + _tam) && mouse_check_button_pressed(mb_left)) {
            bau_slot_click(_bau, _i);
        }
    }

    // Mochila simplificada embaixo, pra guardar itens no baú (clique guarda no primeiro espaço livre)
    var _py2 = _py + _linhas_bau * (_tam + _pad) + 30;
    draw_set_color(c_white);
    draw_text(_px, _py2 - 20, "Mochila — clique guarda no baú");

    for (var _j = 0; _j < _bag; _j++) {
        var _col2 = _j mod _cols, _lin2 = _j div _cols;
        var _sx2 = _px + _col2 * (_tam + _pad);
        var _sy2 = _py2 + _lin2 * (_tam + _pad);

        draw_set_color(c_dkgray);
        draw_rectangle(_sx2, _sy2, _sx2 + _tam, _sy2 + _tam, true);

        var _item2 = global.grid_itens[# INFOS.ITEM, _j];
        if (_item2 != -1) {
            draw_sprite_ext(global.grid_itens[# INFOS.SPRITE, _j], global.grid_itens[# INFOS.IMAGE_IND, _j], _sx2 + _tam / 2, _sy2 + _tam / 2, 2, 2, 0, c_white, 1);
        }

        if (point_in_rectangle(_gx_m, _gy_m, _sx2, _sy2, _sx2 + _tam, _sy2 + _tam) && mouse_check_button_pressed(mb_left)) {
            bau_guardar_item(_bau, _j);
        }
    }

    draw_set_color(c_white);
}
draw_set_color(c_white);
