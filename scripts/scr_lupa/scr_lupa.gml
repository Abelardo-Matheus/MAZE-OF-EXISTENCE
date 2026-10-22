// feather disable GM2017
// Iniciado
// PASSIVA — efeito aplicado por mods_recalcular() (scr_modificadores) a partir do nível.
// Auxiliares (passiva_niveis, passiva_nivel_valor) ficam em scr_passivas_infancia.

/// @desc LUPA DE DETETIVE: +Chance de crítico
function scr_lupa_config() {
    return {
        stats_base: { sprite_icon: spr_lupa_icon },
        niveis: passiva_niveis([
            "LUPA DE DETETIVE: +4% DE CHANCE DE CRÍTICO.",
            "CRÍTICO AUMENTADO EM MAIS 4%.",
            "CRÍTICO AUMENTADO EM MAIS 4%.",
            "CRÍTICO AUMENTADO EM MAIS 4%.",
            "MEGA UPGRADE: CRÍTICO AUMENTADO EM MAIS 8%."
        ]),
        mods: function(_m, _lvl) {
            _m.crit += passiva_nivel_valor([0, 4, 8, 12, 16, 24], _lvl);
        }
    };
}
