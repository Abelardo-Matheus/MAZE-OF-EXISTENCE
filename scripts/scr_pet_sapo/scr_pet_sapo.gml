/// @desc Calcula atributos do 'Sapo' (Pet)
/// [O QUE]: Define dano, velocidade, intervalo de ataque e quantidade de pets.
function scr_frog_calculate_stats(_level) 
{
    var _stats = {
        damage: 10,             // Dano
        move_speed: 3,          // Velocidade de movimento (pixels/frame)
        attack_cooldown: 60,    // Intervalo de ataque (frames)
        orbit_radius: 200,      // Distância que o sapo tenta manter do player
        quantity: 1             // Quantidade de sapos
    };

    var _frog_row_index = 7; // Índice na grid

    for (var i = 1; i <= _level; i++) 
    {
        switch (i % 6) 
        {
            case 1: // Dano (+10%)
                _stats.damage *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _frog_row_index] = "DANO DO PET AUMENTADO EM 10%";
                break;
            case 2: // Velocidade (+10%)
                _stats.move_speed *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _frog_row_index] = "VELOCIDADE DO PET AUMENTADA";
                break;
            case 3: // Cooldown (-10%)
                _stats.attack_cooldown *= 0.90;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _frog_row_index] = "ATAQUE MAIS RÁPIDO";
                break;
            case 4: // Quantidade (+1 Sapo)
                _stats.quantity += 1;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _frog_row_index] = "MAIS UM SAPO";
                break;
            case 5: // Range/Orbit (+12.5%)
                _stats.orbit_radius *= 1.125;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _frog_row_index] = "ALCANCE DE PATRULHA AUMENTADO";
                break;
            case 0: // Dano Extra (+20%)
                _stats.damage *= 1.20;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _frog_row_index] = "DANO DO PET AUMENTADO EM 20%";
                break;
        }
    }
    return _stats;
}
/// @desc Gerencia a matilha de Sapos
/// [O QUE]: Cria novos sapos se necessário e atualiza os status de TODOS os sapos ativos.
/// @desc Gerencia a matilha de Sapos (Criação e Atualização de Status)
function scr_sapo() 
{
    var _frog_row_index = 7;
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, _frog_row_index];
    var _stats = scr_frog_calculate_stats(_current_level); // Usa seu script de config

    // 1. Cria sapos que faltam
    var _current_count = instance_number(obj_sapo_pet);
    var _needed = _stats.quantity - _current_count;

    if (_needed > 0) {
        repeat(_needed) {
            instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_sapo_pet);
        }
    }

    // 2. Atualiza TODOS os sapos (Atributos e Posição na Roda)
    var _index = 0;
    var _total_frogs = instance_number(obj_sapo_pet);

    with (obj_sapo_pet) 
    {
        // Atualiza Status (Isso garante que upgrades de dano funcionem na hora)
        damage = _stats.damage;
        velocidade = _stats.move_speed;
        cooldown_max = _stats.attack_cooldown;
        orbit_radius = _stats.orbit_radius; // Distância do player
        range = _stats.orbit_radius * 1.5; // Range de detecção um pouco maior que a órbita

        // Define o ângulo único deste sapo na formação
        // Ex: 2 sapos = 0 e 180 graus.
        my_angle_offset = (360 / _total_frogs) * _index;
        
        _index++;
    }
}