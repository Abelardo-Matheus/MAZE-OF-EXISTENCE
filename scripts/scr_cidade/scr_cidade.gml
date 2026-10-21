// feather disable GM2017
// ============================================================================
// CIDADE: ruas, calçadas e quadras IRREGULARES + geração das casas/enfeites/carros
// ----------------------------------------------------------------------------
// Layout (tudo em tiles de CIDADE_T = 96 px, determinístico pela semente):
//  * AVENIDAS horizontais contínuas em y = cidade_av_y(j) (espaçamento 12..16 tiles,
//    cada uma num lugar diferente).
//  * RUAS verticais só existem dentro de uma faixa de quadras (entre a avenida j e
//    a j+1) em x = cidade_rua_x(k, j). Cada faixa tem as ruas num lugar diferente,
//    então quase todo encontro vira um "T" (cara de tijolinho, nada de tabuleiro).
//  * Algumas ruas verticais são removidas: duas quadras viram uma quadra larga
//    (praças/parques grandes ou fileiras de casas).
// Dentro de cada quadra (lx/ly contados a partir do canto da rua):
//   0..1 rua · 2 calçada · 3..W-2 miolo · W-1 calçada   (igual para y)
// A quadra onde o jogador nasce (k = 1, j = 1) é sempre igual: CIDADE_INI_*.
// O chão é desenhado pelo TERRENO (terreno_construir_regiao) chamando
// cidade_desenhar_tile; geração, carros e humanos usam as MESMAS funções.
// ============================================================================

#macro CIDADE_P          14       // espaçamento médio entre ruas (tiles)
#macro CIDADE_JIT_AV     2        // variação das avenidas (± tiles)
#macro CIDADE_JIT_RUA    4        // variação das ruas verticais (± tiles)
#macro CIDADE_T          96       // TERRENO_TILE_MUNDO
#macro CIDADE_QUADRA     1344     // (legado) CIDADE_P * CIDADE_T

// quadra inicial fixa (tiles): x 14..30, y 14..28 -> sempre no meio do bloco 0,0
#macro CIDADE_INI_K      1
#macro CIDADE_INI_J      1
#macro CIDADE_INI_X0     14
#macro CIDADE_INI_X1     30
#macro CIDADE_INI_Y0     14
#macro CIDADE_INI_Y1     28

// tipos de tile
#macro CID_MIOLO    0
#macro CID_RUA      1
#macro CID_FAIXA    2
#macro CID_CALCADA  3

function cidade_mod(_v, _m) {
    return ((_v mod _m) + _m) mod _m;
}

// direções (mesma convenção dos humanos): 0 baixo, 1 esquerda, 2 direita, 3 cima
function cidade_dx(_d) { return (_d == 1) ? -1 : ((_d == 2) ? 1 : 0); }
function cidade_dy(_d) { return (_d == 0) ? 1 : ((_d == 3) ? -1 : 0); }
function cidade_oposta(_d) { return 3 - _d; }

function cidade_hash(_a, _b, _s) {
    var _sem = variable_global_exists("semente_terreno") ? global.semente_terreno : 0;
    return terreno_hash(_a, _b, _sem + _s);
}

// ----------------------------------------------------------------------------
// LAYOUT
// ----------------------------------------------------------------------------
/// @desc y (tile) da avenida j (primeira linha do asfalto)
function cidade_av_y(_j) {
    if (_j == CIDADE_INI_J)     return CIDADE_INI_Y0;
    if (_j == CIDADE_INI_J + 1) return CIDADE_INI_Y1;
    return _j * CIDADE_P + floor(cidade_hash(_j, 7, 11) * (2 * CIDADE_JIT_AV + 1)) - CIDADE_JIT_AV;
}

/// @desc faixa de quadras (j) que contém o tile _gy
function cidade_linha_de(_gy) {
    var _j = floor(_gy / CIDADE_P);
    if (cidade_av_y(_j) > _gy) _j--;
    else if (cidade_av_y(_j + 1) <= _gy) _j++;
    return _j;
}

/// @desc x (tile) da rua vertical k dentro da faixa j
function cidade_rua_x(_k, _j) {
    if (_j == CIDADE_INI_J) {
        if (_k == CIDADE_INI_K)     return CIDADE_INI_X0;
        if (_k == CIDADE_INI_K + 1) return CIDADE_INI_X1;
    }
    return _k * CIDADE_P + floor(cidade_hash(_k, _j, 23) * (2 * CIDADE_JIT_RUA + 1)) - CIDADE_JIT_RUA;
}

/// @desc a rua vertical k da faixa j existe? (algumas somem e juntam duas quadras)
function cidade_rua_existe(_k, _j) {
    if (_j == CIDADE_INI_J && (_k == CIDADE_INI_K || _k == CIDADE_INI_K + 1)) return true;
    var _r  = cidade_hash(_k, _j, 41) < 0.22;
    var _ra = cidade_hash(_k - 1, _j, 41) < 0.22;
    return !(_r && !_ra);   // nunca some duas seguidas
}

/// @desc altura (tiles) da faixa de quadras j
function cidade_altura(_j) { return cidade_av_y(_j + 1) - cidade_av_y(_j); }

