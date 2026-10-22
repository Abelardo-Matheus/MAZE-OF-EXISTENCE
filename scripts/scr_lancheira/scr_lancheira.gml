// feather disable GM2017
// Iniciado
// PASSIVA — efeito aplicado por mods_recalcular() (scr_modificadores) a partir do nível.
// Auxiliares (passiva_niveis, passiva_nivel_valor) ficam em scr_passivas_infancia.

/// @desc LANCHEIRA: recupera vida aos poucos
function scr_lancheira_config() {
    return {
        stats_base: { sprite_icon: spr_lancheira_icon },
        niveis: passiva_niveis([
            "LANCHEIRA: RECUPERA 0.5 DE VIDA POR SEGUNDO.",
            "LANCHINHO MAIOR: +0.5 VIDA/S.",
            "LANCHINHO MAIOR: +0.5 VIDA/S.",
            "LANCHINHO MAIOR: +0.5 VIDA/S.",
            "MEGA UPGRADE: +1 VIDA/S."
        ]),
        mods: function(_m, _lvl) {
            _m.regen += passiva_nivel_valor([0, 0.5, 1, 1.5, 2, 3], _lvl);
        }
    };
}
