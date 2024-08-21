randomize();
window_set_fullscreen(true);
criar_chao_room_inteira(global.maze_width,global.maze_height,global.maze);

criar_paredes_borda_sem_circular(global.maze_width,global.maze_height,global.maze,global.distancia_parede_templo,global.distancia_parede_templo);

if (global.direcao_templo == 2) { 
    // Veio da direita
    pos_x = 80;  // Posição à frente do prev_room
    pos_y = (global.room_height / 2);
    direction = 0;
  
   
    ds_grid_set(global.maze, global.x_meio_esquerda, global.y_meio_esquerda, 1); // Ajustar as coordenadas para o grid
	
	for(i = 1;i < 5;i++){
		ds_grid_set(global.maze, global.x_meio_esquerda-i, global.y_meio_esquerda-1, 0);
		ds_grid_set(global.maze, global.x_meio_esquerda-i, global.y_meio_esquerda+1, 0);
	}

    // Criar o templo
    var templo = instance_create_layer(-32, (global.room_height / 2), "instances", obj_goto_templo);

} else if (global.direcao_templo == 4) {  
    // Veio da esquerda
    pos_x = global.room_width - 150;  // Posição à frente do prev_room
    pos_y = (global.room_height / 2);
    direction = 180;

    // Destruir a parede direita
    ds_grid_set(global.maze, global.x_meio_direita, global.y_meio_direita, 1);
		for(i = 1;i < 5;i++){
		ds_grid_set(global.maze, global.x_meio_direita+i, global.y_meio_esquerda-1, 0);
		ds_grid_set(global.maze, global.x_meio_direita+i, global.y_meio_esquerda+1, 0);
	}
    // Transformar a posição no maze em chão (índice 1)
    ds_grid_set(global.maze, global.x_meio_direita, global.y_meio_direita, 1);

    // Criar o templo
    instance_create_layer(global.room_width + 32, (global.room_height / 2), "instances", obj_goto_templo);

} else if (global.direcao_templo == 3) {  
    // Veio de baixo
    pos_x = (global.room_width / 2);
    pos_y = 80;  // Posição à frente do prev_room
    direction = 90;

    ds_grid_set(global.maze, global.x_meio_superior-1, global.y_meio_superior, 1);
	ds_grid_set(global.maze, global.x_meio_superior, global.y_meio_superior, 1);
	for(i = 1;i < 5;i++){
		ds_grid_set(global.maze, global.x_meio_superior-2, global.y_meio_superior-i, 0);
		ds_grid_set(global.maze, global.x_meio_superior+1, global.y_meio_superior-i, 0);
	}

    // Transformar a posição no maze em chão (índice 1)
    ds_grid_set(global.maze, global.x_meio_superior-1, global.y_meio_superior, 1);

    // Criar o templo
	 instance_create_layer((global.room_width / 2) - 32, -32, "instances", obj_goto_templo);
    instance_create_layer((global.room_width / 2) + 32, -32, "instances", obj_goto_templo);

} else if (global.direcao_templo == 1) {  
    // Veio de cima
    pos_x = (global.room_width / 2);
    pos_y = global.room_height - 80;  // Posição à frente do prev_room
    direction = 270;

    // Destruir a parede abaixo
    ds_grid_set(global.maze, global.x_meio_inferior-1, global.y_meio_inferior, 1);
	ds_grid_set(global.maze, global.x_meio_inferior, global.y_meio_inferior, 1);
    // Transformar a posição no maze em chão (índice 1)
	for(i = 1;i < 5;i++){
		ds_grid_set(global.maze, global.x_meio_inferior-2, global.y_meio_inferior+i, 0);
		ds_grid_set(global.maze, global.x_meio_inferior+1, global.y_meio_inferior+i, 0);
	}

    // Criar o templo
	instance_create_layer((global.room_width / 2) - 32, global.room_height + 32, "instances", obj_goto_templo);
    instance_create_layer((global.room_width / 2) + 32, global.room_height + 32, "instances", obj_goto_templo);
}

	criar_paredes_vermelha_intances(global.maze_width,global.maze_height,global.maze,global.cell_size);

	instance_create_layer(pos_x, pos_y, "Layer_Player", obj_SPERM);
	// Escolher um poder aleatório da listr
	poderes();
	//var poder_escolhido = ds_list_find_value(global.lista_poderes, ds_list_size(global.lista_poderes)-1);
	//var objeto_escolhido = global.lista_poderes(poder_escolhido);
	var objeto_escolhido = ds_list_find_value(global.lista_poderes, 0);
	instance_create_layer(global.room_width/2, global.room_height/2, "Layer_poder", objeto_escolhido);


   











