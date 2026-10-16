// feather disable GM2017

/// @desc Retorna a estrutura de dados (Vetor de Skill) das LÂMINAS GIRAS
function scr_laminas_giras_config()
{
    return {
        stats_base: {
            damage: 8,
            cooldown: 2500, // milissegundos
            quantity: 1,
            orbital_speed: 3,
            radius: 80,
            duration: 3333,
            size: 1,
            sprite_icon: spr_laminas_icon
        },
        niveis: [
            { desc: "LÂMINAS ESPIRITUAIS ORBITAM AO REDOR DO JOGADOR.", upgrade: function(_s) { _s.quantity = 1; } },
            { desc: "DANO E VELOCIDADE DE ROTAÇÃO AUMENTADOS.", upgrade: function(_s) { _s.damage += 2; _s.orbital_speed += 1; } },
            { desc: "ADICIONA MAIS 1 LÂMINA.", upgrade: function(_s) { _s.quantity += 1; _s.radius += 5; } },
            { desc: "AUMENTA O DANO E A DURAÇÃO.", upgrade: function(_s) { _s.damage += 3; _s.duration += 1000; } },
            { desc: "MEGA UPGRADE: +1 LÂMINA E VELOCIDADE MÁXIMA.", upgrade: function(_s) { _s.quantity += 1; _s.orbital_speed += 2; _s.damage += 5; } }
        ]
    };
}

/// @desc Executa a lógica das 'Lâminas Giras'
function scr_laminas_giras(_row_index) 
{
    if (global.level_up) exit; 
    var _current_level = global.upgrades_vamp_grid[# UPGRADES_VAMP.LEVEL, _row_index];
    if (_current_level <= 0) exit;

    var _config = scr_laminas_giras_config(); 
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, UPGRADES_VAMP.DESCRIPTION);

    var _timer_var = "timer_laminas_" + string(_row_index);
    if (!variable_global_exists(_timer_var)) variable_global_set(_timer_var, 0);
    var _timer = variable_global_get(_timer_var);
    
    var _cd_mod = (variable_global_exists("player_cooldown_mod") ? global.player_cooldown_mod : 1);
    _timer += (delta_time / 1000); 

    if (_timer >= (_stats.cooldown * _cd_mod)) 
    {
        _timer = 0; // reseta o cooldown (antes era sobrescrito no fim da função)
        var _count = _stats.quantity;
        var _area_mod = (variable_global_exists("player_area_mod") ? global.player_area_mod : 1);
        
        for (var _i = 0; _i < _count; _i++) {
            var _angle = (360 / _count) * _i;
            var _blade = instance_create_layer(obj_player.x, obj_player.y, "Instances", asset_get_index("obj_skill_projectile"));
            
            _blade.damage = _stats.damage;
            _blade.veloc = 0; 
            _blade.image_xscale = _stats.size * _area_mod;
            _blade.image_yscale = _stats.size * _area_mod;
            _blade.sprite_index = spr_shuriken_icon;
            
            _blade.orbital_angle = _angle;
            _blade.orbital_radius = _stats.radius * _area_mod;
            _blade.orbital_speed = _stats.orbital_speed;
            _blade.duration_timer = _stats.duration;
            _blade.parent_player = obj_player;
            
            // method() vincula a função à lâmina (antes rodava no escopo do obj_player e dava crash)
            _blade.Step_0_Custom = method(_blade, function() {
                if (!instance_exists(parent_player)) { instance_destroy(); return; }
                orbital_angle += orbital_speed;
                x = parent_player.x + lengthdir_x(orbital_radius, orbital_angle);
                y = parent_player.y + lengthdir_y(orbital_radius, orbital_angle);
                image_angle += 15;
                
                duration_timer -= delta_time / 1000;
                if (duration_timer <= 0) instance_destroy();
            });
        }
    }
    variable_global_set(_timer_var, _timer);
}
