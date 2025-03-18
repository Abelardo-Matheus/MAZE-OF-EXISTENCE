function scr_explosao_config(_level) {
    // Configuração inicial
    var config = {
        damage: 15,                     // Dano base
        radius: 100,                    // Raio base da explosão
        push: 0.5,                      // Força de empurrão base
        duration: 1,       // Duração da explosão (1 segundo)
        cooldown: room_speed * 5        // Cooldown entre ativações (3 segundos)
    };

    // Aplica modificadores baseados no nível
    for (var i = 1; i <= _level; i++) {
        switch (i % 6) {
            case 1: // Level 1, 7, 13, ... (Aumenta dano em 10%)
                config.damage *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "AUMENTO DE 10% DE DANO";
                break;
            case 2: // Level 2, 8, 14, ... (Aumenta raio da explosão em 10%)
                config.radius *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "RAIO DA EXPLOSÃO AUMENTADO EM 10%";
                break;
            case 3: // Level 3, 9, 15, ... (Aumenta força de empurrão em 5%)
                config.push *= 1.05;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "FORÇA DE EMPURRÃO AUMENTADA EM 5%";
                break;
            case 4: // Level 4, 10, 16, ... (Reduz cooldown em 5%)
                config.cooldown *= 0.85;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "COOLDOWN REDUZIDO EM 5%";
                break;
            case 5: // Level 5, 11, 17, ... (Aumenta duração da explosão em 10%)
                config.duration *= 1.10;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "DURAÇÃO DA EXPLOSÃO AUMENTADA EM 10%";
                break;
            case 0: // Level 6, 12, 18, ... (Aumenta dano em 15%)
                config.damage *= 1.15;
                global.upgrades_vamp_grid[# Upgrades_vamp.description, 1] = "AUMENTO DE 15% DE DANO";
                break;
        }
    }

    return config;
}

function scr_explosao() {
    var level = global.upgrades_vamp_grid[# Upgrades_vamp.level, 1]; // Obtém o nível atual
    var config = scr_explosao_config(level); // Configurações baseadas no nível

    // Inicializa os temporizadores se ainda não existirem
    if (!variable_global_exists("explosao_timer")) global.explosao_timer = 0;
    if (!variable_global_exists("explosao_active")) global.explosao_active = false;

    // Incrementa o temporizador se a explosão não estiver ativa
    if (!global.explosao_active) {
        global.explosao_timer++;
    }

    // Ativa a explosão se o cooldown terminou e nenhuma explosão estiver ativa
    if (!global.explosao_active && global.explosao_timer >= config.cooldown) {
        global.explosao_timer = 0; // Reseta o temporizador
        global.explosao_active = true; // Marca que a explosão está ativa

        // Cria a explosão ao redor do jogador
        with (par_inimigos) {
            if (point_distance(obj_player.x, obj_player.y, x, y) <= config.radius) {
                // Aplica dano ao inimigo
                vida -= config.damage;

                // Aplica empurrão no inimigo
                var knockback_dir = point_direction(obj_player.x, obj_player.y, x, y);
                empurrar_dir = knockback_dir; // Define a direção do empurrão
                state = scr_inimigo_hit; // Muda o estado do inimigo para "hit"
                empurrar_veloc = config.push; // Define a velocidade do empurrão
                alarm[1] = 5; // Configura um alarme para o estado de empurrão
                hit = true; // Marca que o inimigo foi atingido
				
				var _inst = instance_create_layer(x,y,"instances",obj_dano);
				_inst.alvo = self;
				_inst.dano = config.damage;


            }
        }

       // Efeito visual da explosão (opcional)
		var explosao = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_explosion);
		explosao.image_xscale = config.radius / 50; // Ajusta a escala do efeito visual
		explosao.image_yscale = config.radius / 50;
		explosao.duration = config.duration; // Define a duração do efeito visual
		explosao.follow_player = true; // Adiciona uma variável para controlar se a explosão deve seguir o jogador

		// Desativa a explosão após a duração configurada
		alarm[0] = config.duration; // Usa um alarme para desativar a explosão após a duração
		    }

    // Desativa a explosão quando o alarme tocar
    if (alarm[0] == 0 && global.explosao_active) {
        global.explosao_active = false;
    }
}