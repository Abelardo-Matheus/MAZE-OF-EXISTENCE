
 
var _inst = instance_nearest(x,y,obj_player);
	if(distance_to_point(_inst.x,_inst.y)<= 60){
		if(keyboard_check_pressed(ord("E"))){
			aberto = true;
			var item_x = self.x; // Posição X do jogador
			var item_y = self.y; // Posição Y do jogador
		criar_item_aleatorio_passivo(item_x,item_y);
		}
	}












