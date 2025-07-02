function scr_bomba_config(_level) {
    // Configuração inicial da bomba
    var config = {
        quanti: 1,           // Quantidade de bombas lançadas
        damage: 20,          // Dano base da bomba
        timer: 7000,         // Tempo base entre lançamentos (ms)
        radius: 100,         // Raio base da explosão (alterado para 100 para maior impacto visual inicial)
        push: 0,             // Força de empurrão (knockback)
        splash_damage_multiplier: 0.5 // Multiplicador de dano em área (para inimigos fora do centro)
    };

    // Aplica modificadores baseados no nível
    for (var i = 1; i <= _level; i++) {
        switch (i % 6) { // Ciclo de 6 níveis para upgrades
            case 1: // Nível 1, 7, 13... (Aumenta o dano da bomba)
                config.damage *= 1.15; // +15% de dano
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "DANO DA BOMBA AUMENTADO EM 15%";
                break;
            case 2: // Nível 2, 8, 14... (Reduz o tempo de recarga)
                config.timer *= 0.90; // -10% de tempo de recarga
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "TEMPO DE RECARGA REDUZIDO EM 10%";
                break;
            case 3: // Nível 3, 9, 15... (Aumenta o raio da explosão)
                config.radius += 20; // +20 pixels de raio (aumentado para maior visibilidade do efeito)
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "RAIO DA EXPLOSÃO AUMENTADO";
                break;
            case 4: // Nível 4, 10, 16... (Aumenta a quantidade de bombas)
                config.quanti += 1; // +1 bomba
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "LANÇA MAIS UMA BOMBA";
                break;
            case 5: // Nível 5, 11, 17... (Adiciona empurrão aos inimigos)
                config.push += 0.02; // +0.02 de força de empurrão
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "BOMBA EMPURRA OS INIMIGOS";
                break;
            case 0: // Nível 6, 12, 18... (Aumenta o dano em área)
                config.splash_damage_multiplier += 0.05; // +5% de dano em área
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 9] = "DANO EM ÁREA DA BOMBA AUMENTADO";
                break;
        }
    }

    return config;
}
function scr_bomba() {
    var level = global.upgrades_vamp_grid[# Upgrades_vamp.level, 9]; // Obtém o nível atual da bomba
    var config = scr_bomba_config(level); // Pega as configurações baseadas no nível

    if (!variable_global_exists("bomba_timer")) {
        global.bomba_timer = 0;
    }

    global.bomba_timer += delta_time / 1000;

    if (global.bomba_timer >= config.timer) {
        global.bomba_timer = 0;

        var local_targets = ds_list_create();

        with (par_inimigos) {
            if (point_distance(x, y, obj_player.x, obj_player.y) <= 1000) {
                ds_list_add(local_targets, id);
            }
        }

        if (ds_list_size(local_targets) > 0) {
            ds_list_sort(local_targets, function (a, b) {
                var dist_a = point_distance(instance_id_get(a).x, instance_id_get(a).y, obj_player.x, obj_player.y);
                var dist_b = point_distance(instance_id_get(b).x, instance_id_get(b).y, obj_player.x, obj_player.y);
                return dist_a - dist_b;
            });

            for (var i = 0; i < min(config.quanti, ds_list_size(local_targets)); i++) {
                var enemy_id = local_targets[| i];

                if (instance_exists(enemy_id)) {
                    var bomba = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_bomba);
                    bomba.target_x = enemy_id.x;
                    bomba.target_y = enemy_id.y;
                    bomba.damage = config.damage;
                    bomba.radius = config.radius; // <-- 'radius' já está sendo passado
                    bomba.push = config.push;
                    bomba.splash_damage_multiplier = config.splash_damage_multiplier;
                    bomba.state = "flying";
                }
            }
        }
        ds_list_destroy(local_targets);
    }
}