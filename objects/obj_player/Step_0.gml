
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


// Itera sobre a lista de scripts ativos e os executa
for (var i = 0; i < ds_list_size(global.active_upgrades); i++) {
    var _script = global.active_upgrades[| i];
    script_execute(_script); // Executa o script
}
}
