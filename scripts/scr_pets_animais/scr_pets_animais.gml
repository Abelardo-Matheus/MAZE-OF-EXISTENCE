// feather disable GM2017
// ==============================================================================
// scr_pets_animais — Pets novos (Cachorro, Gato, Coelho, Tartaruga) + regras de PET
// ==============================================================================
// Regras:
//   * Toda config de pet tem "pet: true". Só UM pet pode ser escolhido por partida:
//     depois de pegar um, os outros somem do sorteio (LEVEL_UP.gml -> level_upp).
//   * Subindo de nível o pet ganha CÓPIAS (Nv 1 = 1, Nv 3 = 2, Nv 5 = 3, Nv 7 = 4).
//   * Cada pet tem uma peculiaridade:
//       CACHORRO  -> mordida forte (dano alto) e empurra bastante
//       GATO      -> arranhões muito rápidos em área pequena, chance de crítico
//       COELHO    -> corre muito rápido, ataca pulando e deixa o JOGADOR mais rápido (pet_bonus)
//       TARTARUGA -> lenta, gira o casco em área e dá ESCUDO ao jogador (pet_bonus)
//   * pet_bonus(_m, _lvl) é somado em global.mods por mods_recalcular() (scr_modificadores).
// Todos usam o mesmo objeto: obj_pet_animal (variável "tipo" escolhe sprites e ataque).
// ==============================================================================

#macro PET_MAX_COPIAS 4

/// @desc Níveis padrão de pet: cópias no 1/3/5/7 e melhorias nos outros
/// @param _extra  array com 3 structs {desc, upgrade} para os níveis 2, 4 e 6
/// @param _nome   nome do bichinho (para as descrições)
function pet_niveis(_nome, _desc1, _extra) {
    return [
        { desc: _desc1, upgrade: function(_s) { _s.quantity = max(_s.quantity, 1); } },
        _extra[0],
        { desc: "MAIS UM " + _nome + " (+1 PET).", upgrade: function(_s) { _s.quantity = min(_s.quantity + 1, PET_MAX_COPIAS); } },
        _extra[1],
        { desc: "MAIS UM " + _nome + " (+1 PET).", upgrade: function(_s) { _s.quantity = min(_s.quantity + 1, PET_MAX_COPIAS); } },
        _extra[2],
        { desc: "MEGA UPGRADE: MAIS UM " + _nome + " E +25% DANO.", upgrade: function(_s) { _s.quantity = min(_s.quantity + 1, PET_MAX_COPIAS); _s.damage *= 1.25; } }
    ];
}

/// @desc Visual e comportamento base de cada tipo de pet
function pet_visual(_tipo) {
    switch (_tipo) {
        case "cachorro":  return { idle: spr_cachorro_idle,  walk: spr_cachorro_walk,  attack: spr_cachorro_attack,  px: 40 };
        case "gato":      return { idle: spr_gato_idle,      walk: spr_gato_walk,      attack: spr_gato_attack,      px: 38 };
        case "coelho":    return { idle: spr_coelho_idle,    walk: spr_coelho_walk,    attack: spr_coelho_attack,    px: 34 };
        case "tartaruga": return { idle: spr_tartaruga_idle, walk: spr_tartaruga_walk, attack: spr_tartaruga_attack, px: 38 };
    }
    return { idle: spr_cachorro_idle, walk: spr_cachorro_walk, attack: spr_cachorro_attack, px: 40 };
}

// Configs de cada pet (pasta PODERES/ATIVOS/PETS): scr_pet_cachorro, scr_pet_gato,
// scr_pet_coelho, scr_pet_tartaruga.

#region EXECUÇÃO

/// @desc Executor genérico dos pets novos (um por linha da grid)
function scr_pet_animal(_row) {
    if (global.level_up) exit;
    if (!instance_exists(obj_player)) exit;
    var _lvl = global.upgrades_vamp_grid[# UPGRADES_VAMP.LEVEL, _row];
    if (_lvl <= 0) exit;

    var _scr = mods_resolver_script(global.upgrades_vamp_grid[# UPGRADES_VAMP.CONFIG_SCRIPT, _row]);
    if (_scr == -1) exit;
    var _cfg = script_execute(_scr);
    var _st = scr_generic_calculate_stats(_cfg, _lvl, global.upgrades_vamp_grid, _row, UPGRADES_VAMP.DESCRIPTION);
    var _tipo = _cfg.tipo;

    // --- A. Conta as cópias deste tipo e cria as que faltam ---
    var _count = 0;
    with (obj_pet_animal) if (tipo == _tipo) _count++;
    repeat (max(0, _st.quantity - _count)) {
        var _p = instance_create_layer(obj_player.x + irandom_range(-30, 30), obj_player.y + irandom_range(-30, 30), "Instances", obj_pet_animal);
        _p.pet_configurar(_tipo);
    }

    // --- B. Atualiza os status de todas as cópias (formação em roda ao redor do player) ---
    var _idx = 0;
    var _total = max(1, _st.quantity);
    with (obj_pet_animal) {
        if (tipo != _tipo) continue;
        damage          = _st.damage;
        move_speed      = _st.move_speed;
        attack_cooldown = _st.attack_cooldown;
        range           = _st.range;
        attack_radius   = _st.attack_radius;
        knockback       = _st.knockback;
        crit_chance     = _st.crit_chance;
        angulo_roda     = (360 / _total) * _idx;
        _idx++;
    }
}

/// @desc true se o jogador já escolheu algum pet nesta partida (e qual linha)
function pet_linha_escolhida() {
    var _u = global.upgrades_vamp_grid;
    for (var _i = 0; _i < ds_grid_height(_u); _i++) {
        if (_u[# UPGRADES_VAMP.LEVEL, _i] <= 0) continue;
        if (upgrade_e_pet(_i)) return _i;
    }
    return -1;
}

/// @desc A linha _row da upgrades_vamp_grid é um pet?
function upgrade_e_pet(_row) {
    var _scr = mods_resolver_script(global.upgrades_vamp_grid[# UPGRADES_VAMP.CONFIG_SCRIPT, _row]);
    if (_scr == -1) return false;
    var _cfg = script_execute(_scr);
    return variable_struct_exists(_cfg, "pet") && _cfg.pet;
}

#endregion
