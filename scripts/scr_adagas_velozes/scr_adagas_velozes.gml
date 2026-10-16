// feather disable GM2017

/// @desc Retorna a estrutura de dados (Vetor de Skill) das ADAGAS VELOZES
function scr_adagas_velozes_config()
{
    return {
        stats_base: {
            damage: 12,
            cooldown: 1200,
            quantity: 2,
            speed: 12,
            spread: 10,
            size: 0.8,
            sprite_icon: spr_adagas_icon
        },
        niveis: [
            { desc: "DISPARA UMA RAJADA DE ADAGAS NA DIREÇÃO DO OLHAR.", upgrade: function(_s) { _s.quantity = 2; } },
            { desc: "DANO AUMENTADO E +1 ADAGA.", upgrade: function(_s) { _s.damage += 3; _s.quantity += 1; } },
            { desc: "MAIS VELOCIDADE E +1 ADAGA.", upgrade: function(_s) { _s.speed += 2; _s.quantity += 1; } },
            { desc: "DANO E QUANTIDADE AUMENTADOS.", upgrade: function(_s) { _s.damage += 5; _s.quantity += 1; } },
            { desc: "MEGA UPGRADE: RAJADA MÁXIMA (+2 ADAGAS).", upgrade: function(_s) { _s.quantity += 2; _s.speed += 3; _s.damage += 8; } }
        ]
    };
}

/// @desc Executa a lógica das 'Adagas Velozes'
function scr_adagas_velozes(_row_index) 
{
    if (global.level_up) exit; 
    if (!instance_exists(obj_player)) exit;

    var _current_level = global.upgrades_vamp_grid[# UPGRADES_VAMP.LEVEL, _row_index];
    if (_current_level <= 0) exit;

    var _config = scr_adagas_velozes_config(); 
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, UPGRADES_VAMP.DESCRIPTION);

    var _timer_var = "timer_adagas_" + string(_row_index);
    if (!variable_global_exists(_timer_var)) variable_global_set(_timer_var, 0);
    var _timer = variable_global_get(_timer_var);
    
    var _cd_mod = (variable_global_exists("player_cooldown_mod") ? global.player_cooldown_mod : 1);
    _timer += delta_time / 1000; 

    if (_timer >= (_stats.cooldown * _cd_mod)) 
    {
        variable_global_set(_timer_var, 0); 
        
        var _base_dir = 270; 
        if (variable_instance_exists(obj_player, "dir")) {
            switch(obj_player.dir) { 
                case 0: _base_dir = 0; break; 
                case 1: _base_dir = 90; break; 
                case 2: _base_dir = 180; break; 
                case 3: _base_dir = 270; break; 
            }
        }
        
        var _area_mod = (variable_global_exists("player_area_mod") ? global.player_area_mod : 1);
        
        for (var _i = 0; _i < _stats.quantity; _i++) {
            var _angle = _base_dir + random_range(-_stats.spread, _stats.spread);
            var _dagger = instance_create_layer(obj_player.x, obj_player.y, "Instances", asset_get_index("obj_skill_projectile"));
            
            _dagger.damage = _stats.damage;
            _dagger.veloc = _stats.speed;
            _dagger.direction = _angle;
            _dagger.image_angle = _angle;
            _dagger.sprite_index = spr_flecha;
            _dagger.image_xscale = _stats.size * _area_mod;
            _dagger.image_yscale = _stats.size * _area_mod;
        }
    }
    variable_global_set(_timer_var, _timer);
}
