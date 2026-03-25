// ==============================================================================
// REGIÃO 1: CONFIGURAÇÃO (DADOS E VETOR DE NÍVEIS) - Antigo scr_butterfly_calculate_stats
// ==============================================================================
#region CONFIGURAÇÃO

/// @desc Retorna a estrutura de dados (Vetor de Skill) da BORBOLETA (Pet Wander)
function scr_butterfly_config()
{
    return {
        // --- Status Base (Nível 0 - Antes da primeira coleta) ---
        // Usamos os nomes exatos definidos na macro DEFAULT_SKILL_STATS
        stats_base: {
            damage: 15,             // Dano base da explosão de pólen
			sprite_icon: spr_borboleta_idle,
            pollen_radius: 64,      // Raio da explosão de pólen (AoE)
            move_speed: 4,          // Velocidade de voo (pixels/frame do pet)
            wander_radius: 150,     // Raio máx que ela se afasta do player
            quantity: 0,            // Começa com 0 para não criar antes do Lvl 1
            pollen_chance: 0.05     // Chance por frame de soltar pólen (5%)
        },

        // --- Definição Nível a Nível (Data-Driven) ---
        // Índice 0 na array = Upgrade que leva a skill para o Nível 1, etc.
        // Baseado no seu switch mod 6 original.
        niveis: [
            // Nível 1
            { 
                desc: "COLETA UMA BORBOLETA QUE SOLTA PÓLEN EXPLOSIVO NOS INIMIGOS.", 
                upgrade: function(_s) { 
                    _s.quantity = 1; // Ativa a criação
                } 
            },
            // Nível 2
            { 
                desc: "DANO DO PÓLEN AUMENTADO EM 15%", 
                upgrade: function(_s) { _s.damage *= 1.15; } 
            },
            // Nível 3
            { 
                desc: "ÁREA DO PÓLEN AUMENTADA (+15% Radius)", 
                upgrade: function(_s) { _s.pollen_radius *= 1.15; } 
            },
            // Nível 4
            { 
                desc: "SOLTA PÓLEN MAIS FREQUENTEMENTE (+10% Chance)", 
                upgrade: function(_s) { _s.pollen_chance *= 1.10; } 
            },
            // Nível 5
            { 
                desc: "MAIS UMA BORBOLETA (Quantidade +1)", 
                upgrade: function(_s) { _s.quantity += 1; } 
            },
            // Nível 6
            { 
                desc: "BORBOLETA MAIS RÁPIDA E AGRESSIVA (+10% Voo/Wander)", 
                upgrade: function(_s) { _s.move_speed *= 1.10; _s.wander_radius *= 1.10; } 
            },
            // Nível 7 (Ciclo recomeça ou Mega bônus)
            { 
                desc: "SUPER UPGRADE: DANO DO PÓLEN AUMENTADO EM 30%", 
                upgrade: function(_s) { _s.damage *= 1.30; } 
            }
        ]
    };
}

#endregion

// ==============================================================================
// REGIÃO 2: EXECUÇÃO (GERENCIAMENTO DE INSTÂNCIAS E STATUS) - Antigo scr_borboleta
// ==============================================================================
#region EXECUÇÃO

/// @desc Gerencia o enxame de Borboletas (Criação e Atualização Data-Driven)
/// [O QUE]: Cria novas borboletas se necessário e atualiza os status de TODAS ativas.
/// @param _row_index O índice da linha desta skill na grid (recebido do controle)
function scr_borboleta(_row_index) 
{
    // Sistema de Pausa (centralizado no Step do Player)
    if (global.level_up) exit;

    // OBTÉM O NÍVEL ATUAL CORRETAMENTE BASEADO NA LINHA RECEBIDA
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, _row_index];
    
    // Se nível 0, não faz nada (segurança)
    if (_current_level <= 0) exit;

    // ========================================================
    // --- 1. UNIFICAÇÃO: Obter Dados e Calcular Stats Finais ---
    // ========================================================
    var _config = scr_butterfly_config(); // Carrega os dados puro (Região 1)
    
    // Chama a calculadora genérica universal (Passando referências corretas da grid e colunas)
    // Nota: Certifique-se de que a função 'scr_generic_calculate_stats' já foi criada.
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, Upgrades_vamp.description);

    // ========================================================
    // --- 2. LÓGICA ÚNICA DO PET (Spawn, Segurança e Atualização) ---
    // ========================================================
    
    // --- A. Criação de Instâncias ---
    // Verifica quantas borboletas já existem
    // SUBSTÍTUA 'obj_borboleta_pet' PELO NOME DO SEU OBJETO BORBOLETA
    var _current_count = instance_number(obj_borboleta_pet);
    // Calcula quantas faltam criar baseado na quantidade calculada universalmente
    var _needed = _stats.quantity - _current_count;

    // Cria as borboletas que faltam perto do player com variação aleatória
    if (_needed > 0 && instance_exists(obj_player)) {
        repeat(_needed) {
            instance_create_layer(obj_player.x + irandom_range(-20, 20), obj_player.y + irandom_range(-20, 20), "Instances", obj_borboleta_pet);
        }
    }

    // --- B. Atualização de Status de TODAS as instâncias ativas ---
    // Entra no escopo de TODOS os objetos borboleta ativos
    with (obj_borboleta_pet) 
    {
        // Variáveis internas do objeto Borboleta recebem os stats acumulados.
        // A lógica de voo aleatório e teletransporte de segurança (se implementada)
        // roda no Step Event do obj_borboleta_pet usando essas variáveis.
        
        damage = _stats.damage;
        velocidade = _stats.move_speed; // Usando 'velocidade' conforme seu antigo with
        pollen_radius = _stats.pollen_radius;
        wander_radius = _stats.wander_radius; // Distância máx do player
        pollen_chance = _stats.pollen_chance;
        
        // Mantém sua lógica de detecção: Range um pouco maior que a área de órbita do sapo
        // (Assumindo que 200 é a órbita base do sapo para detecção)
        range = 200 * 1.5; 
    }
}

#endregion