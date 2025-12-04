 depth = -y;

 
var _inst = instance_nearest(x,y,obj_player);
	if(distance_to_point(_inst.x,_inst.y)<= 100){
		obj_player.desenha_botao = true;
	
		if(keyboard_check_pressed(ord("F")) and !aberto){
			aberto = true;
			obj_player.alarm[6] = 3;
			var _index_w = sprite_get_width(spr_itens_invent_consumiveis)/2;
			var _index_h = sprite_get_height(spr_itens_invent_consumiveis)/2;
			var item_x = self.x; // Posição X do jogador
			var item_y = self.y; // Posição Y do jogador
		criar_item_aleatorio_passivos_arma(item_x-_index_w,item_y-_index_h,depth, 1);
		furniture_update_state(x, y, global.current_sala, global.salas_com_guarda_roupa, true);
		}
	}
	
	if(image_index = 1){
	obj_player.desenha_botao = false;
}














