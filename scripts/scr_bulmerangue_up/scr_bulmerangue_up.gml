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
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, _row_index];
    
    // Se nível 0, não faz nada (segurança)
    if (_current_level <= 0) exit;

    // ========================================================
    // --- 1. UNIFICAÇÃO: Obter Dados e Calcular Stats Finais ---
    // ========================================================
    var _config = scr_boomerang_config(); // Carrega os dados puro (Região 1)
    
    // Chama a calculadora genérica universal (Passando referências corretas da grid e colunas)
    // Nota: Certifique-se de que a função 'scr_generic_calculate_stats' já foi criada.
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, Upgrades_vamp.description);

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

        // Cria Fila de Prioridade para ordenar inimigos por distância
        var _priority_queue = ds_priority_create();
        
        // Coleta inimigos (SUBSTÍTUA 'par_inimigos' SEU OBJETO PAI)
        // Apenas dentro do alcance definido nos stats calculados universalmente
        with (par_inimigos) 
        {
            var _dist = point_distance(x, y, _player_x, _player_y);
            // Usa o _stats.range calculado
            if (_dist <= _stats.range) 
            {
                // Menor distância = Maior prioridade (delete_min tirarpa o mais próximo)
                ds_priority_add(_priority_queue, id, _dist);
            }
        }

        // Se houver inimigos no alcance, lança
        if (!ds_priority_empty(_priority_queue)) 
        {
            // Define quantos bumerangues vão sair (mínimo entre Qtd calculada ou inimigos disponíveis)
            var _amount_to_throw = min(_stats.quantity, ds_priority_size(_priority_queue));

            // Loop de Criação
            for (var i = 0; i < _amount_to_throw; i++) 
            {
                // Pega o inimigo mais próximo e remove da fila
                var _target_id = ds_priority_delete_min(_priority_queue);

                if (instance_exists(_target_id)) 
                {
                    // Criação do Objeto Bumerangue
                    // SUBSTÍTUA 'obj_bumerangue' PELO NOME DO SEU OBJETO BUMERANGUE
                    var _boomerang = instance_create_layer(_player_x, _player_y, "Instances", obj_bumerangue);
                    
                    // --- Passagem de Parâmetros usa os _stats calculados universalmente ---
                    // Certifique-se de que o objeto 'obj_bumerangue' tem essas variáveis no Create
                    _boomerang.damage = _stats.damage;
                    _boomerang.move_speed = _stats.speed; // Usando a variável que você definiu no antigo scr_bumerangue
                    _boomerang.pierce_max = _stats.pierce_count;
                    _boomerang.push_force = _stats.knockback;
                    
                    // Escala Visual
                    // Se usar o sistema de escala base que você tem (_boomerang.escala_base)
                    var _escala_final = _stats.size;
                    if (variable_instance_exists(_boomerang, "escala_base")) {
                        _escala_final *= _boomerang.escala_base;
                    }
                    _boomerang.image_xscale = _escala_final;
                    _boomerang.image_yscale = _escala_final;

                    // --- LÓGICA ÚNICA DE ALCANCE (RANGE) ---
                    // Calculamos quantos frames ele precisa viajar para atingir o range máximo.
                    // Tempo (frames) = Distância (pixels) / Velocidade (pixels/frame)
                    // Adicionamos +10 frames de "folga" para ele passar um pouco do alvo antes de voltar
                    _boomerang.timer_going = (_stats.range / _stats.speed) + 10;

                    // --- Mira e Estado Inicial ---
                    _boomerang.target_x = _target_id.x;
                    _boomerang.target_y = _target_id.y;
                    _boomerang.direction = point_direction(_player_x, _player_y, _target_id.x, _target_id.y);
                    
                    // Configuração de estado interno do objeto bumerangue
                    _boomerang.state = "going"; 
                    _boomerang.return_target = obj_player; // Define quem ele persegue na volta
                }
            }
        }
        // Limpeza de memória obrigatória da Fila de Prioridade
        ds_priority_destroy(_priority_queue);
    }
}

#endregion