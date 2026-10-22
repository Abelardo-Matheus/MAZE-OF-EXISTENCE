// feather disable GM2017
/// @desc scr_horde — Núcleo da horda noturna (data-oriented)
/// [O QUE]: Simula milhares de inimigos sem criar instâncias. Funções com "_" rodam no escopo
///          de obj_horde. A API pública (dano, alvos) fica em scr_horde_api.
/// [COMO] :
///  - Struct-of-arrays pré-alocado + swap-remove O(1): zero instance_create/destroy na noite.
///  - Tipos gerados a partir do Create real de cada objeto (instância-protótipo, 1x por tipo).
///  - Hash espacial por counting sort (O(n) por frame) para separação, contato, dano e mira.
///  - Separação fatiada no tempo (HORDE_AI_SLICES) e desenho com culling + y-sort grátis
///    (a ordem do hash já é por linha da tela).
///  - Gemas de XP e números de dano também em pool (antes: 1 instância por morte/hit).

#macro HORDE_UID_RING 65536

#region ---------- INIT ----------

function _horde_init() {
    var _n = HORDE_MAX;
    ex     = array_create(_n, 0);   ey     = array_create(_n, 0);
    evx    = array_create(_n, 0);   evy    = array_create(_n, 0);   // perseguição (suavizada)
    esx    = array_create(_n, 0);   esy    = array_create(_n, 0);   // separação (cache fatiado)
    ekx    = array_create(_n, 0);   eky    = array_create(_n, 0);   // knockback
    ehp    = array_create(_n, 0);   ehpmax = array_create(_n, 1);
    espd   = array_create(_n, 0);   erad   = array_create(_n, 0);
    etype  = array_create(_n, 0);   euid   = array_create(_n, -1);
    ecell  = array_create(_n, -1);  estun  = array_create(_n, 0);
    ehpbar = array_create(_n, 0);   etick  = array_create(_n, 0);
    ephase = array_create(_n, 0);
    ecy    = array_create(_n, 0);   // deslocamento Y do centro do corpo (a origem dos sprites fica no pé)
    ea     = array_create(_n, 0);   eb     = array_create(_n, 0);   edir = array_create(_n, 0); // investida
    alive  = 0;

    uid_next = 0;
    uid_slot = array_create(HORDE_UID_RING, -1);

    types = [];
    type_lookup = {};

    // Hash espacial
    grid_items  = array_create(_n, 0);
    grid_start  = [0];
    grid_cursor = [];
    grid_x0 = 0; grid_y0 = 0; grid_w = 0; grid_h = 0;
    q_gx0 = 0; q_gy0 = 0; q_gx1 = -1; q_gy1 = -1;
    qbuf = array_create(_n, 0);
    qd2  = array_create(_n, 0);

    // Câmera / jogador
    cam_x = 0; cam_y = 0; cam_w = 1; cam_h = 1;
    horde_px = 0; horde_py = 0; horde_pr = 8;
    horde_pcx = 0; horde_pcy = 0; // centro da máscara do jogador (contato)

    // Gemas de XP
    gem_x = array_create(HORDE_GEM_MAX, 0);
    gem_y = array_create(HORDE_GEM_MAX, 0);
    gem_v = array_create(HORDE_GEM_MAX, 0);
    gem_s = array_create(HORDE_GEM_MAX, HORDE_GEM_ESCALA); // tamanho no desenho (cresce com o valor)
    gem_count = 0;
    gem_sprite = object_get_sprite(obj_xp_um);

    // Números de dano (ring buffer)
    pop_x = array_create(HORDE_POPUP_MAX, 0);
    pop_y = array_create(HORDE_POPUP_MAX, 0);
    pop_v = array_create(HORDE_POPUP_MAX, 0);
    pop_a = array_create(HORDE_POPUP_MAX, 0);
    pop_c = array_create(HORDE_POPUP_MAX, c_white);
    pop_crit = array_create(HORDE_POPUP_MAX, false);
    pop_next = 0;

    // Recursos opcionais (mesmo padrão do scr_enemy_damage_apply)
    snd_dano  = asset_get_index("snd_damage");
    snd_xp    = asset_get_index("snd_xp_pick");
    fnt_crit  = asset_get_index("fnt_dano_crit");
    som_cd    = 0;
    som_xp_cd = 0;

    // Enxame em anel
    enxame_timer    = HORDE_ENXAME_INTERVALO;
    enxame_pendente = 0;
    enxame_total    = 1;
    enxame_tipo     = -1;

    frame  = 0;
    paused = false;
}

