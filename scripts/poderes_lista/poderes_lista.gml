// ==============================================================================
// REGIÃO 1: ENUMS E DEFINIÇÕES GLOBAIS (INFRAESTRUTURA)
// ==============================================================================
#region DEFINIÇÕES

/// @desc Definição das colunas das tabelas de itens passivos
enum Itens_vamp {
    Name,
    ConfigScript,   // NOVO: Link para o script de config (scr_XXX_config)
    Script,         // NOVO: Link para o script executor (scr_XXX)
    frequency,
    description,
    level,
    Length
}

/// @desc Definição das colunas das tabelas de upgrades ativos
enum Upgrades_vamp {
    Name,
    ConfigScript,   // NOVO: Link para o script de config (scr_XXX_config)
    Script,         // Link para o script executor (scr_XXX)
    frequency,
    description,
    level,
    Length
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
/// @param _row_index O índice da linha desta skill na grid (recebido do controle)
/// @desc Calcula os stats finais e atualiza a descrição (AGORA INFINITO)
function scr_generic_calculate_stats(_skill_config, _current_level, _grid, _row_index, _col_desc)
{
    // 1. Cria a cópia base limpa
    var _stats = DEFAULT_SKILL_STATS;
    
    var _base_defined = _skill_config.stats_base;
    var _names = variable_struct_get_names(_base_defined);
    for (var i = 0; i < array_length(_names); i++) {
        var _name = _names[i];
        variable_struct_set(_stats, _name, variable_struct_get(_base_defined, _name));
    }
    
    if (_current_level == 0) return _stats;

    // 2. Itera aplicando os upgrades nível a nível (LOOP INFINITO)
    var _levels_array = _skill_config.niveis;
    var _max_defined_levels = array_length(_levels_array);
    
    // ATENÇÃO: Removemos a trava de limite máximo. Ele vai contar até o nível atual, seja ele 15, 50 ou 1000.
    for (var i = 0; i < _current_level; i++)
    {
        // O módulo '%' garante que se tivermos 6 níveis, o índice 6 vira 0, o 7 vira 1, etc.
        var _nivel_info = _levels_array[i % _max_defined_levels];
        
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
/// @desc Retorna a estrutura de dados (Vetor de Skill) da BOLA

/// @desc Calcula o upgrade do nível ATUAL e atualiza a grid de descrição de itens PASSIVOS.
/// @desc (Específico para itens passivos que aplicam bônus 'one-time' ao subir de nível)
/// @param _item_config O Struct retornado pela função scr_XXX_config()
/// @param _current_level O nível atual do item (pego da grid)
/// @param _row_index O índice da linha deste item na grid
function scr_generic_calculate_passive_upgrade(_item_config, _current_level, _row_index)
{
    // Retorna cópia base simples para passivos
    var _stats = variable_clone(_item_config.stats_base);
    
    if (_current_level == 0) return _stats;

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
    
    global.itens_vamp_grid[# Itens_vamp.description, _row_index] = _desc_grid;

    return _stats;
}

#endregion

// ==============================================================================
// REGIÃO 3: AUXILIARES DE CRIAÇÃO E BUSCA (MANTIDOS/REFATORADOS)
// ==============================================================================
#region AUXILIARES

/// @desc Cria estrutura de poder básico (MANTIDO)
function criar_poder(nome, nivel, dano, coletado, ID, objeto) 
{
    return {
        poder_nome: nome,
        poder_nivel: nivel,
        dano: dano,
        coletado: coletado,
        ID: ID,
        objeto: objeto
    };
}

/// @desc Busca poder pelo ID na lista (MANTIDO)
function procurar_poder(id_procurado)
{
    var _tamanho = ds_list_size(global.lista_poderes_basicos);
    var _objeto_encontrado = noone; // Variável local segura

    for (var i = 0; i < _tamanho; i++) 
    {
        var _poder = global.lista_poderes_basicos[| i];
        
        if (_poder.ID == id_procurado) 
        {
            _objeto_encontrado = _poder;
            break;
        }
    }
    return _objeto_encontrado;
}

/// @desc Adiciona Item Passivo na Grid (Redimensiona automátiocamente)
/// @param _config_script O Link para o script scr_XXX_config
function ds_grid_add_item_vamp(_name, _config_script, _script, _frequency, _level)
{
    var _grid = global.itens_vamp_grid;
    var _old_height = ds_grid_height(_grid);
    
    // Aumenta a grid em 1 linha
    ds_grid_resize(_grid, Itens_vamp.Length, _old_height + 1);
    var _y = _old_height;

    _grid[# Itens_vamp.Name,         _y] = _name;
    _grid[# Itens_vamp.ConfigScript, _y] = _config_script; // Link de Dados
    _grid[# Itens_vamp.Script,       _y] = _script;        // Link de Execução
    _grid[# Itens_vamp.frequency,    _y] = _frequency;
    // Descrição começa vazia e é preenchida dinamicamente no final da inicialização
    _grid[# Itens_vamp.description,  _y] = ""; 
    _grid[# Itens_vamp.level,        _y] = _level;
    
    return _y; // Retorna o índice da linha criada
}

/// @desc Adiciona Upgrade Ativo na Grid (Redimensiona automátiocamente)
/// @param _config_script O Link para o script scr_XXX_config
function ds_grid_add_upgrade_vamp(_name, _config_script, _script, _frequency, _level)
{
    var _grid = global.upgrades_vamp_grid;
    var _old_height = ds_grid_height(_grid);
    
    // Aumenta a grid em 1 linha
    ds_grid_resize(_grid, Upgrades_vamp.Length, _old_height + 1);
    var _y = _old_height;

    _grid[# Upgrades_vamp.Name,         _y] = _name;
    _grid[# Upgrades_vamp.ConfigScript, _y] = _config_script; // Link de Dados
    _grid[# Upgrades_vamp.Script,       _y] = _script;        // Link de Execução
    _grid[# Upgrades_vamp.frequency,    _y] = _frequency;
    // Descrição começa vazia e é preenchida dinamicamente no final da inicialização
    _grid[# Upgrades_vamp.description,  _y] = ""; 
    _grid[# Upgrades_vamp.level,        _y] = _level;
    
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
    global.itens_vamp_grid = ds_grid_create(Itens_vamp.Length, 0);

    // Adicione novos Itens aqui (Nível começa 0, Descrição vazia "")
    // Nota: Passamos dois scripts agora (Config e Execução)
    ds_grid_add_item_vamp("PENA", scr_feather_config, scr_pena, -1, 0); 
    
    // Ímã não tem script de config/execução ainda, passar -1
    ds_grid_add_item_vamp("IMÃ",  -1, -1, -1, 0); 
    // Mantenha a descrição fixa na grid temporariamente para o imã:
    global.itens_vamp_grid[# Itens_vamp.description, ds_grid_height(global.itens_vamp_grid)-1] = "Coleta recursos de longe.";


    // --- 3. Upgrades Ativos (Reinicia a grid) ---
    if (variable_global_exists("upgrades_vamp_grid")) ds_grid_destroy(global.upgrades_vamp_grid);
    global.upgrades_vamp_grid = ds_grid_create(Upgrades_vamp.Length, 0);

    // Adicione novos Upgrades aqui (Nível começa 0, Descrição vazia "")
    // A ordem de chamada define o índice da linha automaticamente. FIM DO BUG HARDCODE.
    // Nota: A Bola está começando no nível 5 para os seus testes!
    ds_grid_add_upgrade_vamp("BOLA",       scr_bola_config,       scr_bola,       -1, 0);
    ds_grid_add_upgrade_vamp("EXPLOSÃO",   scr_explosion_config,   scr_explosao,   -1, 0);
    ds_grid_add_upgrade_vamp("SHURIKEN",   scr_shuriken_config,   scr_shuriken,   -1, 0);
    ds_grid_add_upgrade_vamp("BUMERANGUE", scr_boomerang_config, scr_bumerangue, -1, 0);

    
    // Habilidades sem config/script ainda
    ds_grid_add_upgrade_vamp("ORBE",       -1, -1, -1, 0);
    ds_grid_add_upgrade_vamp("BOLHAS",     -1, -1, -1, 0);
    
    ds_grid_add_upgrade_vamp("RAIO",       scr_lightning_config,   scr_raio,       -1, 0);
    ds_grid_add_upgrade_vamp("SAPO",       scr_sapo_config,       scr_sapo,       -1, 0);
    ds_grid_add_upgrade_vamp("BORBOLETA",   scr_butterfly_config,   scr_borboleta,  -1, 0);
    ds_grid_add_upgrade_vamp("BOMBA",      scr_bomb_config,      scr_bomba,      -1, 14);


    // ========================================================
    // REGIÃO 4.1: ATUALIZAÇÃO IMEDIATA DAS DESCRIÇÕES (NOVO)
    // ========================================================
    // Isso garante que, mesmo no nível 0, a grid já mostre 
    // a descrição do nível 1 para a UI de sorteio de upgrades.
    
    // --- Atualiza Passivos (PENA) ---
    var _itens_grid = global.itens_vamp_grid;
    for (var k = 0; k < ds_grid_height(_itens_grid); k++) {
        var _config_scr = _itens_grid[# Itens_vamp.ConfigScript, k];
        var _level = _itens_grid[# Itens_vamp.level, k];
        if (_config_scr != -1 && script_exists(_config_scr)) {
            // Calculadora de passivos mantém os 3 argumentos originais
            scr_generic_calculate_passive_upgrade(_config_scr(), _level, k);
        }
    }

    // --- Atualiza Ativos (BOLA, BOMBA, etc.) ---
    var _upgrades_grid = global.upgrades_vamp_grid;
    for (var i = 0; i < ds_grid_height(_upgrades_grid); i++) {
        var _config_scr_up = _upgrades_grid[# Upgrades_vamp.ConfigScript, i];
        var _level_up = _upgrades_grid[# Upgrades_vamp.level, i];
        
        if (_config_scr_up != -1 && script_exists(_config_scr_up)) {
            // ==========================================================
            // AQUI ESTÁ A MUDANÇA: Agora passamos 5 argumentos para a 
            // calculadora genérica ativa suportar níveis infinitos!
            // (_skill_config, _current_level, _grid, _row_index, _col_desc)
            // ==========================================================
            scr_generic_calculate_stats(
                _config_scr_up(), 
                _level_up, 
                _upgrades_grid, 
                i, 
                Upgrades_vamp.description
            );
        }
    }
}

#endregion