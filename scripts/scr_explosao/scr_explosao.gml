/// @desc Calcula atributos da 'Explosão' (Aura)
/// [O QUE]: Define o dano, raio e força da explosão ao redor do player.
/// [COMO] : Itera níveis aplicando multiplicadores.
function scr_explosion_calculate_stats(_level) 
{
    // Status Base
    var _stats = {
        damage: 15,             // Dano base
        radius: 100,            // Raio base (pixels)
        push_force: 5,          // Empurrão (Aumentei para 5, 0.5 é muito fraco geralmente)
        duration: 0.5,          // Duração visual (segundos)
        cooldown: 3000          // Tempo entre explosões (ms)
    };

    // Modificadores de Nível
    for (var i = 1; i <= _level; i++) 
    {
        switch (i % 6) 
        {
            case 1: // Dano (+10%)
                _stats.damage *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "AUMENTO DE 10% DE DANO";
                break;
            case 2: // Raio (+10%)
                _stats.radius *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "RAIO AUMENTADO EM 10%";
                break;
            case 3: // Push (+5%)
                _stats.push_force *= 1.08;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "EMPURRÃO AUMENTADO EM 8%";
                break;
            case 4: // Cooldown (-15%)
                _stats.cooldown *= 0.85;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "COOLDOWN REDUZIDO EM 15%";
                break;
            case 5: // Duração Visual (+10%)
                _stats.duration *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "DURAÇÃO DO EFEITO AUMENTADA";
                break;
            case 0: // Dano Extra (+15%)
                _stats.damage *= 1.15;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "AUMENTO DE 15% DE DANO";
                break;
        }
    }

    return _stats;
}
/// @desc Executa a lógica da 'Explosão' (Aura de Dano)
/// [O QUE]: Gera dano em área ao redor do player periodicamente.
/// [COMO] : Controla um timer interno. Quando estoura, busca inimigos no raio, aplica dano/knockback e cria efeito visual.
function scr_explosao() 
{
    // 1. Obter Stats
    // Nota: 1 é o índice da EXPLOSÃO na grid
    var _current_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, 1]; 
    var _stats = scr_explosion_calculate_stats(_current_level); 

    // 2. Timer
    if (!variable_global_exists("explosion_timer")) global.explosion_timer = 0;
    
    global.explosion_timer += delta_time / 1000;

    // 3. Ativação
    if (global.explosion_timer >= _stats.cooldown) 
    {
        global.explosion_timer = 0;

        // --- Dano em Área ---
        var _hit_something = false;

        with (par_inimigos) 
        {
            var _dist = point_distance(obj_player.x, obj_player.y, x, y);
            
            if (_dist <= _stats.radius) 
            {
                // Aplica Dano
                vida -= _stats.damage;
                
                // Aplica Knockback (Afastando do player)
                var _knock_dir = point_direction(obj_player.x, obj_player.y, x, y);
                empurrar_dir = _knock_dir;
                empurrar_veloc = _stats.push_force;
                
                // Estados e Feedback
                state = scr_inimigo_hit;
                alarm[1] = 5;
                hit = true;
                _hit_something = true;

                // Pop-up de Dano
                var _txt = instance_create_layer(x, y, "Instances", obj_dano);
                _txt.alvo = id; // 'id' aqui refere-se ao inimigo dentro do with
                _txt.dano = _stats.damage;
            }
        }

        // --- Efeito Visual ---
        // Cria o objeto visual da explosão e passa os parâmetros
        var _vfx = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_explosion);
        
        // Ajusta escala baseada no raio (assumindo sprite de 64px: radius*2 / 64)
        // Ou ajuste o divisor '50' conforme o tamanho do seu sprite original
        var _scale = _stats.radius*3 / 64; 
        _vfx.image_xscale = _scale;
        _vfx.image_yscale = _scale;
        
        // O objeto visual deve se destruir sozinho após a animação ou tempo
        _vfx.duration = _stats.duration; 
        _vfx.follow_player = true; // Se quiser que a explosão ande com o player
    }
}