function scr_pena_config(_level) {
    // Configuração inicial
    var config = {
        speed_increase: 1 + (_level - 1) * 2
    };

    return config;
}

function scr_pena() {
    var level = global.itens_vamp_grid[# Upgrades_vamp.level, 1]; // Obtém o nível atual

    // Verifica se o upgrade já foi aplicado neste nível
    if (!variable_global_exists("pena_last_level")) global.pena_last_level = 0;

    if (global.pena_last_level < level) {
        var config = scr_pena_config(level); // Configurações baseadas no nível

        // Aumenta a velocidade do jogador uma vez
        global.speed_player *= (1 + config.speed_increase / 100); // Aumenta a velocidade em porcentagem

        // Atualiza a descrição do upgrade na grid
        global.itens_vamp_grid[# Upgrades_vamp.description, 1] = 
            "VELOCIDADE AUMENTADA EM " + string(config.speed_increase) + "%!";

        // Atualiza o nível do último upgrade aplicado
        global.pena_last_level = level;
    }
}
