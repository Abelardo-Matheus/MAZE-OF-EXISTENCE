/// @desc Calcula atributos da 'Shuriken' (Orbital)
/// [O QUE]: Define quantidade, velocidade de rotação, raio da órbita e duração.
/// [COMO] : Itera níveis aplicando somas e multiplicadores.
function scr_shuriken_calculate_stats(_level) 
{
    // Status Base
    var _stats = {
        quantity: 1,            // Quantidade de projéteis
        rotation_speed: 3,      // Velocidade angular (graus por frame)
        size: 1.2,              // Escala visual
        orbit_radius: 100,      // Distância do player
        duration: 2000,         // Tempo ativo (ms)
        damage: 10,             // Dano
        knockback: 0,           // Empurrão
        cooldown: 3000          // Tempo de espera (ms)
    };

    // Modificadores de Nível
    for (var i = 1; i <= _level; i++) 
    {
        switch (i % 7) 
        {
            case 1: // Quantidade (+1)
                _stats.quantity = min(_stats.quantity + 1, 10);
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 2] = "MAIS UMA SHURIKEN GIRANDO";
                break;

            case 2: // Velocidade (+0.5)
                _stats.rotation_speed += 0.5;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 2] = "ROTAÇÃO MAIS RÁPIDA";
                break;

            case 3: // Tamanho (+0.2)
                _stats.size += 0.2;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 2] = "SHURIKEN GIGANTE";
                break;

            case 4: // Raio (+20px)
                _stats.orbit_radius += 20;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 2] = "ÓRBITA MAIOR";
                break;

            case 5: // Duração (+500ms)
                _stats.duration += 500;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 2] = "DURAÇÃO AUMENTADA";
                break;
            
            case 6: // Knockback (+0.1)
                _stats.knockback += 0.1;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 2] = "EMPURRA INIMIGOS";
                break;

            case 0: // Dano (+2)
                _stats.damage += 2;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 2] = "DANO AUMENTADO";
                break;
        }
    }

    return _stats;
}
/// @desc Gerencia o Spawn das Shurikens Orbitais
/// [O QUE]: Verifica o cooldown e cria as shurikens em posições equidistantes ao redor do player.
/// [COMO] : 
/// 1. Se já existirem shurikens (instance_exists), não faz nada (espera elas sumirem).
/// 2. Se não existirem, incrementa timer.
/// 3. Ao atingir o cooldown, calcula o ângulo de separação (360 / qtd) e cria as instâncias.
function scr_shuriken() 
{
    // 1. Controle de Estado
    // Se ainda tem shuriken girando, não conta cooldown
    if (instance_exists(obj_shuriken)) return;

    // 2. Obter Stats
    // Nota: 2 é o índice da SHURIKEN na grid
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, 2]; 
    var _stats = scr_shuriken_calculate_stats(_current_level); 

    // 3. Timer
    if (!variable_global_exists("shuriken_timer")) global.shuriken_timer = 0;
    
    global.shuriken_timer += delta_time / 1000;

    // 4. Spawn
    if (global.shuriken_timer >= _stats.cooldown) 
    {
        global.shuriken_timer = 0;

        // Loop de Criação
        for (var i = 0; i < _stats.quantity; i++) 
        {
            // Matemática: Divide 360 graus pela quantidade para espalhar igualmente
            // Ex: 2 shurikens = 0 e 180 graus. 3 shurikens = 0, 120, 240.
            var _start_angle = i * (360 / _stats.quantity); 
            
            var _shuriken = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_shuriken);
            
            // Passagem de Parâmetros
            _shuriken.current_angle = _start_angle; // Ângulo individual
            _shuriken.rotation_speed = _stats.rotation_speed;
            _shuriken.orbit_radius = _stats.orbit_radius;
            _shuriken.damage = _stats.damage;
            _shuriken.push_force = _stats.knockback;
            
            // Controle de Tempo de Vida
            _shuriken.duration = _stats.duration;   // Tempo total (ms)
            _shuriken.life_timer = 0;               // Cronômetro (ms)
            
            // Visual
            _shuriken.image_xscale = _stats.size;
            _shuriken.image_yscale = _stats.size;
        }
    }
}