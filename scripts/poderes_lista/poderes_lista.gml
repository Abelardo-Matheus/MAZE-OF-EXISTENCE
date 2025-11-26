/// @desc Definição das colunas das tabelas
enum Itens_vamp {
    Name,
    Script,
    frequency,
    description,
    level,
    Length
}

enum Upgrades_vamp {
    Name,
    Script,
    frequency,
    description,
    level,
    Length
}

/// @desc Cria estrutura de poder básico
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

/// @desc Busca poder pelo ID na lista
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

/// @desc Adiciona Item na Grid (Redimensiona automátiocamente)
function ds_grid_add_item_vamp(_name, _script, _frequency, _description, _level)
{
    var _grid = global.itens_vamp_grid;
    var _old_height = ds_grid_height(_grid);
    
    // Aumenta a grid em 1 linha
    ds_grid_resize(_grid, Itens_vamp.Length, _old_height + 1);
    var _y = _old_height;

    _grid[# Itens_vamp.Name,        _y] = _name;
    _grid[# Itens_vamp.Script,      _y] = _script;
    _grid[# Itens_vamp.frequency,   _y] = _frequency;
    _grid[# Itens_vamp.description, _y] = _description;
    _grid[# Itens_vamp.level,       _y] = _level;
}

/// @desc Adiciona Upgrade na Grid (Redimensiona automátiocamente)
function ds_grid_add_upgrade_vamp(_name, _script, _frequency, _description, _level)
{
    var _grid = global.upgrades_vamp_grid;
    var _old_height = ds_grid_height(_grid);
    
    // Aumenta a grid em 1 linha
    ds_grid_resize(_grid, Upgrades_vamp.Length, _old_height + 1);
    var _y = _old_height;

    _grid[# Upgrades_vamp.Name,        _y] = _name;
    _grid[# Upgrades_vamp.Script,      _y] = _script;
    _grid[# Upgrades_vamp.frequency,   _y] = _frequency;
    _grid[# Upgrades_vamp.description, _y] = _description;
    _grid[# Upgrades_vamp.level,       _y] = _level;
}

/// @desc Inicializa todos os dados do jogo
function inicializar_tudo()
{
    // --- 1. Poderes Básicos ---
    if (!variable_global_exists("lista_poderes_basicos")) 
    {
        global.lista_poderes_basicos = ds_list_create();
        
        // Adicione novos poderes básicos aqui
        ds_list_add(global.lista_poderes_basicos, criar_poder("correr",   1, 0, false, 0, obj_poder_correr));
        ds_list_add(global.lista_poderes_basicos, criar_poder("dash",     1, 0, false, 1, obj_poder_dash));
        ds_list_add(global.lista_poderes_basicos, criar_poder("mapa",     1, 0, false, 2, obj_poder_mapa));
        ds_list_add(global.lista_poderes_basicos, criar_poder("lanterna", 1, 0, false, 3, obj_poder_lanterna));
    }

    // --- 2. Itens Passivos (Reinicia a grid para evitar duplicatas) ---
    if (variable_global_exists("itens_vamp_grid")) ds_grid_destroy(global.itens_vamp_grid);
    global.itens_vamp_grid = ds_grid_create(Itens_vamp.Length, 0);

    // Adicione novos Itens aqui
    ds_grid_add_item_vamp("PENA", scr_pena, -1, "Deixa o jogador mais rápido.", 0);
    ds_grid_add_item_vamp("IMÃ",  -1,       -1, "Coleta recursos de longe.",    0);

    // --- 3. Upgrades Ativos (Reinicia a grid) ---
    if (variable_global_exists("upgrades_vamp_grid")) ds_grid_destroy(global.upgrades_vamp_grid);
    global.upgrades_vamp_grid = ds_grid_create(Upgrades_vamp.Length, 0);

    // Adicione novos Upgrades aqui
    ds_grid_add_upgrade_vamp("BOLA",       scr_bola,       -1, "Joga uma bola que persegue.",         0);
    ds_grid_add_upgrade_vamp("EXPLOSÃO",   scr_explosao,   -1, "Energia pulsante que repele.",        0);
    ds_grid_add_upgrade_vamp("SHURIKEN",   scr_shuriken,   -1, "Gira ao redor do jogador.",           0);
    ds_grid_add_upgrade_vamp("BUMERANGUE", scr_bumerangue, -1, "Vai e volta atingindo inimigos.",     0);
    ds_grid_add_upgrade_vamp("ORBE",       -1,             -1, "Explode em confetes.",                0);
    ds_grid_add_upgrade_vamp("BOLHAS",     -1,             -1, "Chuva de bolhas.",                    0);
    ds_grid_add_upgrade_vamp("RAIO",       scr_raio,       -1, "Ursinho gigante que bloqueia.",       0);
    ds_grid_add_upgrade_vamp("SAPO",       scr_sapo,       -1, "Pet sapo que engole inimigos.",       0);
    ds_grid_add_upgrade_vamp("BORBOLETA",  -1,             -1, "Distrai inimigos.",                   0);
    ds_grid_add_upgrade_vamp("BOMBA",      scr_bomba,      -1, "Joga bomba aleatoriamente.",          0);
}