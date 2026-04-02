// ============================================================================
// 7. FUNÇÃO DE SPAWN DE MONSTROS (Filhos Reais com Scaling)
// ============================================================================
function gerar_monstros_para_bloco(bx, by, bioma_atual, dist_minima) 
{
    var _bloco_id = "monstros_" + string(bx) + "," + string(by);
    if (ds_map_exists(global.blocos_gerados, _bloco_id)) return;
    ds_map_add(global.blocos_gerados, _bloco_id, true);

    var _centro_x = (bx + 0.5) * global.tamanho_bloco;
    var _centro_y = (by + 0.5) * global.tamanho_bloco;

    // =================================================================
    // O SISTEMA DE LEVELING (Anéis de Distância)
    // =================================================================
    var _distancia_da_origem = point_distance(0, 0, _centro_x, _centro_y);
    var _distancia_por_level = 8000; 
    var _level_da_area = 1 + floor(_distancia_da_origem / _distancia_por_level);

    // =================================================================
    // CATÁLOGO DE OBJETOS INIMIGOS POR BIOMA (O "Pool")
    // =================================================================
    var _qtd_base = 0;
    var _obj_monstro = noone; // Agora guarda o OBJETO real, e não o sprite!
    
    switch (bioma_atual) 
    {
        case "floresta":
            _qtd_base = irandom_range(3, 6);
            // Escolhe entre os objetos filhos do par_inimigos específicos daqui
            _obj_monstro = choose(obj_amoeba, obj_amoeba_azul); 
            break;
            
        case "cidade":
            _qtd_base = irandom_range(5, 10);
            _obj_monstro = choose(obj_amoeba_laranja, obj_amoeba_rosa);
            break;
            
        case "floresta_negra":
            _qtd_base = irandom_range(8, 15);
            _obj_monstro = choose(obj_esqueleto, obj_inimigo_fantasma);
            break;
            
        case "vazia":
            _qtd_base = irandom_range(1, 3);
            _obj_monstro = obj_esqueleto; // Na área vazia podemos pôr só os mais chatos
            break;
    }

    // Se não tiver objeto configurado para o bioma, cancela a geração
    if (_obj_monstro == noone) return;

    // =================================================================
    // APLICAÇÃO DO LEVEL E STATUS
    // =================================================================
    var _quantidade_final = _qtd_base + floor(_level_da_area / 2);
    var _escala_monstro = 1 + (_level_da_area * 0.15); 
    
    var _hp_calculado = 50 * _level_da_area;
    var _dano_calculado = 5 * _level_da_area;

    // =================================================================
    // LOOP DE GERAÇÃO FÍSICA
    // =================================================================
    var _gerados = 0;
    var _tentativas = 0;
    var _max_tentativas = _quantidade_final * 3;

    while (_gerados < _quantidade_final && _tentativas < _max_tentativas) 
    {
        var _pos_x = _centro_x + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);
        var _pos_y = _centro_y + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);
        var _posicao_valida = true;

        var _total_estruturas = ds_list_size(global.posicoes_estruturas);
        for (var j = 0; j < _total_estruturas; j++) {
            var _info = global.posicoes_estruturas[| j];
            if (point_distance(_pos_x, _pos_y, _info[0], _info[1]) < dist_minima) {
                _posicao_valida = false; break;
            }
        }

        if (_posicao_valida) 
        {
            randomize();
            var _seed = random_get_seed();

            // =====================================================
            // CRIAÇÃO DO OBJETO FILHO DIRETO
            // =====================================================
            // Passamos _obj_monstro na criação. Como ele já tem a sprite dele,
            // não precisamos mais forçar o sprite_index!
            var _novo_monstro = instance_create_depth(_pos_x, _pos_y, 0, _obj_monstro, { 
                seed: _seed,
                level: _level_da_area,
                hp_maximo: _hp_calculado,
                dano_base: _dano_calculado
            });

            _novo_monstro.image_xscale = _escala_monstro;
            _novo_monstro.image_yscale = _escala_monstro;

            // Salva o objeto (_obj_monstro) na memória, para ele dar o load no filho exato depois!
            ds_list_add(global.posicoes_monstros, [_pos_x, _pos_y, _seed, _obj_monstro, _level_da_area, _escala_monstro]);

            instance_deactivate_object(_novo_monstro);
            _gerados++;
        }
        _tentativas++;
    }
}
// ===========================================================================
// SCRIPT: scr_wave_manager
// DESC: Gerencia ondas de inimigos baseadas no tempo noturno.
// ===========================================================================

