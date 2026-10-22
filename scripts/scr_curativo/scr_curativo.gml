// feather disable GM2017
// Iniciado
// PASSIVA — efeito aplicado por mods_recalcular() (scr_modificadores) a partir do nível.
// Auxiliares (passiva_niveis, passiva_nivel_valor) ficam em scr_passivas_infancia.

/// @desc CURATIVO: reduz o dano recebido
function scr_curativo_config() {
    return {
        stats_base: { sprite_icon: spr_curativo_icon },
        niveis: passiva_niveis([
            "CURATIVO DE BICHINHO: RECEBE 6% MENOS DANO.",
            "DANO RECEBIDO REDUZIDO EM MAIS 6%.",
            "DANO RECEBIDO REDUZIDO EM MAIS 6%.",
            "DANO RECEBIDO REDUZIDO EM MAIS 6%.",
            "MEGA UPGRADE: DANO RECEBIDO REDUZIDO EM MAIS 6%."
        ]),
        mods: function(_m, _lvl) {
            // Nv1-5 igual a antes (6% por nível); depois cada nível tira 6% do dano que ainda sobra.
            var _red = 0.06 * min(_lvl, 5);
            if (_lvl > 5) _red = 1 - (1 - _red) * power(0.94, _lvl - 5);
            _m.reducao_dano += _red;
        }
    };
}
