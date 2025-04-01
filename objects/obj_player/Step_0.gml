
var limite_escuridao = 0.5;




var recuperacao_sanidade = 0; // Define o total de recuperação baseado na proximidade


for (var i = 0; i < ds_list_size(global.lista_luzes); i++) {
    var luz = global.lista_luzes[| i];
    if (instance_exists(luz)) {
        var distancia = point_distance(obj_player.x, obj_player.y, luz.x, luz.y);

        var tamanho_luz_1 = luz.luz_1;
        var tamanho_luz_2 = luz.luz_2;
        var tamanho_luz_3 = luz.luz_3;
        var tamanho_luz_4 = luz.luz_4;
        var tamanho_luz_5 = luz.luz_5;

        // Se o jogador estiver dentro da luz, calcular recuperação proporcional
        if (distancia < tamanho_luz_1) {
            recuperacao_sanidade = max(recuperacao_sanidade, 0.09); // Centro da luz (mais forte)
        } else if (distancia < tamanho_luz_2) {
            recuperacao_sanidade = max(recuperacao_sanidade, 0.07);
        } else if (distancia < tamanho_luz_3) {
            recuperacao_sanidade = max(recuperacao_sanidade, 0.05);
        } else if (distancia < tamanho_luz_4) {
            recuperacao_sanidade = max(recuperacao_sanidade, 0.04);
        } else if (distancia < tamanho_luz_5) {
            recuperacao_sanidade = max(recuperacao_sanidade, 0.02); 
        } else if (global.day_night_cycle.is_day){
			recuperacao_sanidade = max(recuperacao_sanidade, 0.09);
		}
    }
}

// --- Atualizando a sanidade do jogador ---
if (recuperacao_sanidade > 0 ) {
    global.sanidade += recuperacao_sanidade;
} else if (!global.day_night_cycle.is_day && global.day_night_cycle.current_light < limite_escuridao) {
    var fator_escuridao = 1 - (global.day_night_cycle.current_light / limite_escuridao);
    global.sanidade -= 0.08 * fator_escuridao; // Perde sanidade no escuro
}

// Mantém o valor da sanidade dentro dos limites
global.sanidade = clamp(global.sanidade, 0, 100);


if(global.level_up == true){
	alarm[0]++;
	alarm[2]++;
	alarm[3]++;
	alarm[6]++;
	alarm[11]++;
	image_speed = 0;
	exit;		
}else{
	image_speed = 1;
script_execute(state);

if(global.estamina <= global.max_estamina && !andar){
global.estamina += 0.5;
}

if(global.vida <= 0){
	//game_end();
}

if (global.estamina <= 0 && !andar){
andar = true;
global.estamina = 0;
alarm[0] = 50;
}

//// Verifica rolagem para cima
//if (mouse_wheel_up() && dir_alfa <= 0){
//    global.armamento += 1;
//	dir_alfa = 1;
//	desenha_arma = true;
//}

//// Verifica rolagem para baixo
//if (mouse_wheel_down() && dir_alfa <= 0){
//    global.armamento -= 1;
//	dir_alfa = 1;
//	desenha_arma = true;
//}

//// Verifica se `armamento` excede os limites
//if (global.armamento >= Armamentos.Altura){

//    global.armamento = 0;  // Reseta para o primeiro armamento se exceder o total
//} else if (global.armamento < 0){
	
//    global.armamento = Armamentos.Altura - 1;  // Volta para o último armamento se for menor que 0
//}


//// Diminuir o alfa a cada step
//if (desenha_arma) {
//    dir_alfa -= 0.02;  // Diminui o alfa gradativamente (ajuste o valor conforme a velocidade desejada)

//    if (dir_alfa <= 0) {
//        dir_alfa = 0;  // Garante que o alfa não fique menor que 0
//        desenha_arma = false;  // Para de desenhar quando o alfa chegar a 0
//    }
//}

if(hit){
	state = scr_personagem_hit;
}



for (var i = 0; i < ds_list_size(global.active_upgrades); i++) {
    var _script = global.active_upgrades[| i];
    script_execute(_script); 
}
}
