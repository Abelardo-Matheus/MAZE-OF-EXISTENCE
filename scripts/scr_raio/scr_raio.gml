// feather disable GM2017
// ==============================================================================
// REGIÃO 1: CONFIGURAÇÃO (DADOS E VETOR DE NÍVEIS)
// ==============================================================================
#region CONFIGURAÇÃO

/// @desc Retorna a estrutura de dados (Vetor de Skill) do RAIO
function scr_lightning_config()
{
    return {
		
        // --- Status Base (Nível 0 - Antes da primeira coleta) ---
        stats_base: {
            damage: 20,             // Dano direto
			sprite_icon: spr_raio_icon,
            radius: 120,            // Área de efeito (AoE)
            push_force: 3,          // Empurrão
            duration: 0.5,          // Duração visual
            cooldown: 4000,         // Tempo entre raios (ms)
            quantity: 0             // Começa com 0 para não atirar antes do Lvl 1
        },

        // --- Definição Nível a Nível (Data-Driven) ---
        niveis: [
            // Nível 1 (Ativação)
            { 
                desc: "INVOCA UM RAIO NOS INIMIGOS PRÓXIMOS.", 
                upgrade: function(_s) { 
                    _s.quantity = 1; // Ativa a skill
                } 
            },
            // Nível 2
            { 
                desc: "AUMENTO DE 10% DE DANO", 
                upgrade: function(_s) { _s.damage *= 1.10; } 
            },
            // Nível 3
            { 
                desc: "ÁREA DE EFEITO AUMENTADA (+10%)", 
                upgrade: function(_s) { _s.radius *= 1.10; } 
            },
            // Nível 4
            { 
                desc: "EMPURRÃO AUMENTADO (+5%)", 
                upgrade: function(_s) { _s.push_force *= 1.05; } 
            },
            // Nível 5
            { 
                desc: "RECARGA MAIS RÁPIDA (-15%)", 
                upgrade: function(_s) { _s.cooldown *= 0.85; } 
            },
            // Nível 6
            { 
                desc: "CAI MAIS UM RAIO", 
                upgrade: function(_s) { _s.quantity += 1; } 
            },
            // Nível 7 (Mega Dano)
            { 
                desc: "AUMENTO DE 15% DE DANO EXTRA", 
                upgrade: function(_s) { _s.damage *= 1.15; } 
            }
        ]
    };
}

#endregion

// ==============================================================================
// REGIÃO 2: EXECUÇÃO (LÓGICA E DISPARO)
// ==============================================================================
#region EXECUÇÃO

/// @desc Executa a lógica do 'Raio' (Ataque Orbital Múltiplo)
/// @param _row_index O índice da linha desta skill na grid (recebido do controle)
function scr_raio(_row_index) 
{
    // Sistema de Pausa
    if (global.level_up) exit; 

    // OBTÉM O NÍVEL ATUAL CORRETAMENTE BASEADO NA LINHA RECEBIDA
    var _current_level = global.upgrades_vamp_grid[# UPGRADES_VAMP.LEVEL, _row_index];
    
    // Se nível 0, não faz nada (segurança)
    if (_current_level <= 0) exit;

    // ========================================================
    // --- 1. UNIFICAÇÃO: Obter Dados e Calcular Stats Finais ---
    // ========================================================
    var _config = scr_lightning_config(); 
    
    // Chama a calculadora genérica universal
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, UPGRADES_VAMP.DESCRIPTION);

    // ========================================================
    // --- 2. LÓGICA DO TIMER ---
    // ========================================================
    if (!variable_global_exists("lightning_timer")) global.lightning_timer = 0;
    
    // delta_time é em microsegundos. Dividir por 1000 converte para milissegundos.
    global.lightning_timer += delta_time / 1000; 

    // Disparo
    if (global.lightning_timer >= _stats.cooldown) 
    {
        global.lightning_timer = 0; 

        // ========================================================
        // --- 3. SUA LÓGICA ÚNICA DE TARGETING (Apenas na Tela) ---
        // ========================================================
        // Mira universal: inimigos (instância + horda) visíveis na câmera, escolhidos ao acaso
        var _px = instance_exists(obj_player) ? obj_player.x : camera_get_view_x(view_camera[0]);
        var _py = instance_exists(obj_player) ? obj_player.y : camera_get_view_y(view_camera[0]);
        var _alvos = inimigos_alvos(_px, _py, 100000, _stats.quantity, "aleatorio", true);
        var _total_targets = array_length(_alvos);

        if (_total_targets > 0) 
        {
            // Mais raios que alvos: recomeça a lista (múltiplos hits no mesmo inimigo)
            for (var _i = 0; _i < _stats.quantity; _i++)
            {
                var _target_enemy = _alvos[_i % _total_targets];

                var _lightning = instance_create_layer(_target_enemy.x, _target_enemy.y, "Instances", obj_raio);
                _lightning.damage = _stats.damage;
                _lightning.radius = _stats.radius;
                _lightning.push_force = _stats.push_force;
                _lightning.duration = _stats.duration;

                // Pequeno offset aleatório para não cair tudo no mesmo pixel exato
                _lightning.x += irandom_range(-10, 10);
                _lightning.y += irandom_range(-10, 10);
            }
        }
    }
}

#endregion