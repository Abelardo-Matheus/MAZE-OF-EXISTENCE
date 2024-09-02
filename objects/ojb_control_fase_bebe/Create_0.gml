
randomize();
global.maze = ds_grid_create(global.maze_width+2 , global.maze_height+2);
global.visited = ds_grid_create(global.maze_width+2 , global.maze_height+2 );
global.salas_geradas = gera_salas_procedurais(global.total_rooms);
global.current_sala = [0, 0];  // Sala inicial é sempre a sala [0, 0]

create_slow_em_salas_aleatorias(global.salas_geradas, 10,2);
criar_salas_distantes_com_templos(global.current_sala,global.salas_geradas,1);
create_pontos_em_salas_aleatorias(global.salas_geradas, 10,5); // Criar até 5 pontos em salas aleatórias
carregar_sala(global.current_sala,global.current_sala);
recriar_pontos_na_sala_atual(global.current_sala);
instance_create_layer(global.room_width / 2 + 32, global.room_height / 2, "Layer_Player", obj_player);
recriar_slow_na_sala_atual(global.current_sala);
sala_tuto();


global.minimap = [];
for (var i = 0; i < array_length_1d(global.salas_geradas); i++) {
    global.minimap[i] = c_white;  // Todas as salas começam com cor branca
}









