/// @desc Calcula os atributos da 'Bomba' baseado no nível
/// [O QUE]: Define os status base da bomba (dano, raio, voo) e aplica upgrades progressivos.
/// [COMO] : Itera níveis anteriores aplicando multiplicadores e somas.
function scr_bomb_calculate_stats(_level) 
{
    // --- Status Base ---
    var _stats = {
        bomb_count: 1,              // Quantidade
        damage: 20,                 // Dano
        cooldown: 7000,             // Tempo de recarga (ms)
        radius: 100,                // Raio da explosão
        push_force: 0,              // Empurrão
        splash_multiplier: 0.5,     // Dano na borda
        flight_duration: 1.0        // NOVO: Tempo que a bomba fica no ar (segundos)
    };

    // --- Modificadores de Nível ---
    for (var i = 1; i <= _level; i++) 
    {
        switch (i % 6) 
        {
            case 1: // Dano (+15%)
                _stats.damage *= 1.35;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "DANO DA BOMBA AUMENTADO EM 15%";
                break;

            case 2: // Cooldown (-10%)
                _stats.cooldown *= 0.90;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "TEMPO DE RECARGA REDUZIDO EM 10%";
                break;

            case 3: // Raio (+20px)
                _stats.radius += 20;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "RAIO DA EXPLOSÃO AUMENTADO";
                break;

            case 4: // Quantidade (+1 Bomba)
                _stats.bomb_count += 2;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "LANÇA MAIS UMA BOMBA";
                break;

            case 5: // Knockback (+0.02)
                _stats.push_force += 0.02;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "BOMBA EMPURRA OS INIMIGOS";
                break;

            case 0: // Splash Damage (+5%)
                _stats.splash_multiplier += 0.05;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "DANO EM ÁREA AUMENTADO";
                break;
        }
    }

    return _stats;
}
/// @desc Executa a lógica da 'Bomba' (Arremesso)
/// [O QUE]: Busca inimigos próximos, ordena por distância e arremessa bombas com movimento parabólico.
/// [COMO] : Usa Priority Queue para achar os alvos mais próximos e instancia a bomba passando os parâmetros de voo.
function scr_bomba() 
{
    // 1. Obter Stats
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, 9]; 
    var _stats = scr_bomb_calculate_stats(_current_level); 

    // 2. Timer Global (Cooldown)
    if (!variable_global_exists("bomb_timer")) global.bomb_timer = 0;
    
    global.bomb_timer += delta_time / 1000; // Converte microssegundos para milissegundos

    // 3. Disparo
    if (global.bomb_timer >= _stats.cooldown) 
    {
        global.bomb_timer = 0;

        // --- Busca de Alvos ---
        var _targets_list = ds_list_create();

        // Coleta inimigos dentro do alcance (1000px)
        with (par_inimigos) 
        {
            if (point_distance(x, y, obj_player.x, obj_player.y) <= 1000) 
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
                var _dist = point_distance(obj_player.x, obj_player.y, _enemy.x, _enemy.y);
                // Adiciona na fila: Menor distância = Maior prioridade
                ds_priority_add(_priority_queue, _enemy, _dist);
            }

            // Loop de Arremesso
            var _bombs_to_throw = min(_stats.bomb_count, _total_targets);

            for (var i = 0; i < _bombs_to_throw; i++) 
            {
                // Pega o inimigo mais próximo e remove da fila
                var _target_id = ds_priority_delete_min(_priority_queue);

                if (instance_exists(_target_id)) 
                {
                    var _bomb = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_bomba);
                    
                    // --- Configuração de MOVIMENTO (Crucial!) ---
                    _bomb.start_x = obj_player.x;     // Ponto A
                    _bomb.start_y = obj_player.y;
                    _bomb.target_x = _target_id.x;    // Ponto B
                    _bomb.target_y = _target_id.y;
                    
                    _bomb.flight_duration = _stats.flight_duration; // Tempo total
                    _bomb.flight_timer = 0;           // Timer interno (inicia zerado)
                    _bomb.state = "flying";           // Estado inicial

                    // --- Configuração de STATUS ---
                    _bomb.damage = _stats.damage;
                    _bomb.radius = _stats.radius;
                    _bomb.push_force = _stats.push_force;
                    _bomb.splash_multiplier = _stats.splash_multiplier;
                }
            }
            ds_priority_destroy(_priority_queue);
        }
        ds_list_destroy(_targets_list);
    }
}

