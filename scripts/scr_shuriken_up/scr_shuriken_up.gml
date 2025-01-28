function scr_shuriken_config(_level) {
    // Configuração inicial
    var config = {
        count: 1,                       // Quantidade de shurikens
        speed: 3,                       // Velocidade de rotação
        size: 1.2,                        // Tamanho da shuriken
        radius: 100,                     // Raio da órbita
        duration: room_speed * 2,       // Duração da shuriken (2 segundos)
        damage: 10,                     // Dano da shuriken
		push: 0,
        cooldown: room_speed * 3        // Cooldown entre ativações (3 segundos)
    };

    // Aplica modificadores baseados no nível
    for (var i = 1; i <= _level; i++) {
        switch (i % 7) { // Alterna entre 6 tipos de upgrades
            case 1: // Nível 1, 7, 13, ... (Aumenta a quantidade de shurikens)
                config.count = min(config.count + 1, 10); // Máximo de 10 shurikens
                global.upgrades_grid[# Upgrades.description, 4] = "MAIS UMA SHURIKEN GIRANDO!";
                break;

            case 2: // Nível 2, 8, 14, ... (Aumenta a velocidade de rotação)
                config.speed += 0.5;
                global.upgrades_grid[# Upgrades.description, 4] = "VELOCIDADE DA SHURIKEN AUMENTADA!";
                break;

            case 3: // Nível 3, 9, 15, ... (Aumenta o tamanho da shuriken)
                config.size += 0.2;
                global.upgrades_grid[# Upgrades.description, 4] = "TAMANHO DA SHURIKEN AUMENTADO!";
                break;

            case 4: // Nível 4, 10, 16, ... (Aumenta o raio da órbita)
                config.radius += 5;
                global.upgrades_grid[# Upgrades.description, 4] = "RAIO DA ÓRBITA AUMENTADO!";
                break;

            case 5: // Nível 5, 11, 17, ... (Aumenta a duração da shuriken)
                config.duration += room_speed * 0.5; // Aumenta a duração em 0.5 segundos
                global.upgrades_grid[# Upgrades.description, 4] = "DURAÇÃO DA SHURIKEN AUMENTADA!";
                break;
			case 6: // Level 5, 11, 17, ... (Aumenta o knockback em 1%)
                config.push += 0.01;
				global.upgrades_grid[# Upgrades.description, 4] = "EMPURRA OS INIMIGOS";
                break;

            case 0: // Nível 6, 12, 18, ... (Aumenta o dano da shuriken)
                config.damage += 2;
                global.upgrades_grid[# Upgrades.description, 4] = "DANO DA SHURIKEN AUMENTADO!";
                break;
        }
    }

    return config;
}


function scr_shuriken() {
    var level = global.upgrades_grid[# Upgrades.level, 4]; // Obtém o nível atual
    var config = scr_shuriken_config(level); // Configurações baseadas no nível

    // Inicializa os temporizadores se ainda não existirem
    if (!variable_global_exists("shuriken_timer")) global.shuriken_timer = 0;
    if (!variable_global_exists("shuriken_active")) global.shuriken_active = false;

    // Incrementa o temporizador
    if (!global.shuriken_active) {
        global.shuriken_timer++;
    }

    // Cria as shurikens apenas se o cooldown terminou e nenhuma estiver ativa
    if (!global.shuriken_active && global.shuriken_timer >= config.cooldown) {
        global.shuriken_timer = 0; // Reseta o temporizador
        global.shuriken_active = true; // Marca que as shurikens estão ativas

        // Cria o número configurado de shurikens
        for (var i = 0; i < config.count; i++) {
            var angle = i * (360 / config.count); // Divide o círculo igualmente para cada shuriken
            var shuriken = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_shuriken);
            shuriken.angle = angle;           // Define o ângulo inicial
            shuriken.veloc = config.speed;    // Velocidade de rotação
            shuriken.size = config.size;      // Tamanho da shuriken
            shuriken.radius = config.radius;  // Raio de órbita
            shuriken.damage = config.damage;  // Dano da shuriken
			shuriken.push = config.push;
            shuriken.duration = config.duration; // Tempo de vida da shuriken (em frames)

            // Ajusta o tamanho visual da shuriken
            shuriken.image_xscale = config.size;
            shuriken.image_yscale = config.size;
        }
    }
}


