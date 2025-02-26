global.xp = 0;
global.level_player = 1;
global.vida_max_calc[global.level_player] = 30;
global.vida_max = global.vida_max_calc[global.level_player];
global.vida = global.vida_max_calc[global.level_player];
global.max_estamina_calc[global.level_player] = 50;
global.max_estamina = global.max_estamina_calc[global.level_player];
global.estamina = global.max_estamina_calc[global.level_player];
global.dano_base[global.level_player] = 6;
global.ataque = global.dano_base[global.level_player];
global.critico = 0;
global.max_xp = global.level_player * 100;
global.level_up = false
global.upgrades_vamp_list = ds_list_create();


function level_up() {
	global.level_up = true;
    global.level_player += 1;
	ds_list_clear(global.upgrades_vamp_list);
	repeat(global.upgrade_num){
		randomize();
		var _upgrade = irandom(ds_grid_height(global.upgrades_vamp_grid) - 1);
		while(ds_list_find_index(global.upgrades_vamp_list, _upgrade) != -1){
			_upgrade = irandom(ds_grid_height(global.upgrades_vamp_grid) - 1);
		}
		ds_list_add(global.upgrades_vamp_list, _upgrade);
	}
	
    global.vida_max_calc[global.level_player] = global.vida_max_calc[global.level_player - 1] + global.level_player*0.8; // Aumenta 10 de vida a cada level
    global.max_estamina_calc[global.level_player] = global.max_estamina_calc[global.level_player - 1] + 5; // Aumenta 5 de estamina
    global.dano_base[global.level_player] = global.dano_base[global.level_player - 1] + global.level_player*0.5; // Aumenta 1 de ataque base
    global.vida = global.vida_max_calc[global.level_player];
	global.vida_max = global.vida_max_calc[global.level_player];
    global.estamina = global.max_estamina_calc[global.level_player];
    global.ataque = global.dano_base[global.level_player];
    global.max_estamina = global.max_estamina_calc[global.level_player];

}

function level_up_upgrade(_selected_upgrade) {
    // Verifica se o índice do poder selecionado é válido
    if (_selected_upgrade >= 0 && _selected_upgrade < ds_grid_height(global.upgrades_vamp_grid)) {
        // Incrementa o nível do poder na grid
        global.upgrades_vamp_grid[# Upgrades_vamp.level, _selected_upgrade] += 1;
    } 
}

// Função para calcular o crítico
function calcular_critico() {
	randomize();
    // A chance de crítico aumenta em 2% a cada nível (por exemplo)
    var chance_critico = global.level_player * 1;
    
    // Gera um valor aleatório para decidir se o ataque é crítico ou não
    var sorteio = irandom_range(1, 100);
    
    if (sorteio <= chance_critico) {
        // Se for crítico, aumenta o dano em 50% (pode ajustar o multiplicador se desejar)
        global.critico = 1; // Marcador de crítico
        global.ataque = global.dano_base[global.level_player] * 1.5;
    } else {
        global.critico = 0; // Não foi crítico
        global.ataque = global.dano_base[global.level_player];
    }
}



function ganhar_xp(xp_ganho) {
    // Adiciona o XP ganho ao XP global
    global.xp += xp_ganho;
    
    // Laço para continuar verificando se o jogador tem XP suficiente para subir de nível
    while (true) {
        global.max_xp = global.level_player * 100;
        if (global.xp >= global.max_xp) {
            global.xp -= global.max_xp;
            level_up();
        } else {
            break;
        }
    }
}