/// @desc a rua k da faixa j é um BECO (sai da avenida de cima e termina no meio da quadra)?
function cidade_beco(_k, _j) {
    if (_j == CIDADE_INI_J && (_k == CIDADE_INI_K || _k == CIDADE_INI_K + 1)) return false;
    if (!cidade_rua_existe(_k, _j)) return false;
    return cidade_altura(_j) >= 13 && cidade_hash(_k, _j, 57) < 0.22;
}

/// @desc última linha (ly) de asfalto do beco na faixa j
function cidade_beco_fim(_j) { return cidade_altura(_j) div 2; }

/// @desc a rua k existe na linha ly da faixa j? (beco só na metade de cima)
function cidade_rua_existe_em(_k, _j, _ly) {
    if (!cidade_rua_existe(_k, _j)) return false;
    if (_ly > cidade_beco_fim(_j) && cidade_beco(_k, _j)) return false;
    return true;
}

/// @desc a rua k é inteira (de avenida a avenida)?
function cidade_rua_inteira(_k, _j) { return cidade_rua_existe(_k, _j) && !cidade_beco(_k, _j); }

/// @desc acha a quadra da faixa j que contém o tile _gx, na linha _ly.
///       Resultado em global.cid_x0 / global.cid_x1 (tiles das ruas), global.cid_k
///       (rua da esquerda) e global.cid_kr (rua "crua" à esquerda, contando removidas).
function cidade_bloco_x(_gx, _j, _ly) {
    var _k = floor(_gx / CIDADE_P);
    if (cidade_rua_x(_k, _j) > _gx) _k--;
    else if (cidade_rua_x(_k + 1, _j) <= _gx) _k++;
    var _k0 = _k;
    repeat (3) { if (cidade_rua_existe_em(_k0, _j, _ly)) break; _k0--; }
    var _k1 = _k + 1;
    repeat (3) { if (cidade_rua_existe_em(_k1, _j, _ly)) break; _k1++; }
    global.cid_kr = _k;
    global.cid_k  = _k0;
    global.cid_x0 = cidade_rua_x(_k0, _j);
    global.cid_x1 = cidade_rua_x(_k1, _j);
}

/// @desc o tile _gx é asfalto de rua vertical na faixa j (linha _ly)? Retorna o x da rua ou -infinito
function cidade_rua_v_em(_gx, _j, _ly) {
    cidade_bloco_x(_gx, _j, _ly);
    return ((_gx - global.cid_x0) <= 1) ? global.cid_x0 : -infinity;
}

/// @desc é coluna de calçada de rua vertical na faixa j (linha _ly)?
function cidade_calcada_v_em(_gx, _j, _ly) {
    cidade_bloco_x(_gx, _j, _ly);
    var _lx = _gx - global.cid_x0;
    return (_lx == 2 || _lx == global.cid_x1 - global.cid_x0 - 1);
}

/// @desc tile (_gx, linha _ly) é a calçada que fecha o fim de um beco? (usa global.cid_kr)
function cidade_fim_beco_em(_gx, _j, _ly) {
    if (_ly != cidade_beco_fim(_j) + 1) return false;
    for (var _kk = global.cid_kr; _kk <= global.cid_kr + 1; _kk++) {
        if (cidade_beco(_kk, _j)) {
            var _rx = cidade_rua_x(_kk, _j);
            if (_gx >= _rx - 1 && _gx <= _rx + 2) { global.cid_beco_rx = _rx; return true; }
        }
    }
    return false;
}

/// @desc Tipo do tile da grade (não olha o bioma).
function cidade_tipo_tile(_gx, _gy) {
    var _j  = cidade_linha_de(_gy);
    var _y0 = cidade_av_y(_j);
    var _ly = _gy - _y0;
    var _H  = cidade_av_y(_j + 1) - _y0;

    if (_ly <= 1) {   // avenida
        var _hp = cidade_altura(_j - 1) - 1;   // fundo da faixa de cima (becos não chegam lá)
        if (cidade_rua_v_em(_gx, _j, 0) != -infinity || cidade_rua_v_em(_gx, _j - 1, _hp) != -infinity) return CID_RUA;
        if (cidade_calcada_v_em(_gx, _j, 0) || cidade_calcada_v_em(_gx, _j - 1, _hp)) return CID_FAIXA;
        return CID_RUA;
    }
    cidade_bloco_x(_gx, _j, _ly);
    if (cidade_fim_beco_em(_gx, _j, _ly)) return CID_CALCADA;
    var _lx = _gx - global.cid_x0;
    var _W  = global.cid_x1 - global.cid_x0;
    var _sh = (_ly == 2 || _ly == _H - 1);
    if (_lx <= 1) return _sh ? CID_FAIXA : CID_RUA;
    if (_sh || _lx == 2 || _lx == _W - 1) return CID_CALCADA;
    return CID_MIOLO;
}

/// @desc Tipo de tile num ponto do mundo (px).
function cidade_tipo_em(_x, _y) {
    return cidade_tipo_tile(floor(_x / CIDADE_T), floor(_y / CIDADE_T));
}

