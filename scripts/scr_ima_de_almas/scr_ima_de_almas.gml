// feather disable GM2017

/// @desc Retorna a estrutura de dados (Vetor de Item) do ÍMÃ DE ALMAS (Passivo)
/// O efeito é aplicado por mods_recalcular() (scr_modificadores) a partir do nível.
function scr_ima_de_almas_config()
{
    return {
        stats_base: { sprite_icon: spr_ima_icon },
        niveis: passiva_niveis([
            "AUMENTA O RAIO DE COLETA DE XP E ITENS (+50).",
            "RAIO DE COLETA AUMENTADO EM MAIS 50.",
            "RAIO DE COLETA AUMENTADO EM MAIS 70.",
            "RAIO DE COLETA AUMENTADO EM MAIS 80.",
            "MEGA UPGRADE: RAIO DE COLETA AUMENTADO EM MAIS 200."
        ]),
        mods: function(_m, _lvl) {
            _m.coleta += passiva_nivel_valor([0, 50, 100, 170, 250, 450], _lvl);
        }
    };
}

/// @desc Mantido só por compatibilidade (a grid usa executor -1 para passivas)
function scr_ima_de_almas(_row_index) { }
