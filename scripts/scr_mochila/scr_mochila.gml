// feather disable GM2017
// Iniciado
// PASSIVA — efeito aplicado por mods_recalcular() (scr_modificadores) a partir do nível.
// Auxiliares (passiva_niveis, passiva_nivel_valor) ficam em scr_passivas_infancia.

/// @desc MOCHILA EXTRA: +1 projétil em todas as armas (Nv 1, 3 e 5)
function scr_mochila_config() {
    return {
        stats_base: { sprite_icon: spr_mochila_icon },
        niveis: passiva_niveis([
            "MOCHILA EXTRA: TODAS AS ARMAS JOGAM +1 PROJÉTIL.",
            "CABE MAIS COISA: RECARGA -4%.",
            "MAIS UM BOLSO: +1 PROJÉTIL.",
            "CABE MAIS COISA: RECARGA -4%.",
            "MEGA UPGRADE: +1 PROJÉTIL."
        ]),
        mods: function(_m, _lvl) {
            _m.quantidade += floor((_lvl + 1) / 2);   // 1,1,2,2,3
            _m.cooldown   *= power(0.96, floor(_lvl / 2));   // -4% a cada 2 níveis, nunca chega a 0
        }
    };
}
