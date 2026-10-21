skills_owned = {}; // Estrutura: { "id": { level: 1, cooldown_timer: 0 } }

// Inicializa o banco de dados se ainda não foi
if (!variable_global_exists("skill_db")) {
    var _db_script = asset_get_index("scr_skill_database_init");
    if (_db_script != -1) {
        script_execute(_db_script);
    }
}

/// @desc Adiciona ou sobe nível de uma skill
function add_skill(_skill_id) {
    if (!variable_struct_exists(global.skill_db, _skill_id)) return;
    
    if (!variable_struct_exists(skills_owned, _skill_id)) {
        skills_owned[$ _skill_id] = {
            level: 1,
            cooldown_timer: 0
        };
    } else {
        var _skill = skills_owned[$ _skill_id];
        if (_skill.level < global.skill_db[$ _skill_id].max_level) {
            _skill.level += 1;
        }
    }
    
    recalculate_player_stats();
}

/// @desc Recalcula os status do player baseando-se nas passivas
function recalculate_player_stats() {
    // Valores base do nível atual
    var _lvl = global.level_player;
    var _new_stats = {
        ataque: global.dano_base[_lvl],
        speed_player: global.speed_player_base,
        vida_max: global.vida_max_calc[_lvl]
    };
    
    // Aplica todos os modificadores de skills passivas
    var _owned_ids = variable_struct_get_names(skills_owned);
    for (var _i = 0; _i < array_length(_owned_ids); _i++) {
        var _id = _owned_ids[_i];
        var _skill_def = global.skill_db[$ _id];
        var _owned_data = skills_owned[$ _id];
        
        if (_skill_def.type == SKILL_TYPE.PASSIVE) {
            var _level_stats = _skill_def.levels[_owned_data.level - 1];
            _skill_def.modifiers(_level_stats, _new_stats);
        }
    }
    
    // Atualiza variáveis globais que o jogo já utiliza
    global.ataque = _new_stats.ataque;
    global.speed_player = _new_stats.speed_player;
    global.vida_max = _new_stats.vida_max;

    // Soma equipamentos, adesivos e buffs do inventário (scripts/inventario)
    equip_aplicar_pos_skill();
}
