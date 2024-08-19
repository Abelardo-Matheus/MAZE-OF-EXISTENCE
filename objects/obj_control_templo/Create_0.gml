
window_set_fullscreen(true);
criar_chao_room_inteira(global.maze_width,global.maze_height+1,global.maze);
criar_paredes_borda(global.maze_width-1,global.maze_height,global.maze);
criar_paredes_vermelha_intances(global.maze_width,global.maze_height,global.maze,global.cell_size);
recriar_pontos_na_sala_atual(global.current_sala);

    
if (global.direcao_templo == 2) { 
	
            pos_x = 80;  // Posição à frente do prev_room
            pos_y = (global.room_height / 2);
			global.direcao_templo = 0;
			direction = 0;
			 var parede_direita = instance_position(32, (global.room_height / 2), obj_wall_carne);
                    if (parede_direita != noone) {
                        instance_destroy(parede_direita);
                    }
			instance_create_layer(-32, (global.room_height / 2), "instances", obj_goto_templo);
			}
// Veio da direita
else if (global.direcao_templo == 4) {  

            pos_x = global.room_width-150;  // Posição à frente do prev_room
            pos_y = (global.room_height / 2);
			global.direcao_templo = 0;
			direction = 180;
			var parede_esquerda = instance_position(global.room_width - 32, (global.room_height / 2), obj_wall_carne);
                    if (parede_esquerda != noone) {
                        instance_destroy(parede_esquerda);
                    }
			instance_create_layer(global.room_width + 32, (global.room_height / 2), "instances", obj_goto_templo);
	}
// Veio de baixo
else if (global.direcao_templo == 3) {  

      
            pos_x =(global.room_width / 2);
            pos_y = 80;  // Posição à frente do prev_room
			global.direcao_templo = 0;
				direction = 90;
				 var parede_abaixo = instance_position((global.room_width / 2) , 32, obj_wall_carne);
                    if (parede_abaixo != noone) {
                        instance_destroy(parede_abaixo);
                    }
				instance_create_layer((global.room_width / 2) + 32, -32, "instances", obj_goto_templo);
 }
// Veio de cima

else if (global.direcao_templo == 1) {  
	
  
            pos_x = (global.room_width / 2);
            pos_y = global.room_height-80;  // Posição à frente do prev_room
			global.direcao_templo = 0;
				direction = 270;
				 var parede_acima = instance_position((global.room_width / 2) + 32, global.room_height - 32, obj_wall_carne);
                    if (parede_acima != noone) {
                        instance_destroy(parede_acima);
                    }
				instance_create_layer((global.room_width / 2) + 32, global.room_height + 32, "instances", obj_goto_templo);
}

	instance_create_layer(pos_x+32, pos_y, "Layer_Player", obj_SPERM);













