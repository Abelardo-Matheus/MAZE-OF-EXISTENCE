// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function carregar_templo(direcao){

criar_chao_room_inteira(global.maze_width,global.maze_height,global.maze);
criar_paredes_borda_sem_circular(global.maze_width,global.maze_height,global.maze,global.distancia_parede_templo,global.distancia_parede_templo);

if (direcao == 2) { 

    ds_grid_set(global.maze, global.x_meio_esquerda, global.y_meio_esquerda, 1); // Ajustar as coordenadas para o grid
	
	for(i = 1;i < 5;i++){
		ds_grid_set(global.maze, global.x_meio_esquerda-i, global.y_meio_esquerda-1, 0);
		ds_grid_set(global.maze, global.x_meio_esquerda-i, global.y_meio_esquerda+1, 0);
	}

  

} else if (direcao == 4) {  

    // Destruir a parede direita
    ds_grid_set(global.maze, global.x_meio_direita, global.y_meio_direita, 1);
		for(i = 1;i < 5;i++){
		ds_grid_set(global.maze, global.x_meio_direita+i, global.y_meio_esquerda-1, 0);
		ds_grid_set(global.maze, global.x_meio_direita+i, global.y_meio_esquerda+1, 0);
	}
    // Transformar a posição no maze em chão (índice 1)
    ds_grid_set(global.maze, global.x_meio_direita, global.y_meio_direita, 1);


} else if (direcao == 3) {  


    ds_grid_set(global.maze, global.x_meio_superior-1, global.y_meio_superior, 1);
	ds_grid_set(global.maze, global.x_meio_superior, global.y_meio_superior, 1);
	for(i = 1;i < 5;i++){
		ds_grid_set(global.maze, global.x_meio_superior-2, global.y_meio_superior-i, 0);
		ds_grid_set(global.maze, global.x_meio_superior+1, global.y_meio_superior-i, 0);
	}

    // Transformar a posição no maze em chão (índice 1)
    ds_grid_set(global.maze, global.x_meio_superior-1, global.y_meio_superior, 1);



} else if (direcao == 1) {    

    // Destruir a parede abaixo
    ds_grid_set(global.maze, global.x_meio_inferior-1, global.y_meio_inferior, 1);
	ds_grid_set(global.maze, global.x_meio_inferior, global.y_meio_inferior, 1);
    // Transformar a posição no maze em chão (índice 1)
	for(i = 1;i < 5;i++){
		ds_grid_set(global.maze, global.x_meio_inferior-2, global.y_meio_inferior+i, 0);
		ds_grid_set(global.maze, global.x_meio_inferior+1, global.y_meio_inferior+i, 0);
	}


    
}

	criar_paredes_vermelha_intances(global.maze_width,global.maze_height,global.maze,global.cell_size);
	global.objeto_escolhido = procurar_poder(global.poder_escolhido);
	if(!global.objeto_escolhido.coletado){
	instance_create_layer(global.room_width/2, global.room_height/2, "instances", global.objeto_escolhido.objeto);
	}

   





}