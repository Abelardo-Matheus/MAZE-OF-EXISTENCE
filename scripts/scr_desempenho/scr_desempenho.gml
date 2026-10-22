// feather disable GM2017
// ============================================================================
//  DESEMPENHO: muitas instâncias sem perder FPS
// ----------------------------------------------------------------------------
//  1) INIMIGOS EM MASSA: a horda (obj_horde / scr_horde) já guarda os inimigos em ARRAYS
//     (sem instâncias) com hash espacial e culling — é o jeito mais rápido no GameMaker.
//     Inimigos comuns da noite vão para lá (spawn_night_enemy -> horde_spawn_ronda).
//
//  2) MUNDO VIRTUAL (obj_otimizador): árvores, pedras, casas, bichos, monstros... existem só
//     como DADOS em global.grid_entidades_mundo. Este script cria a instância real quando a
//     câmera chega perto e destrói quando fica longe:
//       - varre os blocos a cada OTIM_INTERVALO_SPAWN frames (antes era TODO frame);
//       - a chave de cada entidade é montada uma vez só e fica guardada em _ent[2];
//       - o que está NA TELA nasce na hora; o que está só na margem entra numa FILA e nasce
//         no máximo OTIM_CRIAR_POR_FRAME por frame (sem travadinha ao chegar num bloco novo);
//       - despawn a cada OTIM_INTERVALO_DESPAWN frames.
//
//  3) DORMIR FORA DA TELA (desempenho_cull): a cada CULL_INTERVALO frames, os objetos de
//     cenário fora da câmera (+ CULL_MARGEM) ficam visible = false. O GameMaker não chama o
//     Draw de instância invisível, e o Step deles começa com "if (!visible) exit;".
//     (instance_deactivate não foi usado: instance_exists() fica false para instância desativada
//      e o otimizador acharia que ela foi quebrada.)
//
//  4) F10: mostra FPS, instâncias, horda, ativas/fila/dormindo (desempenho_debug_desenhar).
// ============================================================================

#macro OTIM_MARGEM_SPAWN       1200   // px além da câmera onde as entidades já existem
#macro OTIM_DIST_DESPAWN       2500   // px do player para destruir a instância
#macro OTIM_INTERVALO_SPAWN    10     // frames entre varreduras de spawn
#macro OTIM_INTERVALO_DESPAWN  30     // frames entre varreduras de despawn
#macro OTIM_CRIAR_POR_FRAME    40     // máximo de instâncias da fila criadas por frame
#macro CULL_INTERVALO          6      // frames entre atualizações de "dormir fora da tela"
#macro CULL_MARGEM             200    // px além da câmera que continuam acordados

function desempenho_init() {
    if (!variable_global_exists("desempenho_debug")) global.desempenho_debug = false;
    global.otim_fila = [];                       // [chave, entidade] esperando para nascer
    if (variable_global_exists("otim_na_fila") && ds_exists(global.otim_na_fila, ds_type_map)) ds_map_clear(global.otim_na_fila);
    else global.otim_na_fila = ds_map_create(); // chave -> true (não enfileira duas vezes)
    global.cull_dormindo = 0;                    // quantas estão dormindo (debug)
}

/// Retângulo da câmera [x0, y0, x1, y1] com margem
function desempenho_view(_margem) {
    var _cam = view_camera[0];
    var _cx = camera_get_view_x(_cam), _cy = camera_get_view_y(_cam);
    return [_cx - _margem, _cy - _margem, _cx + camera_get_view_width(_cam) + _margem, _cy + camera_get_view_height(_cam) + _margem];
}

/// Chave única da entidade virtual (montada uma vez e guardada em _ent[2])
function otimizador_chave(_ent) {
    if (array_length(_ent) < 3) {
        var _d = _ent[1];
        array_push(_ent, string(_d[0]) + "_" + string(_d[1]) + "_" + string(_d[2]));
    }
    return _ent[2];
}

