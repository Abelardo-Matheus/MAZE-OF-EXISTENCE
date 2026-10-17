// feather disable GM2017
/// @desc scr_horde_api — Ponte entre as armas/pets e TODOS os inimigos (instâncias + horda)
/// [O QUE]: Funções públicas que qualquer objeto pode chamar.
///   - Dano na horda:   horde_hit_instance, horde_hit_instance_tick, horde_damage_circle, horde_pull_circle
///   - Mira universal:  inimigo_mais_proximo, inimigos_alvos, inimigo_posicao
/// [COMO] : Os inimigos-instância (obj_par_inimigos) continuam levando dano pelos eventos de
///          colisão de sempre. A horda não gera eventos de colisão, então cada arma chama uma
///          destas funções no próprio Step. Um "alvo" é sempre a struct { x, y, inst, uid, d2 }:
///          inst != noone -> instância; uid >= 0 -> inimigo da horda.

#region ---------- DANO NA HORDA ----------

/// Acerta inimigos da horda que tocam a bbox da instância.
/// _hit_list: ds_list da arma (perfuração) — guarda quem já levou dano. -1 = sem lista.
/// _max_hits: máximo de inimigos neste frame (-1 = todos). Retorna quantos foram atingidos.
function horde_hit_instance(_inst, _dmg, _kb, _from_x, _from_y, _hit_list = -1, _max_hits = -1, _crit = false) {
    var _hits = 0;
    if (!instance_exists(obj_horde) || !instance_exists(_inst)) return 0;
    var _cx = (_inst.bbox_left + _inst.bbox_right) * 0.5;
    var _cy = (_inst.bbox_top + _inst.bbox_bottom) * 0.5;
    var _r  = max(_inst.bbox_right - _inst.bbox_left, _inst.bbox_bottom - _inst.bbox_top) * 0.5;
    with (obj_horde) {
        var _n = _horde_collect_circle(_cx, _cy, _r);
        for (var _k = 0; _k < _n; _k++) {
            if (_max_hits >= 0 && _hits >= _max_hits) break;
            var _j = qbuf[_k];
            if (_hit_list != -1) {
                var _key = -1 - euid[_j]; // negativo: nunca colide com id de instância
                if (ds_list_find_index(_hit_list, _key) != -1) continue;
                ds_list_add(_hit_list, _key);
            }
            _horde_hit_index(_j, _dmg, _kb, _from_x, _from_y, _crit, false);
            _hits += 1;
        }
    }
    return _hits;
}

/// Para armas de contato contínuo (áreas, hitboxes que ficam paradas):
/// cada inimigo só leva dano dessa fonte a cada HORDE_TICK_IFRAMES frames.
function horde_hit_instance_tick(_inst, _dmg, _kb, _from_x, _from_y, _crit = false) {
    var _hits = 0;
    if (!instance_exists(obj_horde) || !instance_exists(_inst)) return 0;
    var _cx = (_inst.bbox_left + _inst.bbox_right) * 0.5;
    var _cy = (_inst.bbox_top + _inst.bbox_bottom) * 0.5;
    var _r  = max(_inst.bbox_right - _inst.bbox_left, _inst.bbox_bottom - _inst.bbox_top) * 0.5;
    with (obj_horde) {
        var _n = _horde_collect_circle(_cx, _cy, _r);
        for (var _k = 0; _k < _n; _k++) {
            var _j = qbuf[_k];
            if (etick[_j] > 0) continue;
            etick[_j] = HORDE_TICK_IFRAMES;
            _horde_hit_index(_j, _dmg, _kb, _from_x, _from_y, _crit, false);
            _hits += 1;
        }
    }
    return _hits;
}