/// @desc Ponto está dentro do bioma cidade?
function cidade_ponto_ok(_x, _y) {
    return terreno_bioma_em(_x, _y) == "cidade";
}

/// @desc Tipo da quadra (determinístico pela semente do mundo).
///       Quadras largas (rua removida) viram praça/parque com mais frequência.
function cidade_tipo_quadra(_k, _j) {
    if (_k == CIDADE_INI_K && _j == CIDADE_INI_J) return "inicio";
    var _h = cidade_hash(_k, _j, 333);
    var _larga = !cidade_rua_inteira(_k + 1, _j);
    var _beco = cidade_beco(_k + 1, _j) || (!cidade_rua_existe(_k + 1, _j) && cidade_beco(_k + 2, _j));
    if (_beco) return (_h < 0.7) ? "residencial" : "comercial";   // casas viradas pra avenida, beco no fundo
    if (_larga) {
        if (_h < 0.35) return "parque";
        if (_h < 0.60) return "praca";
        return "residencial";
    }
    if (_h < 0.50) return "residencial";
    if (_h < 0.72) return "comercial";
    if (_h < 0.86) return "praca";
    return "parque";
}

/// @desc ponto (px) onde o jogador nasce: na calçada, na porta da casa inicial
function cidade_spawn_x() { return (CIDADE_INI_X0 + 1 + (CIDADE_INI_X1 - CIDADE_INI_X0) / 2) * CIDADE_T; }   // meio do miolo
function cidade_spawn_y() { return (CIDADE_INI_Y1 - 1) * CIDADE_T - 26 + 80; }                             // calçada, na porta

// ----------------------------------------------------------------------------
// CRUZAMENTOS (para os carros)
// ----------------------------------------------------------------------------
/// @desc Se (_x,_y) está numa avenida onde chega/sai rua vertical, retorna
///       { av: y da avenida (tile), desce: x da rua que desce (ou -inf), sobe: x da rua que sobe (ou -inf) }
///       senão retorna undefined.
function cidade_cruzamento(_x, _y) {
    var _gx = floor(_x / CIDADE_T), _gy = floor(_y / CIDADE_T);
    var _j  = cidade_linha_de(_gy);
    var _av = cidade_av_y(_j);
    if (_gy - _av > 1) return undefined;
    // só ruas inteiras (os carros não entram em beco)
    var _desce = cidade_rua_v_em(_gx, _j, cidade_altura(_j) - 1);
    var _sobe  = cidade_rua_v_em(_gx, _j - 1, cidade_altura(_j - 1) - 1);
    if (_desce == -infinity && _sobe == -infinity) return undefined;
    return { av: _av, j: _j, desce: _desce, sobe: _sobe };
}

/// @desc faixa (lane) mais próxima para a direção _d, a partir de um ponto qualquer da rua
function cidade_faixa_aqui(_x, _y, _d) {
    var _gx = floor(_x / CIDADE_T), _gy = floor(_y / CIDADE_T);
    var _j  = cidade_linha_de(_gy);
    if (_d == 1 || _d == 2) {
        var _av = cidade_av_y(_j);
        if (_gy - _av > 1) _av = cidade_av_y(_j + 1);   // (não deveria acontecer)
        return _av * CIDADE_T + ((_d == 2) ? 178 : 84);
    }
    var _ly = _gy - cidade_av_y(_j);
    cidade_bloco_x(_gx, _j, max(_ly, 2));
    return global.cid_x0 * CIDADE_T + ((_d == 0) ? 48 : 144);
}

// ----------------------------------------------------------------------------
// DESENHO DO CHÃO (chamado dentro da surface da região, em pixels nativos 32)
// ----------------------------------------------------------------------------
function cidade_tile(_i, _px, _py) {
    draw_sprite_part(spr_cidade_chao, 0, (_i mod 4) * 32, (_i div 4) * 32, 32, 32, _px, _py);
}

