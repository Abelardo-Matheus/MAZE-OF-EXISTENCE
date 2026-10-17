// feather disable GM2017
// ==============================================================================
// REGIÃO 1: ENUMS E DEFINIÇÕES GLOBAIS (INFRAESTRUTURA)
// ==============================================================================
#region DEFINIÇÕES

/// @desc Definição das colunas das tabelas de itens passivos
enum ITENS_VAMP {
    NAME,
    CONFIG_SCRIPT,   // NOVO: Link para o script de config (scr_XXX_config)
    SCRIPT,         // NOVO: Link para o script executor (scr_XXX)
    FREQUENCY,
    DESCRIPTION,
    LEVEL,
    LENGTH
}

/// @desc Definição das colunas das tabelas de upgrades ativos
enum UPGRADES_VAMP {
    NAME,
    CONFIG_SCRIPT,   // NOVO: Link para o script de config (scr_XXX_config)
    SCRIPT,         // Link para o script executor (scr_XXX)
    FREQUENCY,
    DESCRIPTION,
    LEVEL,
    LENGTH
}

// --- MACRO: Struct de Status Padrão Universal ---
// Isso garante que toda skill tenha todas as variáveis, evitando erros de leitura.
#macro DEFAULT_SKILL_STATS {\
    damage: 0,\
    cooldown: 999999,\
    size: 1,\
    speed: 0,\
    projectile_count: 0,\
    knockback: 0,\
    radius: 0,\
    duration: 0,\
    pierce_count: 0,\
    range: 0,\
    quantity: 0,\
    pollen_chance: 0,\
    wander_radius: 0,\
    move_speed: 0,\
    attack_cooldown: 0,\
    orbit_radius: 0,\
    push_force: 0,\
    splash_multiplier: 0\
}

#endregion

// ==============================================================================
// REGIÃO 2: CALCULADORAS GENÉRICAS (O CORAÇÃO DO SISTEMA)
// ==============================================================================
#region CALCULADORAS

