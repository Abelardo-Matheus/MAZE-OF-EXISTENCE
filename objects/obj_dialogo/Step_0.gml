if(initialized = false){
	scr_dialogs();
	initialized = true;
	alarm[0] = 1;
}


	if(char_index < string_length(text_grid[# DialogInfo.TEXT, page])){
		if(keyboard_check_pressed(ord("E"))){
		char_index = string_length(text_grid[# DialogInfo.TEXT, page]);
		}
	}else{
	if(page < ds_grid_height(text_grid) - 1){
		if(keyboard_check_pressed(ord("E"))){
		alarm[0] = 1;
		char_index = 0;
		page++;
		}
	}else{
		 if(op_num != 0){
			 op_draw = true;
		 }else{
			 if(keyboard_check_pressed(ord("E"))){
			global.dialogo = false;
			instance_destroy();
			obj_player.andar = false;
			}
		 }
		}
}