/// @function init_night_waves()
/// @description Inicializa a estrutura de dados para as ondas noturnas.
/// Chamar no CREATE do controlador.
function init_night_waves() {
    // NÃO PRECISAMOS MAIS DE global.wave_timer. Usaremos global.timer.

    // Variáveis de Controle
    global.current_wave_idx = -1; // Índice da onda atual
    global.next_wave_idx = 0;     // Índice da próxima onda a ser checada
    global.night_started = false; // Flag para detectar o início da noite
    
    // Array de timers para controlar spawns individuais da onda atual
    global.wave_spawn_timers = []; 

    // LISTA DE ONDAS (Tempos em MINUTOS DO JOGO)
    // Estrutura: [MinutoInicio, [ListaDeInimigos]]
    // ListaDeInimigos: [[Obj, MultiplicadorHP, Escala, IntervaloSpawnSegundos]]
    global.night_waves = [
        // --- ONDA 0 (Começa no minuto 0 do jogo) ---
        [3, [ 
            [obj_esqueleto, global.level_player, 0.12, 0.1], // Spawna a cada 2 segundos
            [obj_amoeba_azul, global.level_player * 1.5, 2.0, 3.5] // Spawna a cada 3.5 segundos
        ]],
        
        // --- ONDA 1 (Começa no minuto 1 do jogo) ---
        [4, [
            [obj_amoeba_laranja, global.level_player * 2.0, 1.2, 1.5]
        ]],

        // --- ONDA 2 (Começa no minuto 3 do jogo) ---
        [5, [
             [obj_amoeba_azul, global.level_player * 3, 1.5, 1.0],
             [obj_amoeba_laranja, global.level_player * 1, 1.0, 2.5]
        ]],
		 [6, [
             [obj_amoeba, global.level_player * 3, 3, 0.5],
            
        ]]
    ];
}

