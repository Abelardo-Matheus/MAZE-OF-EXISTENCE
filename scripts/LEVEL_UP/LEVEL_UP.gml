/// @desc Inicialização de Status e XP
/// [O QUE]: Define os atributos base do player e prepara as listas de upgrade.

// --- Status Básicos ---
global.level_player = 1;
global.xp = 0;
global.max_xp = 100; // XP inicial para o primeiro nível
global.level_up = false;

// --- Tabelas de Crescimento (Stats por Nível) ---
// Inicializa arrays para evitar erro de "index out of bounds"
global.vida_max_calc[1] = 30;
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

/// @desc Processa a subida de nível e gera opções
/// [O QUE]: Aumenta o nível, recalcula vida/dano e sorteia 3 opções misturando Armas e Itens.
/// [COMO] :
/// 1. Incrementa nível e atualiza arrays de status (vida, estamina, dano).
/// 2. Cria um "Pool" (lista temporária) e joga dentro dele todas as Armas e Itens disponíveis.
/// 3. Embaralha o Pool e escolhe os primeiros X itens para exibir na tela.
function level_up() 
{
    global.level_up = true;
    global.level_player += 1;

    // ============================================================
    // PARTE 1: ATUALIZAÇÃO DE STATUS (Matemática)
    // ============================================================
    
    var _prev_lvl = global.level_player - 1;
    var _curr_lvl = global.level_player;

    // Cálculo Progressivo (Mantive sua lógica original)
    global.vida_max_calc[_curr_lvl]     = global.vida_max_calc[_prev_lvl] + (_curr_lvl * 0.8);
    global.max_estamina_calc[_curr_lvl] = global.max_estamina_calc[_prev_lvl] + 5;
    global.dano_base[_curr_lvl]         = global.dano_base[_prev_lvl] * 1.1;

    // Aplica os novos valores
    global.vida_max = global.vida_max_calc[_curr_lvl];
    global.max_estamina = global.max_estamina_calc[_curr_lvl];
    
    // Opcional: Cura o jogador ao upar? (Descomente se quiser)
    // global.vida = global.vida_max;
    // global.estamina = global.max_estamina;
    
    global.ataque = global.dano_base[_curr_lvl];

    // ============================================================
    // PARTE 2: SORTEIO DE CARTAS (Dealer System)
    // ============================================================
    
    ds_list_clear(global.upgrades_vamp_list);
    var _pool = ds_list_create();

    // --- A. Adiciona ARMAS (Upgrades) ao Pool ---
    // Tipo 0 = Arma
    var _total_weapons = ds_grid_height(global.upgrades_vamp_grid);
    
    for (var i = 0; i < _total_weapons; i++) 
    {
        var _lvl_weapon = global.upgrades_vamp_grid[# Upgrades_vamp.level, i];
        // Regra: Só adiciona se não estiver no nível máximo (ex: 100)
        if (_lvl_weapon < 100) {
            ds_list_add(_pool, [0, i]); // [TIPO, ID]
        }
    }

    // --- B. Adiciona ITENS Passivos ao Pool ---
    // Tipo 1 = Item
    var _total_items = ds_grid_height(global.itens_vamp_grid);
    
    for (var i = 0; i < _total_items; i++) 
    {
        var _lvl_item = global.itens_vamp_grid[# Itens_vamp.level, i];
        // Regra: Só adiciona se não estiver no nível máximo (ex: 5)
        if (_lvl_item < 5) {
            ds_list_add(_pool, [1, i]); // [TIPO, ID]
        }
    }

    // --- C. Embaralha e Seleciona ---
    ds_list_shuffle(_pool);
    
    // Garante que não tentamos pegar mais opções do que existem disponíveis
    var _picks = min(global.upgrade_num, ds_list_size(_pool)); 
    
    for (var i = 0; i < _picks; i++) 
    {
        ds_list_add(global.upgrades_vamp_list, _pool[| i]);
    }

    ds_list_destroy(_pool);
}

/// @desc Adiciona XP e verifica Level Up
function ganhar_xp(_xp_amount) 
{
    global.xp += _xp_amount;
    
    // Loop while para garantir que, se ganhar muito XP, suba vários níveis
    while (true) 
    {
        global.max_xp = global.level_player * 100; // Curva de XP
        
        if (global.xp >= global.max_xp) 
        {
            global.xp -= global.max_xp;
            level_up();
        } 
        else 
        {
            break; // Sai do loop se não tiver XP suficiente
        }
    }
}

/// @desc Calcula se o ataque atual é crítico
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