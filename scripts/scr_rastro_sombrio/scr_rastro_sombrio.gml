// feather disable GM2017

/// @desc Retorna a estrutura de dados (Vetor de Skill) do RASTRO SOMBRIO
function scr_rastro_sombrio_config()
{
    return {
        stats_base: {
            damage: 3,
            cooldown: 400, 
            duration: 2000, 
            radius: 30,
            sprite_icon: spr_rastro_icon
        },
        niveis: [
            { desc: "DEIXA POÇAS DE ENERGIA ESCURA NO CHÃO ENQUANTO SE MOVE.", upgrade: function(_s) { _s.damage = 3; } },
            { desc: "DANO E DURAÇÃO DAS POÇAS AUMENTADOS.", upgrade: function(_s) { _s.damage += 2; _s.duration += 500; } },
            { desc: "AUMENTA O TAMANHO DAS POÇAS.", upgrade: function(_s) { _s.radius += 10; } },
            { desc: "DANO SIGNIFICATIVAMENTE MAIOR.", upgrade: function(_s) { _s.damage += 5; } },
            { desc: "MEGA UPGRADE: POÇAS GIGANTES E DURADOURAS.", upgrade: function(_s) { _s.radius += 20; _s.duration += 1000; _s.damage += 5; } }
        ]
    };
}

/// @desc Executa a lógica do 'Rastro Sombrio'
function scr_rastro_sombrio(_row_index) 
{
    if (global.level_up) exit; 
    if (!instance_exists(obj_player)) exit;
    if (obj_player.hveloc == 0 && obj_player.vveloc == 0) exit; 

    var _current_level = global.upgrades_vamp_grid[# UPGRADES_VAMP.LEVEL, _row_index];
    if (_current_level <= 0) exit;

    var _config = scr_rastro_sombrio_config(); 
    var _stats = scr_generic_calculate_stats(_config, _current_level, global.upgrades_vamp_grid, _row_index, UPGRADES_VAMP.DESCRIPTION);

    var _timer_var = "timer_rastro_" + string(_row_index);
    if (!variable_global_exists(_timer_var)) variable_global_set(_timer_var, 0);
    var _timer = variable_global_get(_timer_var);
    
    var _cd_mod = (variable_global_exists("player_cooldown_mod") ? global.player_cooldown_mod : 1);
    _timer += delta_time / 1000; 

    if (_timer >= (_stats.cooldown * _cd_mod)) 
    {
        variable_global_set(_timer_var, 0); 
        var _area_mod = (variable_global_exists("player_area_mod") ? global.player_area_mod : 1);
        
        var _trail = instance_create_layer(obj_player.x, obj_player.y, "Instances", asset_get_index("obj_skill_area_effect"));
        
        _trail.damage = _stats.damage;
        _trail.radius = _stats.radius * _area_mod;
        _trail.duration = _stats.duration;
        _trail.follow_player = false;
        _trail.sprite_index = spr_hitbox_ataque;
        _trail.image_blend = c_black;
        _trail.image_alpha = 0.5;
        
        var _base_spr_width = sprite_get_width(spr_hitbox_ataque);
        if (_base_spr_width > 0) {
            var _scale = (_trail.radius * 2) / _base_spr_width;
            _trail.image_xscale = _scale;
            _trail.image_yscale = _scale;
        }
    }
    variable_global_set(_timer_var, _timer);
}
