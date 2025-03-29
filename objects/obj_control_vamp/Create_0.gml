spaw_timer = 10;
global.map_vamp = true;
global.map_bebe = false;

// Variáveis de controle

distancia_minima = 400; // Distância mínima entre as estruturas
quantidade_estruturas = 3; // Quantidade máxima de estruturas por área


if(global.sair){
	global.estruturas_criadas = true;
	recriar_estruturas();
	obj_player.x = global.pos_x_map;
	obj_player.y = global.pos_y_map+200;
	global.sair = false;
	
}

instance_create_layer( 0, 0, "Instances",obj_poste)