#endregion

#region ---------- TIPOS (gerados do Create real do objeto) ----------

/// Devolve o índice do tipo para (objeto, mult. de vida da onda, escala da onda).
/// Na primeira vez cria uma instância-protótipo, lê os valores do Create e a destrói.
function _horde_type_get(_obj, _hp_mult, _scale, _over = undefined, _key_extra = "") {
    var _key = string(_obj) + "|" + string(_hp_mult) + "|" + string(_scale) + _key_extra;
    var _found = type_lookup[$ _key];
    if (!is_undefined(_found)) return _found;

    var _t = { obj: _obj, split: undefined, split_type: -1 };
    var _p = instance_create_depth(-100000, -100000, 0, _obj);
    with (_p) {
        var _spr = (variable_instance_exists(id, "sprite_normal") && sprite_exists(sprite_normal)) ? sprite_normal : sprite_index;
        _t.sprite = _spr;
        // Mesma conta do antigo spawn_night_enemy: escala = escala_da_onda * sprite_ajuste(sprite_index)
        _t.escala = is_undefined(_scale) ? escala : _scale * sprite_ajuste(sprite_index);
        _t.hp     = max(1, vida * _hp_mult);
        _t.dmg    = dano;
        _t.spd    = veloc_perse;
        _t.lvl    = (variable_instance_exists(id, "lvl_inimigo") && lvl_inimigo > 0) ? lvl_inimigo
                  : ((variable_instance_exists(id, "lvl") && is_real(lvl) && lvl > 0) ? lvl : 1);
        var _comp = variable_instance_exists(id, "comportamento") ? comportamento : "perseguir";
        _t.modo   = (_comp == "erratico") ? 1 : ((_comp == "investida") ? 2 : 0);
        _t.voa    = variable_instance_exists(id, "voa") ? voa : false;
        _t.transp = variable_instance_exists(id, "transparencia") ? transparencia : 1;
        _t.sombra = variable_instance_exists(id, "sombra_largura") ? sombra_largura : 30;
    }
    _t.xp    = HORDE_XP_BASE + _t.lvl * HORDE_XP_POR_LVL;
    _t.elite = false;
    instance_destroy(_p, false); // false = não roda o Destroy (não mexe em enemy_list/grupos)

    if (!is_undefined(_over)) {
        if (variable_struct_exists(_over, "hp"))     _t.hp     = max(1, _over.hp);
        if (variable_struct_exists(_over, "dmg"))    _t.dmg    = _over.dmg;
        if (variable_struct_exists(_over, "escala")) _t.escala = _over.escala;
        if (variable_struct_exists(_over, "spd"))    _t.spd    = _over.spd;
        if (variable_struct_exists(_over, "xp"))     _t.xp     = _over.xp;
        // Multiplicadores das rondas da noite (scr_rondas_noite)
        if (variable_struct_exists(_over, "mult_hp"))  _t.hp     = max(1, _t.hp * _over.mult_hp);
        if (variable_struct_exists(_over, "mult_dmg")) _t.dmg    = _t.dmg * _over.mult_dmg;
        if (variable_struct_exists(_over, "mult_esc")) _t.escala = _t.escala * _over.mult_esc;
        if (variable_struct_exists(_over, "mult_spd")) _t.spd    = _t.spd * _over.mult_spd;
        if (variable_struct_exists(_over, "mult_xp"))  _t.xp     = _t.xp * _over.mult_xp;
        if (variable_struct_exists(_over, "elite"))    _t.elite  = _over.elite;
    }

    // Cor pela força (mesma regra das instâncias: IA_INIMIGOS -> inimigo_cor_por_poder)
    var _mh = (!is_undefined(_over) && variable_struct_exists(_over, "mult_hp")) ? _over.mult_hp : 1;
    _t.poder = max((_t.lvl - 1) / (INIMIGO_NIVEL_COR_MAX - 1), (_mh * (_t.elite ? 2 : 1) - 1) / (INIMIGO_RONDA_COR_MAX - 1));
    _t.cor   = inimigo_cor_por_poder(_t.poder);

    var _spr2 = _t.sprite;
    var _sp = sprite_get_speed(_spr2);
    _t.anim_fps = ((sprite_get_speed_type(_spr2) == spritespeed_framespersecond) ? _sp : _sp * game_get_speed(gamespeed_fps)) * 1.2;
    var _bw = (sprite_get_bbox_right(_spr2)  - sprite_get_bbox_left(_spr2) + 1) * _t.escala;
    var _bh = (sprite_get_bbox_bottom(_spr2) - sprite_get_bbox_top(_spr2)  + 1) * _t.escala;
    // HITBOX: círculo no CENTRO da bbox do sprite (antes ficava na origem = pé do inimigo,
    // então armas e jogador acertavam o chão embaixo dele). Raio = média de largura/altura.
    _t.radius = max(4, (_bw + _bh) * 0.25);
    _t.cy     = ((sprite_get_bbox_top(_spr2) + sprite_get_bbox_bottom(_spr2) + 1) * 0.5 - sprite_get_yoffset(_spr2)) * _t.escala;
    _t.topo   = (sprite_get_bbox_top(_spr2) - sprite_get_yoffset(_spr2)) * _t.escala; // bbox_top relativo
    _t.split  = horde_split_rule(_obj);

    var _idx = array_length(types);
    array_push(types, _t);
    type_lookup[$ _key] = _idx;
    return _idx;
}

