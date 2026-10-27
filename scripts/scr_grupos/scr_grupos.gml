// feather disable GM2017
/// _nivel_area: nível da área onde o grupo está (scr_progressao) — sobe a dificuldade
function grupo_inimigo_configurar(_seed, _nivel_area = 1) {
    random_set_seed(_seed);

    // Distribuição de _dificuldade (probabilidades aproximadas)
    var _sorteio = irandom(99); // 0 a 99

    var _dificuldade;
    if (_sorteio < 40) {
        _dificuldade = 1; // 40%
    } else if (_sorteio < 70) {
        _dificuldade = 2; // 30%
    } else if (_sorteio < 85) {
        _dificuldade = 3; // 15%
    } else if (_sorteio < 95) {
        _dificuldade = 4; // 10%
    } else {
        _dificuldade = 5; // 5%
    }

    _dificuldade = progressao_dificuldade_grupo(_dificuldade, _nivel_area);
    randomize(); // devolve o random normal do jogo (random_set_seed acima)

    // Parâmetros por _dificuldade
    var _qtd_min = [2, 3, 4, 5, 6];
    var _qtd_max = [4, 6, 8, 10, 12];

    var _tempo_min = [180, 160, 140, 120, 100]; // em frames (~3s até ~1.6s)
    var _tempo_max = [240, 200, 180, 150, 120]; // em frames

    var _quantidade = irandom_range(_qtd_min[_dificuldade - 1], _qtd_max[_dificuldade - 1]);
    var _tempo_spawn = irandom_range(_tempo_min[_dificuldade - 1], _tempo_max[_dificuldade - 1]);

    return [_dificuldade, _quantidade, _tempo_spawn];
}
