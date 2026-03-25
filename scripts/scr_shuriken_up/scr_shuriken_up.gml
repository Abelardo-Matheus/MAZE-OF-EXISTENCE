// ==============================================================================
// REGIÃO 1: CONFIGURAÇÃO (DADOS E VETOR DE NÍVEIS)
// ==============================================================================
#region CONFIGURAÇÃO

/// @desc Retorna a estrutura de dados (Vetor de Skill) da SHURIKEN (Orbital)
function scr_shuriken_config()
{
    return {
		
        // --- Status Base (Nível 0 - Antes da primeira coleta) ---
        // Usamos os nomes exatos definidos na macro DEFAULT_SKILL_STATS
        stats_base: {
            damage: 10,             // Dano base
			sprite_icon: spr_shuriken_icon,
            rotation_speed: 3,      // Velocidade angular (graus por frame)
            size: 1.2,              // Escala visual
            orbit_radius: 100,      // Distância do player
            duration: 2000,         // Tempo ativo (ms)
            knockback: 0,           // Empurrão
            cooldown: 3000,         // Tempo de espera (ms)
            quantity: 0             // Começa com 0 para não spawm antes do Lvl 1
        },

        // --- Definição Nível a Nível (Data-Driven) ---
        // Índice 0 na array = Upgrade que leva a skill para o Nível 1, etc.
        niveis: [
            // Nível 1
            { 
                desc: "GERA UMA SHURIKEN QUE GIRA AO REDOR DO JOGADOR.", // Descrição inicial
                upgrade: function(_s) { 
                    _s.quantity = 1; // Ativa
                } 
            },
            // Nível 2
            { 
                desc: "MAIS UMA SHURIKEN GIRANDO (+1 Qtd)", 
                upgrade: function(_s) { _s.quantity = min(_s.quantity + 1, 10); } 
            },
            // Nível 3
            { 
                desc: "ROTAÇÃO MAIS RÁPIDA (+0.5 Veloc.)", 
                upgrade: function(_s) { _s.rotation_speed += 0.5; } 
            },
            // Nível 4
            { 
                desc: "SHURIKEN GIGANTE (+Tamanho)", 
                upgrade: function(_s) { _s.size += 0.2; } 
            },
            // Nível 5
            { 
                desc: "ÓRBITA MAIOR (+Range)", 
                upgrade: function(_s) { _s.orbit_radius += 20; } 
            },
            // Nível 6
            { 
                desc: "DURAÇÃO AUMENTADA (+500ms)", 
                upgrade: function(_s) { _s.duration += 500; } 
            },
            // Nível 7 (Ciclo de 7 níveis)
            { 
                desc: "DANO E EMPURRÃO AUMENTADOS", 
                upgrade: function(_s) { _s.damage += 2; _s.knockback += 0.1; } 
            }
        ]
    };
}

#endregion

// ==============================================================================
// REGIÃO 2: EXECUÇÃO (LÓGICA E SPAWN)
// ==============================================================================
#region EXECUÇÃO

/// @desc Executa a lógica da 'Shuriken' (Orbital)
/// @param _row_index O índice da linha desta skill na grid (recebido do controle)
function scr_shuriken(_row_index) 
{
    // Sistema de Pausa (centralizado no Step do Player)
    if (global.level_up) exit; 

    // OBTÉM O NÍVEL ATUAL CORRETAMENTE BASEADO NA LINHA RECEBIDA
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, _row_index];
    
    // Se nível 0, não faz nada (segurança)
    if (_current_level <= 0) exit;

    // ========================================================
    // --- NOVO: CONTROLE DE ESTADO (Anti-Spawm) ---
    // ========================================================
    // Se ainda tem shuriken girando, não faz nada (espera elas sumirem).
    // SUBSTÍTUA 'obj_shuriken' PELO NOME DO SEU OBJETO SHURIKEN
    if (instance_exists(obj_shuriken)) exit;


    // ========================================================
    // --- 1. UNIFICAÇÃO: Obter Dados e Calcular Stats Finais ---
    // ========================================================
    var _config = scr_shuriken_config(); // Carrega os dados puro (Região 1)
    
    // Chama a calculadora genérica universal (Passando referências corretas da grid e colunas)
    // Nota: Certifique-se de que a função 'scr_generic_calculate_stats' já foi criada.
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, Upgrades_vamp.description);

    // ========================================================
    // --- 2. LÓGICA DO TIMER (Sua lógica Delta_Time permanece aqui) ---
    // ========================================================
    if (!variable_global_exists("shuriken_timer")) global.shuriken_timer = 0;
    
    // delta_time é em microsegundos. Dividir por 1000 converte para milissegundos.
    global.shuriken_timer += delta_time / 1000; 

    // Ativação (Spawm)
    if (global.shuriken_timer >= _stats.cooldown) 
    {
        global.shuriken_timer = 0; 

        // ========================================================
        // --- 3. SUA LÓGICA ÚNICA DE SPAWN EQUIDISTANTE (Fica aqui!) ---
        // ========================================================
        // SUBSTÍTUA 'obj_player' PELO NOME DO SEU OBJETO JOGADOR
        if (!instance_exists(obj_player)) exit; 
        
        var _player_x = obj_player.x;
        var _player_y = obj_player.y;

        // Loop pela quantidade calculada universalmente
        for (var i = 0; i < _stats.quantity; i++) 
        {
            // Matemática: Divide 360 graus pela quantidade para espalhar igualmente
            // Ex: 2 shurikens = 0 e 180 graus. 3 shurikens = 0, 120, 240.
            var _start_angle = i * (360 / _stats.quantity); 
            
            // Cria o Objeto Shuriken
            var _shuriken = instance_create_layer(_player_x, _player_y, "Instances", obj_shuriken);
            
            // --- Passagem de Parâmetros usa os _stats calculados universalmente ---
            // Certifique-se de que o objeto 'obj_shuriken' tem essas variáveis no Create
            _shuriken.current_angle = _start_angle; // Ângulo individual inicial
            _shuriken.rotation_speed = _stats.rotation_speed; // Velocidade angular
            _shuriken.orbit_radius = _stats.orbit_radius; // Raio da órbita
            _shuriken.damage = _stats.damage; // Dano
            _shuriken.push_force = _stats.knockback; // Knockback
            
            // Controle de Tempo de Vida (Duração)
            _shuriken.duration = _stats.duration; // Tempo total (ms)
            _shuriken.life_timer = 0;             // Cronômetro (ms) - inicia zerado
            
            // Escala Visual
            // Se usar o sistema de escala base que você tem (_shuriken.escala_base)
            var _escala_final = _stats.size;
            if (variable_instance_exists(_shuriken, "escala_base")) {
                _escala_final *= _shuriken.escala_base;
            }
            
            _shuriken.image_xscale = _escala_final;
            _shuriken.image_yscale = _escala_final;
        }
    }
}

#endregion