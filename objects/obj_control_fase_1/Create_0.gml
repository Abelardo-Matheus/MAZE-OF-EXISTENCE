salas();
randomize();
global._maze = ds_grid_create(global._maze_width+2 , global._maze_height+2);
global.visited = ds_grid_create(global._maze_width+2 , global._maze_height+2 );
global.salas_geradas = gera_salas_procedurais(global.total_rooms);

window_set_fullscreen(true);
global.current_sala = [0, 0];  // Sala inicial é sempre a sala [0, 0]
create_inimigos_em_salas_aleatorias(global.salas_geradas, 5,1);
create_slow_em_salas_aleatorias(global.salas_geradas, 10,7);
create_random_ovulo(global.salas_geradas);
criar_salas_distantes_com_templos(global.current_sala,global.salas_geradas,1);
create_pontos_em_salas_aleatorias(global.salas_geradas, 10,5); // Criar até 5 pontos em salas aleatórias
carregar_sala(global.current_sala,global.current_sala);
recriar_pontos_na_sala_atual(global.current_sala);
recriar_slow_na_sala_atual(global.current_sala);
instance_create_layer(global.room_width / 2 + 32, global.room_height / 2, "Layer_Player", obj_SPERM);
sala_tuto();


global.minimap = [];
for (var i = 0; i < array_length_1d(global.salas_geradas); i++) {
    global.minimap[i] = c_white;  // Todas as salas começam com cor branca
}

