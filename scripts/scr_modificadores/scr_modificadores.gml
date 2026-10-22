// feather disable GM2017
// ==============================================================================
// scr_modificadores — Bônus globais das PASSIVAS e dos PETS aplicados a TODOS os poderes
// ==============================================================================
// [O QUE]: Guarda em global.mods os multiplicadores/bônus vindos das passivas (Anel, Tomo,
//          Leite, Mochila...) e do pet escolhido (Coelho, Tartaruga).
// [COMO] : mods_recalcular() refaz a conta DO ZERO a partir do nível de cada item na grid,
//          então nunca perde/duplica bônus (antes cada passiva somava "um nível por vez" e,
//          subindo 2 níveis seguidos no menu, o primeiro se perdia).
//          scr_generic_calculate_stats() chama mods_aplicar_stats() e com isso área, recarga,
//          dano, duração, velocidade e quantidade valem para todas as armas e pets.
// ==============================================================================

#macro MAX_SLOTS_ATIVOS   4
#macro MAX_SLOTS_PASSIVOS 4
#macro REROLLS_POR_PARTIDA 3
#macro SKILL_RAIO_ATIVAR 450   // distância (px) de um inimigo para as habilidades ativas dispararem
#macro MODS_COOLDOWN_MIN  0.10  // recarga mínima (10% do original) — evita disparar todo frame
#macro MODS_REDUCAO_MAX   0.90  // dano recebido nunca é 100% ignorado
#macro SKILL_TAMANHO_MAX_PX 192 // maior tamanho VISUAL (px no mundo) de uma saída de poder via skill_escala_px.
                                // Com o Anel sem limite, as adagas/aviões passavam de milhares de px e
                                // ficavam "invisíveis" (um pixel do sprite cobrindo a tela inteira).

/// @desc Valores neutros dos modificadores
function mods_padrao() {
    return {
        area: 1,            // multiplica size / radius / pollen_radius / orbit_radius das armas
        cooldown: 1,        // multiplica cooldown / attack_cooldown (menor = mais rápido)
        dano: 1,            // multiplica damage
        duracao: 1,         // multiplica duration
        veloc_proj: 1,      // multiplica speed dos projéteis
        quantidade: 0,      // soma em quantity / projectile_count / bomb_count (armas, não pets)
        veloc_player: 1,    // multiplica a velocidade de andar do jogador
        coleta: 0,          // soma no raio de coleta de XP
        xp: 1,              // multiplica o XP ganho
        crit: 0,            // soma na chance de crítico (%)
        reducao_dano: 0,    // fração do dano recebido que é ignorada (0.1 = -10%)
        regen: 0            // vida recuperada por segundo
    };
}

/// @desc Retorna os modificadores atuais (sem criar lixo se ainda não existirem)
function mods_get() {
    if (!variable_global_exists("mods") || !is_struct(global.mods)) global.mods = mods_padrao();
    return global.mods;
}

/// @desc Resolve um link de config da grid (script, função ou string) para algo executável
function mods_resolver_script(_raw) {
    if (is_undefined(_raw) || _raw == -1) return -1;
    var _scr = is_string(_raw) ? asset_get_index(_raw) : _raw;
    if (_scr == -1) return -1;
    return _scr;
}

