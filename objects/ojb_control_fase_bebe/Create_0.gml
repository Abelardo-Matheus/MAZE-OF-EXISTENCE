// Evento Create do obj_control_fase_bebe

// Inicializar variáveis globais
global.current_level = 1;


// Inicializar grids
global._maze = ds_grid_create(global._maze_width + 2, global._maze_height + 2);
global.visited = ds_grid_create(global._maze_width + 2, global._maze_height + 2);

// Criar e gerar salas pela primeira vez
resetar_fase_por_level();
instance_create_layer(global.room_width / 2 + 32, global.room_height / 2, "Layer_Player", obj_player);
