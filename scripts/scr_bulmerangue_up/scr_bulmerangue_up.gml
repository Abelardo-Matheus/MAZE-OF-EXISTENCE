// feather disable GM2017
// ==============================================================================
// REGIÃO 1: CONFIGURAÇÃO (DADOS E VETOR DE NÍVEIS)
// ==============================================================================
#region CONFIGURAÇÃO

/// @desc Retorna a estrutura de dados (Vetor de Skill) do BUMERANGUE
function scr_boomerang_config()
{
    return {
		
        // --- Status Base (Nível 0 - Antes da primeira coleta) ---
        // Usamos os nomes exatos definidos na macro DEFAULT_SKILL_STATS
        stats_base: {
            damage: 15,             // Dano base
			sprite_icon: spr_bulmerangue_icon,
            cooldown: 5000,         // Tempo de recarga (ms)
            speed: 10,              // Velocidade de movimento
            size: 2,                // Escala visual (multiplicador)
            knockback: 0,           // Empurrão
            pierce_count: 1,        // Inimigos atravessados antes de voltar (padrão base)
            range: 200,             // Alcance máximo de ida (pixels)
            quantity: 0             // Começa com 0 para não disparar antes do Lvl 1
        },

        // --- Definição Nível a Nível (Data-Driven) ---
        // Índice 0 na array = Upgrade que leva a skill para o Nível 1, etc.
        // Baseado no seu switch mod 8 original, adaptado para array sequencial.
        niveis: [
            // Nível 1
            { 
                desc: "LANÇA UM BUMERANGUE QUE VAI E VOLTA ATINGINDO INIMIGOS.", // Descrição inicial
                upgrade: function(_s) { 
                    _s.quantity = 1; // Ativa o disparo
                } 
            },
            // Nível 2
            { 
                desc: "ATRAVESSA MAIS 10 INIMIGOS (+Pierce)", // Mantendo seu texto original (+10), mas lógica original somava +1.
                upgrade: function(_s) { _s.pierce_count += 1; } 
            },
            // Nível 3
            { 
                desc: "VELOCIDADE AUMENTADA EM 5%", 
                upgrade: function(_s) { _s.speed *= 1.05; } 
            },
            // Nível 4
            { 
                desc: "RECARGA REDUZIDA EM 5% (-Cooldown)", 
                upgrade: function(_s) { _s.cooldown *= 0.95; } 
            },
            // Nível 5
            { 
                desc: "DANO AUMENTADO EM 10%", 
                upgrade: function(_s) { _s.damage *= 1.10; } 
            },
            // Nível 6
            { 
                desc: "BUMERANGUE EMPURRA INIMIGOS (+Knockback)", 
                upgrade: function(_s) { _s.knockback += 0.01; } 
            },
            // Nível 7
            { 
                desc: "MAIS UM BUMERANGUE (Quantidade +1)", 
                upgrade: function(_s) { _s.quantity += 1; } 
            },
            // Nível 8
            { 
                desc: "ALCANCE MAIOR (+Range)", 
                upgrade: function(_s) { _s.range += 100; } 
            }
        ]
    };
}

#endregion

// ==============================================================================
// REGIÃO 2: EXECUÇÃO (LÓGICA E DISPARO)
// ==============================================================================
#region EXECUÇÃO

/// @desc Executa a lógica do 'Bumerangue' (Cooldown, Targeting e Arremesso)
/// @param _row_index O índice da linha desta skill na grid (recebido do controle)
function scr_bumerangue(_row_index) 
{
    // Sistema de Pausa (centralizado no Step do Player)
    if (global.level_up) exit; 

    // OBTÉM O NÍVEL ATUAL CORRETAMENTE BASEADO NA LINHA RECEBIDA
    var _current_level = global.upgrades_vamp_grid[# UPGRADES_VAMP.LEVEL, _row_index];
    
    // Se nível 0, não faz nada (segurança)
    if (_current_level <= 0) exit;

    // ========================================================
    // --- 1. UNIFICAÇÃO: Obter Dados e Calcular Stats Finais ---
    // ========================================================
    var _config = scr_boomerang_config(); // Carrega os dados puro (Região 1)
    
    // Chama a calculadora genérica universal (Passando referências corretas da grid e colunas)
    // Nota: Certifique-se de que a função 'scr_generic_calculate_stats' já foi criada.
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, UPGRADES_VAMP.DESCRIPTION);

    // ========================================================
    // --- 2. LÓGICA DO TIMER (Sua lógica Delta_Time permanece aqui) ---
    // ========================================================
    if (!variable_global_exists("boomerang_timer")) global.boomerang_timer = 0;
    
    // delta_time é em microsegundos. Dividir por 1000 converte para milissegundos.
    global.boomerang_timer += delta_time / 1000; 

    // Disparo (Arremesso)
    if (global.boomerang_timer >= _stats.cooldown) 
    {
        global.boomerang_timer = 0; 

        // ========================================================
        // --- 3. SUA LÓGICA ÚNICA DE TARGETING (Priority Queue) ---
        // ========================================================
        // SUBSTÍTUA 'obj_player' PELO NOME DO SEU OBJETO JOGADOR
        if (!instance_exists(obj_player)) exit; 
        
        var _player_x = obj_player.x;
        var _player_y = obj_player.y;

        // Mira universal: os N inimigos mais próximos (instância + horda) dentro do alcance
        var _alvos = inimigos_alvos(_player_x, _player_y, _stats.range, _stats.quantity, "perto");
        var _amount_to_throw = array_length(_alvos);

        for (var _i = 0; _i < _amount_to_throw; _i++) 
        {
            var _target_id = _alvos[_i];

            var _boomerang = instance_create_layer(_player_x, _player_y, "Instances", obj_bumerangue);
            _boomerang.damage = _stats.damage;
            _boomerang.move_speed = _stats.speed;
            _boomerang.pierce_max = _stats.pierce_count;
            _boomerang.push_force = _stats.knockback;

            var _escala_final = _stats.size;
            if (variable_instance_exists(_boomerang, "escala_base")) {
                _escala_final *= _boomerang.escala_base;
            }
            _boomerang.image_xscale = _escala_final;
            _boomerang.image_yscale = _escala_final;

            // Frames para atingir o alcance máximo (+10 de folga para passar do alvo)
            _boomerang.timer_going = (_stats.range / _stats.speed) + 10;

            _boomerang.target_x = _target_id.x;
            _boomerang.target_y = _target_id.y;
            _boomerang.direction = point_direction(_player_x, _player_y, _target_id.x, _target_id.y);
            _boomerang.state = "going"; 
            _boomerang.return_target = obj_player;
        }
    }
}

#endregion