/// @desc Recalcula TODOS os modificadores a partir dos níveis atuais (idempotente)
function mods_recalcular() {
    var _m = mods_padrao();

    // --- Passivas ---
    if (variable_global_exists("itens_vamp_grid")) {
        var _g = global.itens_vamp_grid;
        for (var _k = 0; _k < ds_grid_height(_g); _k++) {
            var _lvl = _g[# ITENS_VAMP.LEVEL, _k];
            if (_lvl <= 0) continue;
            var _scr = mods_resolver_script(_g[# ITENS_VAMP.CONFIG_SCRIPT, _k]);
            if (_scr == -1) continue;
            var _cfg = script_execute(_scr);
            if (variable_struct_exists(_cfg, "mods") && is_method(_cfg.mods)) {
                _cfg.mods(_m, _lvl); // sem limite: cada passiva calcula o próprio ciclo (passiva_valor)
            }
        }
    }

    // --- Bônus do pet escolhido (Coelho = velocidade, Tartaruga = escudo...) ---
    if (variable_global_exists("upgrades_vamp_grid")) {
        var _u = global.upgrades_vamp_grid;
        for (var _i = 0; _i < ds_grid_height(_u); _i++) {
            var _lvl_u = _u[# UPGRADES_VAMP.LEVEL, _i];
            if (_lvl_u <= 0) continue;
            var _scr_u = mods_resolver_script(_u[# UPGRADES_VAMP.CONFIG_SCRIPT, _i]);
            if (_scr_u == -1) continue;
            var _cfg_u = script_execute(_scr_u);
            if (variable_struct_exists(_cfg_u, "pet_bonus") && is_method(_cfg_u.pet_bonus)) {
                _cfg_u.pet_bonus(_m, _lvl_u);
            }
        }
    }

    // Travas de segurança
    _m.cooldown     = max(MODS_COOLDOWN_MIN, _m.cooldown);
    _m.reducao_dano = clamp(_m.reducao_dano, 0, MODS_REDUCAO_MAX);

    global.mods = _m;

    // Compatibilidade com o código antigo que ainda lê estas globais
    global.player_area_mod     = _m.area;
    global.player_cooldown_mod = _m.cooldown;
    if (!variable_global_exists("coleta_base")) global.coleta_base = variable_global_exists("coleta") ? global.coleta : 50;
    global.coleta = global.coleta_base + _m.coleta;
}

/// @desc Zera os modificadores para uma partida nova (chamado no inicializar_tudo)
function mods_resetar() {
    global.mods = mods_padrao();
    global.coleta_base = 50;
    global.coleta = 50;
    global.player_area_mod = 1;
    global.player_cooldown_mod = 1;
    global.mods_regen_acc = 0;
    global.cache_upgrade_pet = [];
}

/// @desc true se existe algum inimigo (instância ou horda) a até _raio pixels de (_x, _y)
function skill_tem_inimigo_perto(_x, _y, _raio = SKILL_RAIO_ATIVAR) {
    return array_length(inimigos_alvos(_x, _y, _raio, 1, "perto")) > 0;
}

/// @desc A linha _row da upgrades_vamp_grid é pet? (resultado guardado em cache)
function upgrade_e_pet_cache(_row) {
    var _h = ds_grid_height(global.upgrades_vamp_grid);
    if (!variable_global_exists("cache_upgrade_pet") || !is_array(global.cache_upgrade_pet)
     || array_length(global.cache_upgrade_pet) != _h) {
        global.cache_upgrade_pet = array_create(_h, false);
        for (var _i = 0; _i < _h; _i++) global.cache_upgrade_pet[_i] = upgrade_e_pet(_i);
    }
    return global.cache_upgrade_pet[_row];
}

/// @desc Roda todos os poderes ativos e pets do jogador (chamado no Step do obj_player e do
///       obj_player_tutorial). Ativos só disparam se houver inimigo perto (a recarga fica pausada);
///       pets rodam sempre (seguem o jogador mesmo sem inimigos).
function skills_executar_tick() {
    if (!variable_global_exists("upgrades_vamp_grid") || !ds_exists(global.upgrades_vamp_grid, ds_type_grid)) exit;
    var _g = global.upgrades_vamp_grid;
    var _inimigo_perto = skill_tem_inimigo_perto(x, y);
    for (var _i = 0; _i < ds_grid_height(_g); _i++) {
        if (_g[# UPGRADES_VAMP.LEVEL, _i] <= 0) continue;
        if (!_inimigo_perto && !upgrade_e_pet_cache(_i)) continue;
        var _script = _g[# UPGRADES_VAMP.SCRIPT, _i];
        if (_script == -1) continue;
        var _scr = is_string(_script) ? asset_get_index(_script) : _script;
        if (_scr != -1 && (script_exists(_scr) || is_method(_scr) || is_real(_scr))) script_execute(_scr, _i);
    }
}

/// @desc Aplica os modificadores num struct de stats de ARMA/PET (chamado pela calculadora genérica)
/// @param _stats  struct já com os upgrades de nível aplicados
/// @param _config struct da config (para saber se é pet)
function mods_aplicar_stats(_stats, _config) {
    var _m = mods_get();
    var _is_pet = variable_struct_exists(_config, "pet") && _config.pet;

    // Área (pets só ganham no raio do ataque, não na distância que andam do player)
    if (variable_struct_exists(_stats, "size"))          _stats.size          *= _m.area;
    if (variable_struct_exists(_stats, "radius"))        _stats.radius        *= _m.area;
    if (variable_struct_exists(_stats, "pollen_radius")) _stats.pollen_radius *= _m.area;
    if (!_is_pet && variable_struct_exists(_stats, "orbit_radius")) _stats.orbit_radius *= _m.area;
    if (variable_struct_exists(_stats, "attack_radius")) _stats.attack_radius *= _m.area;

    // Recarga
    if (variable_struct_exists(_stats, "cooldown"))        _stats.cooldown        *= _m.cooldown;
    if (variable_struct_exists(_stats, "attack_cooldown")) _stats.attack_cooldown *= _m.cooldown;

    // Dano, duração e velocidade do projétil
    if (variable_struct_exists(_stats, "damage"))   _stats.damage   *= _m.dano;
    if (variable_struct_exists(_stats, "duration")) _stats.duration *= _m.duracao;
    if (!_is_pet && variable_struct_exists(_stats, "speed")) _stats.speed *= _m.veloc_proj;

    // Quantidade extra (Mochila) — só se a arma já estiver ativa (> 0)
    if (!_is_pet && _m.quantidade > 0) {
        if (variable_struct_exists(_stats, "quantity")         && _stats.quantity > 0)         _stats.quantity         += _m.quantidade;
        if (variable_struct_exists(_stats, "projectile_count") && _stats.projectile_count > 0) _stats.projectile_count += _m.quantidade;
        if (variable_struct_exists(_stats, "bomb_count")       && _stats.bomb_count > 0)       _stats.bomb_count       += _m.quantidade;
    }
    return _stats;
}

/// @desc Roda todo frame (Step do obj_player): regeneração da Lancheira
function mods_tick() {
    if (global.level_up) exit;
    var _m = mods_get();
    if (_m.regen <= 0) exit;
    if (!variable_global_exists("mods_regen_acc")) global.mods_regen_acc = 0;
    if (global.vida <= 0 || global.vida >= global.vida_max) exit;
    global.mods_regen_acc += _m.regen / game_get_speed(gamespeed_fps);
    if (global.mods_regen_acc >= 1) {
        var _cura = floor(global.mods_regen_acc);
        global.mods_regen_acc -= _cura;
        global.vida = min(global.vida_max, global.vida + _cura);
    }
}

/// @desc Escala para um sprite aparecer com _px pixels (maior lado VISÍVEL da bbox) * _mult
/// Usado para padronizar o tamanho de todas as saídas dos poderes, independente do tamanho do PNG.
function skill_escala_px(_spr, _px, _mult = 1) {
    if (!sprite_exists(_spr)) return _mult;
    var _w = sprite_get_bbox_right(_spr) - sprite_get_bbox_left(_spr) + 1;
    var _h = sprite_get_bbox_bottom(_spr) - sprite_get_bbox_top(_spr) + 1;
    var _maior = max(1, _w, _h);
    if (_maior > max(sprite_get_width(_spr), sprite_get_height(_spr))) _maior = max(sprite_get_width(_spr), sprite_get_height(_spr));
    return min(_px * _mult, SKILL_TAMANHO_MAX_PX) / _maior;
}

/// @desc Dano em área para TODOS os inimigos (instâncias + horda)
function skill_dano_area(_x, _y, _r, _dmg, _kb = 2, _crit = false) {
    var _hits = horde_damage_circle(_x, _y, _r, _dmg, _kb, _x, _y, _crit);
    with (obj_par_inimigos) {
        if (inimigo_colisao_ignorar(id)) continue;
        var _bx = (bbox_left + bbox_right) * 0.5, _by = (bbox_top + bbox_bottom) * 0.5;
        if (point_distance(_x, _y, _bx, _by) <= _r + (bbox_right - bbox_left) * 0.5) {
            scr_enemy_damage_apply(id, _dmg, _kb, point_direction(_x, _y, _bx, _by), _crit);
            _hits++;
        }
    }
    return _hits;
}

/// @desc Dano num alvo de mira universal ({x, y, inst, uid}) — instância ou horda
function skill_dano_alvo(_alvo, _dmg, _kb, _from_x, _from_y, _crit = false) {
    if (inimigo_posicao(_alvo) == undefined) return false;
    if (_alvo.inst != noone) {
        if (inimigo_colisao_ignorar(_alvo.inst)) return false;
        scr_enemy_damage_apply(_alvo.inst, _dmg, _kb, point_direction(_from_x, _from_y, _alvo.x, _alvo.y), _crit);
        return true;
    }
    return horde_damage_circle(_alvo.x, _alvo.y, 12, _dmg, _kb, _from_x, _from_y, _crit) > 0;
}