function _horde_split_type(_parent_idx) {
    var _pt = types[_parent_idx];
    if (_pt.split_type < 0) {
        // Intenção do antigo obj_amoeba_laranja: metade da vida/dano e um pouco menor
        _pt.split_type = _horde_type_get(_pt.split.obj, 1, undefined,
            { hp: _pt.hp * 0.5, dmg: _pt.dmg * 0.5, escala: max(0.4, _pt.escala - 0.5), spd: _pt.spd, xp: _pt.xp * 0.5 },
            "|split" + string(_parent_idx));
    }
    return _pt.split_type;
}

#endregion

#region ---------- POOL ----------

function _horde_add(_type, _x, _y) {
    if (alive >= HORDE_MAX) return -1;
    var _i = alive;
    alive += 1;
    var _t = types[_type];
    ex[_i] = _x;   ey[_i] = _y;
    evx[_i] = 0;   evy[_i] = 0;
    esx[_i] = 0;   esy[_i] = 0;
    ekx[_i] = 0;   eky[_i] = 0;
    ehp[_i] = _t.hp;  ehpmax[_i] = _t.hp;
    espd[_i] = _t.spd * random_range(0.92, 1.08); // quebra o "bloco" uniforme
    erad[_i] = _t.radius;
    ecy[_i] = _t.cy;
    etype[_i] = _type;
    ecell[_i] = -1;
    estun[_i] = 0;  ehpbar[_i] = 0;  etick[_i] = 0;
    ephase[_i] = random(100);
    ea[_i] = 0;  eb[_i] = irandom_range(60, 140);  edir[_i] = 0;

    var _uid = uid_next;
    uid_next += 1;
    euid[_i] = _uid;
    uid_slot[_uid mod HORDE_UID_RING] = _i;
    return _i;
}

/// Remoção O(1): o último ocupa o buraco.
function _horde_remove(_i) {
    alive -= 1;
    var _l = alive;
    if (_i == _l) return;
    ex[_i] = ex[_l];        ey[_i] = ey[_l];
    evx[_i] = evx[_l];      evy[_i] = evy[_l];
    esx[_i] = esx[_l];      esy[_i] = esy[_l];
    ekx[_i] = ekx[_l];      eky[_i] = eky[_l];
    ehp[_i] = ehp[_l];      ehpmax[_i] = ehpmax[_l];
    espd[_i] = espd[_l];    erad[_i] = erad[_l];
    etype[_i] = etype[_l];  euid[_i] = euid[_l];
    ecell[_i] = ecell[_l];  estun[_i] = estun[_l];
    ehpbar[_i] = ehpbar[_l]; etick[_i] = etick[_l];
    ephase[_i] = ephase[_l];
    ecy[_i] = ecy[_l];
    ea[_i] = ea[_l];  eb[_i] = eb[_l];  edir[_i] = edir[_l];
    uid_slot[euid[_i] mod HORDE_UID_RING] = _i;
}

