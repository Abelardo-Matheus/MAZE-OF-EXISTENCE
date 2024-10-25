
if(global.permitido == true){
    var sala_destino = room_destino;  // Sala que você está indo
	if(sala_destino == global.templos_salas_pos[0]){
		global.current_sala = global.templos_salas_pos[0];
	carregar_sala_templo(sala_destino, room_origem,direcao);
	}else{
    carregar_sala(sala_destino, room_origem);
	}


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
	if(global.current_sala == global.templos_salas_pos[0]){
		pos_x -=32;
	}
		obj_player.x = pos_x +32;
		obj_player.y = pos_y;
	
}
	
