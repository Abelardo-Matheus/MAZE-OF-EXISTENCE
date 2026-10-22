// feather disable GM2017

/// @desc Retorna a estrutura de dados (Vetor de Item) do ANEL AMPLIFICADOR (Passivo)
/// +Área para TODOS os poderes (size, radius, órbita, pólen) via mods_aplicar_stats().
function scr_anel_amplificador_config()
{
    return {
        stats_base: { sprite_icon: spr_anel_icon },
        niveis: passiva_niveis([
            "AUMENTA A ÁREA DE TODOS OS PODERES (+15%).",
            "ÁREA AUMENTADA EM MAIS 15%.",
            "ÁREA AUMENTADA EM MAIS 15%.",
            "ÁREA AUMENTADA EM MAIS 15%.",
            "MEGA UPGRADE: ÁREA AUMENTADA EM MAIS 20%."
        ]),
        mods: function(_m, _lvl) {
            // Bônus TOTAL de área no nível _lvl (sem limite: Nv6 = +95%, Nv10 = +160%...).
            // mods_aplicar_stats() aplica _m.area em size / radius / orbit_radius / pollen_radius /
            // attack_radius de TODOS os poderes e pets — não precisa mexer em cada poder.
            _m.area *= 1 + passiva_nivel_valor([0, 0.15, 0.30, 0.45, 0.60, 0.80], _lvl);
        }
    };
}

/// @desc Mantido só por compatibilidade (a grid usa executor -1 para passivas)
function scr_anel_amplificador(_row_index) { }