/// Índice atual de um uid, ou -1 se morreu.
function _horde_slot_of(_uid) {
    var _s = uid_slot[_uid mod HORDE_UID_RING];
    if (_s < 0 || _s >= alive || euid[_s] != _uid) return -1;
    return _s;
}

#endregion

#region ---------- CÂMERA ----------

function _horde_view() {
    var _cam = view_camera[0];
    cam_x = camera_get_view_x(_cam);
    cam_y = camera_get_view_y(_cam);
    cam_w = camera_get_view_width(_cam);
    cam_h = camera_get_view_height(_cam);
}

#endregion

#region ---------- HASH ESPACIAL ----------

function _horde_grid_build() {
    var _cs = HORDE_GRID_CELL, _m = HORDE_GRID_MARGIN;
    grid_x0 = cam_x - _m;
    grid_y0 = cam_y - _m;
    grid_w  = ceil((cam_w + _m * 2) / _cs);
    grid_h  = ceil((cam_h + _m * 2) / _cs);
    var _cells = grid_w * grid_h;
    var _i, _c, _gx, _gy;

    // Só cresce (o zoom da câmera muda o tamanho sem realocar todo frame)
    if (array_length(grid_cursor) < _cells) {
        grid_start  = array_create(_cells + 1, 0);
        grid_cursor = array_create(_cells, 0);
    } else {
        for (_c = 0; _c < _cells; _c++) grid_cursor[_c] = 0;
    }

    for (_i = 0; _i < alive; _i++) {
        _gx = floor((ex[_i] - grid_x0) / _cs);
        _gy = floor((ey[_i] + ecy[_i] - grid_y0) / _cs);
        if (_gx < 0 || _gy < 0 || _gx >= grid_w || _gy >= grid_h) { ecell[_i] = -1; continue; }
        _c = _gy * grid_w + _gx;
        ecell[_i] = _c;
        grid_cursor[_c] += 1;
    }
    grid_start[0] = 0;
    for (_c = 0; _c < _cells; _c++) {
        grid_start[_c + 1] = grid_start[_c] + grid_cursor[_c];
        grid_cursor[_c] = grid_start[_c];
    }
    for (_i = 0; _i < alive; _i++) {
        _c = ecell[_i];
        if (_c < 0) continue;
        grid_items[grid_cursor[_c]] = _i;
        grid_cursor[_c] += 1;
    }
    grid_total = grid_start[_cells];
}

function _horde_query_bounds(_x, _y, _r) {
    if (grid_w <= 0) return false;
    var _cs = HORDE_GRID_CELL;
    q_gx0 = max(0, floor((_x - _r - grid_x0) / _cs) - 1);
    q_gy0 = max(0, floor((_y - _r - grid_y0) / _cs) - 1);
    q_gx1 = min(grid_w - 1, floor((_x + _r - grid_x0) / _cs) + 1);
    q_gy1 = min(grid_h - 1, floor((_y + _r - grid_y0) / _cs) + 1);
    return (q_gx0 <= q_gx1 && q_gy0 <= q_gy1);
}

/// Preenche qbuf/qd2 com inimigos vivos cujo corpo toca o círculo. Retorna a quantidade.
function _horde_collect_circle(_x, _y, _r) {
    if (!_horde_query_bounds(_x, _y, _r)) return 0;
    var _n = 0, _gx, _gy, _cc, _k, _kend, _j, _dx, _dy, _rr, _d2;
    for (_gy = q_gy0; _gy <= q_gy1; _gy++) {
        for (_gx = q_gx0; _gx <= q_gx1; _gx++) {
            _cc = _gy * grid_w + _gx;
            _kend = grid_start[_cc + 1];
            for (_k = grid_start[_cc]; _k < _kend; _k++) {
                _j = grid_items[_k];
                if (_j >= alive || ehp[_j] <= 0) continue;
                _dx = ex[_j] - _x;
                _dy = ey[_j] + ecy[_j] - _y; // centro do corpo
                _rr = _r + erad[_j];
                _d2 = _dx * _dx + _dy * _dy;
                if (_d2 >= _rr * _rr) continue;
                qbuf[_n] = _j;
                qd2[_n]  = _d2;
                _n += 1;
            }
        }
    }
    return _n;
}

