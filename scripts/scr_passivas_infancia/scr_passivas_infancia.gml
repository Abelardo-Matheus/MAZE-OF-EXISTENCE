// feather disable GM2017
// ==============================================================================
// scr_passivas_infancia — Passivas novas com tema de criança
// ==============================================================================
// Cada config tem:
//   stats_base.sprite_icon -> ícone da carta
//   niveis                 -> 5 descrições (o upgrade é vazio: o efeito vem de "mods")
//   mods(_m, _lvl)         -> soma o bônus TOTAL do nível _lvl em global.mods
// SEM LIMITE DE NÍVEL: depois do 5 o ciclo recomeça (igual às armas). O nível 6 dá de novo o
// bônus do nível 1 em cima do total do 5, o 10 dá outro MEGA, etc. -> passiva_nivel_valor().
// Bônus multiplicativos (recarga, dano recebido) usam power() para nunca passar de 100%.
// O efeito é recalculado do zero em mods_recalcular() (scr_modificadores) sempre que um
// nível muda, então vale para TODOS os poderes e nunca se perde/duplica.
// Registro na grid: poderes_lista.gml -> inicializar_tudo() (executor -1).
// Cada passiva fica no seu script (pasta PODERES/PASSIVAS): scr_leite, scr_mochila, scr_chiclete,
// scr_lancheira, scr_estrelinha, scr_lupa, scr_curativo, scr_tenis. Aqui ficam só os auxiliares.
// ==============================================================================

/// @desc Monta o vetor de níveis de uma passiva a partir das descrições
function passiva_niveis(_descs) {
    var _arr = [];
    for (var _i = 0; _i < array_length(_descs); _i++) {
        array_push(_arr, { desc: _descs[_i], upgrade: function(_s) { } });
    }
    return _arr;
}

/// @desc Valor TOTAL de uma tabela de passiva em qualquer nível (sem limite).
/// _tab[0] = nível 0 (sem bônus) ... _tab[n] = último nível definido (MEGA).
/// Acima de n o ciclo se repete: nível = ciclos * n + resto  ->  ciclos * _tab[n] + _tab[resto].
/// Ex.: _tab = [0, 10, 20, 30, 40, 60]  ->  Nv5 = 60, Nv6 = 70, Nv10 = 120, Nv12 = 140.
function passiva_nivel_valor(_tab, _lvl) {
    var _n = array_length(_tab) - 1;
    if (_lvl <= 0 || _n <= 0) return 0;
    var _ciclos = _lvl div _n;
    var _resto  = _lvl mod _n;
    return _ciclos * _tab[_n] + _tab[_resto];
}
