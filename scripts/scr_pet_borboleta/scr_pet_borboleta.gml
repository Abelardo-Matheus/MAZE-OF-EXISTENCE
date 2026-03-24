/// @desc Calcula atributos da 'Borboleta' (Pet)
/// [O QUE]: Define dano, área, velocidade, quantidade e chance de pólen.
function scr_butterfly_calculate_stats(_level) 
{
    var _stats = {
        damage: 15,             // Dano base da explosão de pólen
        pollen_radius: 64,      // Raio da explosão de pólen (área)
        move_speed: 4,          // Velocidade de voo
        wander_radius: 150,     // Raio máximo que ela se afasta do player
        quantity: 1,            // Quantidade de borboletas
        pollen_chance: 0.05     // Chance por frame de soltar pólen perto de inimigo (5%)
    };

    // ÍNDICE NA GRID (Ajuste se necessário, assumindo que Sapo é 7, Borboleta é 8)
    var _butterfly_row_index = 8; 

    for (var i = 1; i <= _level; i++) 
    {
        // Lógica de progressão (Ciclo de 6 níveis)
        switch (i % 6) 
        {
            case 1: // Dano (+15%)
                _stats.damage *= 1.15;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _butterfly_row_index] = "DANO DO PÓLEN AUMENTADO EM 15%";
                break;
            case 2: // Área (+15%)
                _stats.pollen_radius *= 1.15;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _butterfly_row_index] = "ÁREA DO PÓLEN AUMENTADA";
                break;
            case 3: // Chance (+10% relativo)
                _stats.pollen_chance *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _butterfly_row_index] = "SOLTA PÓLEN MAIS FREQUENTEMENTE";
                break;
            case 4: // Quantidade (+1 Borboleta)
                _stats.quantity += 1;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _butterfly_row_index] = "MAIS UMA BORBOLETA";
                break;
            case 5: // Velocidade e Área de Voo (+10%)
                _stats.move_speed *= 1.10;
                _stats.wander_radius *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _butterfly_row_index] = "BORBOLETA MAIS RÁPIDA E AGRESSIVA";
                break;
            case 0: // Super Upgrade de Dano (+30%)
                _stats.damage *= 1.30;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, _butterfly_row_index] = "DANO DO PÓLEN AUMENTADO EM 30%";
                break;
        }
    }

    // Garante valores inteiros para área (opcional, ajuda na performance)
    _stats.pollen_radius = round(_stats.pollen_radius);
    
    return _stats;
}
/// @desc Gerencia o enxame de Borboletas
/// [O QUE]: Cria novas borboletas se necessário e atualiza os status de TODAS ativas.
function scr_borboleta() 
{
    // ÍNDICE NA GRID
    var _butterfly_row_index = 8;
    
    // Pega o nível atual na grid
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, _butterfly_row_index];
    
    // Se o nível for 0, não faz nada
    if (_current_level <= 0) return;

    // Calcula os stats baseados no nível
    var _stats = scr_butterfly_calculate_stats(_current_level);

    // 1. Cria borboletas que faltam
    var _current_count = instance_number(obj_borboleta_pet);
    var _needed = _stats.quantity - _current_count;

    if (_needed > 0) {
        repeat(_needed) {
            // Cria perto do player com uma variação aleatória
            instance_create_layer(obj_player.x + irandom_range(-20, 20), obj_player.y + irandom_range(-20, 20), "Instances", obj_borboleta_pet);
        }
    }

    // 2. Atualiza TODOS os objetos borboleta ativos
    // Passa os stats calculados para dentro das instâncias
    with (obj_borboleta_pet) 
    {
        damage = _stats.damage;
        velocidade = _stats.move_speed;
        pollen_radius = _stats.pollen_radius;
        wander_radius = _stats.wander_radius;
        pollen_chance = _stats.pollen_chance;
    }
}