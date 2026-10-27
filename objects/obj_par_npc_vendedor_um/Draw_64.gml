// feather disable GM2017
/// @desc Loja do vendedor (Draw GUI)
/// O layout segue os pixels do spr_loja_fundo_vendedor (346x320):
///   grade 6x3 de espaços (colunas x = 24,74,125,176,227,278 | linhas y = 23,77,131 | 42x45 cada)
///   caixa pequena (19,213)-(105,231): suas moedas
///   caixa grande (147,213)-(326,302): detalhes do item
///   espaço livre embaixo da caixa pequena: botão COMPRAR
/// Tudo é escalado pela altura/largura da GUI (antes usava 1920x1088 fixo e textos em pixels de tela).
if (!venda_aberta) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

var _spr = spr_loja_fundo_vendedor;
var _fw = sprite_get_width(_spr), _fh_spr = sprite_get_height(_spr);
// escala (em passos de 0.25) que cabe em 90% x 82% da tela
var _s = min((_gw * 0.9) / _fw, (_gh * 0.82) / _fh_spr);
_s = max(0.5, floor(_s * 4) / 4);
var _ox = round((_gw - _fw * _s) / 2);
var _oy = round((_gh - _fh_spr * _s) / 2);

draw_set_font(fnt_descricao);
var _fh = max(1, string_height("Ag"));
var _te = function(_px_sprite, _fh_, _s_) { return (_px_sprite * _s_) / _fh_; }; // texto com N px do sprite de altura

// ---------- fundo ----------
draw_set_alpha(0.7); draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);
draw_sprite_ext(_spr, 0, _ox, _oy, _s, _s, 0, c_white, 1);

// título
draw_set_halign(fa_center); draw_set_valign(fa_bottom);
ui_text(_gw / 2, _oy - 4 * _s, "LOJA", make_color_rgb(255, 215, 100), _te(11, _fh, _s));

// ---------- grade de itens ----------
var _cols_x = [24, 74, 125, 176, 227, 278];
var _rows_y = [23, 77, 131];
var _cw = 42, _ch = 45;
var _n = min(ds_grid_height(inventario_venda), 18);
var _hover = -1;

