// ==============================================================================
// REGIÃO 1: CONFIGURAÇÃO (DADOS E VETOR DE NÍVEIS) - Antigo scr_feather_calculate_stats
// ==============================================================================
#region CONFIGURAÇÃO

/// @desc Retorna a estrutura de dados (Vetor de Item) da PENA (Passivo)
function scr_feather_config()
{
    return {
		
        // --- Status Base (Nível 0) ---
        // Para passivos simples, definimos apenas as variáveis que mudam a cada nível.
        stats_base: {
            speed_gain_percent: 0, // Quanto de bônus ganha EXATAMENTE neste nível (ex: 5 para 5%)
			sprite_icon: spr_pena_icon
        },

        // --- Definição Nível a Nível (Data-Driven) ---
        // Índice 0 na array = Upgrade que leva o item para o Nível 1, etc.
        // Baseado na sua lógica switch original (5, 5, 10, 10, 15 %).
        niveis: [
            // Nível 1 (Upgrade para Lvl 1)
            { 
                desc: "DEIXA O JOGADOR MAIS RÁPIDO (+5% Velocidade).", // Descrição para UI
                upgrade: function(_s) { _s.speed_gain_percent = 5; } // Define o ganho DESTE nível
            },
            // Nível 2
            { 
                desc: "VELOCIDADE AUMENTADA EM MAIS 5%.", 
                upgrade: function(_s) { _s.speed_gain_percent = 5; } 
            },
            // Nível 3
            { 
                desc: "VELOCIDADE AUMENTADA EM MAIS 10%.", 
                upgrade: function(_s) { _s.speed_gain_percent = 10; } 
            },
            // Nível 4
            { 
                desc: "VELOCIDADE AUMENTADA EM MAIS 10%.", 
                upgrade: function(_s) { _s.speed_gain_percent = 10; } 
            },
            // Nível 5
            { 
                desc: "MEGA UPGRADE: VELOCIDADE AUMENTADA EM MAIS 15%.", 
                upgrade: function(_s) { _s.speed_gain_percent = 15; } 
            }
        ]
    };
}

#endregion

// ==============================================================================
// REGIÃO 2: EXECUÇÃO (APLICAÇÃO DO BÔNUS ONE-TIME) - Antigo scr_pena
// ==============================================================================
#region EXECUÇÃO

/// @desc Lógica da 'Pena' (Aplica bônus permanente MULTIPLICATIVO ao subir de nível)
/// [COMO] : 
/// 1. Verifica se houve level up usando variável de controle dinâmica.
/// 2. Se sim, calcula o bônus do nível ATUAL e multiplica a velocidade global do player.
/// 3. Atualiza a descrição na grid de UI via calculadora genérica.
/// @param _row_index O índice da linha deste item na grid de PASSIVOS (recebido do controle)
function scr_pena(_row_index) 
{
    // Sistema de Pausa (centralizado no Step do Player, itens passivos também respeitam)
    if (global.level_up) exit;

    // 1. Obter Nível Atual (Nota: Usamos a grid de ITENS PASSIVOS global.itens_vamp_grid)
    var _current_level = global.itens_vamp_grid[# Itens_vamp.level, _row_index]; 

    // Se nível 0, não faz nada (segurança)
    if (_current_level <= 0) exit;

    // ========================================================
    // --- 2. UNIFICAÇÃO: Inicialização Segura da Variável de Controle ---
    // ========================================================
    // Criamos um nome dinâmico para a variável global de controle baseada no índice da linha.
    // Ex: Se a Pena estiver na linha 0, cria "passive_last_applied_0". FIM DO BUG HARDCODE.
    var _control_var_name = "passive_last_applied_" + string(_row_index);
    if (!variable_global_exists(_control_var_name)) 
    {
        // Se não existe, cria inicializando com 0 (nível 0 aplicado)
        variable_global_set(_control_var_name, 0);
    }
    
    // Pega o último nível que foi realmente aplicado ao player
    var _last_applied_level = variable_global_get(_control_var_name);

    // ========================================================
    // --- 3. CHECAGEM DE LEVEL UP E APLICAÇÃO ---
    // ========================================================
    // Só entra aqui UMA VEZ por level up do item
    if (_last_applied_level < _current_level) 
    {
        // A. Carrega os Dados puro do item (Região 1)
        var _config = scr_feather_config(); 

        // B. Chama a calculadora genérica específica para upgrades passivos 'one-time'
        // Ela calcula o bônus do nível ATUAL e já atualiza a descrição na grid correta.
        // Nota: Certifique-se de que 'scr_generic_calculate_passive_upgrade' já foi criada.
        var _upgrade_stats = scr_generic_calculate_passive_upgrade(_config, _current_level, global.itens_vamp_grid, _row_index, Itens_vamp.description);

        // ========================================================
        // --- 4. SUA LÓGICA ÚNICA DE APLICAÇÃO (Fica aqui!) ---
        // ========================================================
        // Aplica o Bônus PERMANENTE e MULTIPLICATIVO à velocidade global do player
        if (_upgrade_stats.speed_gain_percent > 0) {
            // Converte porcentagem (ex: 5) em multiplicador (ex: 1.05)
            var _multiplier = 1 + (_upgrade_stats.speed_gain_percent / 100);
            
            // Multiplica a velocidade global atual (efeito acumulativo multiplicativo)
            global.speed_player *= _multiplier;
            
            // Opcional: Efeito sonoro/visual de status up no player
            // audio_play_sound(snd_stat_up, 1, false);
            // instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_vfx_speedup);
        }

        // --- Marca o Nível como Aplicado ---
        // Atualiza a variável global de controle dinâmica para travar este bloco até o próximo level up.
        variable_global_set(_control_var_name, _current_level);
        
        // Debug (Opcional)
        show_debug_message("Pena Upada Lvl "+string(_current_level)+"! Bônus aplicado: "+string(_upgrade_stats.speed_gain_percent)+"%. Nova Velocidade Global: " + string(global.speed_player));
    }
}

#endregion