// feather disable GM2017

/// @desc Retorna a estrutura de dados (Vetor de Item) da PENA (Passivo)
/// O efeito é aplicado por mods_recalcular() (scr_modificadores) a partir do nível.
function scr_feather_config()
{
    return {
        stats_base: { sprite_icon: spr_pena_icon },
        niveis: passiva_niveis([
            "DEIXA O JOGADOR MAIS RÁPIDO (+5% VELOCIDADE).",
            "VELOCIDADE AUMENTADA EM MAIS 5%.",
            "VELOCIDADE AUMENTADA EM MAIS 10%.",
            "VELOCIDADE AUMENTADA EM MAIS 10%.",
            "MEGA UPGRADE: VELOCIDADE AUMENTADA EM MAIS 15%."
        ]),
        mods: function(_m, _lvl) {
            _m.veloc_player += passiva_nivel_valor([0, 0.05, 0.10, 0.20, 0.30, 0.45], _lvl);
        }
    };
}

/// @desc Mantido só por compatibilidade (a grid usa executor -1 para passivas)
function scr_pena(_row_index) { }
