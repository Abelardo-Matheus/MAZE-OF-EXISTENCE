// feather disable GM2017
// Iniciado
// PASSIVA — efeito aplicado por mods_recalcular() (scr_modificadores) a partir do nível.
// Auxiliares (passiva_niveis, passiva_nivel_valor) ficam em scr_passivas_infancia.

/// @desc ESTRELINHA DOURADA: +XP ganho
function scr_estrelinha_config() {
    return {
        stats_base: { sprite_icon: spr_estrela_icon },
        niveis: passiva_niveis([
            "ESTRELINHA DOURADA: GANHA 10% MAIS XP.",
            "XP AUMENTADO EM MAIS 10%.",
            "XP AUMENTADO EM MAIS 10%.",
            "XP AUMENTADO EM MAIS 10%.",
            "MEGA UPGRADE: XP AUMENTADO EM MAIS 20%."
        ]),
        mods: function(_m, _lvl) {
            _m.xp += passiva_nivel_valor([0, 0.10, 0.20, 0.30, 0.40, 0.60], _lvl);
        }
    };
}
