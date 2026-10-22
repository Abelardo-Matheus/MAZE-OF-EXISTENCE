// feather disable GM2017
// Iniciado
// PASSIVA — efeito aplicado por mods_recalcular() (scr_modificadores) a partir do nível.
// Auxiliares (passiva_niveis, passiva_nivel_valor) ficam em scr_passivas_infancia.

/// @desc TÊNIS DE RODINHA: projéteis mais rápidos (vão mais longe)
function scr_tenis_config() {
    return {
        stats_base: { sprite_icon: spr_tenis_icon },
        niveis: passiva_niveis([
            "TÊNIS DE RODINHA: SEUS PROJÉTEIS VOAM 10% MAIS RÁPIDO.",
            "PROJÉTEIS 10% MAIS RÁPIDOS.",
            "PROJÉTEIS 10% MAIS RÁPIDOS.",
            "PROJÉTEIS 10% MAIS RÁPIDOS.",
            "MEGA UPGRADE: PROJÉTEIS 20% MAIS RÁPIDOS E +5% VELOCIDADE DO JOGADOR."
        ]),
        mods: function(_m, _lvl) {
            _m.veloc_proj   += passiva_nivel_valor([0, 0.10, 0.20, 0.30, 0.40, 0.60], _lvl);
            _m.veloc_player += 0.05 * (_lvl div 5);   // +5% a cada MEGA (Nv 5, 10, 15...)
        }
    };
}
