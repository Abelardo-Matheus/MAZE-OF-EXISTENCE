function scr_raio_config(_level) {
    // Configuração inicial
    var config = {
        damage: 20,                     // Dano base do raio
        radius: 120,                    // Raio base da área de efeito
        push: 0.3,                      // Força de empurrão base
        duration: 1,                    // Duração do raio (1 segundo)
        cooldown: room_speed * 4        // Cooldown entre ativações (4 segundos)
    };

    // Aplica modificadores baseados no nível
    for (var i = 1; i <= _level; i++) {
        switch (i % 6) {
            case 1: // Level 1, 7, 13, ... (Aumenta dano em 10%)
                config.damage *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "AUMENTO DE 10% DE DANO";
                break;
            case 2: // Level 2, 8, 14, ... (Aumenta raio da área de efeito em 10%)
                config.radius *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "RAIO DA ÁREA DE EFEITO AUMENTADO EM 10%";
                break;
            case 3: // Level 3, 9, 15, ... (Aumenta força de empurrão em 5%)
                config.push *= 1.05;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "FORÇA DE EMPURRÃO AUMENTADA EM 5%";
                break;
            case 4: // Level 4, 10, 16, ... (Reduz cooldown em 5%)
                config.cooldown *= 0.65;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "COOLDOWN REDUZIDO EM 5%";
                break;
            case 5: // Level 5, 11, 17, ... (Aumenta duração do raio em 10%)
                config.duration *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "DURAÇÃO DO RAIO AUMENTADA EM 10%";
                break;
            case 0: // Level 6, 12, 18, ... (Aumenta dano em 15%)
                config.damage *= 1.15;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 6] = "AUMENTO DE 15% DE DANO";
                break;
        }
    }

    return config;
}
function scr_raio() {
    var level = global.upgrades_vamp_grid[# Upgrades_vamp.level, 6]; // Obtém o nível atual
    var config = scr_raio_config(level); // Configurações baseadas no nível

    // Inicializa os temporizadores se ainda não existirem
    if (!variable_global_exists("raio_timer")) global.raio_timer = 0;
    if (!variable_global_exists("raio_active")) global.raio_active = false;

    // Inicializa a lista de inimigos atingidos se ainda não existir
    if (!variable_global_exists("inimigos_atingidos")) {
        global.inimigos_atingidos = ds_list_create();
    }

    // Incrementa o temporizador se o raio não estiver ativo
    if (!global.raio_active) {
        global.raio_timer++;
    }

    // Ativa o raio se o cooldown terminou e nenhum raio estiver ativo
    if (!global.raio_active && global.raio_timer >= config.cooldown) {
        global.raio_timer = 0; // Reseta o temporizador
        global.raio_active = true; // Marca que o raio está ativo

        // Lista para armazenar inimigos disponíveis (não atingidos)
        var inimigos_disponiveis = ds_list_create();

        // Adiciona todos os inimigos na sala que ainda não foram atingidos
        with (par_inimigos) {
            if (!ds_list_find_index(global.inimigos_atingidos, id) >= 0) {
                ds_list_add(inimigos_disponiveis, id);
            }
        }

        // Se todos os inimigos já foram atingidos, reseta a lista
        if (ds_list_size(inimigos_disponiveis) == 0) {
            ds_list_clear(global.inimigos_atingidos);
            with (par_inimigos) {
                ds_list_add(inimigos_disponiveis, id);
            }
        }

        // Escolhe um inimigo aleatório da lista de disponíveis
        if (ds_list_size(inimigos_disponiveis) > 0) {
            var random_index = irandom(ds_list_size(inimigos_disponiveis) - 1);
            var enemy_id = inimigos_disponiveis[| random_index];

            // Adiciona o inimigo à lista de atingidos
            ds_list_add(global.inimigos_atingidos, enemy_id);

            // Cria o raio no local do inimigo
            var raio = instance_create_layer(enemy_id.x, enemy_id.y, "Instances", obj_raio);
            raio.damage = config.damage; // Passa o dano configurado
            raio.radius = config.radius; // Define a área de efeito
            raio.duration = config.duration; // Define a duração do raio

            // Aplica dano e empurrão ao inimigo
            if (instance_exists(enemy_id)) {
                enemy_id.vida -= config.damage;

                // Aplica empurrão no inimigo
                var knockback_dir = point_direction(obj_player.x, obj_player.y, enemy_id.x, enemy_id.y);
                enemy_id.empurrar_dir = knockback_dir; // Define a direção do empurrão
                enemy_id.state = scr_inimigo_hit; // Muda o estado do inimigo para "hit"
                enemy_id.empurrar_veloc = config.push; // Define a velocidade do empurrão
                enemy_id.alarm[1] = 5; // Configura um alarme para o estado de empurrão
                enemy_id.hit = true; // Marca que o inimigo foi atingido

                // Cria um efeito de dano (opcional)
                var _inst = instance_create_layer(enemy_id.x, enemy_id.y, "Instances", obj_dano);
                _inst.alvo = enemy_id;
                _inst.dano = config.damage;
            }
        }

        // Limpa a lista de inimigos disponíveis após o uso
        ds_list_destroy(inimigos_disponiveis);

        // Desativa o raio após a duração configurada
        alarm[0] = config.duration; // Usa um alarme para desativar o raio após a duração
    }

    // Desativa o raio quando o alarme tocar
    if (alarm[0] == 0 && global.raio_active) {
        global.raio_active = false;
    }
}