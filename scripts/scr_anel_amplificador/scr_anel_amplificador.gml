// feather disable GM2017

/// @desc Retorna a estrutura de dados (Vetor de Item) do ANEL AMPLIFICADOR (Passivo)
function scr_anel_amplificador_config()
{
    return {
        stats_base: {
            area_gain: 0,
            sprite_icon: spr_anel_icon
        },
        niveis: [
            { desc: "AUMENTA A ÁREA DE EFEITO DOS ATAQUES (+15%).", upgrade: function(_s) { _s.area_gain = 0.15; } },
            { desc: "ÁREA AUMENTADA EM MAIS 15%.", upgrade: function(_s) { _s.area_gain = 0.15; } },
            { desc: "ÁREA AUMENTADA EM MAIS 15%.", upgrade: function(_s) { _s.area_gain = 0.15; } },
            { desc: "ÁREA AUMENTADA EM MAIS 15%.", upgrade: function(_s) { _s.area_gain = 0.15; } },
            { desc: "MEGA UPGRADE: ÁREA AUMENTADA EM MAIS 20%.", upgrade: function(_s) { _s.area_gain = 0.20; } }
        ]
    };
}

/// @desc Lógica do 'Anel Amplificador' (Aplica bônus permanente de Área)
function scr_anel_amplificador(_row_index) 
{
    if (global.level_up) exit;

    var _current_level = global.itens_vamp_grid[# ITENS_VAMP.LEVEL, _row_index]; 
    if (_current_level <= 0) exit;

    var _control_var_name = "passive_last_applied_anel_" + string(_row_index);
    if (!variable_global_exists(_control_var_name)) variable_global_set(_control_var_name, 0);
    
    var _last_applied_level = variable_global_get(_control_var_name);

    if (_last_applied_level < _current_level) 
    {
        var _config = scr_anel_amplificador_config(); 
        var _upgrade_stats = scr_generic_calculate_passive_upgrade(_config, _current_level, global.itens_vamp_grid, _row_index, ITENS_VAMP.DESCRIPTION);

        if (_upgrade_stats.area_gain > 0) {
            if (!variable_global_exists("player_area_mod")) global.player_area_mod = 1.0;
            global.player_area_mod += _upgrade_stats.area_gain;
        }

        variable_global_set(_control_var_name, _current_level);
        show_debug_message("Anel Amplificador Lvl "+string(_current_level)+"! Área Total: " + string(global.player_area_mod));
    }
}