/// Dano em área circular (raio, bomba, explosão, pólen).
/// _splash >= 0: dano cai com a distância igual ao obj_bomba. _silent: sem flash/número/som.
function horde_damage_circle(_x, _y, _r, _dmg, _kb = 0, _from_x = undefined, _from_y = undefined, _crit = false, _splash = -1, _silent = false) {
    var _hits = 0;
    if (!instance_exists(obj_horde)) return 0;
    if (is_undefined(_from_x)) _from_x = _x;
    if (is_undefined(_from_y)) _from_y = _y;
    with (obj_horde) {
        var _n = _horde_collect_circle(_x, _y, _r);
        for (var _k = 0; _k < _n; _k++) {
            var _j = qbuf[_k];
            var _final = _dmg;
            if (_splash >= 0) {
                var _d = sqrt(qd2[_k]);
                if (_d > 0) _final = max(0, _dmg * (1 - (_d / _r) * (1 - _splash)));
            }
            _horde_hit_index(_j, _final, _kb, _from_x, _from_y, _crit, _silent);
            _hits += 1;
        }
    }
    return _hits;
}

/// Puxa a horda para um ponto (buraco negro da bomba evoluída).
function horde_pull_circle(_x, _y, _r, _force, _min_dist = 10) {
    if (!instance_exists(obj_horde)) return 0;
    var _n = 0;
    with (obj_horde) {
        _n = _horde_collect_circle(_x, _y, _r);
        for (var _k = 0; _k < _n; _k++) {
            var _j = qbuf[_k];
            var _d = sqrt(qd2[_k]);
            if (_d <= _min_dist) continue;
            ex[_j] += (_x - ex[_j]) / _d * _force;
            ey[_j] += (_y - ey[_j]) / _d * _force;
        }
    }
    return _n;
}

/// XP no chão SEM criar instância (pool de gemas do obj_horde, com junção automática).
/// Retorna false se não há obj_horde na sala (outras fases): aí use o obj_xp_um normal.
function horde_xp_drop(_x, _y, _valor) {
    if (!instance_exists(obj_horde)) return false;
    with (obj_horde) _horde_gem_drop(_x, _y, _valor);
    return true;
}

function horde_count() {
    return instance_exists(obj_horde) ? obj_horde.alive : 0;
}

#endregion

#region ---------- MIRA UNIVERSAL (instâncias + horda) ----------

function _alvo_considerar(_sel, _x, _y, _inst, _uid, _d2) {
    switch (_sel.modo) {
        case "perto": {
            var _lst = _sel.lista, _len = array_length(_lst);
            if (_sel.lim >= 0 && _len >= _sel.lim && _d2 >= _lst[_len - 1].d2) return;
            var _a = { x: _x, y: _y, inst: _inst, uid: _uid, d2: _d2 };
            var _pos = _len;
            while (_pos > 0 && _lst[_pos - 1].d2 > _d2) _pos -= 1;
            array_insert(_lst, _pos, _a);
            if (_sel.lim >= 0 && array_length(_lst) > _sel.lim) array_pop(_lst);
            break;
        }
        case "aleatorio": { // reservoir sampling: escolha uniforme sem montar a lista inteira
            _sel.vistos += 1;
            var _a2 = { x: _x, y: _y, inst: _inst, uid: _uid, d2: _d2 };
            if (_sel.lim < 0 || array_length(_sel.lista) < _sel.lim) array_push(_sel.lista, _a2);
            else {
                var _r = irandom(_sel.vistos - 1);
                if (_r < _sel.lim) _sel.lista[_r] = _a2;
            }
            break;
        }
        default:
            array_push(_sel.lista, { x: _x, y: _y, inst: _inst, uid: _uid, d2: _d2 });
    }
}