for (var _i = 0; _i < _n; _i++) {
    var _x1 = _ox + _cols_x[_i mod 6] * _s;
    var _y1 = _oy + _rows_y[_i div 6] * _s;
    var _x2 = _x1 + _cw * _s, _y2 = _y1 + _ch * _s;
    var _tem = (inventario_venda[# INFOS.ITEM, _i] != -1);
    var _sobre = point_in_rectangle(_mx, _my, _x1, _y1, _x2, _y2);

    if (_sobre) {
        draw_set_alpha(0.25); draw_set_color(c_white);
        draw_rectangle(_x1, _y1, _x2, _y2, false);
        draw_set_alpha(1);
        if (_tem) _hover = _i;
        if (mouse_check_button_pressed(mb_left)) global.item_selecionado_venda = _tem ? _i : -1;
        // botão direito compra direto
        if (_tem && mouse_check_button_pressed(mb_right)) { global.item_selecionado_venda = _i; loja_comprar = true; }
    }

    if (_tem) {
        var _preco = inventario_venda[# INFOS.PRECO, _i];
        var _pode = (global.moedas >= _preco);
        // ícone centralizado, cabendo no espaço (deixa a faixa de baixo pro preço)
        ui_icon(inventario_venda[# INFOS.SPRITE, _i], inventario_venda[# INFOS.IMAGE_IND, _i],
                (_x1 + _x2) / 2, _y1 + 19 * _s, 34 * _s, _pode ? 1 : 0.55);
        // preço: moedinha + valor na faixa de baixo do espaço
        var _ts_p = _te(7, _fh, _s);
        var _txt_p = string(_preco);
        var _wp = string_width(_txt_p) * _ts_p + 8 * _s;
        var _pcx = (_x1 + _x2) / 2, _pcy = _y2 - 5 * _s;
        ui_moeda(_pcx - _wp / 2 + 3 * _s, _pcy, 2.6 * _s);
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        ui_text(_pcx - _wp / 2 + 7 * _s, _pcy, _txt_p, _pode ? make_color_rgb(255, 220, 90) : make_color_rgb(255, 110, 100), _ts_p);
        // quantidade (consumíveis)
        var _q = inventario_venda[# INFOS.QUANTIDADE, _i];
        if (is_real(_q) && _q > 1) {
            draw_set_halign(fa_right); draw_set_valign(fa_top);
            ui_text(_x2 - 2 * _s, _y1 + 1 * _s, "x" + string(_q), c_white, _te(6.5, _fh, _s));
        }
    }

    // borda do selecionado
    if (global.item_selecionado_venda == _i) {
        draw_set_color(make_color_rgb(120, 255, 120));
        for (var _b = 0; _b < max(1, round(_s * 0.7)); _b++) draw_rectangle(_x1 + _b, _y1 + _b, _x2 - _b, _y2 - _b, true);
    }
}

// ---------- caixa pequena: moedas ----------
var _mx1 = _ox + 19 * _s, _my1 = _oy + 213 * _s, _mx2 = _ox + 105 * _s, _my2 = _oy + 231 * _s;
var _mcy = (_my1 + _my2) / 2;
ui_moeda(_mx1 + 8 * _s, _mcy, 4.5 * _s);
draw_set_halign(fa_left); draw_set_valign(fa_middle);
ui_text_fit(_mx1 + 15 * _s, _mcy, string(global.moedas), make_color_rgb(255, 220, 90), _te(9, _fh, _s), _mx2 - _mx1 - 18 * _s);

// ---------- botão COMPRAR (embaixo da caixa de moedas) ----------
var _sel = global.item_selecionado_venda;
var _sel_ok = (_sel >= 0 && _sel < ds_grid_height(inventario_venda) && inventario_venda[# INFOS.ITEM, _sel] != -1);
var _bx1 = _ox + 19 * _s, _by1 = _oy + 253 * _s, _bx2 = _ox + 105 * _s, _by2 = _oy + 273 * _s;
var _ativo = _sel_ok && global.moedas >= inventario_venda[# INFOS.PRECO, _sel];
ui_button(_bx1, _by1, _bx2, _by2, "COMPRAR", _ativo, make_color_rgb(90, 180, 70), _te(8, _fh, _s), _mx, _my);
if (_sel_ok && point_in_rectangle(_mx, _my, _bx1, _by1, _bx2, _by2) && mouse_check_button_pressed(mb_left)) loja_comprar = true;

// mensagem (comprou / sem moedas / mochila cheia)
if (loja_msg_timer > 0) {
    loja_msg_timer--;
    draw_set_halign(fa_center); draw_set_valign(fa_top);
    draw_set_alpha(min(1, loja_msg_timer / 20));
    ui_text((_bx1 + _bx2) / 2, _by2 + 5 * _s, loja_msg, loja_msg_cor, _te(6.5, _fh, _s));
    draw_set_alpha(1);
}

// ---------- caixa grande: detalhes (hover > selecionado) ----------
var _dx1 = _ox + 150 * _s, _dy1 = _oy + 216 * _s, _dx2 = _ox + 323 * _s, _dy2 = _oy + 299 * _s;
var _info = (_hover != -1) ? _hover : (_sel_ok ? _sel : -1);
draw_set_halign(fa_left); draw_set_valign(fa_top);
if (_info != -1) {
    var _iid = item_id_por_nome(inventario_venda[# INFOS.NOME, _info]);
    var _L = [];
    if (!is_undefined(_iid)) {
        _L = item_tooltip_linhas(_iid, 1, [], inventario_venda[# INFOS.QUANTIDADE, _info], "loja");
        // tira a linha "Valor: X moedas" (o preço da loja é outro)
        if (array_length(_L) > 0 && string_pos("Valor:", _L[array_length(_L) - 1].t) == 1) array_pop(_L);
    } else {
        array_push(_L, { t: inventario_venda[# INFOS.NOME, _info], c: c_white, s: 1.25 });
        array_push(_L, { t: inventario_venda[# INFOS.DESCRICAO, _info], c: make_color_rgb(230, 220, 205), s: 0.9, wrap: true });
    }
    array_push(_L, { t: "Preço: " + string(inventario_venda[# INFOS.PRECO, _info]) + " moedas", c: make_color_rgb(255, 215, 100), s: 0.95 });

    // escala do texto: começa grande e diminui até caber na caixa
    var _bw = _dx2 - _dx1, _bh = _dy2 - _dy1;
    var _base = _te(8.5, _fh, _s);
    repeat (12) {
        var _tot = 0;
        for (var _k = 0; _k < array_length(_L); _k++) {
            var _sc = _base * _L[_k].s;
            _tot += variable_struct_exists(_L[_k], "wrap") ? string_height_ext(_L[_k].t, -1, _bw / _sc) * _sc : _fh * _sc;
            _tot += _s;
        }
        if (_tot <= _bh) break;
        _base *= 0.9;
    }
    var _yy = _dy1;
    for (var _k = 0; _k < array_length(_L); _k++) {
        var _ln = _L[_k];
        var _sc = _base * _ln.s;
        if (variable_struct_exists(_ln, "wrap")) {
            draw_set_color(make_color_rgb(70, 46, 34));
            draw_text_ext_transformed(_dx1, _yy, _ln.t, -1, _bw / _sc, _sc, _sc, 0);
            _yy += string_height_ext(_ln.t, -1, _bw / _sc) * _sc + _s;
        } else {
            ui_text_fit(_dx1, _yy, _ln.t, _ln.c, _sc, _bw);
            _yy += _fh * _sc + _s;
        }
    }
} else {
    draw_set_color(make_color_rgb(110, 84, 66));
    var _sc0 = _te(8, _fh, _s);
    draw_text_ext_transformed(_dx1, _dy1, "Passe o mouse num item para ver os detalhes.\nClique para escolher e aperte COMPRAR\n(ou clique com o botão direito).", -1, (_dx2 - _dx1) / _sc0, _sc0, _sc0, 0);
}

// dica embaixo
draw_set_halign(fa_center); draw_set_valign(fa_top);
ui_text(_gw / 2, _oy + _fh_spr * _s + 4 * _s, "F: fechar", make_color_rgb(200, 190, 180), _te(7, _fh, _s));
draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);

// ---------- comprar (botão ou botão direito) ----------
if (loja_comprar) {
    loja_comprar = false;
    var _si = global.item_selecionado_venda;
    if (_si >= 0 && inventario_venda[# INFOS.ITEM, _si] != -1) {
        var _preco_c = inventario_venda[# INFOS.PRECO, _si];
        var _nome_c = inventario_venda[# INFOS.NOME, _si];
        var _antes = global.moedas;
        comprar_item_loja(_si);
        if (global.moedas < _antes) { loja_msg = "Comprou " + _nome_c + "!"; loja_msg_cor = make_color_rgb(140, 255, 140); }
        else if (_antes < _preco_c) { loja_msg = "Moedas insuficientes!";    loja_msg_cor = make_color_rgb(255, 110, 100); }
        else                         { loja_msg = "Mochila cheia!";           loja_msg_cor = make_color_rgb(255, 110, 100); }
        loja_msg_timer = 120;
    }
}
