
if(keyboard_check_pressed(ord("E"))){

if(global.entrou && alarm[0] <= 0){
	show_debug_message("1")
	global.entrou = !global.entrou;
	carregar_sala(global.passada,sala_ida);
	var escada_in = instance_find(obj_escada_porao,false);
	instance_create_layer(escada_in.x, escada_in.y, "Layer_Player", global.current_player);
}else{
	alarm[0] =60*3;
	global.entrou = !global.entrou;
	global.passada = global.current_sala;
	carregar_sala(sala_ida,global.sala_entrada);
	if (direcao == 2) { 
	
            pos_x = 80; 
            pos_y = (global.room_height / 2);
			direcao = 0;
			direction = 0;
			
			
			}

else if (direcao == 4) {  

            pos_x = global.room_width-150;  
            pos_y = (global.room_height / 2);
			direcao = 0;
			direction = 180;
	}
// Veio de baixo
else if (direcao == 3) {  

      
            pos_x =(global.room_width / 2);
            pos_y = 80;  
			direcao = 0;
				direction = 90;
 }
// Veio de cima

else if (direcao == 1) {  
	
  
            pos_x = (global.room_width / 2);
            pos_y = global.room_height-80;  
			direcao = 0;
				direction = 270;
}
		var escada = instance_create_layer(pos_x, pos_y, "instances", obj_escada_porao);
	
		instance_create_layer(pos_x, pos_y, "Layer_Player", global.current_player);

	

}

}















