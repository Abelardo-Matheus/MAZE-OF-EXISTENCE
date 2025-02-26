function scr_bola_config(_level) {
    // Configuração inicial
    var config = {
        damage: 10,         // Dano base
        timer: 5000,        // Tempo base (ms)
        size: 1,            // Tamanho base
        speed: 8,           // Velocidade base
        balls: 1,           // Quantidade de bolas disparadas
        push: 0             // Empurrão base (força de knockback)
    };

    // Aplica modificadores baseados no nível
    for (var i = 1; i <= _level; i++) {
        switch (i % 6) {
            case 5: // Level 1, 7, 13, ... (Atira em mais um inimigo)
                config.balls += 1;
				global.upgrades_vamp_grid[# Upgrades_vamp.description, 0] = "MAIS 1 BOLA ATIRADA";
                break;
            case 2: // Level 2, 8, 14, ... (Aumenta velocidade em 5%)
                config.speed *= 1.05;
				global.upgrades_vamp_grid[# Upgrades_vamp.description, 0] = "VELOCIDADE DE DISPARO MAIS RAPIDO";
                break;
            case 3: // Level 3, 9, 15, ... (Aumenta frequência de tiro em 5%)
                config.timer *= 0.75;
				global.upgrades_vamp_grid[# Upgrades_vamp.description, 0] = "FREQUENCIA AUMENTADA EM 5%";
                break;
            case 1: // Level 4, 10, 16, ... (Aumenta dano em 10%)
                config.damage *= 1.10;
				global.upgrades_vamp_grid[# Upgrades_vamp.description, 0] = "AUMENTO DE 10% DE DANO";
                break;
            case 4: // Level 5, 11, 17, ... (Empurra inimigos em 1%)
                config.push += 0.01;
				global.upgrades_vamp_grid[# Upgrades_vamp.description, 0] = "EMPURRA MAIS OS INIMIGOS";
                break;
     
        }
    }

    return config;
}

function scr_bola() {
    var level = global.upgrades_vamp_grid[# Upgrades_vamp.level, 0]; // Obtém o nível atual
    var config = scr_bola_config(level); // Configurações baseadas no nível

    // Timer e lógica da bola
    if (!variable_global_exists("bola_timer")) global.bola_timer = 0;

    global.bola_timer += delta_time / 1000;
    if (global.bola_timer >= config.timer) { // Timer em segundos
        global.bola_timer = 0;

        // Lista para armazenar inimigos já selecionados
        var selected_enemies = ds_list_create();

        // Adiciona todos os inimigos possíveis em uma lista temporária
        var all_enemies = ds_list_create();
        with (par_inimigos) {
            ds_list_add(all_enemies, id);
        }

        // Garante que vamos atirar em no máximo config.balls inimigos
        for (var i = 0; i < min(config.balls, ds_list_size(all_enemies)); i++) {
            // Escolhe um inimigo aleatório da lista de todos os inimigos restantes
            var random_index = irandom(ds_list_size(all_enemies) - 1);
            var enemy_id = all_enemies[| random_index];
            ds_list_delete(all_enemies, random_index); // Remove da lista temporária

            if (instance_exists(enemy_id)) {
                // Cria uma bola direcionada ao inimigo selecionado
                var bola = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_bola);
                bola.direction = point_direction(bola.x, bola.y, enemy_id.x, enemy_id.y);
                bola.veloc = config.speed;
                bola.damage = config.damage; // Passa o dano configurado
                bola.image_xscale = config.size; // Escala da bola
                bola.image_yscale = config.size;
                bola.push = config.push;

                // Adiciona o inimigo à lista de selecionados
                ds_list_add(selected_enemies, enemy_id);

                // Aplica knockback no inimigo
                with (enemy_id) {
                    var knockback_dir = point_direction(obj_player.x, obj_player.y, x, y);
                    motion_add(knockback_dir, config.push);
                }
            }
        }

        // Limpa as listas após o uso
        ds_list_destroy(all_enemies);
        ds_list_destroy(selected_enemies);
    }
}

