// feather disable GM2017
// Iniciado
// PASSIVA — efeito aplicado por mods_recalcular() (scr_modificadores) a partir do nível.
// Auxiliares (passiva_niveis, passiva_nivel_valor) ficam em scr_passivas_infancia.

/// @desc CHICLETE ESTICADO: +Duração dos efeitos
function scr_chiclete_config() {
    return {
        stats_base: { sprite_icon: spr_chiclete_icon },
        niveis: passiva_niveis([
            "CHICLETE ESTICADO: OS PODERES DURAM 12% MAIS.",
            "DURAÇÃO AUMENTADA EM MAIS 12%.",
            "DURAÇÃO AUMENTADA EM MAIS 12%.",
            "DURAÇÃO AUMENTADA EM MAIS 12%.",
            "MEGA UPGRADE: DURAÇÃO AUMENTADA EM MAIS 22%."
        ]),
        mods: function(_m, _lvl) {
            _m.duracao += passiva_nivel_valor([0, 0.12, 0.24, 0.36, 0.48, 0.70], _lvl);
        }
    };
}