/// @desc Desenha rua/calçada/gramado. Retorna true se o tile não deve receber
///       a decoração comum do bioma.
function cidade_desenhar_tile(_gx, _gy, _px, _py, _mx, _my) {
    var _h = abs((_gx * 73856093) ^ (_gy * 19349663));
    var _j  = cidade_linha_de(_gy);
    var _y0 = cidade_av_y(_j);
    var _ly = _gy - _y0;
    var _H  = cidade_av_y(_j + 1) - _y0;

    if (_ly <= 1) {   // ---------- avenida ----------
        var _hp = cidade_altura(_j - 1) - 1;
        if (cidade_rua_v_em(_gx, _j, 0) != -infinity || cidade_rua_v_em(_gx, _j - 1, _hp) != -infinity) {
            cidade_tile(((_h mod 5) == 0) ? 19 : 0, _px, _py);   // cruzamento
            if ((_h mod 9) == 0) cidade_tile(12, _px, _py);
            return true;
        }
        var _fx = cidade_calcada_v_em(_gx, _j, 0) || cidade_calcada_v_em(_gx, _j - 1, _hp);
        cidade_tile(_fx ? 6 : ((_ly == 0) ? 1 : 2), _px, _py);
        return true;
    }

    cidade_bloco_x(_gx, _j, _ly);
    var _x0 = global.cid_x0;
    var _lx = _gx - _x0;
    var _W  = global.cid_x1 - _x0;
    var _sh = (_ly == 2 || _ly == _H - 1);
    var _sv = (_lx == 2 || _lx == _W - 1);

    if (cidade_fim_beco_em(_gx, _j, _ly)) {   // calçada que fecha o beco
        cidade_tile(7, _px, _py);
        var _bl = _gx - global.cid_beco_rx;
        if (_bl == 0 || _bl == 1) cidade_tile(8, _px, _py);   // meio-fio virado para o asfalto do beco
        return true;
    }
    if (_lx <= 1) {
        // fim do beco: retorno (cruzamento sem faixa)
        if (_ly == cidade_beco_fim(_j) && cidade_beco(global.cid_k, _j)) { cidade_tile(0, _px, _py); return true; }
        cidade_tile(_sh ? 5 : ((_lx == 0) ? 3 : 4), _px, _py);
        return true;
    }
    if (_sv || _sh) {                         // calçada + meio-fio
        var _var = _h mod 11;
        cidade_tile((_var == 0) ? 13 : ((_var == 1) ? 18 : 7), _px, _py);
        if (_ly == 2)      cidade_tile(8, _px, _py);
        if (_ly == _H - 1) cidade_tile(10, _px, _py);
        if (_lx == 2)      cidade_tile(11, _px, _py);
        if (_lx == _W - 1) cidade_tile(9, _px, _py);
        return true;
    }

    // miolo da quadra (o tipo vem da quadra "de baixo", que junta as do beco)
    cidade_bloco_x(_gx, _j, _H - 1);
    var _q = cidade_tipo_quadra(global.cid_k, _j);
    var _grama = (_q == "residencial" || _q == "parque" || _q == "inicio");
    if (_grama) {
        draw_sprite_part(spr_terreno, terreno_id("floresta"), _mx * 32, _my * 32, 32, 32, _px, _py);
        var _d = (_h div 100) mod 8;
        if ((_h mod 100) < 20) draw_sprite_part(spr_terreno, terreno_id("floresta"), (_d mod 4) * 32, 128 + (_d div 4) * 32, 32, 32, _px, _py);
    }
    if (_lx == 3)      cidade_tile(17, _px, _py);
    if (_lx == _W - 2) cidade_tile(15, _px, _py);
    if (_ly == 3)      cidade_tile(14, _px, _py);
    if (_ly == _H - 2) cidade_tile(16, _px, _py);
    return _grama;
}
// ----------------------------------------------------------------------------
// GERAÇÃO (dados virtuais; o obj_otimizador cria as instâncias perto da câmera)
// ----------------------------------------------------------------------------
#macro CASA_AZUL 0
#macro CASA_TIJOLO 1
#macro CASA_SOBRADO 2
#macro CASA_MOINHO 3
#macro CASA_PADARIA 4
#macro CASA_BRINQUEDOS 5
#macro CASA_FLORICULTURA 6
#macro CASA_ESCOLA 7

// tipos de enfeite (mesma ordem do Create do obj_enfeite_cidade)
#macro ENF_BANCO 0
#macro ENF_HIDRANTE 1
#macro ENF_CORREIO 2
#macro ENF_LIXEIRA 3
#macro ENF_CANTEIRO 4
#macro ENF_ARVORE 5
#macro ENF_FONTE 6
#macro ENF_BALANCO 7
#macro ENF_GANGORRA 8
#macro ENF_ESCORREGADOR 9
#macro ENF_ARBUSTO 10
#macro ENF_POMBOS 11

function cidade_bloco_de(_v) { return floor(_v / global.tamanho_bloco); }

/// @desc Registra uma estrutura (casa, poste, vendedor) no formato padrão.
function cidade_registrar_estrutura(_x, _y, _obj, _spr_mapa, _nome, _variante) {
    var _esc = 1;
    if (_spr_mapa != noone && sprite_exists(_spr_mapa)) {
        var _w = sprite_get_width(_spr_mapa);
        if (_w > 0) _esc = 10 / _w;
    }
    var _seed = irandom(9999999);
    var _dados = [_x, _y, _seed, _obj, _spr_mapa, _nome, _esc, _variante];
    ds_list_add(global.posicoes_estruturas, _dados);
    registrar_entidade_no_bloco(cidade_bloco_de(_x), cidade_bloco_de(_y), "estrutura", _dados);
    registrar_posicao_geracao(_x, _y);
}

/// @desc Poste sem ícone no minimapa (só os das esquinas aparecem lá)
function cidade_registrar_poste(_x, _y) {
    var _dados = [_x, _y, irandom(9999999), obj_poste, noone, "Poste", 1, -1];
    registrar_entidade_no_bloco(cidade_bloco_de(_x), cidade_bloco_de(_y), "estrutura", _dados);
    registrar_posicao_geracao(_x, _y);
}

function cidade_registrar_enfeite(_x, _y, _tipo) {
    if (!cidade_ponto_ok(_x, _y)) return;
    var _dados = [_x, _y, irandom(9999999), _tipo];
    registrar_entidade_no_bloco(cidade_bloco_de(_x), cidade_bloco_de(_y), "enfeite", _dados);
}

