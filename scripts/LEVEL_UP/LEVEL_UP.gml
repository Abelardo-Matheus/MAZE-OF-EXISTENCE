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


function level_up() {
	global.level_up = true;
    global.level_player += 1;
    global.vida_max_calc[global.level_player] = global.vida_max_calc[global.level_player - 1] + global.level_player*0.8; // Aumenta 10 de vida a cada level
    global.max_estamina_calc[global.level_player] = global.max_estamina_calc[global.level_player - 1] + 5; // Aumenta 5 de estamina
    global.dano_base[global.level_player] = global.dano_base[global.level_player - 1] + global.level_player*0.5; // Aumenta 1 de ataque base
    global.vida = global.vida_max_calc[global.level_player];
	global.vida_max = global.vida_max_calc[global.level_player];
    global.estamina = global.max_estamina_calc[global.level_player];
    global.ataque = global.dano_base[global.level_player];
    global.max_estamina = global.max_estamina_calc[global.level_player];

   
  
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

