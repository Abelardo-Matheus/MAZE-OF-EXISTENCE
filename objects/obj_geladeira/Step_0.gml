// feather disable GM2017

depth = -y;
 
var _inst = instance_nearest(x,y,obj_player);
	if(distance_to_point(_inst.x,_inst.y)<= 100){
		// botão "[F] Abrir": scr_interacao

		if(interacao_pedida() and !aberto){
			aberto = true;
			obj_player.alarm[6] = 3;
			var _index_w = sprite_get_width(spr_itens_invent_consumiveis)/2;
			var _index_h = sprite_get_height(spr_itens_invent_consumiveis)/2;
			var _item_x = self.x; // Posição X do jogador
			var _item_y = self.y; // Posição Y do jogador
		criar_item_aleatorio_ativos(_item_x-_index_w,_item_y-_index_h,depth, 1);
		// Exemplo dentro do obj_geladeira
	furniture_update_state(x, y, global.current_sala, global.salas_com_geladeira, true);
		}
	}
	
	














