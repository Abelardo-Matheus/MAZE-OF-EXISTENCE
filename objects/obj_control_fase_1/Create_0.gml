/// @description Configuração inicial da fase com geração procedural
randomize();
// Definir o tamanho das células e da room
window_set_fullscreen(true);




create_inimigos_em_salas_aleatorias(global.salas_geradas, 10,1);
create_torretas_em_salas_aleatorias(global.salas_geradas, 5,1);
create_random_ovulo(global.salas_geradas);
criar_sala_distante_com_templo(global.current_sala,global.salas_geradas);
create_pontos_em_salas_aleatorias(global.salas_geradas, 10,5); // Criar até 5 pontos em salas aleatórias
carregar_sala(global.current_sala,global.current_sala);
recriar_pontos_na_sala_atual(global.current_sala);


instance_create_layer(global.room_width / 2 + 32, global.room_height / 2, "Layer_Player", obj_SPERM);
// Restaura as paredes no grid da sala [1, 2]
sala_tuto();



