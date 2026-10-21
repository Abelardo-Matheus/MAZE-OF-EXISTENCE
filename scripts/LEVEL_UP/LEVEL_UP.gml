// feather disable GM2017
/// @desc Inicialização de Status e XP
/// [O QUE]: Define os atributos base do player e prepara as listas de upgrade.

// --- Status Básicos ---
global.level_player = 1;
global.xp = 0;
global.max_xp = 100; // XP inicial para o primeiro nível
global.level_up = false;

// --- Tabelas de Crescimento (Stats por Nível) ---
// Inicializa arrays para evitar erro de "index out of bounds"
global.vida_max_calc[1] = 100;
global.max_estamina_calc[1] = 50;
global.dano_base[1] = 6;

// Define valores atuais baseados no nível 1
global.vida_max = global.vida_max_calc[1];
global.vida = global.vida_max;

global.max_estamina = global.max_estamina_calc[1];
global.estamina = global.max_estamina;

global.ataque = global.dano_base[1];
global.critico = 0;

// --- Sistema de Upgrade ---
global.upgrades_vamp_list = ds_list_create(); // Lista que guardará as opções sorteadas
global.upgrade_num = 4; // Quantidade de opções que aparecem na tela (3 ou 4)

// ============================================================================
// 1. FUNÇÃO DE ABRIR O MENU DE CARTAS (Modificada)
// ============================================================================
function level_upp() 
{
    global.level_up = true; // Ativa flag para pausar a lógica do jogo e abrir o menu
	audio_play_sound(snd_up, 1 , false);
    // ============================================================
    // SORTEIO DE CARTAS (Dealer System - Data-Driven INFINITO)
    // ============================================================
    ds_list_clear(global.upgrades_vamp_list);
    var _pool = ds_list_create();

    // ========================================================
    // --- Sub-Part A: Coleta ARMAS (Upgrades Ativos) candidatos ---
    // ========================================================
    var _grid_weapons = global.upgrades_vamp_grid;
    var _total_weapons = ds_grid_height(_grid_weapons);
    
    for (var _i = 0; _i < _total_weapons; _i++) 
    {
        var _config_raw = _grid_weapons[# UPGRADES_VAMP.CONFIG_SCRIPT, _i];
        if (_config_raw == -1) continue;

        var _scr_index = is_string(_config_raw) ? asset_get_index(_config_raw) : _config_raw;

        if (_scr_index != -1 && (script_exists(_scr_index) || is_method(_scr_index) || is_real(_scr_index))) 
        {
            var _curr_lvl_weapon = _grid_weapons[# UPGRADES_VAMP.LEVEL, _i];
            var _skill_data = script_execute(_scr_index); 
            var _max_lvl = array_length(_skill_data.niveis);
            
            var _next_level = _curr_lvl_weapon + 1;
            var _safe_index = _curr_lvl_weapon % _max_lvl;
            var _next_lvl_info = _skill_data.niveis[_safe_index]; 
            
            var _desc_final = _next_lvl_info.desc;
            var _sprite_final = variable_struct_exists(_skill_data.stats_base, "sprite_icon") ? _skill_data.stats_base.sprite_icon : -1;
            
            if (variable_struct_exists(_skill_data, "evolucao")) 
            {
                if (_next_level == _skill_data.evolucao.nivel) {
                    _desc_final = _skill_data.evolucao.desc;
                }
                if (_curr_lvl_weapon >= _skill_data.evolucao.nivel - 1) {
                    _sprite_final = _skill_data.evolucao.sprite_icon;
                }
            }
            
            var _ciclos = floor(_curr_lvl_weapon / _max_lvl);
            if (_ciclos > 0 && _next_level != 15) { 
                _desc_final += "\n[Ciclo " + string(_ciclos + 1) + "]";
            }
            
            var _card_info = {
                nome: _grid_weapons[# UPGRADES_VAMP.NAME, _i],
                sprite: _sprite_final,
                description: _desc_final, 
                next_level: _next_level,
                type: 0, 
                id_grid: _i 
            };
            
            ds_list_add(_pool, _card_info);
        }
    }

    // ========================================================
    // --- Sub-Part B: Coleta ITENS PASSIVOS candidatos ---
    // ========================================================
    var _grid_items = global.itens_vamp_grid;
    var _total_items = ds_grid_height(_grid_items);
    
    for (var _k = 0; _k < _total_items; _k++) 
    {
        var _config_raw_item = _grid_items[# ITENS_VAMP.CONFIG_SCRIPT, _k];
        if (_config_raw_item == -1) continue;

        var _scr_item_index = is_string(_config_raw_item) ? asset_get_index(_config_raw_item) : _config_raw_item;

        if (_scr_item_index != -1 && (script_exists(_scr_item_index) || is_method(_scr_item_index) || is_real(_scr_item_index))) 
        {
            var _curr_lvl_item = _grid_items[# ITENS_VAMP.LEVEL, _k];
            var _item_data = script_execute(_scr_item_index);
            var _max_lvl_item = array_length(_item_data.niveis);
            
            var _next_level_item = _curr_lvl_item + 1;
            var _safe_index_item = _curr_lvl_item % _max_lvl_item;
            var _next_lvl_info_item = _item_data.niveis[_safe_index_item];
            
            var _desc_final_item = _next_lvl_info_item.desc;
            var _ciclos_item = floor(_curr_lvl_item / _max_lvl_item);
            if (_ciclos_item > 0) _desc_final_item += "\n[Ciclo " + string(_ciclos_item + 1) + "]";
            
            var _item_card_info = {
                nome: _grid_items[# ITENS_VAMP.NAME, _k],
                sprite: variable_struct_exists(_item_data.stats_base, "sprite_icon") ? _item_data.stats_base.sprite_icon : -1,
                description: _desc_final_item, 
                next_level: _next_level_item,
                type: 1, 
                id_grid: _k 
            };
            
            ds_list_add(_pool, _item_card_info);
        }
    }

    // ========================================================
    // --- Sub-Part D: NOVO SISTEMA DE SKILLS (Struct-Based) ---
    // ========================================================
    if (variable_global_exists("skill_db")) {
        var _skill_ids = variable_struct_get_names(global.skill_db);
        for (var _m = 0; _m < array_length(_skill_ids); _m++) {
            var _sid = _skill_ids[_m];
            var _sdef = global.skill_db[$ _sid];
            
            var _clvl = 0;
            if (instance_exists(obj_skill_manager)) {
                if (variable_struct_exists(obj_skill_manager.skills_owned, _sid)) {
                    _clvl = obj_skill_manager.skills_owned[$ _sid].level;
                }
            }
            
            if (_clvl < _sdef.max_level) {
                var _nlvl = _clvl + 1;
                var _sinfo = _sdef.levels[_nlvl - 1];
                
                var _skill_card = {
                    nome: _sdef.name,
                    sprite: _sdef.icon,
                    description: _sdef.description + "\nLv." + string(_nlvl),
                    next_level: _nlvl,
                    type: 2, // NOVO SISTEMA
                    skill_id: _sid 
                };
                ds_list_add(_pool, _skill_card);
            }
        }
    }

    // ========================================================
    // --- Sub-Part C: Embaralha e Seleciona ---
    // ========================================================
    ds_list_shuffle(_pool);
    
    var _pool_size = ds_list_size(_pool);
    var _picks = min(global.upgrade_num, _pool_size); 
    
    for (var _j = 0; _j < _picks; _j++) 
    {
        ds_list_add(global.upgrades_vamp_list, _pool[| _j]);
    }

    ds_list_destroy(_pool);
}


// ============================================================================
// 2. FUNÇÃO AUXILIAR DE MATEMÁTICA (Separada para organização)
// ============================================================================
function aplicar_status_level() {
    var _prev_lvl = global.level_player - 1;
    var _curr_lvl = global.level_player;

    // Garante que os arrays de cálculo cresçam
    if (_curr_lvl >= array_length(global.vida_max_calc)) {
        global.vida_max_calc[_curr_lvl]     = global.vida_max_calc[_prev_lvl] + (_curr_lvl * 0.8);
        global.max_estamina_calc[_curr_lvl] = global.max_estamina_calc[_prev_lvl] + 5;
        global.dano_base[_curr_lvl]         = global.dano_base[_prev_lvl] * 1.1;
    }

    global.max_estamina = global.max_estamina_calc[_curr_lvl];
    
    // Deixa o Skill Manager recalcular ataque, velocidade e vida máxima considerando passivas
    if (instance_exists(obj_skill_manager)) {
        obj_skill_manager.recalculate_player_stats();
    } else {
        global.vida_max = global.vida_max_calc[_curr_lvl] + (variable_global_exists("equip_aplicado") ? global.equip_aplicado.vida : 0);
    }
    // Ataque = base do nível + equipamentos/adesivos (scripts/inventario)
    player_stats_recalcular();
}


// ============================================================================
// 3. FUNÇÃO DE GANHAR XP (Com sistema de Fila de Level Up)
// ============================================================================
function ganhar_xp(_xp_amount) 
{
    global.xp += _xp_amount;
    
    // Calcula o max_xp baseado no level atual
    global.max_xp = global.level_player * 100;
    
    // 1. Verifica quantos níveis foram subidos e acumula na fila
    while (global.xp >= global.max_xp) 
    {
        global.xp -= global.max_xp;
        global.level_player += 1;
        
        // Recalcula o max_xp pro PRÓXIMO nível dentro do loop
        global.max_xp = global.level_player * 100; 
        
        // Acumula na fila de upgrades pendentes
        global.levels_pendentes += 1;
        
        // Aplica os bônus matemáticos imediatamente (Vida, Estamina, Dano)
        aplicar_status_level(); 
    }
    
    // 2. Se subiu de nível e o jogo ainda não está pausado pelo Level Up, abre o menu
    if (global.levels_pendentes > 0 && global.level_up == false) 
    {
        level_upp();
    }
}

function calcular_critico() 
{
    // Ataque sem crítico já inclui equipamentos e adesivos (player_stats_recalcular)
    var _base = variable_global_exists("ataque_sem_crit") ? global.ataque_sem_crit : global.dano_base[global.level_player];
    var _e = variable_global_exists("equip_stats") ? global.equip_stats : undefined;

    // Chance baseada no nível (Nível 10 = 10%) + passivas/buffs de crítico
    var _chance = global.level_player * 1 + (is_undefined(_e) ? 0 : _e.crit);
    var _mult   = 1.5 + (is_undefined(_e) ? 0 : _e.crit_dano / 100);

    if (irandom_range(1, 100) <= _chance) 
    {
        global.critico = 1; // Flag visual
        global.ataque = _base * _mult; // Dano Crítico
    } 
    else 
    {
        global.critico = 0;
        global.ataque = _base; // Dano Normal
    }

    // Vampirismo (Dentinho de Vampiro): cura uma parte do golpe
    if (!is_undefined(_e) && _e.vampirismo > 0) {
        global.vida = min(global.vida_max, global.vida + global.ataque * _e.vampirismo / 100);
    }
}