/// @desc Calcula atributos do 'Raio' (Lightning Strike)
/// [O QUE]: Define o dano, área de impacto, quantidade e cooldown.
/// [COMO] : Aplica multiplicadores baseados no nível.
function scr_lightning_calculate_stats(_level) 
{
    var _stats = {
        damage: 20,             // Dano direto
        radius: 120,            // Área de efeito (AoE)
        push_force: 3,          // Empurrão
        duration: 0.5,          // Duração visual
        cooldown: 4000,         // Tempo entre raios (ms)
        quantity: 1             // NOVO: Quantidade de raios por ativação
    };

    for (var i = 1; i <= _level; i++) 
    {
        switch (i % 6) 
        {
            case 1: // Dano (+10%)
                _stats.damage *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "AUMENTO DE 10% DE DANO";
                break;
            case 2: // Raio (+10%)
                _stats.radius *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "ÁREA DE EFEITO AUMENTADA";
                break;
            case 3: // Push (+5%)
                _stats.push_force *= 1.05;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "EMPURRÃO AUMENTADO";
                break;
            case 4: // Cooldown (-15%)
                _stats.cooldown *= 0.85;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "RECARGA MAIS RÁPIDA";
                break;
            case 5: // Quantidade (+1 Raio) - ALTERADO AQUI
                _stats.quantity += 1;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "CAI MAIS UM RAIO";
                break;
            case 0: // Dano Extra (+15%)
                _stats.damage *= 1.15;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "AUMENTO DE 15% DE DANO";
                break;
        }
    }

    return _stats;
}
/// @desc Executa a lógica do 'Raio' (Ataque Orbital Múltiplo)
/// [O QUE]: Seleciona inimigos aleatórios na tela e invoca raios neles.
/// [COMO] : Coleta inimigos na tela, embaralha a lista e itera X vezes (baseado na quantidade).
function scr_raio() 
{
    // 1. Obter Stats
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, 6]; 
    var _stats = scr_lightning_calculate_stats(_current_level); 

    // 2. Timer
    if (!variable_global_exists("lightning_timer")) global.lightning_timer = 0;
    
    global.lightning_timer += delta_time / 1000;

    // 3. Disparo
    if (global.lightning_timer >= _stats.cooldown) 
    {
        global.lightning_timer = 0;

        // --- Seleção de Alvo ---
        var _targets_list = ds_list_create();

        // Pega apenas inimigos visíveis na tela
        var _cam_x = camera_get_view_x(view_camera[0]);
        var _cam_y = camera_get_view_y(view_camera[0]);
        var _cam_w = camera_get_view_width(view_camera[0]);
        var _cam_h = camera_get_view_height(view_camera[0]);

        with (par_inimigos) 
        {
            if (x > _cam_x - 50 && x < _cam_x + _cam_w + 50 && 
                y > _cam_y - 50 && y < _cam_y + _cam_h + 50)
            {
                ds_list_add(_targets_list, id);
            }
        }

        var _total_targets = ds_list_size(_targets_list);

        // Se houver alvos válidos
        if (_total_targets > 0) 
        {
            // Embaralha a lista para que os raios caiam em inimigos variados
            ds_list_shuffle(_targets_list);

            // Loop pela Quantidade de Raios
            for (var i = 0; i < _stats.quantity; i++)
            {
                // O operador '%' (módulo) garante que se tivermos mais raios que inimigos,
                // a lista recomeça do zero (hit kill no mesmo inimigo várias vezes)
                var _target_enemy = _targets_list[| i % _total_targets];

                if (instance_exists(_target_enemy)) 
                {
                    // Cria o Objeto Raio
                    var _lightning = instance_create_layer(_target_enemy.x, _target_enemy.y, "Instances", obj_raio);
                    
                    // Passa os stats
                    _lightning.damage = _stats.damage;
                    _lightning.radius = _stats.radius;
                    _lightning.push_force = _stats.push_force;
                    _lightning.duration = _stats.duration;
                    
                    // Opcional: Adicionar um pequeno offset aleatório para não cair tudo no mesmo pixel exato
                    _lightning.x += irandom_range(-10, 10);
                    _lightning.y += irandom_range(-10, 10);
                }
            }
        }
        
        // Limpeza de memória
        ds_list_destroy(_targets_list);
    }
}