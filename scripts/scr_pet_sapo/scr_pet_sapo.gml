// ==============================================================================
// REGIÃO 1: CONFIGURAÇÃO (DADOS E VETOR DE NÍVEIS) - Antigo scr_frog_calculate_stats
// ==============================================================================
#region CONFIGURAÇÃO

/// @desc Retorna a estrutura de dados (Vetor de Skill) do SAPO (Pet Orbital)
function scr_sapo_config()
{
    return {
        // --- Status Base (Nível 0 - Antes da primeira coleta) ---
        // Usamos os nomes exatos definidos na macro DEFAULT_SKILL_STATS
        stats_base: {
            damage: 10,             // Dano
			sprite_icon: spr_sapo_idle,
            move_speed: 3,          // Velocidade de movimento (pixels/frame do pet)
            attack_cooldown: 60,    // Intervalo de ataque (frames do pet)
            orbit_radius: 200,      // Distância que o sapo tenta manter do player
            quantity: 0             // Começa com 0 para não criar antes do Lvl 1
        },

        // --- Definição Nível a Nível (Data-Driven) ---
        // Índice 0 na array = Upgrade que leva a skill para o Nível 1, etc.
        // Baseado no seu switch mod 6 original.
        niveis: [
            // Nível 1
            { 
                desc: "COLETA UM PET SAPO QUE ENGOLE INIMIGOS PERIÓDICAMENTE.", 
                upgrade: function(_s) { 
                    _s.quantity = 1; // Ativa a criação
                } 
            },
            // Nível 2
            { 
                desc: "DANO DO PET AUMENTADO EM 10%", 
                upgrade: function(_s) { _s.damage *= 1.10; } 
            },
            // Nível 3
            { 
                desc: "VELOCIDADE DO PET AUMENTADA (+10%)", 
                upgrade: function(_s) { _s.move_speed *= 1.10; } 
            },
            // Nível 4
            { 
                desc: "ATAQUE MAIS RÁPIDO (-10% Cooldown frames)", 
                upgrade: function(_s) { _s.attack_cooldown *= 0.90; } 
            },
            // Nível 5
            { 
                desc: "MAIS UM SAPO (Quantidade +1)", 
                upgrade: function(_s) { _s.quantity += 1; } 
            },
            // Nível 6
            { 
                desc: "ALCANCE DE PATRULHA AUMENTADO (+12.5% Orbit)", 
                upgrade: function(_s) { _s.orbit_radius *= 1.125; } 
            },
            // Nível 7 (Ciclo recomeça ou Mega bônus)
            { 
                desc: "MEGA UPGRADE: DANO DO PET AUMENTADO EM 20%", 
                upgrade: function(_s) { _s.damage *= 1.20; } 
            }
        ]
    };
}

#endregion

// ==============================================================================
// REGIÃO 2: EXECUÇÃO (GERENCIAMENTO DE INSTÂNCIAS E STATUS) - Antigo scr_sapo
// ==============================================================================
#region EXECUÇÃO

/// @desc Gerencia a matilha de Sapos (Criação e Atualização Data-Driven)
/// [O QUE]: Cria novos sapos se necessário e atualiza os status de TODOS os sapos ativos.
/// @param _row_index O índice da linha desta skill na grid (recebido do controle)
function scr_sapo(_row_index) 
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
    var _config = scr_sapo_config(); // Carrega os dados puro (Região 1)
    
    // Chama a calculadora genérica universal (Passando referências corretas da grid e colunas)
    // Nota: Certifique-se de que a função 'scr_generic_calculate_stats' já foi criada.
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, Upgrades_vamp.description);

    // ========================================================
    // --- 2. LÓGICA ÚNICA DO PET (Spawn e Atualização) ---
    // ========================================================
    
    // --- A. Criação de Instâncias ---
    // Verifica quantos sapos já existem
    // SUBSTÍTUA 'obj_sapo_pet' PELO NOME DO SEU OBJETO SAPO
    var _current_count = instance_number(obj_sapo_pet);
    // Calcula quantos faltam criar baseado na quantidade calculada universalmente
    var _needed = _stats.quantity - _current_count;

    // Cria os sapos que faltam perto do player
    if (_needed > 0 && instance_exists(obj_player)) {
        repeat(_needed) {
            instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_sapo_pet);
        }
    }

    // --- B. Atualização de Status (Atributos e Posição na Roda) ---
    var _index = 0;
    var _total_frogs = instance_number(obj_sapo_pet);

    // Entra no escopo de TODOS os objetos sapo ativos
    with (obj_sapo_pet) 
    {
        // Variáveis internas do objeto Sapo recebem os stats acumulados
        // Isso garante que upgrades de dano/velocidade funcionem na hora.
        damage = _stats.damage;
        velocidade = _stats.move_speed;
        cooldown_max = _stats.attack_cooldown;
        orbit_radius = _stats.orbit_radius; // Distância alvo do player
        
        // Mantém sua lógica única: Range de detecção um pouco maior que a órbita
        range = _stats.orbit_radius * 1.5; 

        // Lógica de Formação: Define o ângulo único deste sapo na roda ao redor do player
        // Ex: 2 sapos = 0 e 180 graus. 3 sapos = 0, 120, 240.
        my_angle_offset = (360 / _total_frogs) * _index;
        
        _index++;
    }
}

#endregion