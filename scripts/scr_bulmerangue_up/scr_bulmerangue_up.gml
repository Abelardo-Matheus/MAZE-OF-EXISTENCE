/// @desc Calcula os atributos do 'Bumerangue' baseado no nível
/// [O QUE]: Define o status base do bumerangue (dano, perfuração, retorno) e aplica upgrades.
/// [COMO] : Itera níveis anteriores aplicando multiplicadores.
function scr_boomerang_calculate_stats(_level) 
{
    var _stats = {
        quantity: 1,            // Quantidade de bumerangues
        damage: 15,             // Dano base
        cooldown: 5000,         // Tempo de recarga (ms)
        speed: 10,               // Velocidade
        size: 2,                // Escala
        knockback: 0,           // Empurrão
        pierce_count: 1,        // Inimigos atravessados antes de voltar
		range: 200
    };

    for (var i = 1; i <= _level; i++) 
    {
        switch (i % 8) 
        {
            case 1: // Pierce (+10)
                _stats.pierce_count += 1;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 3] = "ATRAVESSA MAIS 10 INIMIGOS";
                break;
            case 2: // Speed (+5%)
                _stats.speed *= 1.05;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 3] = "VELOCIDADE AUMENTADA EM 5%";
                break;
            case 3: // Cooldown (-5%)
                _stats.cooldown *= 0.95;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 3] = "RECARGA REDUZIDA EM 5%";
                break;
            case 4: // Damage (+10%)
                _stats.damage *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 3] = "DANO AUMENTADO EM 10%";
                break;
            case 5: // Knockback (+0.01)
                _stats.knockback += 0.01;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 3] = "EMPURRA INIMIGOS";
                break;
            case 6: // Quantity (+1)
                _stats.quantity += 1;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 3] = "MAIS UM BUMERANGUE";
                break;
			case 7: // RAnge ++
                _stats.range += 100;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 3] = "RANGE MAIOR";
                break;
            // case 0: (Nível 7, 14...) Pode adicionar algo aqui se quiser
        }
    }

    return _stats;
}
/// @desc Executa a lógica do 'Bumerangue' (Arremesso)
function scr_bumerangue() 
{
    // 1. Obter Stats
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, 3]; 
    var _stats = scr_boomerang_calculate_stats(_current_level); 

    // 2. Timer
    if (!variable_global_exists("boomerang_timer")) global.boomerang_timer = 0;
    
    global.boomerang_timer += delta_time / 1000;

    // 3. Disparo
    if (global.boomerang_timer >= _stats.cooldown) 
    {
        global.boomerang_timer = 0;

        // --- Busca de Alvos ---
        var _priority_queue = ds_priority_create();
        
        // Coleta inimigos dentro do alcance definido nos stats
        with (par_inimigos) 
        {
            var _dist = point_distance(x, y, obj_player.x, obj_player.y);
            // Usa o _stats.range para definir quem pode ser alvo
            if (_dist <= _stats.range) 
            {
                ds_priority_add(_priority_queue, id, _dist);
            }
        }

        // Se tiver inimigos, lança
        if (!ds_priority_empty(_priority_queue)) 
        {
            var _amount_to_throw = min(_stats.quantity, ds_priority_size(_priority_queue));

            for (var i = 0; i < _amount_to_throw; i++) 
            {
                var _target_id = ds_priority_delete_min(_priority_queue);

                if (instance_exists(_target_id)) 
                {
                    var _boomerang = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_bumerangue);
                    
                    // --- Configuração de Status ---
                    _boomerang.damage = _stats.damage;
                    _boomerang.move_speed = _stats.speed;
                    _boomerang.pierce_max = _stats.pierce_count;
                    _boomerang.push_force = _stats.knockback;
                    
                    // Escala Visual
                    _boomerang.image_xscale = _stats.size;
                    _boomerang.image_yscale = _stats.size;

                    // --- CORREÇÃO DE ALCANCE (RANGE) ---
                    // Calculamos quantos frames ele precisa viajar para atingir o range máximo.
                    // Tempo = Distância / Velocidade
                    // Adicionamos +10 frames de "folga" para ele passar um pouco do alvo
                    _boomerang.timer_going = (_stats.range / _stats.speed) + 10;

                    // --- Mira ---
                    _boomerang.target_x = _target_id.x;
                    _boomerang.target_y = _target_id.y;
                    _boomerang.direction = point_direction(obj_player.x, obj_player.y, _target_id.x, _target_id.y);
                    
                    // Estado inicial
                    _boomerang.state = "going"; 
                    _boomerang.return_target = obj_player;
                }
            }
        }
        ds_priority_destroy(_priority_queue);
    }
}