#endregion

#region ---------- DANO (interno) ----------

/// Aplica dano no inimigo de índice _j (mesmo efeito do scr_enemy_damage_apply).
function _horde_hit_index(_j, _dmg, _kb, _from_x, _from_y, _crit, _silent) {
    ehp[_j] -= _dmg;
    if (_silent) return;

    estun[_j]  = HORDE_STUN_FRAMES;
    ehpbar[_j] = HORDE_HPBAR_FRAMES;
    if (_kb > 0) {
        var _dx = ex[_j] - _from_x, _dy = ey[_j] - _from_y;
        var _d = sqrt(_dx * _dx + _dy * _dy);
        if (_d < 0.001) { _dx = 1; _dy = 0; _d = 1; }
        ekx[_j] = _dx / _d * _kb;
        eky[_j] = _dy / _d * _kb;
    }

    // Número de dano (pool, sobrescreve o mais antigo)
    var _p = pop_next;
    pop_next = (pop_next + 1) mod HORDE_POPUP_MAX;
    pop_x[_p] = ex[_j];
    pop_y[_p] = ey[_j] + ecy[_j];
    pop_v[_p] = _dmg;
    pop_a[_p] = 1;
    pop_c[_p] = _crit ? c_red : c_white;
    pop_crit[_p] = _crit;

    if (snd_dano != -1 && som_cd <= 0) {
        audio_play_sound(snd_dano, 1, false);
        som_cd = HORDE_SOM_DANO_INTERVALO;
    }
}

#endregion

#region ---------- SPAWN ----------

/// Ponto na borda do quadrado de spawn fixo (Camera.gml), sempre fora do zoom máximo.
function _horde_edge_point() {
    spawn_ponto_quadrado();
    spawn_x = global.spawn_px;
    spawn_y = global.spawn_py;
}

function _horde_spawn_group(_type, _qtd) {
    _horde_edge_point();
    var _g = HORDE_GRUPO_ESPALHAR;
    repeat (_qtd) {
        if (_horde_add(_type, spawn_x + random_range(-_g, _g), spawn_y + random_range(-_g, _g)) < 0) break;
    }
}

/// Tipo da horda para um objeto + multiplicadores da ronda (rondas_mults).
function _horde_ronda_tipo(_obj, _m) {
    return _horde_type_get(_obj, 1, undefined,
        { mult_hp: _m.hp, mult_dmg: _m.dmg, mult_esc: _m.esc, mult_spd: _m.spd, mult_xp: _m.xp, elite: _m.elite },
        _m.chave);
}

/// Escolhe um tipo da ronda atual (para o cerco automático).
function _horde_tipo_da_onda() {
    var _spec = rondas_spec_aleatorio(1);
    if (is_undefined(_spec)) return -1;
    return _horde_ronda_tipo(_spec.obj, _spec.mult);
}

/// Começa um cerco em anel em volta do jogador (sai aos poucos, HORDE_SPAWN_BUDGET por frame).
function _horde_enxame_iniciar(_type, _qtd) {
    if (_type < 0 || _qtd <= 0) return;
    enxame_tipo     = _type;
    enxame_pendente = _qtd;
    enxame_total    = _qtd;
}

