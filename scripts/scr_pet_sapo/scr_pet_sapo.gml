function scr_pet_config(_level) {
    // Configuração inicial
    var config = {
        damage: 10,                     
        velocidade: 1,                   
        attack_interval: 60, 
        orbit_distance: 400,             
        quanti: 1                      
    };

    var linha_sapo = 7;
    var pode_alterar_grid = ds_grid_height(global.upgrades_vamp_grid) > linha_sapo;

    // Limite máximo baseado na viewport customizada
    var max_width = 1280 * 4; // 5120
    var max_height = max_width * (1080 / 1920); // 2880
    var max_orbit_distance = min(max_width, max_height) / 2;  // metade do menor lado

    for (var i = 1; i <= _level; i++) {
        switch (i % 6) {
            case 1:
                config.damage *= 1.10;
                if (pode_alterar_grid) global.upgrades_vamp_grid[# Upgrades_vamp.description, linha_sapo] = "DANO DO PET AUMENTADO EM 10%";
                break;
            case 2:
                config.velocidade *= 1.10;
                if (pode_alterar_grid) global.upgrades_vamp_grid[# Upgrades_vamp.description, linha_sapo] = "VELOCIDADE DO PET AUMENTADA EM 10%";
                break;
            case 3:
                config.attack_interval *= 0.90;
                if (pode_alterar_grid) global.upgrades_vamp_grid[# Upgrades_vamp.description, linha_sapo] = "INTERVALO DE ATAQUE DO PET REDUZIDO EM 10%";
                break;
            case 4:
                config.quanti += 1;
                if (pode_alterar_grid) global.upgrades_vamp_grid[# Upgrades_vamp.description, linha_sapo] = "MAIS UM SAPO";
                break;
            case 5:
                var novo_orbit = config.orbit_distance + (config.orbit_distance / 8);
                if (novo_orbit <= max_orbit_distance) {
                    config.orbit_distance = novo_orbit;
                    if (pode_alterar_grid) global.upgrades_vamp_grid[# Upgrades_vamp.description, linha_sapo] = "MAIS 12.5% DE RANGE PARA O SAPO";
                } else {
                    config.orbit_distance = max_orbit_distance;
                    if (pode_alterar_grid) global.upgrades_vamp_grid[# Upgrades_vamp.description, linha_sapo] = "RANGE MÁXIMO ALCANÇADO";
                }
                break;
            case 0:
                config.damage *= 1.20;
                if (pode_alterar_grid) global.upgrades_vamp_grid[# Upgrades_vamp.description, linha_sapo] = "DANO DO PET AUMENTADO EM 20%";
                break;
        }
    }

    return config;
}



function scr_sapo() {
    var linha_sapo = 7;
    var pet_level = global.upgrades_vamp_grid[# Upgrades_vamp.level, linha_sapo];
    var pet_config = scr_pet_config(pet_level);

    // Verifica quantos sapos já existem para não criar infinitos
    var sapos_existentes = instance_number(obj_sapo_pet);

    var para_criar = pet_config.quanti - sapos_existentes;
    if (para_criar <= 0) return; // Já tem sapos suficientes

    // Distribuir sapos em círculo ao redor do jogador
    var cx = obj_player.x;
    var cy = obj_player.y;
    var distancia = pet_config.orbit_distance * 0.7; // distância do player para espalhar sapos

    for (var i = 0; i < para_criar; i++) {
        var angulo = (360 / pet_config.quanti) * i;
        var sx = cx + lengthdir_x(distancia, angulo);
        var sy = cy + lengthdir_y(distancia, angulo);

        var pet = instance_create_layer(sx, sy, "Instances", obj_sapo_pet);
        pet.damage = pet_config.damage;
        pet.velocidade = pet_config.velocidade;
        pet.cooldown_max = pet_config.attack_interval;
        pet.follow_distance = pet_config.orbit_distance;
    }
}