/// Cria a instância real de uma entidade virtual
function otimizador_criar(_ent, _key) {
    if (ds_map_exists(global.instancias_ativas, _key) || ds_map_exists(global.entidades_mortas, _key)) return noone;
    var _tipo = _ent[0];
    var _dados = _ent[1];
    var _px = _dados[0], _py = _dados[1], _seed = _dados[2];
    var _inst = noone;
    switch (_tipo) {
        case "estrutura":
            // casas da cidade levam o visual (variante) junto
            _inst = instance_create_depth(_px, _py, 0, _dados[3], (array_length(_dados) > 7) ? { variante: _dados[7] } : {});
            _inst.seed = _seed;
            _inst.nome = _dados[5];
            _inst.escala_mini = _dados[6];
            break;
        case "arvore":
            _inst = instance_create_depth(_px, _py, 0, obj_arvore, {});
            break;
        case "pedra":
            _inst = instance_create_depth(_px, _py, 0, obj_rock, {});
            break;
        case "terra": // montinho de terra (pá) — scr_coleta
            _inst = instance_create_depth(_px, _py, 0, obj_monte_terra, {});
            break;
        case "fauna":
            _inst = instance_create_depth(_px, _py, 0, obj_bicho_ambiente, {});
            _inst.sprite_index = _dados[3];
            _inst.vel_maxima = _dados[4];
            break;
        case "humano":
            _inst = instance_create_depth(_px, _py, -_py, obj_humano_cidade, { variante: _dados[3] });
            break;
        case "enfeite":
            _inst = instance_create_depth(_px, _py, -_py, obj_enfeite_cidade, { tipo: _dados[3] });
            break;
        case "carro":
            _inst = instance_create_depth(_px, _py, -_py, obj_carro_cidade, { variante: _dados[3], dir: _dados[4] });
            break;
        case "monstro":
            _inst = instance_create_depth(_px, _py, 0, _dados[3], {
                seed: _seed, escala: _dados[4], hp: _dados[5], dano: _dados[6], lvl: _dados[7]
            });
            break;
    }
    if (_inst != noone) {
        global.instancias_ativas[? _key] = _inst;
        _inst.virtual_id = _key; // identificador para o despawn e para "morto de vez"
    }
    return _inst;
}

/// Varre os blocos perto da câmera: o que está na tela nasce já, o resto vai para a fila
function otimizador_varrer_spawn() {
    var _r = desempenho_view(OTIM_MARGEM_SPAWN);
    var _tela = desempenho_view(64);
    var _tb = global.tamanho_bloco;
    var _bx0 = floor(_r[0] / _tb), _bx1 = floor(_r[2] / _tb);
    var _by0 = floor(_r[1] / _tb), _by1 = floor(_r[3] / _tb);
    var _ativas = global.instancias_ativas, _mortas = global.entidades_mortas, _fila = global.otim_na_fila;

    for (var _bx = _bx0; _bx <= _bx1; _bx++) {
        for (var _by = _by0; _by <= _by1; _by++) {
            var _lista = global.grid_entidades_mundo[? string(_bx) + "," + string(_by)];
            if (is_undefined(_lista)) continue;
            var _n = ds_list_size(_lista);
            for (var _i = 0; _i < _n; _i++) {
                var _ent = _lista[| _i];
                var _d = _ent[1];
                var _px = _d[0], _py = _d[1];
                if (_px < _r[0] || _py < _r[1] || _px > _r[2] || _py > _r[3]) continue;
                var _key = otimizador_chave(_ent);
                if (ds_map_exists(_ativas, _key) || ds_map_exists(_mortas, _key) || ds_map_exists(_fila, _key)) continue;
                if (_px >= _tela[0] && _py >= _tela[1] && _px <= _tela[2] && _py <= _tela[3]) {
                    otimizador_criar(_ent, _key);               // na tela: nasce já
                } else {
                    array_push(global.otim_fila, [_key, _ent]);  // na margem: nasce aos poucos
                    _fila[? _key] = true;
                }
            }
        }
    }
}