function _horde_director(_noite) {
    if (_noite) {
        // Cerco automático a cada HORDE_ENXAME_INTERVALO segundos (0 = só os anéis das rondas)
        if (HORDE_ENXAME_INTERVALO > 0) {
            enxame_timer -= min(delta_time / 1000000, 0.1);
            if (enxame_timer <= 0) {
                enxame_timer = HORDE_ENXAME_INTERVALO;
                if (enxame_pendente <= 0) _horde_enxame_iniciar(_horde_tipo_da_onda(), HORDE_ENXAME_QTD);
            }
        }
        // Anel pendente (automático ou evento "anel" de scr_rondas_noite)
        var _ring = SPAWN_QUADRADO_LADO * 0.5; // círculo inscrito no quadrado de spawn (fora do zoom máximo)
        var _budget = HORDE_SPAWN_BUDGET;
        while (enxame_pendente > 0 && _budget > 0) {
            var _ang = 360 * enxame_pendente / enxame_total;
            enxame_pendente -= 1;
            _budget -= 1;
            if (_horde_add(enxame_tipo, horde_px + lengthdir_x(_ring, _ang), horde_py + lengthdir_y(_ring, _ang)) < 0) {
                enxame_pendente = 0;
            }
        }
    } else {
        enxame_pendente = 0;
        enxame_timer = HORDE_ENXAME_INTERVALO;
        // Amanhecer: some quem está fora da tela, poucos por frame
        if (HORDE_SOME_AO_AMANHECER) {
            var _n = HORDE_AMANHECER_POR_FRAME;
            var _x0 = cam_x - 32, _y0 = cam_y - 32, _x1 = cam_x + cam_w + 32, _y1 = cam_y + cam_h + 32;
            for (var _i = alive - 1; _i >= 0 && _n > 0; _i--) {
                if (ex[_i] < _x0 || ey[_i] < _y0 || ex[_i] > _x1 || ey[_i] > _y1) {
                    _horde_remove(_i);
                    _n -= 1;
                }
            }
        }
    }
}

/// Debug: cria _qtd inimigos (tipo da onda atual ou o primeiro da lista de ondas).
function _horde_stress_test(_qtd) {
    var _type = _horde_tipo_da_onda();
    if (_type < 0) _type = _horde_ronda_tipo(obj_esqueleto, rondas_mults(0, false));
    while (_qtd > 0 && alive < HORDE_MAX) {
        var _lote = min(_qtd, 25);
        _horde_spawn_group(_type, _lote);
        _qtd -= _lote;
    }
}

#endregion

#region ---------- MORTES / XP ----------

function _horde_process_deaths() {
    for (var _i = alive - 1; _i >= 0; _i--) {
        if (ehp[_i] > 0) continue;
        var _type = etype[_i], _x = ex[_i], _y = ey[_i];
        var _t = types[_type];

        _horde_gem_drop(_x, _y, round(_t.xp)); // XP já escalado pela ronda (scr_rondas_noite)
        horde_on_enemy_death(_t.obj, _x, _y);
        item_ao_matar(_x, _y); // XP dos itens equipados + passivas de abate
        _horde_remove(_i);

        if (!is_undefined(_t.split)) {
            var _child = _horde_split_type(_type);
            repeat (_t.split.count) _horde_add(_child, _x + random_range(-12, 12), _y + random_range(-12, 12));
        }
    }
}

/// Tamanho de desenho de uma gema pelo valor (cresce devagar, em escala log).
function _horde_gem_escala(_v) {
    var _rel = max(1, _v / HORDE_XP_BASE);
    return HORDE_GEM_ESCALA * min(HORDE_GEM_ESCALA_MAX, 1 + log2(_rel) * 0.25);
}

/// Solta XP no chão. Gemas não são instâncias: são só 4 arrays (x, y, valor, tamanho).
/// Se já existe uma gema a menos de HORDE_GEM_JUNTAR_RAIO, o XP é somado nela
/// (morte em massa vira poucas gemas grandes em vez de centenas pequenas).
function _horde_gem_drop(_x, _y, _v) {
    if (_v <= 0) return;
    var _r2 = HORDE_GEM_JUNTAR_RAIO * HORDE_GEM_JUNTAR_RAIO;
    var _best = -1, _best_d2 = infinity;
    for (var _g = gem_count - 1; _g >= 0; _g--) {
        var _dx = gem_x[_g] - _x, _dy = gem_y[_g] - _y;
        var _d2 = _dx * _dx + _dy * _dy;
        if (_d2 < _best_d2) { _best_d2 = _d2; _best = _g; }
    }
    if (_best >= 0 && (_best_d2 <= _r2 || gem_count >= HORDE_GEM_MAX)) {
        // Junta (ou chão cheio: soma na mais próxima)
        gem_v[_best] += _v;
        gem_s[_best] = _horde_gem_escala(gem_v[_best]);
        return;
    }
    if (gem_count >= HORDE_GEM_MAX) return;
    gem_x[gem_count] = _x;
    gem_y[gem_count] = _y;
    gem_v[gem_count] = _v;
    gem_s[gem_count] = _horde_gem_escala(_v);
    gem_count += 1;
}

