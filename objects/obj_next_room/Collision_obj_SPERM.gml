// Evento de colisão com `obj_next_room` ou `obj_prev_room`
	
    // Carregar a nova sala

    var sala_destino = room_destino;  // Sala que você está indo
	show_debug_message(global.current_sala);

    carregar_sala(sala_destino, room_origem);
	recriar_pontos_na_sala_atual(global.current_sala);

if (direcao == 2) { 
	
            pos_x = 80;  // Posição à frente do prev_room
            pos_y = (global.room_height / 2);
			direcao = 0;
			direction = 0;
			}
// Veio da direita
else if (direcao == 4) {  

            pos_x = global.room_width-150;  // Posição à frente do prev_room
            pos_y = (global.room_height / 2);
			direcao = 0;
			direction = 180;
	}
// Veio de baixo
else if (direcao == 3) {  

      
            pos_x =(global.room_width / 2);
            pos_y = 80;  // Posição à frente do prev_room
			direcao = 0;
				direction = 90;
 }
// Veio de cima

else if (direcao == 1) {  
	
  
            pos_x = (global.room_width / 2);
            pos_y = global.room_height-80;  // Posição à frente do prev_room
			direcao = 0;
				direction = 270;
}

		instance_create_layer(pos_x+32, pos_y, "Layer_Player", obj_SPERM);
    
	if (global.current_sala == global.ovulo_sala_pos) {
        // Criar o óvulo nesta sala
	
        instance_create_layer(global.room_width/2, global.room_height/2, "Layer_Player", obj_ovulo);
    }
	
	
