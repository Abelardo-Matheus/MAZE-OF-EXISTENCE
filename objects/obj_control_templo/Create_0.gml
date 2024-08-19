
window_set_fullscreen(true);
criar_chao_room_inteira(global.maze_width,global.maze_height+1,global.maze);

criar_paredes_borda_sem_circular(global.maze_width-1,global.maze_height-1,global.maze);

if (global.direcao_templo == 2) { 
    // Veio da direita
    pos_x = 80;  // Posição à frente do prev_room
    pos_y = (global.room_height / 2);
    direction = 0;
    
    // Destruir a parede esqurda
    var parede_direita = instance_position(64, (global.room_height / 2), obj_wall_vermelha);
    if (parede_direita != noone) {
        instance_destroy(parede_direita);
    }
    
    // Transformar a posição no maze em chão (índice 1)
    ds_grid_set(global.maze, 0, floor(global.room_height / global.cell_size / 2), 1); // Ajustar as coordenadas para o grid
	
    // Criar o templo
    var templo = instance_create_layer(-32, (global.room_height / 2), "instances", obj_goto_templo);

} else if (global.direcao_templo == 4) {  
    // Veio da esquerda
    pos_x = global.room_width - 150;  // Posição à frente do prev_room
    pos_y = (global.room_height / 2);
    direction = 180;

    // Destruir a parede direita
    var parede_esquerda = instance_position(global.room_width - 64, (global.room_height / 2), obj_wall_vermelha);
    if (parede_esquerda != noone) {
        instance_destroy(parede_esquerda);
    }

    // Transformar a posição no maze em chão (índice 1)
    ds_grid_set(global.maze, global.maze_width-2, floor(global.room_height / global.cell_size / 2), 1);

    // Criar o templo
    instance_create_layer(global.room_width + 32, (global.room_height / 2), "instances", obj_goto_templo);

} else if (global.direcao_templo == 3) {  
    // Veio de baixo
    pos_x = (global.room_width / 2);
    pos_y = 80;  // Posição à frente do prev_room
    direction = 90;

    // Destruir a parede acima
    var parede_abaixo = instance_position((global.room_width / 2), 64, obj_wall_vermelha);
    if (parede_abaixo != noone) {
        instance_destroy(parede_abaixo);
    }

    // Transformar a posição no maze em chão (índice 1)
    ds_grid_set(global.maze, floor(global.room_width / global.cell_size / 2)-1, 0, 1);

    // Criar o templo
    instance_create_layer((global.room_width / 2) + 32, -32, "instances", obj_goto_templo);

} else if (global.direcao_templo == 1) {  
    // Veio de cima
    pos_x = (global.room_width / 2);
    pos_y = global.room_height - 80;  // Posição à frente do prev_room
    direction = 270;

    // Destruir a parede abaixo
    var parede_acima = instance_position((global.room_width / 2), global.room_height - 64, obj_wall_vermelha);
    if (parede_acima != noone) {
        instance_destroy(parede_acima);
    }

    // Transformar a posição no maze em chão (índice 1)
	
    ds_grid_set(global.maze, floor(global.room_width / global.cell_size / 2)-1, global.maze_height -2,1);

    // Criar o templo
    instance_create_layer((global.room_width / 2) + 32, global.room_height + 32, "instances", obj_goto_templo);
}

	criar_paredes_vermelha_intances(global.maze_width,global.maze_height,global.maze,global.cell_size);

	instance_create_layer(pos_x, pos_y+32, "Layer_Player", obj_SPERM);













