// ==============================================================================
// REGIÃO 1: CONFIGURAÇÃO (DADOS E VETOR DE NÍVEIS) - Antigo scr_bomb_calculate_stats
// ==============================================================================
#region CONFIGURAÇÃO

/// @desc Retorna a estrutura de dados (Vetor de Skill) da BOMBA (Arremesso)
function scr_bomb_config()
{
    return {
		
        // --- Status Base (Nível 0 - Antes da primeira coleta) ---
        // Usamos os nomes exatos definidos na macro DEFAULT_SKILL_STATS onde possível, 
        // e nomes customizados para a lógica única da bomba.
        stats_base: {
            damage: 20,                 // Dano
			sprite_icon: spr_bomba_icon,
            cooldown: 7000,             // Tempo de recarga (ms)
            radius: 100,                // Raio da explosão (pixels)
            push_force: 0,              // Empurrão (Knockback)
            
            // Variáveis customizadas para a lógica do objeto bomba
            bomb_count: 0,              // Começa com 0 para não atirar antes do Lvl 1
            splash_multiplier: 0.5,     // Dano na borda da explosão
            flight_duration: 1.0        // Tempo que a bomba fica no ar (segundos)
        },

        // --- Definição Nível a Nível (Data-Driven) ---
        // Índice 0 na array = Upgrade que leva a skill para o Nível 1, etc.
        // Baseado no seu switch mod 6 original, adaptado para sequência lógica.
        niveis: [
            // Nível 1 (Ativação)
            { 
                desc: "LANÇA UMA BOMBA EM ARCO QUE EXPLODE AO ATINGIR O CHÃO.", // Descrição inicial
                upgrade: function(_s) { 
                    _s.bomb_count = 1; // Ativa o arremesso
                } 
            },
            // Nível 2
            { 
                desc: "DANO DA BOMBA AUMENTADO EM 35%", 
                upgrade: function(_s) { _s.damage *= 1.35; } 
            },
            // Nível 3
            { 
                desc: "TEMPO DE RECARGA REDUZIDO EM 10% (-Cooldown)", 
                upgrade: function(_s) { _s.cooldown *= 0.90; } 
            },
            // Nível 4
            { 
                desc: "RAIO DA EXPLOSÃO AUMENTADO (+Área)", 
                upgrade: function(_s) { _s.radius += 20; } 
            },
            // Nível 5
            { 
                desc: "LANÇA MAIS DUAS BOMBAS (+2 Qtd)", 
                upgrade: function(_s) { _s.bomb_count += 2; } 
            },
            // Nível 6
            { 
                desc: "BOMBA EMPURRA OS INIMIGOS (+Knockback)", 
                upgrade: function(_s) { _s.push_force += 0.02; } 
            },
            // Nível 7 (Mega Área)
            { 
                desc: "DANO EM ÁREA AUMENTADO (+Splash)", 
                upgrade: function(_s) { _s.splash_multiplier += 0.05; } 
            }
        ]
    };
}

#endregion

// ==============================================================================
// REGIÃO 2: EXECUÇÃO (LÓGICA E DISPARO) - Antigo scr_bomba
// ==============================================================================
#region EXECUÇÃO

/// @desc Executa a lógica da 'Bomba' (Cooldown, Targeting por Prioridade e Arremesso Parabólico)
/// @param _row_index O índice da linha desta skill na grid (recebido do controle)
function scr_bomba(_row_index) 
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
    var _config = scr_bomb_config(); // Carrega os dados puro (Região 1)
    
    // Chama a calculadora genérica universal (Passando referências corretas da grid e colunas)
    // Nota: Certifique-se de que a função 'scr_generic_calculate_stats' já foi criada.
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, Upgrades_vamp.description);

    // ========================================================
    // --- 2. LÓGICA DO TIMER (Sua lógica Delta_Time permanece aqui) ---
    // ========================================================
    if (!variable_global_exists("bomb_timer")) global.bomb_timer = 0;
    
    // delta_time é em microsegundos. Dividir por 1000 converte para milissegundos.
    global.bomb_timer += delta_time / 1000; 

    // Disparo (Arremesso)
    if (global.bomb_timer >= _stats.cooldown) 
    {
        global.bomb_timer = 0; 

        // ========================================================
        // --- 3. SUA LÓGICA ÚNICA DE TARGETING (Priority Queue) ---
        // ========================================================
        // SUBSTÍTUA 'obj_player' PELO NOME DO SEU OBJETO JOGADOR
        if (!instance_exists(obj_player)) exit; 
        
        var _player_x = obj_player.x;
        var _player_y = obj_player.y;

        var _targets_list = ds_list_create();

        // Coleta inimigos (SUBSTÍTUA 'par_inimigos' SEU OBJETO PAI)
        // Dentro do alcance de arremesso (1000px fixo na sua lógica original)
        with (par_inimigos) 
        {
            if (point_distance(x, y, _player_x, _player_y) <= 1000) 
            {
                ds_list_add(_targets_list, id);
            }
        }

        var _total_targets = ds_list_size(_targets_list);

        if (_total_targets > 0) 
        {
            // Cria Fila de Prioridade para ordenar por distância real
            var _priority_queue = ds_priority_create();
            
            for(var k = 0; k < _total_targets; k++)
            {
                var _enemy = _targets_list[| k];
                var _dist = point_distance(_player_x, _player_y, _enemy.x, _enemy.y);
                // Adiciona na fila: Menor distância = Maior prioridade (delete_min pega o mais perto)
                ds_priority_add(_priority_queue, _enemy, _dist);
            }

            // Define quantas bombas vão sair (mínimo entre status calculados ou inimigos disponíveis)
            var _bombs_to_throw = min(_stats.bomb_count, _total_targets);

            // Loop de Arremesso
            for (var i = 0; i < _bombs_to_throw; i++) 
            {
                // Pega o inimigo mais próximo e remove da fila para o próximo tiro
                var _target_id = ds_priority_delete_min(_priority_queue);

                if (instance_exists(_target_id)) 
                {
                    // Criação do Objeto Bomba (SUBSTÍTUA 'obj_bomba' PELO NOME DO SEU OBJETO)
                    var _bomb = instance_create_layer(_player_x, _player_y, "Instances", obj_bomba);
                    
                    // --- Configuração de MOVIMENTO Parabólico (Crucial!) ---
                    _bomb.start_x = _player_x;     // Ponto A (Player)
                    _bomb.start_y = _player_y;
                    _bomb.target_x = _target_id.x;    // Ponto B (Inimigo)
                    _bomb.target_y = _target_id.y;
                    
                    // Passa parâmetros de voo calculados universalmente
                    _bomb.flight_duration = _stats.flight_duration; // Tempo total em segundos
                    _bomb.flight_timer = 0;           // Timer interno da bomba (inicia zerado)
                    _bomb.state = "flying";           // Define estado inicial para o objeto bomba
                    // A lógica parabólica real roda no Step Event do obj_bomba usando start/target/duration

                    // --- Configuração de STATUS usa os _stats calculados universalmente ---
                    _bomb.damage = _stats.damage;
                    _bomb.radius = _stats.radius;
                    _bomb.push_force = _stats.push_force; // Knockback
                    _bomb.splash_multiplier = _stats.splash_multiplier;
                }
            }
            // Limpeza de memória obrigatória da Fila de Prioridade
            ds_priority_destroy(_priority_queue);
        }
        // Limpeza de memória obrigatória da lista temporária
        ds_list_destroy(_targets_list);
    }
}

#endregion