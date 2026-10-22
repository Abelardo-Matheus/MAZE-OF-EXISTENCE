// feather disable GM2017

// Tela de level up aberta: o jogo fica pausado (igual ao obj_player)
if (!variable_instance_exists(id, "vel_anim_pausa")) vel_anim_pausa = -1;
if (global.level_up) {
    if (vel_anim_pausa < 0) vel_anim_pausa = image_speed;
    image_speed = 0;
    exit;
}
if (vel_anim_pausa >= 0) {
    image_speed = vel_anim_pausa;
    vel_anim_pausa = -1;
}

script_execute(state);
depth = -y;
if(global.estamina <= global.max_estamina && !andar){
global.estamina += 0.5;
}

if(global.vida <= 0){
	game_end();
}

if (global.estamina <= 0 && !andar){
andar = true;
global.estamina = 0;
alarm[0] = 50;
}

// Verifica rolagem para cima
if (mouse_wheel_up() && dir_alfa <= 0){
    global.armamento += 1;
	dir_alfa = 1;
	desenha_arma = true;
}

// Verifica rolagem para baixo
if (mouse_wheel_down() && dir_alfa <= 0){
    global.armamento -= 1;
	dir_alfa = 1;
	desenha_arma = true;
}

// Verifica se `armamento` excede os limites
if (global.armamento >= ARMAMENTOS.ALTURA){

    global.armamento = 0;  // Reseta para o primeiro armamento se exceder o total
} else if (global.armamento < 0){
	
    global.armamento = ARMAMENTOS.ALTURA - 1;  // Volta para o último armamento se for menor que 0
}


// Diminuir o alfa a cada step
if (desenha_arma) {
    dir_alfa -= 0.02;  // Diminui o alfa gradativamente (ajuste o valor conforme a velocidade desejada)

    if (dir_alfa <= 0) {
        dir_alfa = 0;  // Garante que o alfa não fique menor que 0
        desenha_arma = false;  // Para de desenhar quando o alfa chegar a 0
    }
}

// Poderes e pets ganhos no tutorial (mesmo sistema do jogo: scr_modificadores)
skills_executar_tick();
mods_tick();
