// feather disable GM2017

/// @desc Retorna a estrutura de dados (Vetor de Item) do TOMO DA CELERIDADE (Passivo)
/// -Recarga para TODOS os poderes e pets via mods_aplicar_stats().
function scr_tomo_celeridade_config()
{
    return {
        stats_base: { sprite_icon: spr_tomo_icon },
        niveis: passiva_niveis([
            "TODOS OS PODERES RECARREGAM MAIS RÁPIDO (-8%).",
            "RECARGA REDUZIDA EM MAIS 8%.",
            "RECARGA REDUZIDA EM MAIS 8%.",
            "RECARGA REDUZIDA EM MAIS 8%.",
            "MEGA UPGRADE: RECARGA REDUZIDA EM MAIS 8%."
        ]),
        mods: function(_m, _lvl) {
            // -8% por nível sobre a recarga que sobra (sem limite de nível e nunca chega a 0).
            // Nv5 = -34%, Nv10 = -57%. O piso fica em MODS_COOLDOWN_MIN (scr_modificadores).
            _m.cooldown *= power(0.92, _lvl);
        }
    };
}

/// @desc Mantido só por compatibilidade (a grid usa executor -1 para passivas)
function scr_tomo_celeridade(_row_index) { }
