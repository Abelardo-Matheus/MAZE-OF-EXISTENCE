// ==============================================================================
// REGIÃO 1: CONFIGURAÇÃO (DADOS E VETOR DE NÍVEIS)
// ==============================================================================
#region CONFIGURAÇÃO

/// @desc Retorna a estrutura de dados (Vetor de Skill) da EXPLOSÃO (Aura)
function scr_explosion_config()
{
    return {
		
        // --- Status Base (Nível 0 - Antes da primeira coleta) ---
        // Usamos os nomes exatos definidos na macro DEFAULT_SKILL_STATS
        stats_base: {
            damage: 15,             // Dano base
			sprite_icon: spr_confete_icon,
            radius: 100,            // Raio base (pixels)
            push_force: 5,          // Força de Knockback (5-8 é um bom valor inicial)
            duration: 0.5,          // Duração visual (segundos do VFX)
            cooldown: 3000          // Tempo entre explosões (ms)
        },

        // --- Definição Nível a Nível (Data-Driven) ---
        // Índice 0 na array = Upgrade que leva a skill para o Nível 1, etc.
        niveis: [
            // Nível 1
            { 
                desc: "GERA UMA ONDA DE CHOQUE PERIÓDICA AO REDOR DO JOGADOR.", // Descrição inicial
                upgrade: function(_s) { 
                    // Nível 1 apenas ativa a skill com os status base, não precisa bônus extra
                } 
            },
            // Nível 2
            { 
                desc: "AUMENTO DE 10% DE DANO", 
                upgrade: function(_s) { _s.damage *= 1.10; } 
            },
            // Nível 3
            { 
                desc: "RAIO AUMENTADO EM 10%", 
                upgrade: function(_s) { _s.radius *= 1.10; } 
            },
            // Nível 4
            { 
                desc: "EMPURRÃO AUMENTADO EM 8%", 
                upgrade: function(_s) { _s.push_force *= 1.08; } 
            },
            // Nível 5
            { 
                desc: "COOLDOWN REDUZIDO EM 15%", 
                upgrade: function(_s) { _s.cooldown *= 0.85; } 
            },
            // Nível 6
            { 
                desc: "DURAÇÃO DO EFEITO E DANO AUMENTADOS", 
                upgrade: function(_s) { _s.duration *= 1.10; _s.damage *= 1.15; } 
            }
        ]
    };
}

#endregion

// ==============================================================================
// REGIÃO 2: EXECUÇÃO (LÓGICA E DISPARO)
// ==============================================================================
#region EXECUÇÃO

/// @desc Executa a lógica da 'Explosão' (Aura de Dano Periódico)
/// @param _row_index O índice da linha desta skill na grid (recebido do controle)
function scr_explosao(_row_index) 
{
    // Sistema de Pausa (centralizado no Step do Player)
    if (global.level_up) exit; 

    // Obtém o nível atual corretamente baseado na linha recebida
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, _row_index];
    
    // Se nível 0, não faz nada (segurança)
    if (_current_level <= 0) exit;

    // ========================================================
    // --- 1. UNIFICAÇÃO: Obter Dados e Calcular Stats Finais ---
    // ========================================================
    var _config = scr_explosion_config(); // Carrega os dados puro (Região 1)
    
    // Chama a calculadora genérica universal (Passando referências corretas da grid e colunas)
    // Nota: Certifique-se de que a função 'scr_generic_calculate_stats' já foi criada.
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, Upgrades_vamp.description);

    // ========================================================
    // --- 2. LÓGICA DO TIMER (Sua lógica Delta_Time permanece aqui) ---
    // ========================================================
    if (!variable_global_exists("explosion_timer")) global.explosion_timer = 0;
    
    // delta_time é em microsegundos. Dividir por 1000 converte para milissegundos.
    global.explosion_timer += delta_time / 1000; 

    // Ativação
    if (global.explosion_timer >= _stats.cooldown) 
    {
        global.explosion_timer = 0; 

        // ========================================================
        // --- 3. SUA LÓGICA ÚNICA DE DANO EM ÁREA (Fica aqui!) ---
        // ========================================================
        // SUBSTÍTUA 'obj_player' PELO NOME DO SEU OBJETO JOGADOR
        if (!instance_exists(obj_player)) exit; 
        
        var _player_x = obj_player.x;
        var _player_y = obj_player.y;

        // Itera por todos os inimigos (SUBSTÍTUA 'par_inimigos' SEU OBJETO PAI)
        with (par_inimigos) 
        {
            var _dist = point_distance(_player_x, _player_y, x, y);
            
            // Verifica se está dentro do raio calculado universalmente
            if (_dist <= _stats.radius) 
            {
                // Aplica Dano
                // (Assumindo que seus inimigos têm as variáveis 'vida', 'max_vida', 'hit', etc.)
                vida -= _stats.damage;
                
                // Aplica Knockback (Afastando do player)
                var _knock_dir = point_direction(_player_x, _player_y, x, y);
                empurrar_dir = _knock_dir;
                empurrar_veloc = _stats.push_force; // Usa o push_force calculado
                
                // Estados e Feedback do Inimigo (SUBSTÍTUA PELOS SEUS SCRIPTS/ALARMES)
                state = scr_inimigo_hit; // Script de estado de hit do inimigo
                alarm[1] = 5;           // Alarme para sair do hit (se usar esse padrão)
                hit = true;              // Flag de hit

                // Pop-up de Dano
                // SUBSTÍTUA 'obj_dano' PELO NOME DO SEU OBJETO DE TEXTO DE DANO
                var _txt = instance_create_layer(x, y, "Instances", obj_dano);
                _txt.alvo = id; // Passa o ID do inimigo
                _txt.dano = _stats.damage; // Passa o dano
            }
        }

        // --- Efeito Visual (VFX) ---
        // Cria o objeto visual da explosão (SUBSTÍTUA 'obj_confete' PELO SEU OBJETO)
        var _vfx = instance_create_layer(_player_x, _player_y, "Instances", obj_confete);
        
        // Ajusta escala baseada no raio calculado universalmente
        // Exemplo: Se o sprite original tem 64px de raio, escala = (radius / 64)
        // Você usou radius*3 / 64, mantenho esse padrão aqui, ajustando pela escala base se usar.
        var _base_sprite_size = sprite_get_width(_vfx.sprite_index) / 2; // Pega o raio do sprite original
        if (_base_sprite_size <= 0) _base_sprite_size = 32; // Segurança se não tiver sprite
        
        var _scale = _stats.radius / _base_sprite_size; 
        
        // Se usar o sistema de escala base que você tem (_vfx.escala_base)
        if (variable_instance_exists(_vfx, "escala_base")) {
            _scale *= _vfx.escala_base;
        }

        _vfx.image_xscale = _scale;
        _vfx.image_yscale = _scale;
        
        // Passa parâmetros de duração para o objeto visual se destruir
        _vfx.duration = _stats.duration; // Duração em segundos
        
        // Se você quer que a explosão ande com o player
        if (variable_instance_exists(_vfx, "follow_player")) {
            _vfx.follow_player = true; 
        }
    }
}

#endregion