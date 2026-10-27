// feather disable GM2017
// ============================================================================
//  PASSIVAS DOS ITENS + NÍVEL POR ABATES + HABILIDADE DA ARMA (tecla X)
// ----------------------------------------------------------------------------
//  global.passivas_itens = VETOR com todos os tipos de passiva. Cada uma:
//    id, nome, stat, base, teto (-1 = sem teto), inteiro, para, sorteavel,
//    desc ("{v}" vira o valor no nível), cor, adesivo (item adesivo ou "") + ad_frame (frame no spr_itens_craft),
//    icone (item usado para desenhar a passiva)
//  "para" diz em quais itens ela pode aparecer:
//    "todos" | "ataque" (arma, arco) | "defesa" (cabeça, armadura, bota) | um tipo ("arma", "arco", "cabeca"...)
//  global.passivas_db[$ id] / global.passivas_ordem são montados a partir do vetor.
//
//  NÍVEL DO ITEM: sobe matando monstros (item_ao_matar). Sem limite.
//    XP para o próximo nível = ITEM_XP_BASE * nível ^ ITEM_XP_EXPOENTE  (item_xp_prox)
//    Ganham XP: cabeça, armadura, bota e o item na mão (hotbar).
//    Passiva no nível N = base * (1 + ITEM_CRESC_PASSIVA * (N - 1))  (com "teto" se tiver)
//  Todo equipamento tem 1 passiva própria (inata; se o catálogo não deu, ganha a do tipo:
//  item_passiva_padrao) + até ITEM_PASSIVAS_MAX passivas sorteadas/adesivos.
//
//  HABILIDADE (tecla X, ação "habilidade"):
//    Espada: Giro — golpe em volta do player.   Arco: Chuva de flechas em leque.
//    Ficam mais fortes com o nível do item; recarga reduzida pela passiva "Pressa".
// ============================================================================

#macro ITEM_PASSIVAS_MAX     3      // passivas sorteadas + adesivos por item
#macro ITEM_CRESC_PASSIVA    0.25   // +25% da base por nível
#macro ITEM_XP_BASE          12     // XP do Nv1 -> Nv2
#macro ITEM_XP_EXPOENTE      1.5
#macro ITEM_XP_POR_ABATE     1
#macro ITEM_ATIVO_ESPADA_CD  360    // 6 s
#macro ITEM_ATIVO_ARCO_CD    300    // 5 s

#region ---------- VETOR DE PASSIVAS ----------

