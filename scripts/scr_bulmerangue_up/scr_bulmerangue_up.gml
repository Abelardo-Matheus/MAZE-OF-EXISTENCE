function scr_bumerangue_config(_level) {
    // Configuração inicial
    var config = {
		quanti: 1,
        damage: 15,         // Dano base
        timer: 5000,        // Tempo base (ms)
        speed: 4,          // Velocidade base
        size: 2,            // Tamanho base
        push: 0,            // Empurrão base (força de knockback)
        pierce: 1           // Quantidade de inimigos atravessados antes de voltar
    };

    // Aplica modificadores baseados no nível
    for (var i = 1; i <= _level; i++) {
        switch (i % 7) {
            case 1: // Level 1, 7, 13, ... (Aumenta a quantidade de inimigos atravessados)
                config.pierce += 1;
				global.upgrades_grid[# Upgrades.description, 6] = "ATRAVESSA MAIS UM INIMIGO";
                break;
            case 2: // Level 2, 8, 14, ... (Aumenta a velocidade em 5%)
                config.speed *= 1.05;
				global.upgrades_grid[# Upgrades.description, 6] = "VELOCIDADE DO BUMERANGUE AUMENTADA EM 5%";
                break;
            case 3: // Level 3, 9, 15, ... (Reduz o tempo entre lançamentos em 5%)
                config.timer *= 0.95;
				global.upgrades_grid[# Upgrades.description, 6] = "TEMPO DE RECARGA REDUZIDO EM 5%";
                break;
            case 4: // Level 4, 10, 16, ... (Aumenta o dano em 10%)
                config.damage *= 1.10;
				global.upgrades_grid[# Upgrades.description, 6] = "DANO DO BUMERANGUE AUMENTADO EM 10%";
                break;
            case 5: // Level 5, 11, 17, ... (Aumenta o knockback em 1%)
                config.push += 0.01;
				global.upgrades_grid[# Upgrades.description, 6] = "EMPURRA OS INIMIGOS";
                break;
			case 6: // Level 5, 11, 17, ... (Aumenta a quantidade atirada )
                config.quanti += 1;
				global.upgrades_grid[# Upgrades.description, 6] = "ATIRA MAIS UM BULMERANGUE";
                break;
        }
    }

    return config;
}


function scr_bumerangue() {
	
	
    var level = global.upgrades_grid[# Upgrades.level, 6]; // Obtém o nível atual
    var config = scr_bumerangue_config(level); // Configurações baseadas no nível

    // Inicializa a lista global para rastrear alvos atingidos se ainda não existir
    if (!variable_global_exists("bumerangue_targets")) {
        global.bumerangue_targets = ds_list_create();
    }

    // Timer e lógica de lançamento do bumerangue
    if (!variable_global_exists("bumerangue_timer")) global.bumerangue_timer = 0;

    global.bumerangue_timer += delta_time / 1000;

    // Lança bumerangue apenas quando o tempo está pronto
    if (global.bumerangue_timer >= config.timer) {
        global.bumerangue_timer = 0;
		
        // Procura o inimigo mais próximo que ainda não foi atingido
        var enemy_id = instance_nearest(obj_player.x, obj_player.y, par_inimigos);

        if (instance_exists(enemy_id)) {
            // Verifica se o ID do inimigo já está na lista de alvos atingidos
            if (ds_list_find_index(global.bumerangue_targets, enemy_id.id) == -1) {
                // Adiciona o ID do inimigo à lista de alvos atingidos
                ds_list_add(global.bumerangue_targets, enemy_id.id);

                // Cria o bumerangue na posição do jogador
                var bumerangue = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_bumerangue);
                bumerangue.target = enemy_id; // Define o alvo
                bumerangue.veloc = config.speed;
                bumerangue.damage = config.damage;
                bumerangue.size = config.size;
                bumerangue.push = config.push;
                bumerangue.pierce = config.pierce; // Define o número de inimigos que pode atravessar
                bumerangue.returning = false; // Inicialmente, ele não está voltando
                bumerangue.targets = ds_list_create(); // Lista local para rastrear alvos deste bumerangue
                ds_list_add(bumerangue.targets, enemy_id.id); // Adiciona o primeiro alvo
            }
        }
    }
}


