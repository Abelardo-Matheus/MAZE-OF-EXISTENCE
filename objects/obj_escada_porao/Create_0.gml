image_xscale = global._cell_size / sprite_get_width(sprite_index)*1.5;
image_yscale = global._cell_size / sprite_get_height(sprite_index)*1.5;

if(global.direcao_escada_porao == 0){
	image_angle = 90;
}if(global.direcao_escada_porao == 1){
	image_angle = 270;
}if(global.direcao_escada_porao == 2){
	image_angle = 180;
}if(global.direcao_escada_porao == 3){
	image_angle = 0;
}

global.sala_entrada = global.current_sala;
sala_ida = global.salas_escuras[0];
direcao = global.direcao_escada;