function itens_definir_passivas() {
    global.passivas_itens = [
        // ---- qualquer equipamento ----
        { id: "coracao",   nome: "Coração Quentinho",    stat: "regen",          base: 0.5, teto: -1,  para: ["todos"],  desc: "Recupera {v} de vida por segundo.",            cor: make_color_rgb(255, 110, 140), adesivo: "ad_coracao", ad_frame: 15 },
        { id: "estrela",   nome: "Estrela da Sorte",     stat: "crit",           base: 4,   teto: 60,  para: ["todos"],  desc: "+{v}% de chance de crítico.",                  cor: make_color_rgb(255, 210,  60), adesivo: "ad_estrela", ad_frame: 16 },
        { id: "raio",      nome: "Raio Veloz",           stat: "vel",            base: 0.5, teto: 6,   para: ["todos"],  desc: "+{v} de velocidade.",                          cor: make_color_rgb(255, 225,  80), adesivo: "ad_raio", ad_frame: 19 },
        { id: "cofrinho",  nome: "Cofrinho",             stat: "moeda_abate",    base: 8,   teto: 100, para: ["todos"],  desc: "{v}% de chance de ganhar 1 moeda por abate.",  cor: make_color_rgb(255, 200, 120), icone: "ad_estrela" },
        { id: "sabedoria", nome: "Livro de Colorir",     stat: "xp_item",        base: 15,  teto: -1,  para: ["todos"],  desc: "+{v}% de XP para os itens equipados.",         cor: make_color_rgb(180, 140, 255), icone: "po_estrela" },
        // ---- ataque (espada e arco) ----
        { id: "forca",     nome: "Músculo de Brinquedo", stat: "dano_pct",       base: 8,   teto: -1,  para: ["ataque"], desc: "+{v}% de dano.",                               cor: make_color_rgb(255, 140, 110), adesivo: "ad_forca", ad_frame: 17 },
        { id: "vampiro",   nome: "Dentinho de Vampiro",  stat: "vampirismo",     base: 3,   teto: 30,  para: ["ataque"], desc: "Cura {v}% do dano que você causa.",            cor: make_color_rgb(200,  80, 150), adesivo: "ad_vampiro", ad_frame: 20 },
        { id: "fantasma",  nome: "Caça-Fantasmas",       stat: "mata_fantasma",  base: 1,   teto: 1,   para: ["ataque"], desc: "Seus golpes acertam fantasmas.",               cor: make_color_rgb(190, 200, 255), adesivo: "ad_fantasma", ad_frame: 23, sorteavel: false },
        { id: "bum",       nome: "Bum!",                 stat: "crit_dano",      base: 15,  teto: -1,  para: ["ataque"], desc: "+{v}% de dano crítico.",                       cor: make_color_rgb(255, 150,  70), adesivo: "ad_bum", ad_frame: 24 },
        { id: "lanchinho", nome: "Lanchinho",            stat: "cura_abate",     base: 1,   teto: -1,  para: ["ataque"], desc: "Cura {v} de vida a cada monstro derrotado.",   cor: make_color_rgb(140, 230, 120), icone: "biscoito" },
        { id: "pressa",    nome: "Pressa",               stat: "recarga",        base: 8,   teto: 70,  para: ["ataque"], desc: "-{v}% de recarga da habilidade (X).",          cor: make_color_rgb(120, 220, 255), icone: "ad_raio" },
        { id: "braco",     nome: "Braço Comprido",       stat: "alcance",        base: 10,  teto: 120, para: ["arma"],   desc: "+{v}% de alcance do golpe.",                   cor: make_color_rgb(255, 180, 200), icone: "espada_madeira" },
        { id: "aljava",    nome: "Aljava Cheia",         stat: "flechas",        base: 1,   teto: 6,   para: ["arco"],   desc: "+{v} flecha(s) por tiro.",                     cor: make_color_rgb(200, 170, 110), icone: "arco_madeira", inteiro: true },
        // ---- defesa (cabeça, armadura, bota) ----
        { id: "escudo",    nome: "Escudinho",            stat: "defesa",         base: 2,   teto: -1,  para: ["defesa"], desc: "+{v} de defesa.",                              cor: make_color_rgb(110, 180, 255), adesivo: "ad_escudo", ad_frame: 18 },
        { id: "nuvem",     nome: "Nuvem Fofinha",        stat: "esquiva",        base: 4,   teto: 50,  para: ["defesa"], desc: "{v}% de chance de esquivar de um golpe.",      cor: make_color_rgb(170, 220, 255), adesivo: "ad_nuvem", ad_frame: 21 },
        { id: "urso",      nome: "Abraço de Urso",       stat: "vida",           base: 10,  teto: -1,  para: ["defesa"], desc: "+{v} de vida máxima.",                         cor: make_color_rgb(200, 150, 100), adesivo: "ad_urso", ad_frame: 22 },
        { id: "cacto",     nome: "Cacto Espinhento",     stat: "espinhos",       base: 3,   teto: -1,  para: ["defesa"], desc: "Monstros encostados em você levam {v} de dano por segundo.", cor: make_color_rgb(120, 200, 90), icone: "ad_escudo" },
        { id: "cabeca_fresca", nome: "Cabeça Fresca",    stat: "sanidade_regen", base: 0.4, teto: -1,  para: ["cabeca"], desc: "Recupera {v} de sanidade por segundo.",        cor: make_color_rgb(150, 230, 230), icone: "lampada" },
    ];

    global.passivas_db = {};
    global.passivas_ordem = [];
    for (var _i = 0; _i < array_length(global.passivas_itens); _i++) {
        var _p = global.passivas_itens[_i];
        if (!variable_struct_exists(_p, "adesivo"))   _p.adesivo   = "";
        if (!variable_struct_exists(_p, "icone"))     _p.icone     = _p.adesivo;
        if (!variable_struct_exists(_p, "inteiro"))   _p.inteiro   = false;
        if (!variable_struct_exists(_p, "sorteavel")) _p.sorteavel = true;
        global.passivas_db[$ _p.id] = _p;
        array_push(global.passivas_ordem, _p.id);
    }
}

