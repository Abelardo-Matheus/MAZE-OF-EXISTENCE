// feather disable GM2017
// ==============================================================================
// scr_ativos_infancia — Poderes ATIVOS novos com tema de criança
// ==============================================================================
// Mesmo padrão das outras armas: scr_XXX_config() (dados por nível) + scr_XXX(_row) (executor
// chamado todo frame pelo Step do obj_player para cada linha da upgrades_vamp_grid).
// Os stats passam por scr_generic_calculate_stats -> mods_aplicar_stats, então Anel, Tomo,
// Leite, Mochila, Chiclete e Tênis já valem para eles.
// Todos usam o obj_skill_projectile (Step_0_Custom / perfura / ao_acertar).
// Cada poder fica no seu script (pasta PODERES/ATIVOS): scr_bolhas, scr_aviao, scr_estilingue, scr_piao.
// Aqui ficam só os auxiliares usados por eles.
// ==============================================================================

#region AUXILIARES

/// @desc Stats finais de um ativo, ou undefined se não deve rodar agora (pausa / nível 0)
function skill_stats_ativo(_row, _config) {
    if (global.level_up || !instance_exists(obj_player)) return undefined;
    var _lvl = global.upgrades_vamp_grid[# UPGRADES_VAMP.LEVEL, _row];
    if (_lvl <= 0) return undefined;
    return scr_generic_calculate_stats(_config, _lvl, global.upgrades_vamp_grid, _row, UPGRADES_VAMP.DESCRIPTION);
}

/// @desc Timer em ms por arma/linha. Retorna true (e zera) quando a recarga terminou.
function skill_timer_pronto(_nome, _row, _cooldown) {
    var _v = "timer_" + _nome + "_" + string(_row);
    if (!variable_global_exists(_v)) variable_global_set(_v, 0);
    var _t = variable_global_get(_v) + delta_time / 1000;
    if (_t >= _cooldown) {
        variable_global_set(_v, 0);
        return true;
    }
    variable_global_set(_v, _t);
    return false;
}

/// @desc Cria um obj_skill_projectile já configurado (tamanho padronizado em pixels)
function skill_criar_projetil(_x, _y, _spr, _px, _size, _dmg, _spd, _dir, _kb = 1) {
    var _p = instance_create_layer(_x, _y, "Instances", obj_skill_projectile);
    _p.sprite_index = _spr;
    _p.image_speed = 1;
    var _e = skill_escala_px(_spr, _px, _size);
    _p.image_xscale = _e;
    _p.image_yscale = _e;
    _p.damage = _dmg;
    _p.veloc = _spd;
    _p.speed = _spd;
    _p.direction = _dir;
    _p.image_angle = _dir;
    _p.push_force = _kb;
    return _p;
}

/// @desc Efeito visual simples de "estouro" (some sozinho com o obj_par_efeito_rastro)
function skill_efeito_estouro(_x, _y, _spr, _raio) {
    if (!sprite_exists(_spr)) exit;
    var _fx = instance_create_layer(_x, _y, "Instances", obj_par_efeito_rastro);
    _fx.sprite_index = _spr;
    _fx.image_speed = 0;
    var _e = skill_escala_px(_spr, _raio * 2);
    _fx.image_xscale = _e;
    _fx.image_yscale = _e;
    _fx.image_alpha = 0.6;
}

#endregion
