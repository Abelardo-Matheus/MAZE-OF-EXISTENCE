// feather disable GM2017

/// @desc Retorna a estrutura de dados (Vetor de Item) do TOMO CELERIDADE (Passivo)
function scr_tomo_celeridade_config()
{
    return {
        stats_base: {
            cooldown_reduction: 0,
            sprite_icon: spr_tomo_icon
        },
        niveis: [
            { desc: "REDUZ O TEMPO DE RECARGA DAS HABILIDADES (-8%).", upgrade: function(_s) { _s.cooldown_reduction = 0.08; } },
            { desc: "RECARGA REDUZIDA EM MAIS 8%.", upgrade: function(_s) { _s.cooldown_reduction = 0.08; } },
            { desc: "RECARGA REDUZIDA EM MAIS 8%.", upgrade: function(_s) { _s.cooldown_reduction = 0.08; } },
            { desc: "RECARGA REDUZIDA EM MAIS 8%.", upgrade: function(_s) { _s.cooldown_reduction = 0.08; } },
            { desc: "MEGA UPGRADE: RECARGA REDUZIDA EM MAIS 8%.", upgrade: function(_s) { _s.cooldown_reduction = 0.08; } }
        ]
    };
}

/// @desc Lógica do 'Tomo Celeridade' (Aplica bônus permanente de Cooldown)
function scr_tomo_celeridade(_row_index) 
{
    if (global.level_up) exit;

    var _current_level = global.itens_vamp_grid[# ITENS_VAMP.LEVEL, _row_index]; 
    if (_current_level <= 0) exit;

    var _control_var_name = "passive_last_applied_tomo_" + string(_row_index);
    if (!variable_global_exists(_control_var_name)) variable_global_set(_control_var_name, 0);
    
    var _last_applied_level = variable_global_get(_control_var_name);

    if (_last_applied_level < _current_level) 
    {
        var _config = scr_tomo_celeridade_config(); 
        var _upgrade_stats = scr_generic_calculate_passive_upgrade(_config, _current_level, global.itens_vamp_grid, _row_index, ITENS_VAMP.DESCRIPTION);

        if (_upgrade_stats.cooldown_reduction > 0) {
            if (!variable_global_exists("player_cooldown_mod")) global.player_cooldown_mod = 1.0;
            global.player_cooldown_mod -= _upgrade_stats.cooldown_reduction;
        }

        variable_global_set(_control_var_name, _current_level);
        show_debug_message("Tomo Celeridade Lvl "+string(_current_level)+"! Modificador Cooldown: " + string(global.player_cooldown_mod));
    }
}