/// Passiva que todo equipamento ganha quando o catálogo não deu uma inata
function item_passiva_padrao(_tipo) {
    switch (_tipo) {
        case "arma":     return "forca";
        case "arco":     return "estrela";
        case "armadura": return "escudo";
        case "cabeca":   return "cabeca_fresca";
        case "bota":     return "raio";
        case "luz":      return "coracao";
    }
    return "";
}

/// A passiva pode aparecer num item desse tipo?
function passiva_serve(_pid, _tipo) {
    var _p = global.passivas_db[$ _pid];
    if (is_undefined(_p)) return false;
    for (var _i = 0; _i < array_length(_p.para); _i++) {
        var _g = _p.para[_i];
        if (_g == "todos" || _g == _tipo) return true;
        if (_g == "ataque" && (_tipo == "arma" || _tipo == "arco")) return true;
        if (_g == "defesa" && (_tipo == "cabeca" || _tipo == "armadura" || _tipo == "bota")) return true;
    }
    return false;
}

/// Valor da passiva num item de nível _nivel (sem limite de nível; algumas têm teto "max")
function passiva_valor(_pid, _nivel) {
    var _d = global.passivas_db[$ _pid];
    if (is_undefined(_d)) return 0;
    if (_d.stat == "mata_fantasma") return 1;
    var _v = _d.base * (1 + ITEM_CRESC_PASSIVA * (max(1, floor(_nivel)) - 1));
    if (_d.inteiro) _v = floor(_v);
    if (_d.teto > 0) _v = min(_v, _d.teto);
    return _v;
}

/// Texto da passiva com o valor do nível
function passiva_texto(_pid, _nivel) {
    var _d = global.passivas_db[$ _pid];
    if (is_undefined(_d)) return "";
    return string_replace(_d.desc, "{v}", item_num_str(passiva_valor(_pid, _nivel)));
}

/// Sorteia de 0 a ITEM_PASSIVAS_MAX passivas que servem para o tipo (sem repetir nem a inata)
function passivas_sortear(_tipo, _inata = "") {
    var _r = [];
    if (!item_tipo_e_equipamento(_tipo)) return _r;
    var _ops = [];
    for (var _i = 0; _i < array_length(global.passivas_itens); _i++) {
        var _p = global.passivas_itens[_i];
        if (_p.sorteavel && _p.id != _inata && passiva_serve(_p.id, _tipo)) array_push(_ops, _p.id);
    }
    // 0: 30%  1: 35%  2: 22%  3: 13%
    var _roll = random(1);
    var _n = (_roll < 0.30) ? 0 : ((_roll < 0.65) ? 1 : ((_roll < 0.87) ? 2 : 3));
    _n = min(_n, ITEM_PASSIVAS_MAX, array_length(_ops));
    repeat (_n) {
        var _k = irandom(array_length(_ops) - 1);
        array_push(_r, _ops[_k]);
        array_delete(_ops, _k, 1);
    }
    return _r;
}

#endregion

#region ---------- NÍVEL POR ABATES ----------

