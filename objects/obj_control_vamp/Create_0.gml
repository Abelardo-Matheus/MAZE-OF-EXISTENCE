spaw_timer = 10;


// Variáveis de controle

distancia_minima = 100; // Distância mínima entre as estruturas
quantidade_estruturas = 600; // Quantidade máxima de estruturas por área
raio_geracao = 25000; // Raio ao redor do jogador onde as estruturas serão geradas


if(global.sair){
	global.estruturas_criadas = true;
	recriar_estruturas();
	obj_player.x = global.pos_x_map;
	obj_player.y = global.pos_y_map+300;
	global.sair = false;
	
}

