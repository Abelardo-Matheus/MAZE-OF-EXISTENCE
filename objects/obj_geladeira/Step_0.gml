
 
var _inst = instance_nearest(x,y,obj_player);
	if(distance_to_point(_inst.x,_inst.y)<= 60){
		if(keyboard_check_pressed(ord("E")) and !aberto){
			aberto = true;
			var _index_w = sprite_get_width(spr_itens_invent_consumiveis)/2;
			var _index_h = sprite_get_height(spr_itens_invent_consumiveis)/2;
			var item_x = self.x; // Posição X do jogador
			var item_y = self.y; // Posição Y do jogador
		criar_item_aleatorio_ativos(item_x-_index_w,item_y-_index_h);
		definir_geladeira_aberta(self.x,self.y,global.current_sala);
		}
	}












