function spr_pena_up(level) {
    // Configurações baseadas no nível
    var config = scr_pena_config(level); // Obtém as configurações do nível atual

    // Aumenta a velocidade do jogador com base na frequência e no nível
    if (config.frequency == 1) {
        // Aumenta a velocidade apenas uma vez por nível
        if (!global.pena_upgraded || global.pena_last_level != level) {
            global.speed_player += config.speed_increase;
            global.pena_upgraded = true; // Marca que o upgrade foi aplicado
            global.pena_last_level = level; // Salva o nível atual
        }
    } else {
        // Aumenta a velocidade continuamente
        global.speed_player += config.speed_increase;
    }
}

function scr_pena_config(level) {
    // Configuração inicial
    var config = {
        speed_increase: 5,      // Aumento base de velocidade
        frequency: global.upgrades_grid[# Upgrades.frequency, 1] // Frequência definida na grid (1 = aplica uma vez, 0 = aplica continuamente)
    };

    // Aumenta o valor baseado no nível
    config.speed_increase += level * 2; // A cada nível, aumenta 2% adicional na velocidade

    return config;
}