/// @desc Calcula os stats finais de uma skill ATIVA e atualiza a descrição na grid automaticamente.
/// @param _skill_config O Struct retornado pela função scr_XXX_config()
/// @param _current_level O nível atual da skill (pego da grid)
/// @param _grid A grid onde os dados estão salvos
/// @param _row_index O índice da linha desta skill na grid (recebido do controle)
/// @param _col_desc A coluna da descrição na grid
/// @desc Calcula os stats finais e atualiza a descrição (AGORA INFINITO)
function scr_generic_calculate_stats(_skill_config, _current_level, _grid, _row_index, _col_desc)
{
    // 1. Cria a cópia base limpa
    var _stats = DEFAULT_SKILL_STATS;
    
    var _base_defined = _skill_config.stats_base;
    var _names = variable_struct_get_names(_base_defined);
    for (var _i = 0; _i < array_length(_names); _i++) {
        var _name = _names[_i];
        variable_struct_set(_stats, _name, variable_struct_get(_base_defined, _name));
    }
    
    if (_current_level == 0) return _stats;

    // 2. Itera aplicando os upgrades nível a nível (LOOP INFINITO)
    var _levels_array = _skill_config.niveis;
    var _max_defined_levels = array_length(_levels_array);
    
    // ATENÇÃO: Removemos a trava de limite máximo. Ele vai contar até o nível atual, seja ele 15, 50 ou 1000.
    for (var _i = 0; _i < _current_level; _i++)
    {
        // O módulo '%' garante que se tivermos 6 níveis, o índice 6 vira 0, o 7 vira 1, etc.
        var _nivel_info = _levels_array[_i % _max_defined_levels];
        
        if (variable_struct_exists(_nivel_info, "upgrade") && is_method(_nivel_info.upgrade)) {
             _nivel_info.upgrade(_stats);
        }
    }
    
    // 3. Atualiza a descrição na Grid para o PRÓXIMO nível
    var _next_level = _current_level + 1;
    var _desc_grid = "";

    // Verifica se tem evolução e se o próximo é ela
    if (variable_struct_exists(_skill_config, "evolucao") && _next_level == _skill_config.evolucao.nivel) 
    {
        _desc_grid = _skill_config.evolucao.desc;
    } 
    else 
    {
        var _next_index = _current_level % _max_defined_levels;
        _desc_grid = _levels_array[_next_index].desc;
        
        var _ciclos_completos = floor(_current_level / _max_defined_levels);
        if (_ciclos_completos > 0) {
            _desc_grid += "\n[Ciclo " + string(_ciclos_completos + 1) + "]";
        }
    }
    
    _grid[# _col_desc, _row_index] = _desc_grid;

    return _stats;
}

/// @desc Calcula o upgrade do nível ATUAL e atualiza a grid de descrição de itens PASSIVOS.
/// @desc (Específico para itens passivos que aplicam bônus 'one-time' ao subir de nível)
/// @param _item_config O Struct retornado pela função scr_XXX_config()
/// @param _current_level O nível atual da skill (pego da grid)
/// @param _grid A grid onde os dados estão salvos
/// @param _row_index O índice da linha desta skill na grid (recebido do controle)
/// @param _col_desc A coluna da descrição na grid
function scr_generic_calculate_passive_upgrade(_item_config, _current_level, _grid, _row_index, _col_desc)
{
    // Retorna cópia base simples para passivos
    var _stats = variable_clone(_item_config.stats_base);
    
    if (_col_desc == 0) return _stats;

    var _levels_array = _item_config.niveis;
    var _max_defined_levels = array_length(_levels_array);
    
    // Pega o upgrade apenas do nível ATUAL que acabou de subir
    // Se _current_level = 1 (acabou de pegar Lvl 1), o upgrade está no índice 0 da array.
    var _array_index = _current_level - 1;
    
    if (_array_index >= 0 && _array_index < _max_defined_levels) {
        var _nivel_info = _levels_array[_array_index];
        // Aplica apenas o bônus deste nível no struct temporário
        _nivel_info.upgrade(_stats);
    }
    
    // Atualiza a descrição na Grid para o PRÓXIMO nível (se houver)
    var _desc_grid = "MÁXIMO ATINGIDO";
    if (_current_level < _max_defined_levels)
    {
        // Se nível atual é 1, próximo upgrade é o índice 1 da array (nível 2)
        _desc_grid = _levels_array[_current_level].desc; 
    }
    
    _grid[# _col_desc, _row_index] = _desc_grid;

    return _stats;
}

#endregion

// ==============================================================================
// REGIÃO 3: AUXILIARES DE CRIAÇÃO E BUSCA (MANTIDOS/REFATORADOS)
// ==============================================================================
#region AUXILIARES

/// @desc Cria estrutura de poder básico (MANTIDO)
function criar_poder(_nome, _nivel, _dano, _coletado, ID, _objeto) 
{
    return {
        poder_nome: _nome,
        poder_nivel: _nivel,
        _dano: _dano,
        _coletado: _coletado,
        ID: ID,
        _objeto: _objeto
    };
}

/// @desc Busca poder pelo ID na lista (MANTIDO)
function procurar_poder(_id_procurado)
{
    var _tamanho = ds_list_size(global.lista_poderes_basicos);
    var _objeto_encontrado = noone; // Variável local segura

    for (var _i = 0; _i < _tamanho; _i++) 
    {
        var _poder = global.lista_poderes_basicos[| _i];
        
        if (_poder.id == _id_procurado) 
        {
            _objeto_encontrado = _poder;
            break;
        }
    }
    return _objeto_encontrado;
}

/// @desc Adiciona Item Passivo na Grid (Redimensiona automátiocamente)
/// @param {String} _name O nome do item
/// @param {Asset.GMScript|Function|Real} _config_script O Link para o script scr_XXX_config
/// @param {Asset.GMScript|Function|Real} _script O Link para o script executor
/// @param {Real} _frequency Frequência de sorteio
/// @param {Real} _level Nível inicial
function ds_grid_add_item_vamp(_name, _config_script, _script, _frequency, _level)
{
    var _grid = global.itens_vamp_grid;
    var _old_height = ds_grid_height(_grid);

    // Aumenta a grid em 1 linha
    ds_grid_resize(_grid, ITENS_VAMP.LENGTH, _old_height + 1);
    var _y = _old_height;

    _grid[# ITENS_VAMP.NAME,         _y] = _name;
    _grid[# ITENS_VAMP.CONFIG_SCRIPT, _y] = _config_script; // Link de Dados
    _grid[# ITENS_VAMP.SCRIPT,       _y] = _script;        // Link de Execução
    _grid[# ITENS_VAMP.FREQUENCY,    _y] = _frequency;
    // Descrição começa vazia e é preenchida dinamicamente no final da inicialização
    _grid[# ITENS_VAMP.DESCRIPTION,  _y] = ""; 
    _grid[# ITENS_VAMP.LEVEL,        _y] = _level;

    return _y; // Retorna o índice da linha criada
}

/// @desc Adiciona Upgrade Ativo na Grid (Redimensiona automátiocamente)
/// @param {String} _name O nome do upgrade
/// @param {Asset.GMScript|Function|Real} _config_script O Link para o script scr_XXX_config
/// @param {Asset.GMScript|Function|Real} _script O Link para o script executor
/// @param {Real} _frequency Frequência de sorteio
/// @param {Real} _level Nível inicial
function ds_grid_add_upgrade_vamp(_name, _config_script, _script, _frequency, _level)
{
    var _grid = global.upgrades_vamp_grid;
    var _old_height = ds_grid_height(_grid);

    // Aumenta a grid em 1 linha
    ds_grid_resize(_grid, UPGRADES_VAMP.LENGTH, _old_height + 1);
    var _y = _old_height;

    _grid[# UPGRADES_VAMP.NAME,         _y] = _name;
    _grid[# UPGRADES_VAMP.CONFIG_SCRIPT, _y] = _config_script; // Link de Dados
    _grid[# UPGRADES_VAMP.SCRIPT,       _y] = _script;        // Link de Execução
    _grid[# UPGRADES_VAMP.FREQUENCY,    _y] = _frequency;
    // Descrição começa vazia e é preenchida dinamicamente no final da inicialização
    _grid[# UPGRADES_VAMP.DESCRIPTION,  _y] = "";
    _grid[# UPGRADES_VAMP.LEVEL,        _y] = _level;

    return _y; // Retorna o índice da linha criada
}

#endregion

// ==============================================================================
// REGIÃO 4: INICIALIZAÇÃO TUDO (O NOVO FLUXO)
// ==============================================================================
#region INICIALIZAÇÃO

/// @desc Inicializa todos os dados do jogo no novo formato Unificado.
function inicializar_tudo()
{
    // --- 1. Poderes Básicos (MANTIDO) ---
    if (!variable_global_exists("lista_poderes_basicos")) 
    {
        global.lista_poderes_basicos = ds_list_create();
        
        // Adicione novos poderes básicos aqui
        ds_list_add(global.lista_poderes_basicos, criar_poder("correr",   1, 0, false, 0, obj_poder_correr));
        ds_list_add(global.lista_poderes_basicos, criar_poder("dash",     1, 0, false, 1, obj_poder_dash));
        ds_list_add(global.lista_poderes_basicos, criar_poder("mapa",     1, 0, false, 2, obj_poder_mapa));
        ds_list_add(global.lista_poderes_basicos, criar_poder("lanterna", 1, 0, false, 3, obj_poder_lanterna));
    }

    // --- 2. Itens Passivos (Reinicia a grid) ---
    if (variable_global_exists("itens_vamp_grid")) ds_grid_destroy(global.itens_vamp_grid);
    global.itens_vamp_grid = ds_grid_create(ITENS_VAMP.LENGTH, 0);

    // Adicione novos Itens aqui (Nível começa 0, Descrição vazia "")
    // Nota: Passamos dois scripts agora (Config e Execução)
    ds_grid_add_item_vamp("PENA", scr_feather_config, scr_pena, -1, 0); 
    ds_grid_add_item_vamp("ÍMÃ",  scr_ima_de_almas_config, scr_ima_de_almas, -1, 0); 
    ds_grid_add_item_vamp("ANEL",  scr_anel_amplificador_config, scr_anel_amplificador, -1, 0); 
    ds_grid_add_item_vamp("TOMO",  scr_tomo_celeridade_config, scr_tomo_celeridade, -1, 0); 


    // --- 3. Upgrades Ativos (Reinicia a grid) ---
    if (variable_global_exists("upgrades_vamp_grid")) ds_grid_destroy(global.upgrades_vamp_grid);
    global.upgrades_vamp_grid = ds_grid_create(UPGRADES_VAMP.LENGTH, 0);

    // Adicione novos Upgrades aqui (Nível começa 0, Descrição vazia "")
    // A ordem de chamada define o índice da linha automaticamente. FIM DO BUG HARDCODE.
    // Nota: A Bola está começando no nível 5 para os seus testes!
    ds_grid_add_upgrade_vamp("BOLA",       scr_bola_config,       scr_bola,       -1, 0);
    ds_grid_add_upgrade_vamp("EXPLOSÃO",   scr_explosion_config,   scr_explosao,   -1, 0);
    ds_grid_add_upgrade_vamp("SHURIKEN",   scr_shuriken_config,   scr_shuriken,   -1, 0);
    ds_grid_add_upgrade_vamp("BUMERANGUE", scr_boomerang_config, scr_bumerangue, -1, 0);
    ds_grid_add_upgrade_vamp("LÂMINAS",    scr_laminas_giras_config, scr_laminas_giras, -1, 0);
    ds_grid_add_upgrade_vamp("RASTRO",     scr_rastro_sombrio_config, scr_rastro_sombrio, -1, 0);
    ds_grid_add_upgrade_vamp("ADAGAS",     scr_adagas_velozes_config, scr_adagas_velozes, -1, 0);

    
    // Habilidades sem config/script ainda
    ds_grid_add_upgrade_vamp("ORBE",       -1, -1, -1, 0);
    ds_grid_add_upgrade_vamp("BOLHAS",     -1, -1, -1, 0);
    
    ds_grid_add_upgrade_vamp("RAIO",       scr_lightning_config,   scr_raio,       -1, 0);
    ds_grid_add_upgrade_vamp("SAPO",       scr_sapo_config,       scr_sapo,       -1, 0);
    ds_grid_add_upgrade_vamp("BORBOLETA",   scr_butterfly_config,   scr_borboleta,  -1, 0);
    ds_grid_add_upgrade_vamp("BOMBA",      scr_bomb_config,      scr_bomba,      -1, 0);


    // ========================================================
    // REGIÃO 4.1: ATUALIZAÇÃO IMEDIATA DAS DESCRIÇÕES (NOVO)
    // ========================================================
    // Isso garante que, mesmo no nível 0, a grid já mostre 
    // a descrição do nível 1 para a UI de sorteio de upgrades.
    
    // --- Atualiza Passivos (PENA) ---
    var _itens_grid = global.itens_vamp_grid;
    for (var _k = 0; _k < ds_grid_height(_itens_grid); _k++) {
        var _config_scr = _itens_grid[# ITENS_VAMP.CONFIG_SCRIPT, _k];
        var _level = _itens_grid[# ITENS_VAMP.LEVEL, _k];

        if (_config_scr != -1) {
            var _scr = is_string(_config_scr) ? asset_get_index(_config_scr) : _config_scr;
            if (_scr != -1) {
                scr_generic_calculate_passive_upgrade(script_execute(_scr), _level, _itens_grid, _k, ITENS_VAMP.DESCRIPTION);
            }
        }
    }

    // --- Atualiza Ativos (BOLA, BOMBA, etc.) ---
    var _upgrades_grid = global.upgrades_vamp_grid;
    for (var _i = 0; _i < ds_grid_height(_upgrades_grid); _i++) {
        var _config_scr_up = _upgrades_grid[# UPGRADES_VAMP.CONFIG_SCRIPT, _i];
        var _level_up = _upgrades_grid[# UPGRADES_VAMP.LEVEL, _i];

        if (_config_scr_up != -1) {
            var _scr_up = is_string(_config_scr_up) ? asset_get_index(_config_scr_up) : _config_scr_up;
            if (_scr_up != -1) {
                scr_generic_calculate_stats(script_execute(_scr_up), _level_up, _upgrades_grid, _i, UPGRADES_VAMP.DESCRIPTION);
            }
        }
    }
}

#endregion