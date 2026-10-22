// feather disable GM2017

/// @desc Retorna a estrutura de dados (Vetor de Skill) do RASTRO SOMBRIO
function scr_rastro_sombrio_config()
{
    return {
        stats_base: {
            damage: 3,
            cooldown: 400, 
            duration: 2000, 
            radius: 30,
            sprite_icon: spr_rastro_icon
        },
        niveis: [
            { desc: "DEIXA UM RASTRO DE VENENO NO CHÃO POR ONDE PASSA.", upgrade: function(_s) { _s.damage = 3; } },
            { desc: "DANO E DURAÇÃO DO VENENO AUMENTADOS.", upgrade: function(_s) { _s.damage += 2; _s.duration += 500; } },
            { desc: "RASTRO DE VENENO MAIS LARGO.", upgrade: function(_s) { _s.radius += 10; } },
            { desc: "DANO SIGNIFICATIVAMENTE MAIOR.", upgrade: function(_s) { _s.damage += 5; } },
            { desc: "MEGA UPGRADE: VENENO LARGO E DURADOURO.", upgrade: function(_s) { _s.radius += 20; _s.duration += 1000; _s.damage += 5; } }
        ]
    };
}

// ============================================================================
// RASTRO DE VENENO
// [O QUE]: o player solta pontos no PÉ enquanto anda. Os pontos são ligados por
//          interpolação (Catmull-Rom), então o rastro desenha o CAMINHO dele, sem
//          buracos, mesmo correndo. Cada ponto vive "duration" ms e some encolhendo.
//          Fumaça verde sobe do rastro e caveirinhas flutuam de vez em quando.
//          O tamanho máximo do rastro cresce a cada nível (rastro_pontos_max).
//          No DASH não há fita: fica uma POÇA na entrada e outra na saída (global.rastro.pocas).
// [COMO]:  rastro_atualizar()  -> obj_player Step (pontos, idade, dano)
//          rastro_desenhar()   -> obj_render_chao Draw (no chão, embaixo de tudo)
//          scr_rastro_sombrio  -> continua na grid de upgrades só para o nível/descrição
// Stats (config acima): damage = dano por tique | cooldown = ms entre tiques de dano
//                       duration = ms que cada trecho dura | radius = meia largura do rastro
// ============================================================================
#macro RASTRO_ESPACO       12    // px entre dois pontos gravados
#macro RASTRO_PONTOS_BASE      260  // pontos no Nv1 (~3100 px de rastro)
#macro RASTRO_PONTOS_POR_NIVEL 120  // + pontos a cada nível (sem teto: cresce para sempre)
#macro RASTRO_POCA_MULT        2.2  // raio da poça do dash = radius do rastro * isto
#macro RASTRO_POCA_DUR_MULT    1.5  // poça dura 50% mais que o rastro
#macro RASTRO_SUBPASSOS    0.45  // desenho: 1 mancha a cada (raio * isto) px ao longo do caminho
#macro RASTRO_COR_FUMACA   make_color_rgb(110, 220, 80)

function rastro_estado() {
    if (!variable_global_exists("rastro") || !is_struct(global.rastro)) {
        global.rastro = {
            pontos: [],           // { x, y, idade, dur, raio, rot, semente }
            nivel: 0, stats: undefined, stats_timer: 0,
            ultimo_x: undefined, ultimo_y: undefined,
            tique: 0, caveira_spr: -1, semente: 0, linha: -1,
            pocas: [],            // poças do dash { x, y, idade, dur, raio, semente }
            em_dash: false, ant_x: undefined, ant_y: undefined
        };
    }
    // struct antigo (de antes das poças): completa os campos novos
    if (!variable_struct_exists(global.rastro, "pocas")) {
        global.rastro.pocas = []; global.rastro.em_dash = false;
        global.rastro.ant_x = undefined; global.rastro.ant_y = undefined;
    }
    return global.rastro;
}