/// @function process_night_waves()
/// @description Verifica o tempo e spawna inimigos conforme a onda atual.
/// Chamar no STEP do controlador.
function process_night_waves() {
    var _cycle = global.day_night_cycle;
    var _is_night = !_cycle.is_day;
    
    // 1. Detectar Início/Fim da Noite
    if (_is_night && !global.night_started) {
        // A noite começou
        global.night_started = true;
        global.current_wave_idx = -1;
        // Encontra qual é a primeira onda que deve rodar (caso o jogo tenha carregado no meio da noite)
        global.next_wave_idx = 0;
        while(global.next_wave_idx < array_length(global.night_waves) && global.night_waves[global.next_wave_idx][0] * 60 <= global.timer) {
             global.next_wave_idx++;
        }
        // Se já passou de alguma onda, define a anterior como atual
        if (global.next_wave_idx > 0) {
             // Força a entrada na onda correta abaixo
             global.next_wave_idx--; 
        }

        global.wave_spawn_timers = [];
        show_debug_message("NOITE COMEÇOU! Timer: " + string(global.timer));
    } 
    else if (!_is_night && global.night_started) {
        // O dia amanheceu
        global.night_started = false;
        global.current_wave_idx = -1;
        global.next_wave_idx = 0; // Reseta para a primeira onda na próxima noite
        global.wave_spawn_timers = [];
        show_debug_message("DIA AMANHECEU!");
        return;
    }
    
    if (!global.night_started) return; // Se é dia, sai.

    // 2. Verificar Troca de Onda (Baseado em global.timer)
    var _total_waves = array_length(global.night_waves);
    
    // Enquanto houver uma próxima onda e o tempo atual já tiver passado do tempo de início dela
    while (global.next_wave_idx < _total_waves) {
        var _start_time_minutes = global.night_waves[global.next_wave_idx][0];
        var _start_time_seconds = _start_time_minutes * 60; // Converte para segundos
        
        if (global.timer >= _start_time_seconds) {
            // Trocando para a nova onda
            global.current_wave_idx = global.next_wave_idx;
            global.next_wave_idx++; // Aponta para a próxima
            
            show_debug_message("ONDA " + string(global.current_wave_idx) + " INICIADA NO TEMPO: " + string(global.timer));
            
            // --- Inicializa timers da nova onda ---
            var _enemies_list = global.night_waves[global.current_wave_idx][1];
            var _num_enemies = array_length(_enemies_list);
            
            // Recria o array de timers com o tamanho certo
            global.wave_spawn_timers = array_create(_num_enemies, 0);
            
            // Spawn inicial imediato e definição dos primeiros timers
            for (var i = 0; i < _num_enemies; i++) {
                 // Define o próximo spawn para: Agora + Intervalo (em segundos)
                 // Usamos o tempo exato do timer para precisão
                 global.wave_spawn_timers[i] = global.timer + _enemies_list[i][3];
                 
                 spawn_night_enemy(_enemies_list[i]);
            }
        } else {
            // Se ainda não chegou a hora da próxima onda, sai do loop de verificação
            break; 
        }
    }

    // 3. Executar Spawn da Onda Atual (Controlado por tempo real)
    if (global.current_wave_idx >= 0) {
        var _current_enemies = global.night_waves[global.current_wave_idx][1];
        var _num_enemies = array_length(_current_enemies);
        
        // Loop por cada tipo de inimigo na onda atual
        for (var i = 0; i < _num_enemies; i++) {
            // Verifica se o tempo atual (global.timer) alcançou o tempo agendado para este spawn
            if (global.timer >= global.wave_spawn_timers[i]) {
                var _enemy_data = _current_enemies[i];
                
                spawn_night_enemy(_enemy_data);
                
                // Agenda o próximo spawn
                var _spawn_interval_seconds = _enemy_data[3];
                // Adiciona uma pequena variação de +/- 10% no tempo para não ficar robótico
                var _variance = _spawn_interval_seconds * 0.1; 
                var _next_spawn_time = global.timer + _spawn_interval_seconds + random_range(-_variance, _variance);
                
                global.wave_spawn_timers[i] = _next_spawn_time;
            }
        }
    }
}
/// @function spawn_night_enemy(enemy_data)
// O argumento agora representa os dados de UM inimigo da lista, não da onda inteira.
function spawn_night_enemy(_enemy_data) {
    // Extrai dados (os índices continuam os mesmos dentro do sub-array)
    var _obj_to_spawn = _enemy_data[0];
    var _hp_multiplier = _enemy_data[1];
    var _scale = _enemy_data[2];
    // O índice 3 (timer) não é usado aqui, só no gerenciador
    
    // Lógica de Posição (mesma de antes) ...
    var _enemy_id = global.enemy_id_counter++;
    var _side = irandom(1);
    var _xx, _yy;
    // ... (código de posição igual) ...
     if (_side == 0) {
        _xx = irandom_range(global.cmx, global.cmx + global.cmw);
        _yy = choose(global.cmy - 64, global.cmy + global.cmh + 64); // Aumentei a margem para 64
    } else {
        _xx = choose(global.cmx - 64, global.cmx + global.cmw + 64);
        _yy = irandom_range(global.cmy, global.cmy + global.cmh);
    }

    // 1. CRIA A INSTÂNCIA PRIMEIRO
    // Ao criar, o evento CREATE do inimigo roda e define sua 'vida' base.
    var _novo_inimigo = instance_create_layer(_xx, _yy, "instances", _obj_to_spawn);
    
    // 2. AGORA MODIFICA A INSTÂNCIA CRIADA
    with (_novo_inimigo) {
        // A variável 'vida' já tem o valor padrão do Create do objeto.
        // Agora aplicamos o multiplicador da onda.
        vida = vida * _hp_multiplier;
        max_vida = vida; // Atualiza o max_vida também
        
        // Resto das configurações (igual antes)
        escala = _scale; 
        dist_aggro = 2000;
        dist_desaggro = 2000;
        id_inimigo = _enemy_id;
        
        image_xscale = escala;
        image_yscale = escala;
    }

    // Adiciona à lista global
    ds_list_add(global.enemy_list, _enemy_id);
}