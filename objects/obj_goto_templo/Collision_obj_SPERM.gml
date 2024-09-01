// Desativar todas as instâncias, exceto obj_controle



// Evento de colisão com `obj_next_room` ou `obj_prev_room`
if(global.vinda_templo ==0){
instance_deactivate_all(true); // Desativa todas as instância
instance_activate_object(obj_control_fase_1);
room_goto(TEMPLO)
global.vinda_templo = 1;
}else{
	if (direcao == 4) { 
	
            pos_x = 80;  // esquerda
            pos_y = (global.room_height / 2);
			direcao = 0;
			direction = 0;
			}
// Veio da direita
else if (direcao == 2) {  

            pos_x = global.room_width-150;  // direita
            pos_y = (global.room_height / 2);
			direcao = 0;
			direction = 180;
	}
// Veio de baixo
else if (direcao == 1) {  

      
            pos_x =(global.room_width / 2);
            pos_y = 80;  // em cima
			direcao = 0;
				direction = 90;
 }
// Veio de cima

else if (direcao == 3) {  
	
  
            pos_x = (global.room_width / 2);
            pos_y = global.room_height-80;  // baixo
			direcao = 0;
				direction = 270;
}

	
	instance_deactivate_all(true);
	instance_activate_object(obj_control_fase_1);
	room_goto(Fase_1);
	carregar_sala(global.origem_templo, global.destino_templo);
	global.vinda_templo = 0;
	instance_create_layer(pos_x+32, pos_y, "Layer_Player", obj_SPERM);
	recriar_pontos_na_sala_atual(global.current_sala);
	recriar_inimigos_na_sala_atual(global.current_sala);
	recriar_slow_na_sala_atual(global.current_sala);
	if (global.current_sala == global.ovulo_sala_pos) {
        // Criar o óvulo nesta sala
	
        instance_create_layer(global.room_width/2, global.room_height/2, "Layer_Player", obj_ovulo);
    }
}
	