/// Nível atual do poder Rastro na grid de upgrades (0 = não tem)
function rastro_nivel() {
    if (!variable_global_exists("upgrades_vamp_grid") || !ds_exists(global.upgrades_vamp_grid, ds_type_grid)) return 0;
    var _g = global.upgrades_vamp_grid;
    for (var _i = 0; _i < ds_grid_height(_g); _i++) {
        var _s = _g[# UPGRADES_VAMP.SCRIPT, _i];
        if (_s == scr_rastro_sombrio || (is_string(_s) && _s == "scr_rastro_sombrio")) {
            global.rastro.linha = _i;
            return _g[# UPGRADES_VAMP.LEVEL, _i];
        }
    }
    return 0;
}

/// Quantos pontos o rastro pode ter no nível _nivel (cresce a cada nível, sem teto)
function rastro_pontos_max(_nivel) {
    return RASTRO_PONTOS_BASE + RASTRO_PONTOS_POR_NIVEL * max(0, _nivel - 1);
}

/// Cria uma poça de veneno parada (entrada/saída do dash)
function rastro_criar_poca(_r, _x, _y, _st, _fps) {
    array_push(_r.pocas, {
        x: _x, y: _y, idade: 0,
        dur: max(10, round(_st.duration / 1000 * _fps * RASTRO_POCA_DUR_MULT)),
        raio: _st.radius * RASTRO_POCA_MULT, rot: irandom(359), semente: _r.semente++
    });
}

/// Executor antigo da grid: agora quem faz tudo é rastro_atualizar (roda sempre, não só com inimigo perto)
function scr_rastro_sombrio(_row_index) {
}

/// Chamado no Step do obj_player (no escopo dele)
function rastro_atualizar() {
    var _r = rastro_estado();
    if (variable_global_exists("level_up") && global.level_up) exit;

    // --- nível e stats (recalcula ao mudar o nível e a cada 1 s, por causa das passivas) ---
    var _nivel = rastro_nivel();
    _r.stats_timer--;
    if (_nivel > 0 && (_nivel != _r.nivel || _r.stats_timer <= 0 || is_undefined(_r.stats))) {
        _r.stats = scr_generic_calculate_stats(scr_rastro_sombrio_config(), _nivel, global.upgrades_vamp_grid, _r.linha, UPGRADES_VAMP.DESCRIPTION);
        _r.stats_timer = 60;
    }
    _r.nivel = _nivel;

    // --- idade dos pontos ---
    for (var _i = array_length(_r.pontos) - 1; _i >= 0; _i--) {
        var _p = _r.pontos[_i];
        _p.idade++;
        if (_p.idade >= _p.dur) array_delete(_r.pontos, _i, 1);
    }
    for (var _i = array_length(_r.pocas) - 1; _i >= 0; _i--) {
        var _pc = _r.pocas[_i];
        _pc.idade++;
        if (_pc.idade >= _pc.dur) array_delete(_r.pocas, _i, 1);
    }
    if (_nivel <= 0 || is_undefined(_r.stats)) { _r.ultimo_x = undefined; _r.em_dash = false; exit; }

    var _st  = _r.stats;
    var _fps = game_get_speed(gamespeed_fps);
    var _px  = x;
    var _py  = bbox_bottom - 4; // pé do player

    // --- DASH: sem fita; poça na ENTRADA (onde estava antes) e na SAÍDA (onde parou) ---
    var _dash = variable_global_exists("in_dash") && global.in_dash;
    if (_dash && !_r.em_dash) {
        rastro_criar_poca(_r, is_undefined(_r.ant_x) ? _px : _r.ant_x, is_undefined(_r.ant_y) ? _py : _r.ant_y, _st, _fps);
    }
    if (!_dash && _r.em_dash) {
        rastro_criar_poca(_r, _px, _py, _st, _fps);
        _r.ultimo_x = undefined; // a fita recomeça na saída, sem ligar com a entrada
        _r.corte = true;
    }
    _r.em_dash = _dash;
    _r.ant_x = _px; _r.ant_y = _py;

    // --- grava o caminho: um ponto a cada RASTRO_ESPACO px, preenchendo os saltos de corrida ---
    if (_dash) {
        _r.ultimo_x = undefined; // durante o dash não grava nada
    } else if (is_undefined(_r.ultimo_x)) {
        _r.ultimo_x = _px; _r.ultimo_y = _py;
        _r.corte = true; // primeiro ponto depois de um buraco não liga com o anterior
    } else {
        var _d = point_distance(_r.ultimo_x, _r.ultimo_y, _px, _py);
        if (_d > 400) { // teleporte / troca de sala: não liga os dois lugares
            _r.ultimo_x = _px; _r.ultimo_y = _py;
        } else if (_d >= RASTRO_ESPACO) {
            var _n = floor(_d / RASTRO_ESPACO);
            for (var _k = 1; _k <= _n; _k++) {
                var _t = (_k * RASTRO_ESPACO) / _d;
                array_push(_r.pontos, {
                    x: lerp(_r.ultimo_x, _px, _t), y: lerp(_r.ultimo_y, _py, _t),
                    idade: 0, dur: max(10, round(_st.duration / 1000 * _fps)),
                    raio: _st.radius, rot: irandom(359), semente: _r.semente++,
                    corte: (_k == 1) && variable_struct_exists(_r, "corte") && _r.corte
                });
            }
            _r.corte = false;
            var _tf = (_n * RASTRO_ESPACO) / _d;
            _r.ultimo_x = lerp(_r.ultimo_x, _px, _tf);
            _r.ultimo_y = lerp(_r.ultimo_y, _py, _tf);
            // limite cresce com o nível (antes era fixo em 260 e a cauda "seguia" o player correndo)
            var _max_pts = rastro_pontos_max(_nivel);
            var _sobra = array_length(_r.pontos) - _max_pts;
            if (_sobra > 0) array_delete(_r.pontos, 0, _sobra);
        }
    }

    // --- dano por tique em quem pisar no rastro (instâncias + horda) ---
    _r.tique--;
    if (_r.tique <= 0 && (array_length(_r.pontos) > 0 || array_length(_r.pocas) > 0)) {
        _r.tique = max(5, round(_st.cooldown / 1000 * _fps));
        rastro_aplicar_dano(_r, _st.damage);
    }
}

/// Dano em todos os inimigos que tocam o rastro (cada um leva no máximo 1 vez por tique)
function rastro_aplicar_dano(_r, _dano) {
    var _lista = ds_list_create();
    var _ja = ds_map_create();
    // pontos estão a 12 px: um sim, um não já cobre o caminho. As poças do dash entram no fim.
    var _alvos = [];
    for (var _i = 0; _i < array_length(_r.pontos); _i += 2) array_push(_alvos, _r.pontos[_i]);
    for (var _i = 0; _i < array_length(_r.pocas); _i++)     array_push(_alvos, _r.pocas[_i]);
    var _np = array_length(_alvos);
    for (var _i = 0; _i < _np; _i++) {
        var _p = _alvos[_i];
        var _raio = _p.raio * (1 - 0.5 * (_p.idade / _p.dur)); // encolhe com a idade

        // instâncias
        ds_list_clear(_lista);
        var _q = collision_circle_list(_p.x, _p.y, _raio, obj_par_inimigos, false, true, _lista, false);
        for (var _k = 0; _k < _q; _k++) {
            var _e = _lista[| _k];
            if (ds_map_exists(_ja, _e) || inimigo_colisao_ignorar(_e)) continue;
            _ja[? _e] = true;
            scr_enemy_damage_apply(_e, _dano, 0, 0, false);
        }

        // horda (sem instâncias)
        if (instance_exists(obj_horde)) {
            with (obj_horde) {
                var _n = _horde_collect_circle(_p.x, _p.y, _raio);
                for (var _k = 0; _k < _n; _k++) {
                    var _j = qbuf[_k];
                    var _chave = "h" + string(euid[_j]);
                    if (ds_map_exists(_ja, _chave)) continue;
                    _ja[? _chave] = true;
                    _horde_hit_index(_j, _dano, 0, _p.x, _p.y, false, false);
                }
            }
        }
    }
    ds_map_destroy(_ja);
    ds_list_destroy(_lista);
}

/// Caveirinha 7x7 em pixel art, criada uma vez num surface e virando sprite
function rastro_caveira_sprite() {
    var _r = rastro_estado();
    if (sprite_exists(_r.caveira_spr)) return _r.caveira_spr;
    var _mapa = [
        ".#####.",
        "#######",
        "#..#..#",
        "#..#..#",
        "###.###",
        ".#####.",
        ".#.#.#.",
    ];
    var _s = surface_create(7, 7);
    surface_set_target(_s);
    draw_clear_alpha(c_black, 0);
    for (var _y = 0; _y < 7; _y++) {
        for (var _x = 0; _x < 7; _x++) {
            if (string_char_at(_mapa[_y], _x + 1) == "#") draw_point_colour(_x, _y, c_white);
        }
    }
    surface_reset_target();
    _r.caveira_spr = sprite_create_from_surface(_s, 0, 0, 7, 7, false, false, 3, 3);
    surface_free(_s);
    return _r.caveira_spr;
}

/// Posição no caminho entre os pontos _i e _i+1 (Catmull-Rom), _t = 0..1. Retorna [x, y].
function rastro_curva(_pts, _i, _t) {
    var _n  = array_length(_pts);
    var _p0 = _pts[max(0, _i - 1)], _p1 = _pts[_i], _p2 = _pts[min(_n - 1, _i + 1)], _p3 = _pts[min(_n - 1, _i + 2)];
    var _t2 = _t * _t, _t3 = _t2 * _t;
    var _x = 0.5 * ((2 * _p1.x) + (-_p0.x + _p2.x) * _t + (2 * _p0.x - 5 * _p1.x + 4 * _p2.x - _p3.x) * _t2 + (-_p0.x + 3 * _p1.x - 3 * _p2.x + _p3.x) * _t3);
    var _y = 0.5 * ((2 * _p1.y) + (-_p0.y + _p2.y) * _t + (2 * _p0.y - 5 * _p1.y + 4 * _p2.y - _p3.y) * _t2 + (-_p0.y + 3 * _p1.y - 3 * _p2.y + _p3.y) * _t3);
    return [_x, _y];
}

/// Cores da gosma (escuro = contorno, depois corpo, miolo e brilho)
#macro RASTRO_COR_CONTORNO make_color_rgb(18, 62, 22)
#macro RASTRO_COR_CORPO    make_color_rgb(62, 168, 48)
#macro RASTRO_COR_MIOLO    make_color_rgb(118, 214, 74)
#macro RASTRO_COR_BRILHO   make_color_rgb(196, 255, 140)
#macro RASTRO_AMOSTRA      4     // px entre amostras da curva (menor = fita mais lisa)

/// Largura (meia) e alfa de um ponto conforme a idade: nasce larga, afina e some no fim
function rastro_largura(_p) {
    var _vida = 1 - (_p.idade / _p.dur);
    return _p.raio * (0.35 + 0.65 * _vida);
}
function rastro_alfa(_p) {
    var _vida = 1 - (_p.idade / _p.dur);
    return clamp(_vida * 4, 0, 1); // só esmaece no último quarto da vida
}

/// Amostra a curva inteira: devolve uma lista de trechos contínuos, cada um um array de
/// { x, y, w, a } (posição, meia-largura, alfa). Pontos muito longe um do outro quebram o trecho.
function rastro_amostrar(_pts, _n, _tt) {
    var _trechos = [];
    var _atual = [];
    var _s = 0;
    for (var _i = 0; _i < _n; _i++) {
        var _p = _pts[_i];
        if (_i == _n - 1) {
            array_push(_atual, { x: _p.x, y: _p.y, w: rastro_largura(_p), a: rastro_alfa(_p) });
            break;
        }
        var _q = _pts[_i + 1];
        var _d = point_distance(_p.x, _p.y, _q.x, _q.y);
        var _quebra = (_d > RASTRO_ESPACO * 3) || (variable_struct_exists(_q, "corte") && _q.corte);
        if (_quebra) { // buraco (teleporte/dash): fecha o trecho
            array_push(_atual, { x: _p.x, y: _p.y, w: rastro_largura(_p), a: rastro_alfa(_p) });
            if (array_length(_atual) > 1) array_push(_trechos, _atual);
            _atual = [];
            continue;
        }
        var _steps = max(1, ceil(_d / RASTRO_AMOSTRA));
        var _w0 = rastro_largura(_p), _w1 = rastro_largura(_q);
        var _a0 = rastro_alfa(_p),    _a1 = rastro_alfa(_q);
        for (var _k = 0; _k < _steps; _k++) {
            var _t = _k / _steps;
            var _c = rastro_curva(_pts, _i, _t);
            // ondulação da borda (gosma "respirando")
            var _ond = 1 + 0.13 * sin(_s * 0.45 + _tt * 0.004) + 0.07 * sin(_s * 1.3 - _tt * 0.006);
            array_push(_atual, { x: _c[0], y: _c[1], w: lerp(_w0, _w1, _t) * _ond, a: lerp(_a0, _a1, _t) });
            _s++;
        }
    }
    if (array_length(_atual) > 1) array_push(_trechos, _atual);
    return _trechos;
}

/// Uma camada da fita: triangle strip com a meia-largura de cada amostra * _mult (+ _extra px)
function rastro_fita(_am, _mult, _extra, _cor, _alfa_mult) {
    var _m = array_length(_am);
    draw_primitive_begin(pr_trianglestrip);
    for (var _i = 0; _i < _m; _i++) {
        var _a = _am[max(0, _i - 1)], _b = _am[min(_m - 1, _i + 1)];
        var _dx = _b.x - _a.x, _dy = _b.y - _a.y;
        var _len = max(0.001, sqrt(_dx * _dx + _dy * _dy));
        var _nx = -_dy / _len, _ny = _dx / _len;               // normal da curva
        var _p = _am[_i];
        var _w = _p.w * _mult + _extra;
        var _al = _p.a * _alfa_mult;
        draw_vertex_colour(_p.x + _nx * _w, _p.y + _ny * _w, _cor, _al);
        draw_vertex_colour(_p.x - _nx * _w, _p.y - _ny * _w, _cor, _al);
    }
    draw_primitive_end();
    // pontas arredondadas
    for (var _e = 0; _e < 2; _e++) {
        var _p = _am[_e == 0 ? 0 : _m - 1];
        draw_set_alpha(_p.a * _alfa_mult);
        draw_set_colour(_cor);
        draw_circle(_p.x, _p.y, max(1, _p.w * _mult + _extra), false);
    }
}

/// Desenha a gosma inteira (contorno, corpo, miolo, brilho e bolhas)
function rastro_desenhar_gosma(_pts, _n, _tt) {
    var _trechos = rastro_amostrar(_pts, _n, _tt);
    for (var _t = 0; _t < array_length(_trechos); _t++) {
        var _am = _trechos[_t];
        rastro_fita(_am, 1,    2.5, RASTRO_COR_CONTORNO, 0.95); // borda escura
        rastro_fita(_am, 1,    0,   RASTRO_COR_CORPO,    0.95); // corpo
        rastro_fita(_am, 0.55, 0,   RASTRO_COR_MIOLO,    0.85); // miolo mais claro
        rastro_fita(_am, 0.12, 0,   RASTRO_COR_BRILHO,   0.55); // fio de brilho

        // bolhas que incham e estouram na superfície
        var _m = array_length(_am);
        for (var _i = 3; _i < _m; _i += 7) {
            var _p = _am[_i];
            var _f = ((_tt / 14 + _i * 13) mod 40) / 40;            // 0..1 vida da bolha
            var _r = max(1, _p.w * 0.28 * sin(_f * pi));
            var _ox = sin(_i * 2.1) * _p.w * 0.45, _oy = cos(_i * 1.7) * _p.w * 0.3;
            draw_set_alpha(_p.a * 0.9);
            draw_set_colour(RASTRO_COR_CONTORNO);
            draw_circle(_p.x + _ox, _p.y + _oy, _r + 1, false);
            draw_set_colour(RASTRO_COR_MIOLO);
            draw_circle(_p.x + _ox, _p.y + _oy, _r, false);
            draw_set_colour(RASTRO_COR_BRILHO);
            draw_point(_p.x + _ox - _r * 0.4, _p.y + _oy - _r * 0.4);
        }
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// Desenha uma poça do dash: manchas sobrepostas nas cores da gosma + bolhas
function rastro_desenhar_poca(_pc, _tt) {
    var _vida = 1 - (_pc.idade / _pc.dur);
    var _al = clamp(_vida * 4, 0, 1);
    var _r  = _pc.raio * (0.45 + 0.55 * _vida);
    // forma irregular: 6 bolotas em volta do centro
    var _camadas = [[1, 2.5, RASTRO_COR_CONTORNO, 0.95], [1, 0, RASTRO_COR_CORPO, 0.95], [0.55, 0, RASTRO_COR_MIOLO, 0.85]];
    for (var _c = 0; _c < 3; _c++) {
        var _cm = _camadas[_c];
        draw_set_colour(_cm[2]);
        draw_set_alpha(_al * _cm[3]);
        draw_ellipse(_pc.x - _r * _cm[0] - _cm[1], _pc.y - _r * 0.75 * _cm[0] - _cm[1],
                     _pc.x + _r * _cm[0] + _cm[1], _pc.y + _r * 0.75 * _cm[0] + _cm[1], false);
        for (var _k = 0; _k < 6; _k++) {
            var _ang = _pc.rot + _k * 60 + sin(_tt * 0.002 + _k) * 6;
            var _rr  = _r * (0.42 + 0.08 * sin(_tt * 0.004 + _k * 1.7 + _pc.semente)) * _cm[0] + _cm[1];
            draw_circle(_pc.x + lengthdir_x(_r * 0.62 * _cm[0], _ang), _pc.y + lengthdir_y(_r * 0.47 * _cm[0], _ang), _rr, false);
        }
    }
    // bolhas estourando
    for (var _b = 0; _b < 4; _b++) {
        var _f  = ((_tt / 14 + _b * 23 + _pc.semente * 11) mod 40) / 40;
        var _rb = max(1, _r * 0.14 * sin(_f * pi));
        var _bx = _pc.x + sin(_b * 2.3 + _pc.semente) * _r * 0.5, _by = _pc.y + cos(_b * 1.9 + _pc.semente) * _r * 0.35;
        draw_set_alpha(_al * 0.9);
        draw_set_colour(RASTRO_COR_CONTORNO); draw_circle(_bx, _by, _rb + 1, false);
        draw_set_colour(RASTRO_COR_MIOLO);    draw_circle(_bx, _by, _rb, false);
        draw_set_colour(RASTRO_COR_BRILHO);   draw_point(_bx - _rb * 0.4, _by - _rb * 0.4);
    }
    // fumaça subindo
    for (var _b = 0; _b < 4; _b++) {
        var _f = ((_tt / 16 + _pc.semente * 23 + _b * 31) mod 48) / 48;
        draw_set_alpha((1 - _f) * 0.45 * min(1, _vida * 2));
        draw_set_colour(merge_colour(RASTRO_COR_FUMACA, c_white, _f * 0.4));
        draw_circle(_pc.x + sin(_f * 6 + _b) * 6 + (_b - 1.5) * _r * 0.3, _pc.y - _f * 30, 2 + _f * 6, false);
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// Desenha o rastro no chão (chamado no Draw do obj_render_chao, logo depois do chão)
function rastro_desenhar() {
    if (!variable_global_exists("rastro") || !is_struct(global.rastro)) exit;
    var _tt0 = current_time;
    // poças do dash (embaixo da fita)
    if (variable_struct_exists(global.rastro, "pocas")) {
        var _pocas = global.rastro.pocas;
        for (var _i = 0; _i < array_length(_pocas); _i++) rastro_desenhar_poca(_pocas[_i], _tt0);
    }
    var _pts = global.rastro.pontos;
    var _n = array_length(_pts);
    if (_n == 0) exit;

    var _cam = view_camera[0];
    var _cx0 = camera_get_view_x(_cam) - 80, _cy0 = camera_get_view_y(_cam) - 80;
    var _cx1 = _cx0 + camera_get_view_width(_cam) + 160, _cy1 = _cy0 + camera_get_view_height(_cam) + 160;
    var _tt  = current_time;

    // 1. GOSMA CONTÍNUA: uma fita (triangle strip) ao longo da curva Catmull-Rom.
    //    A largura acompanha a idade de cada trecho (interpolada entre os pontos) e
    //    ondula um pouco, então o rastro parece uma gosma só, não poças separadas.
    rastro_desenhar_gosma(_pts, _n, _tt);

    // poça (spr_rastro) no ponto mais novo, embaixo do pé: a gosma "sai" dela
    var _novo = _pts[_n - 1];
    var _wn = rastro_largura(_novo) * 2.4 / sprite_get_width(spr_rastro);
    draw_sprite_ext(spr_rastro, 0, _novo.x, _novo.y, _wn, _wn * 0.8, 0, c_white, rastro_alfa(_novo));
    draw_set_alpha(1);
    draw_set_colour(c_white);

    // 2. Fumaça verde subindo (2 bolhas por ponto, em ciclo)
    for (var _i = 0; _i < _n; _i += 2) {
        var _p = _pts[_i];
        if (_p.x < _cx0 || _p.x > _cx1 || _p.y < _cy0 || _p.y > _cy1) continue;
        var _vida = 1 - (_p.idade / _p.dur);
        for (var _b = 0; _b < 2; _b++) {
            var _f = ((_tt / 16 + _p.semente * 23 + _b * 31) mod 48) / 48; // 0..1 subida
            var _ox = sin(_f * 6 + _p.semente) * 5 + (_b == 0 ? -4 : 4);
            var _oy = -_f * 26;
            draw_set_alpha((1 - _f) * 0.45 * min(1, _vida * 2));
            draw_set_colour(merge_colour(RASTRO_COR_FUMACA, c_white, _f * 0.4));
            draw_circle(_p.x + _ox, _p.y + _oy, 2 + _f * 5, false);
        }
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);

    // 3. Caveirinhas: ~1 a cada 6 pontos, sobem balançando e somem
    var _cav = rastro_caveira_sprite();
    for (var _i = 0; _i < _n; _i++) {
        var _p = _pts[_i];
        if ((_p.semente mod 6) != 0) continue;
        if (_p.x < _cx0 || _p.x > _cx1 || _p.y < _cy0 || _p.y > _cy1) continue;
        var _f = ((_tt / 20 + _p.semente * 17) mod 70) / 70;
        var _a = sin(_f * pi) * 0.9 * min(1, (1 - _p.idade / _p.dur) * 2);
        if (_a <= 0.02) continue;
        draw_sprite_ext(_cav, 0, _p.x + sin(_f * 8 + _p.semente) * 4, _p.y - 6 - _f * 30, 2, 2, sin(_f * 10) * 12,
            make_color_rgb(200, 255, 170), _a);
    }
}
