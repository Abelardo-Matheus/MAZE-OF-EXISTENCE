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
    
    for (var i = 0; i < _total_weapons; i++) 
    {
        var _config_scr = _grid_weapons[# Upgrades_vamp.ConfigScript, i];
        
        if (_config_scr != -1 && script_exists(_config_scr)) 
        {
            var _curr_lvl_weapon = _grid_weapons[# Upgrades_vamp.level, i];
            var _skill_data = _config_scr(); 
            var _max_lvl = array_length(_skill_data.niveis);
            
            var _next_level = _curr_lvl_weapon + 1;
            
            // Textos e Ícones normais do ciclo infinito
            var _safe_index = _curr_lvl_weapon % _max_lvl;
            var _next_lvl_info = _skill_data.niveis[_safe_index]; 
            
            var _desc_final = _next_lvl_info.desc;
            var _sprite_final = variable_struct_exists(_skill_data.stats_base, "sprite_icon") ? _skill_data.stats_base.sprite_icon : -1;
            
            // ========================================================
            // --- MÁGICA DA EVOLUÇÃO ---
            // ========================================================
            if (variable_struct_exists(_skill_data, "evolucao")) 
            {
                // Se o PRÓXIMO nível for o nível de evolução (ex: está no 14, vai pro 15)
                // Substitui a descrição pelo texto único da evolução
                if (_next_level == _skill_data.evolucao.nivel) {
                    _desc_final = _skill_data.evolucao.desc;
                }
                
                // Se o nível atual for 14 ou maior, a carta passa a usar o Ícone Novo para sempre
                if (_curr_lvl_weapon >= _skill_data.evolucao.nivel - 1) {
                    _sprite_final = _skill_data.evolucao.sprite_icon;
                }
            }
            
            // Adiciona marcador de ciclo para níveis muito altos (Opcional)
            var _ciclos = floor(_curr_lvl_weapon / _max_lvl);
            if (_ciclos > 0 && _next_level != 15) { // Evita botar [Ciclo] justo no nível da evolução
                _desc_final += "\n[Ciclo " + string(_ciclos + 1) + "]";
            }
            
            var _card_info = {
                nome: _grid_weapons[# Upgrades_vamp.Name, i],
                sprite: _sprite_final,
                description: _desc_final, 
                next_level: _next_level,
                type: 0, 
                id_grid: i 
            };
            
            ds_list_add(_pool, _card_info);
        }
    }

    // ========================================================
    // --- Sub-Part B: Coleta ITENS PASSIVOS candidatos ---
    // ========================================================
    var _grid_items = global.itens_vamp_grid;
    var _total_items = ds_grid_height(_grid_items);
    
    for (var k = 0; k < _total_items; k++) 
    {
        var _config_scr_item = _grid_items[# Itens_vamp.ConfigScript, k];
        
        if (_config_scr_item != -1 && script_exists(_config_scr_item)) 
        {
            var _curr_lvl_item = _grid_items[# Itens_vamp.level, k];
            var _item_data = _config_scr_item();
            var _max_lvl_item = array_length(_item_data.niveis);
            
            var _next_level_item = _curr_lvl_item + 1;
            
            // MÁGICA DO INFINITO (Mesma lógica)
            var _safe_index_item = _curr_lvl_item % _max_lvl_item;
            var _next_lvl_info_item = _item_data.niveis[_safe_index_item];
            
            var _desc_final_item = _next_lvl_info_item.desc;
            var _ciclos_item = floor(_curr_lvl_item / _max_lvl_item);
            if (_ciclos_item > 0) _desc_final_item += "\n[Ciclo " + string(_ciclos_item + 1) + "]";
            
            var _item_card_info = {
                nome: _grid_items[# Itens_vamp.Name, k],
                sprite: variable_struct_exists(_item_data.stats_base, "sprite_icon") ? _item_data.stats_base.sprite_icon : -1,
                description: _desc_final_item, 
                next_level: _next_level_item,
                type: 1, 
                id_grid: k 
            };
            
            ds_list_add(_pool, _item_card_info);
        }
    }

    // ========================================================
    // --- Sub-Part C: Embaralha e Seleciona ---
    // ========================================================
    ds_list_shuffle(_pool);
    
    var _pool_size = ds_list_size(_pool);
    var _picks = min(global.upgrade_num, _pool_size); 
    
    for (var j = 0; j < _picks; j++) 
    {
        ds_list_add(global.upgrades_vamp_list, _pool[| j]);
    }

    ds_list_destroy(_pool);
}


// ============================================================================
// 2. FUNÇÃO AUXILIAR DE MATEMÁTICA (Separada para organização)
// ============================================================================
function aplicar_status_level() {
    var _prev_lvl = global.level_player - 1;
    var _curr_lvl = global.level_player;

    global.vida_max_calc[_curr_lvl]     = global.vida_max_calc[_prev_lvl] + (_curr_lvl * 0.8);
    global.max_estamina_calc[_curr_lvl] = global.max_estamina_calc[_prev_lvl] + 5;
    global.dano_base[_curr_lvl]         = global.dano_base[_prev_lvl] * 1.1;

    global.vida_max = global.vida_max_calc[_curr_lvl];
    global.max_estamina = global.max_estamina_calc[_curr_lvl];
    global.ataque = global.dano_base[_curr_lvl];
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
    // Chance baseada no nível (ex: Nível 10 = 10% de chance)
    var _chance = global.level_player * 1;
    var _roll = irandom_range(1, 100);
    
    if (_roll <= _chance) 
    {
        global.critico = 1; // Flag visual
        global.ataque = global.dano_base[global.level_player] * 1.5; // Dano Crítico (150%)
    } 
    else 
    {
        global.critico = 0;
        global.ataque = global.dano_base[global.level_player]; // Dano Normal
    }
}