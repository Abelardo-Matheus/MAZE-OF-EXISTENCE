function grupo_inimigo_configurar(seed) {
    random_set_seed(seed);

    // Distribuição de dificuldade (probabilidades aproximadas)
    var sorteio = irandom(99); // 0 a 99

    var dificuldade;
    if (sorteio < 40) {
        dificuldade = 1; // 40%
    } else if (sorteio < 70) {
        dificuldade = 2; // 30%
    } else if (sorteio < 85) {
        dificuldade = 3; // 15%
    } else if (sorteio < 95) {
        dificuldade = 4; // 10%
    } else {
        dificuldade = 5; // 5%
    }

    // Parâmetros por dificuldade
    var qtd_min = [2, 3, 4, 5, 6];
    var qtd_max = [4, 6, 8, 10, 12];

    var tempo_min = [180, 160, 140, 120, 100]; // em frames (~3s até ~1.6s)
    var tempo_max = [240, 200, 180, 150, 120]; // em frames

    var quantidade = irandom_range(qtd_min[dificuldade - 1], qtd_max[dificuldade - 1]);
    var tempo_spawn = irandom_range(tempo_min[dificuldade - 1], tempo_max[dificuldade - 1]);

    return [dificuldade, quantidade, tempo_spawn];
}