function _horde_gems_update() {
    var _col = variable_global_exists("coleta") ? global.coleta : 50;
    var _px = horde_px, _py = horde_py, _pick = horde_pr + 8;
    for (var _g = gem_count - 1; _g >= 0; _g--) {
        var _dx = _px - gem_x[_g], _dy = _py - gem_y[_g];
        var _d = sqrt(_dx * _dx + _dy * _dy);
        if (_d <= _pick) {
            ganhar_xp(gem_v[_g]);
            if (snd_xp != -1 && som_xp_cd <= 0) { audio_play_sound(snd_xp, 1, false); som_xp_cd = 3; }
            gem_count -= 1;
            gem_x[_g] = gem_x[gem_count];
            gem_y[_g] = gem_y[gem_count];
            gem_v[_g] = gem_v[gem_count];
            gem_s[_g] = gem_s[gem_count];
            if (global.level_up) break; // abriu a tela de level up: para tudo como o obj_xp_um
            continue;
        }
        if (_d - _pick <= _col) { // dentro do raio de coleta: voa para o jogador
            gem_x[_g] += _dx / _d * HORDE_GEM_VELOC;
            gem_y[_g] += _dy / _d * HORDE_GEM_VELOC;
        }
    }
}

#endregion

#region ---------- MOVIMENTO / IA ----------

function _horde_separation(_i) {
    var _c = ecell[_i];
    if (_c < 0) { esx[_i] = 0; esy[_i] = 0; return; }
    var _gx = _c mod grid_w, _gy = _c div grid_w;
    var _x1 = ex[_i], _y1 = ey[_i] + ecy[_i], _r1 = erad[_i];
    var _sx = 0, _sy = 0, _checked = 0;
    var _ox, _oy, _xx, _yy, _cc, _k, _kend, _j, _dx, _dy, _rr, _d2, _d, _push;

    for (_oy = -1; _oy <= 1; _oy++) {
        _yy = _gy + _oy;
        if (_yy < 0 || _yy >= grid_h) continue;
        for (_ox = -1; _ox <= 1; _ox++) {
            _xx = _gx + _ox;
            if (_xx < 0 || _xx >= grid_w) continue;
            _cc = _yy * grid_w + _xx;
            _kend = grid_start[_cc + 1];
            for (_k = grid_start[_cc]; _k < _kend; _k++) {
                _j = grid_items[_k];
                if (_j == _i) continue;
                _dx = _x1 - ex[_j];
                _dy = _y1 - (ey[_j] + ecy[_j]);
                _rr = _r1 + erad[_j];
                _d2 = _dx * _dx + _dy * _dy;
                if (_d2 >= _rr * _rr) continue;
                if (_d2 < 0.0001) { _dx = random_range(-1, 1); _dy = random_range(-1, 1); _d2 = _dx * _dx + _dy * _dy + 0.0001; }
                _d = sqrt(_d2);
                _push = (_rr - _d) / _rr;
                _sx += _dx / _d * _push;
                _sy += _dy / _d * _push;
                _checked += 1;
                if (_checked >= HORDE_MAX_NEIGHBORS) {
                    esx[_i] = _sx * HORDE_SEPARATION_FORCE;
                    esy[_i] = _sy * HORDE_SEPARATION_FORCE;
                    return;
                }
            }
        }
    }
    esx[_i] = _sx * HORDE_SEPARATION_FORCE;
    esy[_i] = _sy * HORDE_SEPARATION_FORCE;
}