function cidade_registrar_carro(_x, _y, _dir) {
    var _dados = [_x, _y, irandom(9999999), irandom(3), _dir];
    registrar_entidade_no_bloco(cidade_bloco_de(_x), cidade_bloco_de(_y), "carro", _dados);
}

/// @desc Espalha enfeites num retângulo sem encostar uns nos outros.
function cidade_espalhar(_x0, _y0, _x1, _y1, _tipos, _qtd, _dist, _ocupados) {
    var _feitos = 0, _tent = 0;
    while (_feitos < _qtd && _tent < _qtd * 8) {
        _tent++;
        var _x = random_range(_x0, _x1), _y = random_range(_y0, _y1);
        var _livre = true;
        for (var _i = 0; _i < array_length(_ocupados); _i++) {
            var _o = _ocupados[_i];
            if (abs(_x - _o[0]) < _o[2] + _dist && abs(_y - _o[1]) < _o[3] + _dist * 0.6) { _livre = false; break; }
        }
        if (!_livre) continue;
        cidade_registrar_enfeite(_x, _y, _tipos[irandom(array_length(_tipos) - 1)]);
        array_push(_ocupados, [_x, _y, 40, 30]);
        _feitos++;
    }
}

/// @desc Conteúdo fixo da quadra onde o jogador nasce (sempre igual em todo jogo).
function cidade_gerar_quadra_inicial(_ix, _iy, _mw, _mh) {
    var _base = _iy + _mh - 26;
    var _cx   = _ix + _mw / 2;
    // casa do jogador no meio, com a porta virada para a calçada de baixo
    cidade_registrar_estrutura(_cx, _base, obj_casa_cidade, spr_casa_mini_map, "Casa", CASA_AZUL);
    // jardim da frente, sempre igual
    cidade_registrar_enfeite(_cx + 200, _base + 10, ENF_CORREIO);
    cidade_registrar_enfeite(_cx - 230, _base - 30, ENF_CANTEIRO);
    cidade_registrar_enfeite(_cx + 300, _base - 30, ENF_CANTEIRO);
    cidade_registrar_enfeite(_ix + 110, _base - 40, ENF_ARVORE);
    cidade_registrar_enfeite(_ix + _mw - 110, _base - 40, ENF_ARVORE);
    // quintal dos fundos
    cidade_registrar_enfeite(_ix + 140, _iy + 170, ENF_ARVORE);
    cidade_registrar_enfeite(_ix + _mw - 160, _iy + 190, ENF_ARVORE);
    cidade_registrar_enfeite(_ix + 330, _iy + 130, ENF_ARBUSTO);
    cidade_registrar_enfeite(_ix + _mw - 360, _iy + 140, ENF_ARBUSTO);
    cidade_registrar_enfeite(_ix + 250, _iy + 300, ENF_BALANCO);
    cidade_registrar_enfeite(_ix + _mw - 260, _iy + 320, ENF_BANCO);
    // ninguém nasce em cima do jogador
    registrar_posicao_geracao(cidade_spawn_x(), cidade_spawn_y());
}

