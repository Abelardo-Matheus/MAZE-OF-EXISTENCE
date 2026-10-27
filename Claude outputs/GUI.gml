// feather disable GM2017
function relogio() {
    // --- Configuração ---
    var _x = display_get_gui_width() / 2;
    var _y = 120;
    var _pointer_len = 32;
    var _color_pointer = c_red;
    
    // --- Desenho Base ---
    draw_sprite_ext(spr_relogio, 0, _x, _y, 1, 1, 0, c_white, 1);
    
    // --- Cálculo do Ângulo ---
    // Timer total do ciclo
    var _total_cycle = global.day_night_cycle.day_duration + global.day_night_cycle.night_duration;
    
    // Mapeia o timer atual (0 a total) para um ângulo (180 a -180 para sentido horário começando da esquerda)
    // Ajuste o '180' e o '-' conforme a direção desejada da sua arte
    var _angle = 180 - ((global.timer / _total_cycle) * 360);
    
    // --- Desenho do Ponteiro ---
    draw_set_color(_color_pointer);
    draw_circle(_x, _y, 4, false); // Eixo central
    
    // Desenha a haste e a seta
    draw_clock_hand(_x, _y, _angle, _pointer_len, _color_pointer);
    
    // Reset de cor
    draw_set_color(c_white);
}

function draw_clock_hand(_x, _y, _angle, _len, _color) {
    // Calcula a ponta e a base da seta
    var _tip_x = _x + lengthdir_x(_len, _angle);
    var _tip_y = _y + lengthdir_y(_len, _angle);
    
    // A linha vai apenas até 90% do caminho para dar espaço à cabeça da seta
    var _line_end_x = _x + lengthdir_x(_len * 0.9, _angle);
    var _line_end_y = _y + lengthdir_y(_len * 0.9, _angle);
    
    // Desenha Linha
    draw_line_width_color(_x, _y, _line_end_x, _line_end_y, 3, _color, _color);
    
    // Desenha Cabeça da Seta (Triângulo)
    var _arrow_size = 8;
    var _angle_diff = 150; // Abertura da seta
    
    var _p1_x = _tip_x + lengthdir_x(_arrow_size, _angle + _angle_diff);
    var _p1_y = _tip_y + lengthdir_y(_arrow_size, _angle + _angle_diff);
    var _p2_x = _tip_x + lengthdir_x(_arrow_size, _angle - _angle_diff);
    var _p2_y = _tip_y + lengthdir_y(_arrow_size, _angle - _angle_diff);
    
    draw_primitive_begin(pr_trianglelist);
    draw_vertex_color(_tip_x, _tip_y, c_black, 1); // Ponta
    draw_vertex_color(_p1_x, _p1_y, c_black, 1);   // Lado A
    draw_vertex_color(_p2_x, _p2_y, c_black, 1);   // Lado B
    draw_primitive_end();
}
// ============================================================================
//  MINIMAPA DO MUNDO ABERTO (mini_mapa_vamp)
//  Pequeno no canto inferior direito; [M] abre o mapa grande.
//  No mapa grande: botão direito marca/desmarca um destino (obj_seta).
//  Ícones vetoriais (casa, inimigos, boss, vendedor, poste, missão, destino),
//  tudo em coordenadas da GUI e escalado pela altura da tela (_k), igual ao inventário.
// ============================================================================

#macro MINIMAPA_ESCALA_PEQ    0.021   // px da GUI por px do mundo (× _k) no mapa pequeno
#macro MINIMAPA_ESCALA_GRANDE 0.0075  // idem no mapa grande
#macro MINIMAPA_POSTES        true    // desenhar postes (pontinhos amarelos)

function minimapa_nome_bioma(_b) {
    switch (_b) {
        case "floresta":       return "Floresta";
        case "cidade":         return "Cidade";
        case "vazia":          return "Terra Vazia";
        case "floresta_negra": return "Floresta Negra";
        case "deserto":        return "Deserto";
        case "neve":           return "Neve";
        case "pantano":        return "Pântano";
        case "vulcanico":      return "Vulcânico";
        case "prado":          return "Prado";
        case "cristalino":     return "Cristalino";
    }
    return string(_b);
}

/// Tipo de ícone de uma entrada de global.posicoes_estruturas / posicoes_grupos_inimigos
function minimapa_tipo_entidade(_data) {
    if (array_length(_data) <= 5) return "inimigos";
    switch (_data[5]) {
        case "Casa":           return "casa";
        case "Poste":          return "poste";
        case "Grupo Inimigos": return "inimigos";
        case "Vendedor":       return "vendedor";
        case "BOSS":           return "boss";
    }
    return "outro";
}