function _horde_move(_noite) {
    var _px = horde_px, _py = horde_py;
    var _slice = frame mod HORDE_AI_SLICES;
    // Teleporte usa o mesmo quadrado fixo do spawn (independe do zoom)
    spawn_quadrado_atualizar();
    var _wx0 = global.spawn_x0, _wy0 = global.spawn_y0;
    var _wx1 = global.spawn_x1, _wy1 = global.spawn_y1;
    var _tnow = current_time;
    var _i, _x1, _y1, _dx, _dy, _dist, _spd, _tvx, _tvy, _dir, _t;

    for (_i = 0; _i < alive; _i++) {
        _x1 = ex[_i]; _y1 = ey[_i];

        // Teleporte para o lado oposto do quadrado de spawn (igual ao obj_par_inimigos à noite)
        if (_noite) {
            if (_y1 < _wy0) _y1 = _wy1; else if (_y1 > _wy1) _y1 = _wy0;
            if (_x1 < _wx0) _x1 = _wx1; else if (_x1 > _wx1) _x1 = _wx0;
        }

        if (estun[_i] > 0) {
            // Estado de hit: só o empurrão age (scr_inimigo_hit)
            estun[_i] -= 1;
            ekx[_i] *= 0.95;
            eky[_i] *= 0.95;
            _x1 += ekx[_i];
            _y1 += eky[_i];
            if (estun[_i] <= 0) { ekx[_i] = 0; eky[_i] = 0; }
        } else {
            _dx = _px - _x1; _dy = _py - _y1;
            _dist = sqrt(_dx * _dx + _dy * _dy);
            _spd = espd[_i];
            _t = types[etype[_i]];
            _tvx = 0; _tvy = 0;

            if (_dist > 0.5) {
                switch (_t.modo) {
                    case 1: // "erratico" (morcego): zigue-zague
                        _dir = point_direction(_x1, _y1, _px, _py) + sin(_tnow * 0.008 + ephase[_i]) * 55;
                        _tvx = lengthdir_x(_spd, _dir);
                        _tvy = lengthdir_y(_spd, _dir);
                        break;

                    case 2: // "investida" (fantasma vermelho): bote rápido
                        if (ea[_i] > 0) {
                            ea[_i] -= 1;
                            _tvx = lengthdir_x(_spd * 4, edir[_i]);
                            _tvy = lengthdir_y(_spd * 4, edir[_i]);
                            evx[_i] = _tvx; evy[_i] = _tvy; // sem suavização durante o bote
                        } else {
                            eb[_i] -= 1;
                            if (eb[_i] <= 0) {
                                edir[_i] = point_direction(_x1, _y1, _px, _py);
                                ea[_i] = 16;
                                eb[_i] = irandom_range(100, 140);
                            } else if (eb[_i] <= 25 && _dist < 260) {
                                _x1 += random_range(-1, 1); // treme avisando
                            } else {
                                _tvx = _dx / _dist * _spd;
                                _tvy = _dy / _dist * _spd;
                            }
                        }
                        break;

                    default: // "perseguir"
                        _tvx = _dx / _dist * _spd;
                        _tvy = _dy / _dist * _spd;
                        break;
                }
            }

            evx[_i] = lerp(evx[_i], _tvx, 0.35);
            evy[_i] = lerp(evy[_i], _tvy, 0.35);

            if ((_i mod HORDE_AI_SLICES) == _slice) _horde_separation(_i);

            _x1 += evx[_i] + esx[_i];
            _y1 += evy[_i] + esy[_i];
        }

        ex[_i] = _x1; ey[_i] = _y1;
        if (ehpbar[_i] > 0) ehpbar[_i] -= 1;
        if (etick[_i]  > 0) etick[_i]  -= 1;
    }
}

function _horde_player_contact(_p) {
    if (!_p.tomar_dano) return;
    var _n = _horde_collect_circle(horde_pcx, horde_pcy, horde_pr); // máscara do jogador, não a origem
    if (_n <= 0) return;
    var _j = qbuf[0];
    horde_on_player_hit(_p, types[etype[_j]].dmg, ex[_j], ey[_j]);
}

function _horde_popups_update() {
    for (var _p = 0; _p < HORDE_POPUP_MAX; _p++) {
        if (pop_a[_p] <= 0) continue;
        pop_y[_p] -= 0.25;   // mesmo ritmo do obj_dano
        pop_a[_p] -= 0.01;
    }
}

#endregion