/// XP que falta do nível _nv para o próximo
function item_xp_prox(_nv) {
    return max(1, round(ITEM_XP_BASE * power(max(1, floor(_nv)), ITEM_XP_EXPOENTE)));
}

/// XP guardado no slot (saves antigos não têm a coluna preenchida)
function item_xp_slot(_grid, _slot) {
    var _x = _grid[# INFOS.XP, _slot];
    return is_real(_x) ? max(0, _x) : 0;
}

/// Chamado quando um monstro morre (obj_par_inimigos Step e horda _horde_process_deaths)
function item_ao_matar(_x, _y) {
    if (!variable_global_exists("grid_itens") || !ds_exists(global.grid_itens, ds_type_grid)) exit;
    var _e = variable_global_exists("equip_stats") ? global.equip_stats : undefined;
    var _mult = 1;
    if (is_struct(_e)) {
        if (_e.cura_abate > 0 && global.vida > 0) global.vida = min(global.vida_max, global.vida + _e.cura_abate);
        if (_e.moeda_abate > 0 && random(100) < _e.moeda_abate) global.moedas += 1;
        _mult += _e.xp_item / 100;
    }
    item_xp_ganhar(ITEM_XP_POR_ABATE * _mult);
    missoes_evento("abate"); // objetivos de abate (scr_missoes)
}

/// Dá XP para os itens equipados (cabeça, armadura, bota e o item na mão)
function item_xp_ganhar(_qtd) {
    var _g = global.grid_itens;
    var _bag = inventory_bag_slots();
    var _slots = [_bag, _bag + 1, _bag + 2, hotbar_slot(hotbar_ativo())];
    var _subiu = false;
    for (var _i = 0; _i < array_length(_slots); _i++) {
        var _s = _slots[_i];
        if (_s < 0 || _s >= ds_grid_height(_g)) continue;
        var _id = _g[# INFOS.ITEM, _s];
        var _d = item_db(_id);
        if (is_undefined(_d) || !item_tipo_e_equipamento(_d.tipo)) continue;
        var _nv = max(1, floor(_g[# INFOS.NIVEL, _s]));
        var _xp = item_xp_slot(_g, _s) + _qtd;
        while (_xp >= item_xp_prox(_nv)) {
            _xp -= item_xp_prox(_nv);
            _nv += 1;
            _subiu = true;
            item_fx_texto(_d.nome + " Nv " + string(_nv) + "!", make_color_rgb(255, 220, 90));
            inventory_msg(_d.nome + " subiu para o Nv " + string(_nv) + "! Passivas mais fortes.", make_color_rgb(255, 220, 90));
        }
        _g[# INFOS.NIVEL, _s] = _nv;
        _g[# INFOS.XP, _s] = _xp;
        item_slot_atualizar_stats(_g, _s);
    }
    if (_subiu) player_stats_recalcular();
}

#endregion

#region ---------- EFEITOS QUE RODAM TODO FRAME ----------

/// Chamado por itens_passivas_tick (obj_inventario Step)
function itens_passivas_especiais_tick() {
    item_ativo_init();
    var _e = global.equip_stats;
    var _fps = game_get_speed(gamespeed_fps);

    // Cabeça Fresca: sanidade
    if (_e.sanidade_regen > 0 && variable_global_exists("sanidade") && variable_global_exists("max_sanidade")) {
        global.sanidade = min(global.max_sanidade, global.sanidade + _e.sanidade_regen / _fps);
    }

    // Cacto Espinhento: dano em quem encosta (2x por segundo)
    if (_e.espinhos > 0 && instance_exists(obj_player) && (current_time div 500) != global.espinhos_ultimo) {
        global.espinhos_ultimo = current_time div 500;
        var _p = obj_player;
        var _dano = _e.espinhos * 0.5;
        var _lista = ds_list_create();
        var _n = collision_circle_list(_p.x, _p.y, 26, obj_par_inimigos, false, true, _lista, false);
        for (var _i = 0; _i < _n; _i++) {
            var _in = _lista[| _i];
            scr_enemy_damage_apply(_in, _dano, 2, point_direction(_p.x, _p.y, _in.x, _in.y), false);
        }
        ds_list_destroy(_lista);
        horde_damage_circle(_p.x, _p.y, 26, _dano, 2);
    }

    // Recarga da habilidade (X)
    if (global.item_ativo_cd > 0) global.item_ativo_cd--;

    // Efeitos visuais
    for (var _i = array_length(global.itens_fx) - 1; _i >= 0; _i--) {
        var _f = global.itens_fx[_i];
        _f.t++;
        if (_f.t >= _f.dur) array_delete(global.itens_fx, _i, 1);
    }
}

#endregion

#region ---------- HABILIDADE DA ARMA (TECLA X) ----------

function item_ativo_init() {
    if (!variable_global_exists("item_ativo_cd"))     global.item_ativo_cd = 0;
    if (!variable_global_exists("item_ativo_cd_max")) global.item_ativo_cd_max = 1;
    if (!variable_global_exists("itens_fx"))          global.itens_fx = [];
    if (!variable_global_exists("espinhos_ultimo"))   global.espinhos_ultimo = 0;
}

/// Lê a tecla X (ação "habilidade"). Chamado no estado de andar do player.
function item_ativo_input() {
    item_ativo_init();
    var _k = tecla("habilidade");
    if (_k <= 0) _k = ord("X");
    if (keyboard_check_pressed(_k)) item_ativo_usar();
}

/// Usa a habilidade do item na mão. Rodar no escopo do player.
function item_ativo_usar() {
    item_ativo_init();
    var _d = hotbar_ativo_db();
    if (is_undefined(_d) || (_d.tipo != "arma" && _d.tipo != "arco")) {
        item_fx_texto("Segure uma espada ou arco!", c_ltgray);
        exit;
    }
    if (global.item_ativo_cd > 0) {
        item_fx_texto("Recarregando...", c_ltgray);
        exit;
    }
    var _nv = max(1, floor(global.grid_itens[# INFOS.NIVEL, hotbar_slot(hotbar_ativo())]));
    var _e = global.equip_stats;
    var _red = 1 - min(70, _e.recarga) / 100;
    var _base = variable_global_exists("ataque_sem_crit") ? global.ataque_sem_crit : global.ataque;

    if (_d.tipo == "arma") {
        // GIRO: acerta tudo em volta
        var _alc = (is_struct(_d.espada) ? _d.espada.alcance : 1) * (1 + _e.alcance / 100);
        var _raio = 46 * _alc * (1 + 0.04 * (_nv - 1));
        var _dano = _base * (1.5 + 0.12 * (_nv - 1));
        var _lista = ds_list_create();
        var _n = collision_circle_list(x, y, _raio, obj_par_inimigos, false, true, _lista, false);
        for (var _i = 0; _i < _n; _i++) {
            var _in = _lista[| _i];
            if (inimigo_colisao_ignorar(_in)) continue; // fantasma só com Caça-Fantasmas
            scr_enemy_damage_apply(_in, _dano, 30 + _dano, point_direction(x, y, _in.x, _in.y), false);
        }
        ds_list_destroy(_lista);
        horde_damage_circle(x, y, _raio, _dano, 6);
        if (_e.vampirismo > 0) global.vida = min(global.vida_max, global.vida + _dano * _e.vampirismo / 100);
        array_push(global.itens_fx, { tipo: "giro", t: 0, dur: 22, raio: _raio, spr: _d.spr, img: _d.img });
        global.item_ativo_cd_max = round(ITEM_ATIVO_ESPADA_CD * _red);
    } else {
        // CHUVA DE FLECHAS: leque na direção do mouse
        var _ad = is_struct(_d.arco) ? _d.arco : { vel: 12, flechas: 1, abertura: 0 };
        var _qtd = 5 + floor((_nv - 1) / 2) + _ad.flechas - 1 + floor(_e.flechas);
        var _leque = 70;
        var _dir = point_direction(x, y, mouse_x, mouse_y);
        var _dano = _base * (1 + 0.08 * (_nv - 1));
        for (var _f = 0; _f < _qtd; _f++) {
            var _ang = _dir - _leque / 2 + _leque * (_qtd > 1 ? _f / (_qtd - 1) : 0.5);
            var _fl = instance_create_layer(x, y, "Instances", obj_flecha);
            _fl.direction = _ang;
            _fl.image_angle = _ang;
            _fl.speed = _ad.vel;
            _fl.dano = _dano;
        }
        array_push(global.itens_fx, { tipo: "anel", t: 0, dur: 14, raio: 30 });
        global.item_ativo_cd_max = round(ITEM_ATIVO_ARCO_CD * _red);
    }
    global.item_ativo_cd = global.item_ativo_cd_max;
}

/// Texto subindo em cima do player
function item_fx_texto(_txt, _cor) {
    item_ativo_init();
    // não empilha o mesmo aviso
    for (var _i = 0; _i < array_length(global.itens_fx); _i++) {
        var _f = global.itens_fx[_i];
        if (_f.tipo == "texto" && _f.txt == _txt && _f.t < 20) return;
    }
    array_push(global.itens_fx, { tipo: "texto", t: 0, dur: 70, txt: _txt, cor: _cor });
}

/// Desenha os efeitos (obj_player Draw End, escopo do player)
function item_fx_desenhar() {
    item_ativo_init();
    var _ny = 0;
    for (var _i = 0; _i < array_length(global.itens_fx); _i++) {
        var _f = global.itens_fx[_i];
        var _p = _f.t / _f.dur;
        switch (_f.tipo) {
            case "giro":
                // a espada dá uma volta inteira em volta do player + rastro
                var _a = _p * 360;
                draw_set_alpha(0.35 * (1 - _p));
                draw_set_colour(make_color_rgb(255, 240, 200));
                draw_circle(x, y - 8, _f.raio, true);
                draw_circle(x, y - 8, _f.raio * 0.92, true);
                for (var _k = 0; _k < 6; _k++) {
                    var _ak = _a - _k * 12;
                    draw_set_alpha((1 - _p) * (1 - _k / 6) * 0.6);
                    draw_circle(x + lengthdir_x(_f.raio * 0.8, _ak), y - 8 + lengthdir_y(_f.raio * 0.8, _ak), 4, false);
                }
                draw_set_alpha(1);
                if (sprite_exists(_f.spr)) {
                    var _sc = 0.6;
                    draw_sprite_ext(_f.spr, _f.img, x + lengthdir_x(_f.raio * 0.6, _a), y - 8 + lengthdir_y(_f.raio * 0.6, _a), _sc, _sc, _a - 45, c_white, 1 - _p * 0.5);
                }
                break;
            case "anel":
                draw_set_alpha(0.6 * (1 - _p));
                draw_set_colour(make_color_rgb(220, 240, 255));
                draw_circle(x, y - 8, _f.raio * (0.5 + _p), true);
                break;
            case "texto":
                draw_set_font(fnt_status);
                draw_set_halign(fa_center);
                draw_set_valign(fa_bottom);
                draw_set_alpha(min(1, (1 - _p) * 3));
                var _ty = y - 78 - _p * 18 - _ny;
                draw_set_colour(c_black);
                draw_text_transformed(x + 1, _ty + 1, _f.txt, 0.5, 0.5, 0);
                draw_set_colour(_f.cor);
                draw_text_transformed(x, _ty, _f.txt, 0.5, 0.5, 0);
                _ny += 12;
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
                break;
        }
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

#endregion