/// Cria até OTIM_CRIAR_POR_FRAME instâncias da fila
function otimizador_processar_fila() {
    var _q = global.otim_fila;
    var _n = min(array_length(_q), OTIM_CRIAR_POR_FRAME);
    if (_n <= 0) exit;
    var _r = desempenho_view(OTIM_MARGEM_SPAWN + 200);
    for (var _i = 0; _i < _n; _i++) {
        var _it = _q[_i];
        ds_map_delete(global.otim_na_fila, _it[0]);
        var _d = _it[1][1];
        // a câmera pode ter ido embora enquanto esperava
        if (_d[0] < _r[0] || _d[1] < _r[1] || _d[0] > _r[2] || _d[1] > _r[3]) continue;
        otimizador_criar(_it[1], _it[0]);
    }
    array_delete(_q, 0, _n);
}

/// Destrói o que ficou longe e esquece instâncias que sumiram (quebradas, mortas)
function otimizador_despawn(_alvo) {
    var _remover = [];
    var _m = global.instancias_ativas;
    var _k = ds_map_find_first(_m);
    while (!is_undefined(_k)) {
        var _inst = _m[? _k];
        if (instance_exists(_inst)) {
            if (point_distance(_inst.x, _inst.y, _alvo.x, _alvo.y) > OTIM_DIST_DESPAWN) {
                instance_destroy(_inst);
                array_push(_remover, _k);
            }
        } else {
            array_push(_remover, _k);
        }
        _k = ds_map_find_next(_m, _k);
    }
    for (var _i = 0; _i < array_length(_remover); _i++) ds_map_delete(_m, _remover[_i]);
}

/// Cenário fora da câmera dorme (visible = false: sem Draw, e o Step sai na 1ª linha)
function desempenho_cull() {
    var _r = desempenho_view(CULL_MARGEM);
    var _x0 = _r[0], _y0 = _r[1], _x1 = _r[2], _y1 = _r[3];
    var _objs = [obj_arvore, obj_rock, obj_monte_terra, obj_bicho_ambiente, obj_humano_cidade, obj_estrutura, obj_poste];
    var _dorm = 0;
    for (var _o = 0; _o < array_length(_objs); _o++) {
        with (_objs[_o]) {
            visible = !(bbox_right < _x0 || bbox_left > _x1 || bbox_bottom < _y0 || bbox_top > _y1);
            if (!visible) _dorm++;
        }
    }
    global.cull_dormindo = _dorm;
}

/// F10: painel de desempenho (Draw GUI do obj_otimizador)
function desempenho_debug_desenhar() {
    if (!global.desempenho_debug) exit;
    var _linhas = [
        "FPS: " + string(fps) + "  (real " + string(round(fps_real)) + ")",
        "Instancias: " + string(instance_count),
        "Horda (sem instancia): " + string(instance_exists(obj_horde) ? obj_horde.alive : 0),
        "Mundo ativas: " + string(ds_map_size(global.instancias_ativas)) + "  fila: " + string(array_length(global.otim_fila)),
        "Dormindo fora da tela: " + string(global.cull_dormindo),
    ];
    draw_set_font(fnt_status);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    var _y = 8;
    draw_set_alpha(0.6); draw_set_colour(c_black);
    draw_rectangle(4, 4, 330, 8 + array_length(_linhas) * 18, false);
    draw_set_alpha(1);
    for (var _i = 0; _i < array_length(_linhas); _i++) {
        draw_set_colour(_i == 0 ? (fps < 50 ? c_red : c_lime) : c_white);
        draw_text_transformed(8, _y, _linhas[_i], 0.5, 0.5, 0);
        _y += 18;
    }
    draw_set_colour(c_white);
}
