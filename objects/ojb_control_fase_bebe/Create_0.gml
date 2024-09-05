
randomize();
salas();
global.maze = ds_grid_create(global.maze_width+2 , global.maze_height+2);
global.visited = ds_grid_create(global.maze_width+2 , global.maze_height+2 );
global.salas_geradas = gera_salas_procedurais(global.total_rooms);


// Para cada sala gerada, criar a sala na lista global e armazenar
for (var i = 0; i < array_length_1d(global.salas_geradas); i++) {
    var sala_info = criar_salas_lista(global.salas_geradas[i], i + 1);
    array_push(global.salas_criadas, sala_info);
}
create_vela_em_quarto3(global.salas_geradas);
recriar_vela_na_sala_atual(global.current_sala);
create_slow_em_salas_aleatorias(global.salas_geradas, 10,2);
criar_salas_distantes_com_templos(global.current_sala,global.salas_geradas,1);
criar_salas_escuras(global.current_sala,global.salas_geradas,1);

create_pontos_em_salas_aleatorias(global.salas_geradas, 10,5); // Criar até 5 pontos em salas aleatórias
carregar_sala(global.current_sala,global.current_sala);
create_inimigos_em_salas_aleatorias(global.salas_geradas,10,2);
instance_create_layer(global.room_width / 2 + 32, global.room_height / 2, "Layer_Player", obj_player);
recriar_pontos_na_sala_atual(global.current_sala);
recriar_inimigos_na_sala_atual(global.current_sala);
recriar_slow_na_sala_atual(global.current_sala);

sala_tuto();


global.minimap = [];
for (var i = 0; i < array_length_1d(global.salas_geradas); i++) {
    global.minimap[i] = c_white;  // Todas as salas começam com cor branca
}





