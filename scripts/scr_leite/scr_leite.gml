// feather disable GM2017
// Iniciado
// PASSIVA — efeito aplicado por mods_recalcular() (scr_modificadores) a partir do nível.
// Auxiliares (passiva_niveis, passiva_nivel_valor) ficam em scr_passivas_infancia.

/// @desc LEITE COM CHOCOLATE: +Dano de todos os poderes e pets
function scr_leite_config() {
    return {
        stats_base: { sprite_icon: spr_leite_icon },
        niveis: passiva_niveis([
            "LEITE COM CHOCOLATE: +10% DE DANO EM TODOS OS PODERES.",
            "DANO AUMENTADO EM MAIS 10%.",
            "DANO AUMENTADO EM MAIS 10%.",
            "DANO AUMENTADO EM MAIS 10%.",
            "MEGA UPGRADE: DANO AUMENTADO EM MAIS 20%."
        ]),
        mods: function(_m, _lvl) {
            _m.dano += passiva_nivel_valor([0, 0.10, 0.20, 0.30, 0.40, 0.60], _lvl);
        }
    };
}