/// Lista de alvos dentro de _range a partir de (_x,_y).
/// _modo: "perto" (ordenado do mais próximo), "aleatorio" ou "todos". _max: -1 = sem limite.
/// _na_tela: true = só quem está na câmera (+50px), como o raio fazia.
function inimigos_alvos(_x, _y, _range, _max = -1, _modo = "perto", _na_tela = false) {
    var _sel = { modo: _modo, lim: _max, lista: [], vistos: 0 };
    var _r2 = _range * _range;
    var _cam = view_camera[0];
    var _cx0 = camera_get_view_x(_cam) - 50, _cy0 = camera_get_view_y(_cam) - 50;
    var _cx1 = _cx0 + camera_get_view_width(_cam) + 100, _cy1 = _cy0 + camera_get_view_height(_cam) + 100;

    // 1) Inimigos-instância (arqueiros, monstros dos chunks, chefes de grupo...)
    with (obj_par_inimigos) {
        if (vida <= 0) continue;
        // Mira no centro da máscara (corpo), não na origem do sprite (pé)
        var _bx = (bbox_left + bbox_right) * 0.5, _by = (bbox_top + bbox_bottom) * 0.5;
        if (_na_tela && (_bx < _cx0 || _bx > _cx1 || _by < _cy0 || _by > _cy1)) continue;
        var _d2i = sqr(_bx - _x) + sqr(_by - _y);
        if (_d2i <= _r2) _alvo_considerar(_sel, _bx, _by, id, -1, _d2i);
    }

    // 2) Horda (só olha as células do hash dentro do alcance)
    if (instance_exists(obj_horde)) {
        with (obj_horde) {
            var _n = _horde_collect_circle(_x, _y, _range);
            for (var _k = 0; _k < _n; _k++) {
                var _j = qbuf[_k];
                var _hy = ey[_j] + ecy[_j]; // centro do corpo
                if (_na_tela && (ex[_j] < _cx0 || ex[_j] > _cx1 || _hy < _cy0 || _hy > _cy1)) continue;
                _alvo_considerar(_sel, ex[_j], _hy, noone, euid[_j], qd2[_k]);
            }
        }
    }
    return _sel.lista;
}

/// Inimigo mais próximo (instância ou horda) ou undefined.
function inimigo_mais_proximo(_x, _y, _range = 100000) {
    var _l = inimigos_alvos(_x, _y, _range, 1, "perto");
    return (array_length(_l) > 0) ? _l[0] : undefined;
}

/// Atualiza e devolve a posição de um alvo; undefined se ele morreu/sumiu.
/// Substitui o padrão "if (instance_exists(alvo)) ... alvo.x" para alvos que podem ser da horda.
function inimigo_posicao(_alvo) {
    if (is_undefined(_alvo) || !is_struct(_alvo)) return undefined;
    if (_alvo.inst != noone) {
        if (!instance_exists(_alvo.inst)) return undefined;
        _alvo.x = (_alvo.inst.bbox_left + _alvo.inst.bbox_right) * 0.5;
        _alvo.y = (_alvo.inst.bbox_top + _alvo.inst.bbox_bottom) * 0.5;
        return _alvo;
    }
    if (!instance_exists(obj_horde)) return undefined;
    var _ok = false;
    with (obj_horde) {
        var _s = _horde_slot_of(_alvo.uid);
        if (_s >= 0 && ehp[_s] > 0) {
            _alvo.x = ex[_s];
            _alvo.y = ey[_s] + ecy[_s];
            _ok = true;
        }
    }
    return _ok ? _alvo : undefined;
}

#endregion

#region ---------- SPAWN (chamado pelo sistema de ondas) ----------

/// Recebe um pedido de scr_rondas_noite: { obj, qtd, mult } (ver rondas_spec).
/// Cria um grupinho de "qtd" inimigos na borda do quadrado de spawn.
/// Retorna false se o objeto deve continuar sendo instância (ver horde_instance_only).
function horde_spawn_ronda(_spec) {
    if (!instance_exists(obj_horde) || horde_instance_only(_spec.obj)) return false;
    with (obj_horde) {
        _horde_spawn_group(_horde_ronda_tipo(_spec.obj, _spec.mult), _spec.qtd);
    }
    return true;
}

/// Evento "anel" das rondas: cerca o jogador com "qtd" inimigos.
function horde_spawn_anel(_spec) {
    if (!instance_exists(obj_horde) || horde_instance_only(_spec.obj)) return false;
    with (obj_horde) {
        _horde_enxame_iniciar(_horde_ronda_tipo(_spec.obj, _spec.mult), _spec.qtd);
    }
    return true;
}

#endregion