/// @desc Gera todas as quadras cuja esquina (rua de cima/esquerda) cai dentro do bloco (chunk) _bx,_by.
function gerar_cidade_para_bloco(_bx, _by)
{
    var _id = "cidade_" + string(_bx) + "," + string(_by);
    if (ds_map_exists(global.blocos_gerados, _id)) return;
    ds_map_add(global.blocos_gerados, _id, true);

    var _T  = CIDADE_T;
    var _tb = global.tamanho_bloco;
    var _px0 = _bx * _tb, _px1 = (_bx + 1) * _tb;
    var _py0 = _by * _tb, _py1 = (_by + 1) * _tb;
    var _tem_vendedor = false;

    var _j0 = cidade_linha_de(floor(_py0 / _T)) - 1;
    var _j1 = cidade_linha_de(floor(_py1 / _T)) + 1;

    for (var _j = _j0; _j <= _j1; _j++) {
        var _ty0 = cidade_av_y(_j);
        if (_ty0 * _T < _py0 || _ty0 * _T >= _py1) continue;   // a quadra pertence a outro chunk
        var _ty1 = cidade_av_y(_j + 1);
        var _H   = _ty1 - _ty0;

        var _k0 = floor(_px0 / _T / CIDADE_P) - 2;
        var _k1 = floor(_px1 / _T / CIDADE_P) + 2;
        for (var _k = _k0; _k <= _k1; _k++) {
            if (!cidade_rua_inteira(_k, _j)) continue;
            var _tx0 = cidade_rua_x(_k, _j);
            if (_tx0 * _T < _px0 || _tx0 * _T >= _px1) continue;
            var _kn = _k + 1;
            var _becos = [];   // x (px) do meio de cada beco dentro desta quadra
            repeat (3) {
                if (cidade_rua_inteira(_kn, _j)) break;
                if (cidade_beco(_kn, _j)) array_push(_becos, cidade_rua_x(_kn, _j) * _T + _T);
                _kn++;
            }
            var _tx1 = cidade_rua_x(_kn, _j);
            var _W   = _tx1 - _tx0;

            var _ox = _tx0 * _T, _oy = _ty0 * _T;        // esquina (canto da rua)
            var _ix = _ox + 3 * _T, _iy = _oy + 3 * _T;   // canto do miolo
            var _mw = (_W - 4) * _T, _mh = (_H - 4) * _T; // tamanho do miolo (px)

            var _tipo = cidade_tipo_quadra(_k, _j);
            var _fixa = (_tipo == "inicio");   // quadra inicial: nada aleatório

            // ---------- postes nas esquinas, hidrante e lixeira na calçada ----------
            if (cidade_ponto_ok(_ox + 2.5 * _T, _oy + 2.5 * _T))
                cidade_registrar_estrutura(_ox + 2.5 * _T, _oy + 2.5 * _T + 30, obj_poste, spr_poste_mini_map, "Poste", -1);
            if (cidade_ponto_ok(_ox + (_W - 0.5) * _T, _oy + (_H - 0.5) * _T))
                cidade_registrar_estrutura(_ox + (_W - 0.5) * _T, _oy + (_H - 0.5) * _T + 30, obj_poste, spr_poste_mini_map, "Poste", -1);
            // postes extras ao longo da calçada de cima e da esquerda (a cada 4 tiles)
            for (var _px = 6; _px < _W - 2; _px += 4) {
                var _qx = _ox + (_px + 0.5) * _T, _qy = _oy + 2.5 * _T;
                if (cidade_ponto_ok(_qx, _qy) && cidade_tipo_em(_qx, _qy) == CID_CALCADA)
                    cidade_registrar_poste(_qx, _qy + 30);
            }
            for (var _py = 6; _py < _H - 2; _py += 4) {
                var _qx = _ox + 2.5 * _T, _qy = _oy + (_py + 0.5) * _T;
                if (cidade_ponto_ok(_qx, _qy) && cidade_tipo_em(_qx, _qy) == CID_CALCADA)
                    cidade_registrar_poste(_qx, _qy + 30);
            }
            if (_fixa || random(1) < 0.5) cidade_registrar_enfeite(_ox + (_W - 0.5) * _T + 26, _oy + (_H * 0.5) * _T, ENF_HIDRANTE);
            if (_fixa || random(1) < 0.5) cidade_registrar_enfeite(_ox + 2.5 * _T - 26, _oy + (_H * 0.5 + 1) * _T, ENF_LIXEIRA);

            // ---------- carros: na avenida de cima e na rua da esquerda ----------
            if (!_fixa && random(1) < 0.25 + _W * 0.02) {
                var _cx = _ix + random(_mw);
                if (cidade_ponto_ok(_cx, _oy + 96) && cidade_ponto_ok(_cx - 600, _oy + 96) && cidade_ponto_ok(_cx + 600, _oy + 96)) {
                    if (random(1) < 0.5) cidade_registrar_carro(_cx, _oy + 178, 2);
                    else cidade_registrar_carro(_cx, _oy + 84, 1);
                }
            }
            if (!_fixa && random(1) < 0.30) {
                var _cy = _iy + random(_mh);
                if (cidade_ponto_ok(_ox + 96, _cy) && cidade_ponto_ok(_ox + 96, _oy + 96) && cidade_ponto_ok(_ox + 96, _oy + _H * _T)) {
                    if (random(1) < 0.5) cidade_registrar_carro(_ox + 48, _cy, 0);
                    else cidade_registrar_carro(_ox + 144, _cy, 3);
                }
            }

            // ---------- miolo: só se a quadra inteira estiver na cidade ----------
            var _ok = cidade_ponto_ok(_ix + 60, _iy + 60) && cidade_ponto_ok(_ix + _mw - 60, _iy + 60)
                   && cidade_ponto_ok(_ix + 60, _iy + _mh - 60) && cidade_ponto_ok(_ix + _mw - 60, _iy + _mh - 60)
                   && cidade_ponto_ok(_ix + _mw / 2, _iy + _mh / 2);
            if (_fixa) { cidade_gerar_quadra_inicial(_ix, _iy, _mw, _mh); continue; }
            if (!_ok) {
                // pedaço de quadra na borda: só umas árvores
                if (cidade_ponto_ok(_ix + _mw / 2, _iy + _mh / 2))
                    cidade_espalhar(_ix + 80, _iy + 120, _ix + _mw - 80, _iy + _mh - 40, [ENF_ARVORE, ENF_ARBUSTO], 3, 90, []);
                continue;
            }

            var _base = _iy + _mh - 26;    // linha onde as casas "pisam" (porta para a calçada de baixo)
            var _ocup = [];
            // becos: nada em cima do asfalto/calçada deles + poste e lixeira no fim
            var _fimb = (cidade_beco_fim(_j) + 2) * _T;   // até onde o beco desce (px a partir da esquina)
            for (var _b = 0; _b < array_length(_becos); _b++) {
                array_push(_ocup, [_becos[_b], _oy + _fimb / 2, 2 * _T + 40, _fimb / 2 + 30]);
                cidade_registrar_enfeite(_becos[_b] + 1.5 * _T, _oy + _fimb - 0.5 * _T + 20, ENF_LIXEIRA);
                cidade_registrar_enfeite(_becos[_b], _oy + _fimb + 90, ENF_ARVORE);   // árvore fechando o fim do beco
            }
            var _n    = floor(_mw / 470);  // quantos lotes cabem na largura
            if (_n < 1 && (_tipo == "residencial" || _tipo == "comercial")) _tipo = "jardim";

            switch (_tipo) {

                case "residencial":
                    var _lote = _mw / _n;
                    if (_n == 2 && array_length(_becos) == 0 && random(1) < 0.12) {
                        // casarão antigo (obj_casa_1..4) no meio do lote
                        cidade_registrar_estrutura(_ix + _mw / 2, _iy + _mh * 0.62, choose(obj_casa_1, obj_casa_2, obj_casa_3, obj_casa_4), spr_casa_mini_map, "Casa", -1);
                        array_push(_ocup, [_ix + _mw / 2, _iy + _mh * 0.5, 420, 420]);
                    } else {
                        var _ult = -1;
                        for (var _i = 0; _i < _n; _i++) {
                            var _hx = _ix + _lote * (_i + 0.5) + random_range(-30, 30);
                            var _sob_beco = false;   // lote bem embaixo do fim de um beco: vira jardim
                            for (var _b = 0; _b < array_length(_becos); _b++) if (abs(_hx - _becos[_b]) < 260) _sob_beco = true;
                            var _v = choose(CASA_AZUL, CASA_TIJOLO, CASA_SOBRADO, CASA_MOINHO);
                            if (_v == _ult) _v = (_v + 1 + irandom(2)) mod 4;
                            _ult = _v;
                            if (_sob_beco || (random(1) < 0.12 && _n > 2)) {
                                // lote vazio com árvores (quebra a fileira)
                                cidade_espalhar(_hx - 150, _base - 300, _hx + 150, _base - 20, [ENF_ARVORE, ENF_ARBUSTO, ENF_CANTEIRO], 3, 60, _ocup);
                                continue;
                            }
                            var _recuo = choose(0, 0, -40, -80);   // casas não ficam todas alinhadas
                            cidade_registrar_estrutura(_hx, _base + _recuo, obj_casa_cidade, spr_casa_mini_map, "Casa", _v);
                            array_push(_ocup, [_hx, _base + _recuo - 200, 220, 220]);
                            var _cxx = _hx + ((random(1) < 0.5) ? -195 : 195);
                            cidade_registrar_enfeite(_cxx, _base + 10, ENF_CORREIO);
                            array_push(_ocup, [_cxx, _base, 30, 30]);
                        }
                    }
                    // quintal (só se a quadra for funda)
                    if (_mh > 620) {
                        cidade_espalhar(_ix + 70, _iy + 110, _ix + _mw - 70, _base - 420, [ENF_ARVORE, ENF_ARVORE, ENF_ARBUSTO], irandom_range(2, 2 + _n), 70, _ocup);
                        cidade_espalhar(_ix + 70, _iy + 110, _ix + _mw - 70, _base - 420, [ENF_CANTEIRO, ENF_ARBUSTO], irandom_range(1, 1 + _n), 40, _ocup);
                    }
                    break;

                case "comercial":
                    if (_mw >= 700 && array_length(_becos) == 0 && random(1) < 0.25) {
                        cidade_registrar_estrutura(_ix + _mw / 2, _base, obj_casa_cidade, spr_casa_mini_map, "Escola", CASA_ESCOLA);
                        array_push(_ocup, [_ix + _mw / 2, _base - 240, 300, 260]);
                        cidade_registrar_enfeite(_ix + 110, _base + 6, ENF_BANCO);
                        cidade_registrar_enfeite(_ix + _mw - 110, _base + 6, ENF_BANCO);
                    } else {
                        var _lt = _mw / _n;
                        var _ant = -1;
                        for (var _i = 0; _i < _n; _i++) {
                            var _l = CASA_PADARIA + irandom(2);
                            if (_l == _ant) _l = CASA_PADARIA + ((_l - CASA_PADARIA + 1) mod 3);
                            _ant = _l;
                            var _sx = _ix + _lt * (_i + 0.5);
                            var _sb = false;
                            for (var _b = 0; _b < array_length(_becos); _b++) if (abs(_sx - _becos[_b]) < 260) _sb = true;
                            if (_sb) { cidade_espalhar(_sx - 150, _base - 260, _sx + 150, _base - 20, [ENF_CANTEIRO, ENF_BANCO, ENF_ARVORE], 2, 60, _ocup); continue; }
                            cidade_registrar_estrutura(_sx, _base, obj_casa_cidade, spr_casa_mini_map, "Loja", _l);
                            array_push(_ocup, [_sx, _base - 200, 220, 220]);
                            if (_i < _n - 1) {
                                cidade_registrar_enfeite(_ix + _lt * (_i + 1), _base + 4, ENF_BANCO);
                                array_push(_ocup, [_ix + _lt * (_i + 1), _base, 60, 30]);
                            }
                        }
                        cidade_registrar_enfeite(_ix + _mw - 60, _base + 4, ENF_LIXEIRA);
                    }
                    if (_mh > 620) cidade_espalhar(_ix + 70, _iy + 110, _ix + _mw - 70, _base - 420, [ENF_ARVORE, ENF_ARBUSTO, ENF_CANTEIRO], irandom_range(2, 4), 60, _ocup);
                    if (random(1) < 0.6) cidade_espalhar(_ix + 100, _iy + 120, _ix + _mw - 100, _base - 300, [ENF_POMBOS], 1, 40, _ocup);
                    break;

                case "jardim":   // quadra estreitinha: canteiros e árvores
                    cidade_espalhar(_ix + 60, _iy + 100, _ix + _mw - 60, _iy + _mh - 40, [ENF_ARVORE, ENF_CANTEIRO, ENF_ARBUSTO], irandom_range(2, 4), 60, _ocup);
                    if (_mh > 500) cidade_registrar_enfeite(_ix + _mw / 2, _iy + _mh / 2, ENF_BANCO);
                    break;

                case "praca":
                    var _pcx = _ix + _mw / 2, _pcy = _iy + _mh / 2 + 40;
                    var _rx = min(_mw * 0.32, 420), _ry = min(_mh * 0.30, 300);
                    cidade_registrar_enfeite(_pcx, _pcy, ENF_FONTE);
                    // bancos e canteiros em volta da fonte (anel, não grade)
                    var _qtd = (_mw > 1300) ? 8 : 6;
                    for (var _a = 0; _a < _qtd; _a++) {
                        var _ang = _a * 360 / _qtd + 22;
                        cidade_registrar_enfeite(_pcx + lengthdir_x(_rx, _ang), _pcy + lengthdir_y(_ry, _ang), (_a mod 2 == 0) ? ENF_BANCO : ENF_CANTEIRO);
                    }
                    cidade_registrar_enfeite(_ix + 110, _iy + 170, ENF_ARVORE);
                    cidade_registrar_enfeite(_ix + _mw - 110, _iy + 170, ENF_ARVORE);
                    cidade_registrar_enfeite(_ix + 110, _iy + _mh - 60, ENF_ARVORE);
                    cidade_registrar_enfeite(_ix + _mw - 110, _iy + _mh - 60, ENF_ARVORE);
                    if (_mw > 1300) {   // praça larga: mais árvores no meio das metades
                        cidade_registrar_enfeite(_ix + _mw * 0.15, _iy + _mh / 2, ENF_ARVORE);
                        cidade_registrar_enfeite(_ix + _mw * 0.85, _iy + _mh / 2, ENF_ARVORE);
                    }
                    cidade_registrar_enfeite(_pcx + random_range(-_rx * 0.5, _rx * 0.5), _pcy + _ry * 0.5, ENF_POMBOS);
                    registrar_posicao_geracao(_pcx, _pcy);
                    if (!_tem_vendedor) {
                        cidade_registrar_estrutura(_pcx + _rx * 0.75, _pcy + _ry + 40, obj_par_npc_vendedor_um, spr_vendedor, "Vendedor", -1);
                        _tem_vendedor = true;
                    }
                    break;

                case "parque":
                    // brinquedos espalhados por frações da quadra (funciona em qualquer tamanho)
                    var _brinq = [ENF_BALANCO, ENF_GANGORRA, ENF_ESCORREGADOR];
                    var _nb = (_mw > 1300) ? 5 : 3;
                    for (var _bq = 0; _bq < _nb; _bq++) {
                        var _fx = (_bq + 0.5) / _nb;
                        var _fy = (_bq mod 2 == 0) ? 0.45 : 0.72;
                        var _bxp = _ix + _mw * _fx, _byp = _iy + _mh * _fy;
                        cidade_registrar_enfeite(_bxp, _byp, _brinq[_bq mod 3]);
                        array_push(_ocup, [_bxp, _byp - 50, 120, 90]);
                    }
                    cidade_registrar_enfeite(_ix + 160, _iy + _mh - 50, ENF_BANCO);
                    cidade_registrar_enfeite(_ix + _mw - 160, _iy + _mh - 50, ENF_BANCO);
                    array_push(_ocup, [_ix + 160, _iy + _mh - 50, 80, 40], [_ix + _mw - 160, _iy + _mh - 50, 80, 40]);
                    cidade_espalhar(_ix + 70, _iy + 100, _ix + _mw - 70, _iy + _mh * 0.3, [ENF_ARVORE, ENF_ARVORE, ENF_ARBUSTO], irandom_range(3, 3 + _nb), 70, _ocup);
                    cidade_espalhar(_ix + 70, _iy + _mh * 0.55, _ix + _mw - 70, _iy + _mh - 40, [ENF_ARBUSTO, ENF_CANTEIRO], 2, 50, _ocup);
                    registrar_posicao_geracao(_ix + _mw / 2, _iy + _mh / 2);
                    break;
            }
        }
    }

    // nenhuma praça neste pedaço: vendedor em lugar aleatório como antes
    if (!_tem_vendedor) gerar_estruturas_para_bloco(_bx, _by, obj_par_npc_vendedor_um, 1, 400);
}