function minimapa_nome_tipo(_tipo) {
    switch (_tipo) {
        case "casa":     return "Casa";
        case "poste":    return "Poste";
        case "inimigos": return "Grupo de inimigos";
        case "vendedor": return "Vendedor";
        case "boss":     return "Chefe";
    }
    return "Lugar";
}

/// Texto pequeno centralizado (ícones)
function minimapa_letra(_x, _y, _txt, _cor, _px, _contorno) {
    draw_set_font(fnt_descricao);
    var _fh = max(1, string_height("Ag"));
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    ui_text(_x, _y, _txt, _cor, _px / _fh, _contorno);
}

/// Desenha um ícone vetorial de tamanho _r (raio em px da GUI)
function minimapa_icone(_tipo, _x, _y, _r, _a = 1) {
    var _esc = ui_cor("escuro");
    var _b = max(1, _r * 0.28);              // espessura da borda
    draw_set_alpha(_a);
    switch (_tipo) {
        case "casa":
            draw_set_color(_esc);
            draw_rectangle(_x - _r * 0.72 - _b, _y - _r * 0.05 - _b, _x + _r * 0.72 + _b, _y + _r * 0.85 + _b, false);
            draw_triangle(_x - _r - _b * 1.4, _y + _b * 0.4, _x + _r + _b * 1.4, _y + _b * 0.4, _x, _y - _r - _b * 1.4, false);
            draw_set_color(make_color_rgb(250, 241, 224));
            draw_rectangle(_x - _r * 0.72, _y - _r * 0.05, _x + _r * 0.72, _y + _r * 0.85, false);
            draw_set_color(make_color_rgb(214, 80, 58));
            draw_triangle(_x - _r, _y, _x + _r, _y, _x, _y - _r, false);
            draw_set_color(make_color_rgb(122, 74, 46));
            draw_rectangle(_x - _r * 0.18, _y + _r * 0.35, _x + _r * 0.18, _y + _r * 0.85, false);   // porta
            break;

        case "poste":
            draw_set_color(_esc);
            draw_circle(_x, _y, _r * 0.5 + _b * 0.6, false);
            draw_set_color(make_color_rgb(255, 226, 120));
            draw_circle(_x, _y, _r * 0.5, false);
            break;

        case "inimigos":
            var _p = 1 + 0.12 * sin(current_time / 170);
            var _rr = _r * _p;
            draw_set_color(_esc);
            draw_circle(_x, _y, _rr + _b, false);
            draw_set_color(make_color_rgb(214, 58, 58));
            draw_circle(_x, _y, _rr, false);
            draw_set_color(c_white);                                    // olhinhos bravos
            draw_circle(_x - _rr * 0.38, _y - _rr * 0.08, max(1, _rr * 0.24), false);
            draw_circle(_x + _rr * 0.38, _y - _rr * 0.08, max(1, _rr * 0.24), false);
            draw_set_color(_esc);
            draw_circle(_x - _rr * 0.38, _y - _rr * 0.02, max(0.5, _rr * 0.11), false);
            draw_circle(_x + _rr * 0.38, _y - _rr * 0.02, max(0.5, _rr * 0.11), false);
            break;

        case "boss":
            var _p = 1 + 0.1 * sin(current_time / 140);
            var _rr = _r * _p;
            draw_set_alpha(_a * 0.35);
            draw_set_color(make_color_rgb(170, 60, 220));
            draw_circle(_x, _y, _rr * 1.6, false);                      // aura
            draw_set_alpha(_a);
            draw_set_color(_esc);
            draw_circle(_x, _y, _rr + _b, false);
            draw_set_color(make_color_rgb(120, 50, 170));
            draw_circle(_x, _y, _rr, false);
            draw_set_color(make_color_rgb(255, 200, 58));               // coroa
            var _cy = _y + _rr * 0.15, _cw = _rr * 0.62;
            draw_rectangle(_x - _cw, _cy, _x + _cw, _cy + _rr * 0.3, false);
            draw_triangle(_x - _cw, _cy, _x - _cw * 0.4, _cy, _x - _cw, _cy - _rr * 0.5, false);
            draw_triangle(_x - _cw * 0.4, _cy, _x + _cw * 0.4, _cy, _x, _cy - _rr * 0.62, false);
            draw_triangle(_x + _cw * 0.4, _cy, _x + _cw, _cy, _x + _cw, _cy - _rr * 0.5, false);
            break;

        case "vendedor":
            draw_set_color(_esc);
            draw_circle(_x, _y, _r + _b, false);
            draw_set_color(make_color_rgb(255, 200, 58));
            draw_circle(_x, _y, _r, false);
            draw_set_alpha(1);
            minimapa_letra(_x, _y, "$", ui_cor("texto"), _r * 1.5, make_color_rgb(255, 200, 58));
            break;

        case "destino":
            var _sobe = abs(sin(current_time / 260)) * _r * 0.35;
            var _py = _y - _sobe;
            draw_set_color(_esc);
            draw_triangle(_x - _r * 0.75 - _b, _py - _r * 0.2, _x + _r * 0.75 + _b, _py - _r * 0.2, _x, _py + _r * 1.25 + _b, false);
            draw_circle(_x, _py - _r * 0.55, _r * 0.8 + _b, false);
            draw_set_color(make_color_rgb(230, 60, 70));
            draw_triangle(_x - _r * 0.75, _py - _r * 0.2, _x + _r * 0.75, _py - _r * 0.2, _x, _py + _r * 1.25, false);
            draw_circle(_x, _py - _r * 0.55, _r * 0.8, false);
            draw_set_color(c_white);
            draw_circle(_x, _py - _r * 0.55, _r * 0.32, false);
            break;

        default:
            draw_set_color(_esc);
            draw_circle(_x, _y, _r * 0.6 + _b, false);
            draw_set_color(make_color_rgb(200, 190, 180));
            draw_circle(_x, _y, _r * 0.6, false);
            break;
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// Marcador da missão: círculo com "?" (não aceita) ou "!" (aceita) + anel pulsando
function minimapa_icone_missao(_x, _y, _r, _simb, _cor) {
    var _t = (current_time mod 1200) / 1200;                     // anel que se expande
    draw_set_alpha((1 - _t) * 0.8);
    draw_set_color(_cor);
    draw_circle(_x, _y, _r * (1 + _t * 1.3), true);
    draw_circle(_x, _y, _r * (1 + _t * 1.3) + 1, true);
    draw_set_alpha(1);
    draw_set_color(ui_cor("escuro"));
    draw_circle(_x, _y, _r + max(1.5, _r * 0.3), false);
    draw_set_color(_cor);
    draw_circle(_x, _y, _r, false);
    minimapa_letra(_x, _y, _simb, ui_cor("texto"), _r * 1.7, _cor);
}

/// Seta do jogador (aponta para onde ele está andando)
function minimapa_icone_jogador(_x, _y, _r, _ang) {
    var _ax = _x + lengthdir_x(_r * 1.25, _ang),        _ay = _y + lengthdir_y(_r * 1.25, _ang);
    var _bx = _x + lengthdir_x(_r, _ang + 140),         _by = _y + lengthdir_y(_r, _ang + 140);
    var _cx = _x + lengthdir_x(_r * 0.45, _ang + 180),  _cy = _y + lengthdir_y(_r * 0.45, _ang + 180);
    var _dx = _x + lengthdir_x(_r, _ang - 140),         _dy = _y + lengthdir_y(_r, _ang - 140);
    var _o = max(1.5, _r * 0.3);
    var _oax = _x + lengthdir_x(_r * 1.25 + _o * 1.6, _ang), _oay = _y + lengthdir_y(_r * 1.25 + _o * 1.6, _ang);
    var _obx = _x + lengthdir_x(_r + _o, _ang + 140),        _oby = _y + lengthdir_y(_r + _o, _ang + 140);
    var _odx = _x + lengthdir_x(_r + _o, _ang - 140),        _ody = _y + lengthdir_y(_r + _o, _ang - 140);
    var _ocx = _x + lengthdir_x(_r * 0.45 + _o, _ang + 180), _ocy = _y + lengthdir_y(_r * 0.45 + _o, _ang + 180);
    draw_set_color(ui_cor("escuro"));
    draw_triangle(_oax, _oay, _obx, _oby, _ocx, _ocy, false);
    draw_triangle(_oax, _oay, _odx, _ody, _ocx, _ocy, false);
    draw_set_color(c_white);
    draw_triangle(_ax, _ay, _bx, _by, _cx, _cy, false);
    draw_triangle(_ax, _ay, _dx, _dy, _cx, _cy, false);
    draw_set_color(make_color_rgb(70, 140, 222));
    draw_triangle(_ax, _ay, _bx, _by, _cx, _cy, false);
    draw_set_color(c_white);
}

/// Camada de desenho de cada tipo (mesma ordem de _camadas em mini_mapa_vamp)
function minimapa_camada(_tipo) {
    switch (_tipo) {
        case "poste": return 0; case "casa": return 1; case "inimigos": return 2;
        case "vendedor": return 3; case "boss": return 4;
    }
    return -1;
}

function mini_mapa_vamp() {
    static _ang_jog = 90;          // direção da seta do jogador
    static _ult_x = undefined;
    static _ult_y = undefined;
    if (tecla_apertou("mapa")) global.minimap_expandido = !global.minimap_expandido;
    if (!instance_exists(obj_player)) return;

    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _k  = max(1, _gh / 360);
    var _big = global.minimap_expandido;
    var _pxw = obj_player.x, _pyw = obj_player.y;

    // --- Moldura e área do mapa ---
    var _w, _h, _x1, _y1, _sc;
    if (_big) {
        _w = min(_gw - 40 * _k, 540 * _k);
        _h = min(_gh - 70 * _k, 300 * _k);
        _x1 = (_gw - _w) / 2;
        _y1 = (_gh - _h) / 2 + 6 * _k;
        _sc = MINIMAPA_ESCALA_GRANDE * _k;
    } else {
        _w = 100 * _k;
        _h = 100 * _k;
        _x1 = _gw - _w - 12 * _k;
        _y1 = _gh - _h - 24 * _k;
        _sc = MINIMAPA_ESCALA_PEQ * _k;
    }
    var _x2 = _x1 + _w, _y2 = _y1 + _h;
    var _cx = (_x1 + _x2) / 2, _cy = (_y1 + _y2) / 2;
    var _bw = max(2, round(2 * _k));

    if (_big) {                                              // escurece o jogo atrás
        draw_set_alpha(0.45); draw_set_color(c_black);
        draw_rectangle(0, 0, _gw, _gh, false);
        draw_set_alpha(1);
    }
    ui_card(_x1 - 5 * _k, _y1 - 5 * _k, _x2 + 5 * _k, _y2 + 5 * _k, 9 * _k, ui_cor("papel"), ui_cor("borda"), _bw);
    ui_rrect(_x1 - _bw, _y1 - _bw, _x2 + _bw, _y2 + _bw, 4 * _k, ui_cor("escuro"));
    draw_set_color(make_color_rgb(58, 44, 38));             // fundo "não explorado"
    draw_rectangle(_x1, _y1, _x2, _y2, false);

    // mundo -> mapa
    var _hw = (_w / 2) / _sc, _hh = (_h / 2) / _sc;

    // --- Biomas (só os blocos que aparecem) ---
    if (variable_global_exists("mapa_biomas") && !is_undefined(global.mapa_biomas) && variable_global_exists("tamanho_bloco")) {
        var _tb = global.tamanho_bloco;
        var _bx0 = floor((_pxw - _hw) / _tb), _bx1 = floor((_pxw + _hw) / _tb);
        var _by0 = floor((_pyw - _hh) / _tb), _by1 = floor((_pyw + _hh) / _tb);
        for (var _bx = _bx0; _bx <= _bx1; _bx++) {
            for (var _by = _by0; _by <= _by1; _by++) {
                var _bioma = global.mapa_biomas[? string(_bx) + "," + string(_by)];
                if (is_undefined(_bioma)) continue;
                var _cor = merge_color(terreno_cor_minimapa(_bioma), c_white, 0.08);
                var _dx1 = clamp(_cx + (_bx * _tb - _pxw) * _sc, _x1, _x2);
                var _dy1 = clamp(_cy + (_by * _tb - _pyw) * _sc, _y1, _y2);
                var _dx2 = clamp(_cx + ((_bx + 1) * _tb - _pxw) * _sc, _x1, _x2);
                var _dy2 = clamp(_cy + ((_by + 1) * _tb - _pyw) * _sc, _y1, _y2);
                if (_dx2 <= _dx1 || _dy2 <= _dy1) continue;
                draw_set_color(_cor);
                draw_rectangle(_dx1, _dy1, _dx2, _dy2, false);
            }
        }
        // grade suave (a cada meio bloco) para dar noção de distância
        var _passo = _tb / 2;
        draw_set_alpha(0.12); draw_set_color(c_black);
        for (var _gx = ceil((_pxw - _hw) / _passo) * _passo; _gx <= _pxw + _hw; _gx += _passo) {
            var _lx = _cx + (_gx - _pxw) * _sc;
            draw_line(_lx, _y1, _lx, _y2);
        }
        for (var _gy = ceil((_pyw - _hh) / _passo) * _passo; _gy <= _pyw + _hh; _gy += _passo) {
            var _ly = _cy + (_gy - _pyw) * _sc;
            draw_line(_x1, _ly, _x2, _ly);
        }
        draw_set_alpha(1);
    }

    // --- Área da câmera (retângulo branco fininho) ---
    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
    var _vw = camera_get_view_width(_cam), _vh = camera_get_view_height(_cam);
    draw_set_alpha(0.45); draw_set_color(c_white);
    draw_rectangle(clamp(_cx + (_vx - _pxw) * _sc, _x1, _x2), clamp(_cy + (_vy - _pyw) * _sc, _y1, _y2),
                   clamp(_cx + (_vx + _vw - _pxw) * _sc, _x1, _x2), clamp(_cy + (_vy + _vh - _pyw) * _sc, _y1, _y2), true);
    draw_set_alpha(1);

    // --- Entidades (desenhadas por camada: postes < casas < inimigos < vendedor < boss) ---
    var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
    var _hover = undefined, _hover_d = 999999;
    var _tam = _big ? 0.85 : 1;                              // ícones um pouco menores no mapa grande
    var _camadas = ["poste", "casa", "inimigos", "vendedor", "boss"];
    var _raios   = [1.7, 3.4, 3.0, 4.0, 5.0];
    var _listas  = [global.posicoes_estruturas, global.posicoes_grupos_inimigos];

    var _vis = [[], [], [], [], []];                         // 1 passada: separa os visíveis por camada
    for (var _l = 0; _l < array_length(_listas); _l++) {
        var _list = _listas[_l];
        if (!ds_exists(_list, ds_type_list)) continue;
        var _n = ds_list_size(_list);
        for (var _i = 0; _i < _n; _i++) {
            var _data = _list[| _i];
            var _tipo = (_l == 1) ? "inimigos" : minimapa_tipo_entidade(_data);
            if (_tipo == "outro") _tipo = "casa";
            var _c = minimapa_camada(_tipo);
            if (_c < 0 || (_tipo == "poste" && !MINIMAPA_POSTES)) continue;
            var _r = _raios[_c] * _k * _tam;
            var _ex = _cx + (_data[0] - _pxw) * _sc;
            var _ey = _cy + (_data[1] - _pyw) * _sc;
            if (_ex < _x1 + _r || _ex > _x2 - _r || _ey < _y1 + _r || _ey > _y2 - _r) {
                if (_tipo != "boss") continue;                    // o chefe fica preso na borda (direção)
                _ex = clamp(_ex, _x1 + _r, _x2 - _r);
                _ey = clamp(_ey, _y1 + _r, _y2 - _r);
            }
            array_push(_vis[_c], [_ex, _ey, _data]);
        }
    }
    for (var _c = 0; _c < array_length(_camadas); _c++) {
        var _tipo = _camadas[_c];
        var _r = _raios[_c] * _k * _tam;
        var _arr = _vis[_c];
        for (var _i = 0; _i < array_length(_arr); _i++) {
            var _ex = _arr[_i][0], _ey = _arr[_i][1], _data = _arr[_i][2];
            minimapa_icone(_tipo, _ex, _ey, _r);
            var _dm = point_distance(_mx, _my, _ex, _ey);
            if (_dm < max(_r * 1.6, 6 * _k) && _dm < _hover_d) {
                _hover_d = _dm;
                _hover = (_tipo == "casa" && array_length(_data) > 5) ? string(_data[5]) : minimapa_nome_tipo(_tipo);
            }
        }
    }

    // --- Destino marcado (obj_seta) ---
    if (instance_exists(obj_seta)) {
        var _r = 4 * _k;
        var _ax = clamp(_cx + (obj_seta.alvo_x - _pxw) * _sc, _x1 + _r, _x2 - _r);
        var _ay = clamp(_cy + (obj_seta.alvo_y - _pyw) * _sc, _y1 + _r * 2, _y2 - _r);
        minimapa_icone("destino", _ax, _ay, _r);
        if (point_distance(_mx, _my, _ax, _ay) < 8 * _k) _hover = "Destino marcado  (" + string(floor(point_distance(_pxw, _pyw, obj_seta.alvo_x, obj_seta.alvo_y) / 32)) + "m)";
    }

    // --- Missão (scr_missoes): "?" = ainda não aceita, "!" = aceita ---
    var _mk = missoes_marcador();
    if (!is_undefined(_mk)) {
        var _r = 5 * _k;
        var _qx = clamp(_cx + (_mk.x - _pxw) * _sc, _x1 + _r + 2 * _k, _x2 - _r - 2 * _k);
        var _qy = clamp(_cy + (_mk.y - _pyw) * _sc, _y1 + _r + 2 * _k, _y2 - _r - 2 * _k);
        minimapa_icone_missao(_qx, _qy, _r, _mk.simb, _mk.cor);
        if (point_distance(_mx, _my, _qx, _qy) < 9 * _k) _hover = _mk.texto + "  (" + string(floor(point_distance(_pxw, _pyw, _mk.x, _mk.y) / 32)) + "m)";
    }

    // --- Jogador (seta no centro, aponta para onde anda) ---
    if (!is_undefined(_ult_x) && point_distance(_ult_x, _ult_y, _pxw, _pyw) > 0.5) _ang_jog = point_direction(_ult_x, _ult_y, _pxw, _pyw);
    _ult_x = _pxw; _ult_y = _pyw;
    minimapa_icone_jogador(_cx, _cy, 4.5 * _k, _ang_jog);

    // --- Bússola ---
    minimapa_letra(_cx, _y1 + 6 * _k, "N", c_white, 7 * _k, ui_cor("escuro"));

    // --- Textos da moldura ---
    var _bioma_aqui = minimapa_nome_bioma(terreno_bioma_em(_pxw, _pyw));
    draw_set_font(fnt_descricao);
    var _fh = max(1, string_height("Ag"));
    if (_big) {
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        ui_text(_x1, _y1 - 14 * _k, "MAPA  -  " + _bioma_aqui, ui_cor("ouro"), (10 * _k) / _fh, ui_cor("escuro"));
        draw_set_halign(fa_right);
        ui_text(_x2, _y1 - 14 * _k, "[" + tecla_nome(tecla("mapa")) + "] fechar   Botão direito: marcar destino", c_white, (7 * _k) / _fh, ui_cor("escuro"));
        // Legenda
        var _leg = [["casa", "Casa"], ["inimigos", "Inimigos"], ["vendedor", "Vendedor"], ["boss", "Chefe"], ["destino", "Destino"]];
        var _lx = _x1, _ly = _y2 + 14 * _k;
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        for (var _i = 0; _i < array_length(_leg); _i++) {
            minimapa_icone(_leg[_i][0], _lx + 5 * _k, _ly, 3.6 * _k);
            draw_set_font(fnt_descricao); draw_set_halign(fa_left); draw_set_valign(fa_middle);
            ui_text(_lx + 12 * _k, _ly, _leg[_i][1], c_white, (7 * _k) / _fh, ui_cor("escuro"));
            _lx += 22 * _k + string_width(_leg[_i][1]) * (7 * _k) / _fh;
        }
        minimapa_icone_missao(_lx + 5 * _k, _ly, 3.6 * _k, "?", make_color_rgb(255, 200, 58));
        draw_set_font(fnt_descricao); draw_set_halign(fa_left); draw_set_valign(fa_middle);
        ui_text(_lx + 12 * _k, _ly, "Missão nova", c_white, (7 * _k) / _fh, ui_cor("escuro"));
        _lx += 22 * _k + string_width("Missão nova") * (7 * _k) / _fh;
        minimapa_icone_missao(_lx + 5 * _k, _ly, 3.6 * _k, "!", make_color_rgb(255, 140, 40));
        draw_set_font(fnt_descricao); draw_set_halign(fa_left); draw_set_valign(fa_middle);
        ui_text(_lx + 12 * _k, _ly, "Missão aceita", c_white, (7 * _k) / _fh, ui_cor("escuro"));
    } else {
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        ui_text_fit(_cx, _y2 + 12 * _k, _bioma_aqui, c_white, (8 * _k) / _fh, _w);
        draw_set_halign(fa_right); draw_set_valign(fa_bottom);
        ui_text(_x2 - 2 * _k, _y2 - 2 * _k, "[" + tecla_nome(tecla("mapa")) + "]", c_white, (6 * _k) / _fh, ui_cor("escuro"));
    }

    // --- Marcar destino com o botão direito (mapa grande) ---
    if (_big && mouse_check_button_pressed(mb_right) && point_in_rectangle(_mx, _my, _x1, _y1, _x2, _y2)) {
        var _clicou_no_marcador = false;
        if (instance_exists(obj_seta)) {
            var _sx = clamp(_cx + (obj_seta.alvo_x - _pxw) * _sc, _x1, _x2);
            var _sy = clamp(_cy + (obj_seta.alvo_y - _pyw) * _sc, _y1, _y2);
            if (point_distance(_mx, _my, _sx, _sy) < 10 * _k) {
                instance_destroy(obj_seta);
                _clicou_no_marcador = true;
                _hover = undefined;
            }
        }
        if (!_clicou_no_marcador) {
            var _mundo_x = ((_mx - _cx) / _sc) + _pxw;
            var _mundo_y = ((_my - _cy) / _sc) + _pyw;
            if (instance_exists(obj_seta)) {
                obj_seta.alvo_x = _mundo_x;
                obj_seta.alvo_y = _mundo_y;
            } else {
                var _seta = instance_create_layer(_pxw, _pyw, "Instances", obj_seta);
                _seta.alvo_x = _mundo_x;
                _seta.alvo_y = _mundo_y;
            }
        }
    }

    // --- Tooltip ---
    if (!is_undefined(_hover)) {
        draw_set_font(fnt_descricao);
        var _ts = (7.5 * _k) / _fh;
        var _tw = string_width(_hover) * _ts + 10 * _k, _th = 13 * _k;
        var _tx = clamp(_mx + 10 * _k, 4 * _k, _gw - _tw - 4 * _k);
        var _ty = clamp(_my - _th - 6 * _k, 4 * _k, _gh - _th - 4 * _k);
        ui_card(_tx, _ty, _tx + _tw, _ty + _th, 5 * _k, ui_cor("papel"), ui_cor("borda"), max(1, round(1.5 * _k)), true);
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        draw_set_color(ui_cor("texto"));
        draw_text_transformed(_tx + 5 * _k, _ty + _th / 2, _hover, _ts, _ts, 0);
    }

    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_alpha(1); draw_set_color(c_white);
}

// ============================================================================
//  MINIMAPA DAS SALAS (fase bebê) — mesma moldura do mapa do mundo
// ============================================================================
function mini_mapa_bebe() {
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _k  = max(1, _gh / 360);
    var _cell = 15 * _k;
    var _w = 100 * _k, _h = 100 * _k;
    var _x1 = _gw - _w - 12 * _k, _y1 = _gh - _h - 24 * _k;
    var _x2 = _x1 + _w, _y2 = _y1 + _h;
    var _cx = (_x1 + _x2) / 2, _cy = (_y1 + _y2) / 2;
    var _bw = max(2, round(2 * _k));

    ui_card(_x1 - 5 * _k, _y1 - 5 * _k, _x2 + 5 * _k, _y2 + 5 * _k, 9 * _k, ui_cor("papel"), ui_cor("borda"), _bw);
    ui_rrect(_x1 - _bw, _y1 - _bw, _x2 + _bw, _y2 + _bw, 4 * _k, ui_cor("escuro"));
    draw_set_color(make_color_rgb(58, 44, 38));
    draw_rectangle(_x1, _y1, _x2, _y2, false);

    if (!variable_global_exists("salas_geradas") || !variable_global_exists("current_sala")) return;
    var _lim_x = floor((_w / 2) / _cell - 0.5), _lim_y = floor((_h / 2) / _cell - 0.5);
    var _esc = (_cell - 2 * _k) / 64;                        // spr_salas tem 64 px

    for (var _i = 0; _i < array_length(global.salas_geradas); _i++) {
        var _sala = global.salas_geradas[_i];
        if (!is_array(_sala)) continue;
        var _rx = _sala[0], _ry = _sala[1];
        var _dx = _rx - global.current_sala[0];
        var _dy = _ry - global.current_sala[1];
        if (abs(_dx) > _lim_x || abs(_dy) > _lim_y) continue;
        var _sx = _cx + _dx * _cell, _sy = _cy - _dy * _cell;   // Y invertido (grid cartesiano)

        // Tipo: 0 normal, 1 templo, 2 jardim (boss)
        var _sub = 0;
        if (variable_global_exists("templos_salas_pos") && is_array(global.templos_salas_pos)) {
            for (var _j = 0; _j < array_length(global.templos_salas_pos); _j++) {
                var _t = global.templos_salas_pos[_j];
                if (_t[0] == _rx && _t[1] == _ry) { _sub = 1; break; }
            }
        }
        if (variable_global_exists("sala_jardim") && is_array(global.sala_jardim) && array_length(global.sala_jardim) > 0) {
            if (!is_array(global.sala_jardim[0])) {
                if (global.sala_jardim[0] == _rx && global.sala_jardim[1] == _ry) _sub = 2;
            } else {
                for (var _j = 0; _j < array_length(global.sala_jardim); _j++) {
                    var _b = global.sala_jardim[_j];
                    if (_b[0] == _rx && _b[1] == _ry) { _sub = 2; break; }
                }
            }
        }

        draw_sprite_ext(spr_salas, _sub, _sx, _sy, _esc, _esc, 0, c_white, 1);
        if (_dx == 0 && _dy == 0) {                              // sala atual: borda dourada pulsando
            var _p = 0.6 + 0.4 * sin(current_time / 200);
            draw_set_alpha(_p);
            draw_set_color(ui_cor("ouro"));
            var _m = _cell / 2;
            for (var _e = 0; _e < max(2, round(1.5 * _k)); _e++) draw_rectangle(_sx - _m + _e, _sy - _m + _e, _sx + _m - _e, _sy + _m - _e, true);
            draw_set_alpha(1);
        }
    }

    draw_set_font(fnt_descricao);
    var _fh = max(1, string_height("Ag"));
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    ui_text(_cx, _y2 + 12 * _k, "Salas", c_white, (8 * _k) / _fh, ui_cor("escuro"));
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(fnt_menu_op);
}
/// @desc Função de debug interativo para posições X e Y na tela.
/// @param {real} _base_x A posição X base (ex: _card_x)
/// @param {real} _base_y A posição Y base (ex: _desc_y)
/// @returns {struct} Um struct contendo os valores finais {x, y}
function scr_debug_posicao_ui(_base_x, _base_y) 
{
    // Variáveis estáticas
    static _debug_ativo = false;
    static _x_offset = 0;    // Offset do X começa em 0
    static _y_offset = -500; // Offset do Y começa onde você já estava testando
    static _ultimo_tempo = 0; 

    // Garante que o teclado seja lido apenas 1x por frame, mesmo dentro do loop
    if (current_time - _ultimo_tempo > 5) 
    {
        _ultimo_tempo = current_time; 

        // 1. Liga/Desliga com a tecla 'P'
        if (keyboard_check_pressed(ord("P"))) 
        {
            _debug_ativo = !_debug_ativo;
            
            if (_debug_ativo) {
                show_debug_message("=== [DEBUG UI ATIVADO] ===");
                show_debug_message("-> Setas Cima/Baixo para mover o Y");
                show_debug_message("-> Setas Esquerda/Direita para mover o X");
                show_debug_message("-> ENTER para imprimir o código final.");
            } else {
                show_debug_message("=== [DEBUG UI DESATIVADO] ===");
            }
        }

        // 2. Lógica de movimento (X e Y)
        if (_debug_ativo) 
        {
            var _speed = keyboard_check(vk_shift) ? 10 : 2;

            // Movimento Y
            if (keyboard_check(vk_up))   _y_offset -= _speed;
            if (keyboard_check(vk_down)) _y_offset += _speed;
            
            // Movimento X
            if (keyboard_check(vk_left))  _x_offset -= _speed;
            if (keyboard_check(vk_right)) _x_offset += _speed;

            // 3. Confirma e Imprime (ENTER)
            if (keyboard_check_pressed(vk_enter)) 
            {
                _debug_ativo = false;
                
                var _sinal_x = (_x_offset >= 0) ? " + " : " - ";
                var _sinal_y = (_y_offset >= 0) ? " + " : " - ";
                
                show_debug_message("---------------------------------------------------");
                show_debug_message("CÓDIGO FINAL GERADO! Substitua sua linha por:");
                show_debug_message("draw_text_colour_outline_escalado(" + _sinal_x + string(abs(_x_offset)) + "," + _sinal_y + string(abs(_y_offset)) + ", TEXTO, 3, c_white, 7, 30, 300, escala, escala);");
                show_debug_message("---------------------------------------------------");
            }
        }
    }

    // --- Aviso visual na tela ---
    if (_debug_ativo) 
    {
        draw_set_color(c_red);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_text(10, 10, "DEBUG UI ATIVO! Offset X: " + string(_x_offset) + " | Offset Y: " + string(_y_offset));
        draw_set_color(c_white); 
    }

    // Retorna as duas posições finais empacotadas num Struct
    return {
        x: _base_x + _x_offset,
        y: _base_y + _y_offset
    };
}


function draw_fps(){
	// Configurações > Vídeo > Mostrar FPS
	if (variable_global_exists("config") && !global.config.mostrar_fps) return;
	
	// ========================================================
// DESENHA O FPS NO CANTO DA TELA (Draw GUI)
// ========================================================

// 1. Configura o alinhamento do texto para o canto superior esquerdo
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// 2. Define uma margem para o texto não ficar colado na borda do monitor
var _margem = 15;

// 3. Monta o texto. 
// 'fps' é o limite do jogo (ex: 60). 
// 'fps_real' é o quanto o seu PC realmente está aguentando processar (ex: 2000).
var _texto_fps = "FPS: " + string(fps) + " / Real: " + string(fps_real);

// 4. EFEITO DE SOMBRA (Muito importante!)
// Desenha o texto de preto um pouquinho pro lado para você conseguir ler 
// mesmo se o personagem estiver na neve ou num fundo branco.
draw_set_color(c_black);
draw_text(_margem + 2, _margem + 2, _texto_fps);

// 5. TEXTO PRINCIPAL
// Desenha o texto principal por cima, em verde limão
draw_set_color(c_lime);
draw_text(_margem, _margem, _texto_fps);

// 6. FAXINA (Boas Práticas)
// Reseta a cor e o alinhamento para o padrão, para não bugar 
// o desenho de outros objetos ou textos no jogo!
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
}
