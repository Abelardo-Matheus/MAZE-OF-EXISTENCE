if(inicializar = false){
	scr_textos();
	inicializar = true;
	alarm[0] = 1;
}


	if(caracter < string_length(texto_grid[# infos.texto, pagina])){
		if(keyboard_check_pressed(ord("E"))){
		caracter = string_length(texto_grid[# infos.texto, pagina]);
		}
	}else{
	if(pagina < ds_grid_height(texto_grid) - 1){
		if(keyboard_check_pressed(ord("E"))){
		alarm[0] = 1;
		caracter = 0;
		pagina++;
		}
	}else{
		 if(op_num != 0){
			 op_draw = true;
		 }else{
			 if(keyboard_check_pressed(ord("E"))){
			global.dialogo = false;
			instance_destroy();
			obj_player_tutorial.andar = false;
			}
		 }
		}
}