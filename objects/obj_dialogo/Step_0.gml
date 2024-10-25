if(inicializar = false){
	scr_textos();
	inicializar = true;
}

if(keyboard_check_pressed(ord("E"))){
	if(pagina < ds_grid_height(texto_grid) - 1){
		pagina++;
	}else{
		global.dialogo = false;
		instance_destroy();
	}
	
}