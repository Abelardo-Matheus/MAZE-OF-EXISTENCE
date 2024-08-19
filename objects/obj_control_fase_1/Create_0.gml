/// @description Configuração inicial da fase com geração procedural
randomize();
// Definir o tamanho das células e da room
window_set_fullscreen(true);
global.cell_size = 64;
global.room_width = 1920;
global.room_height = 1088;
global.sala_passada = noone;
global.current_sala = [0, 0];  // Sala inicial é sempre a sala [0, 0]
global.maze_width = (global.room_width div global.cell_size);
global.maze_height = (global.room_height div global.cell_size);
// Inicializar o mapa global para armazenar as paredes das salas
global.salas_com_paredes = ds_map_create();


// Criar grids de controle da room
global.maze = ds_grid_create(global.maze_width , global.maze_height);
global.visited = ds_grid_create(global.maze_width , global.maze_height );

global.salas_geradas = gera_salas_procedurais(global.total_rooms);

// Inicialize o minimapa com a cor padrão (branca)
global.minimap = [];
for (var i = 0; i < array_length_1d(global.salas_geradas); i++) {
    global.minimap[i] = c_white;  // Todas as salas começam com cor branca
}

create_random_ovulo(global.salas_geradas);
criar_sala_distante_com_templo(global.current_sala,global.salas_geradas);
create_pontos_em_salas_aleatorias(global.salas_geradas, 10,5); // Criar até 5 pontos em salas aleatórias
carregar_sala(global.current_sala,global.current_sala);
recriar_pontos_na_sala_atual(global.current_sala);

instance_create_layer(global.room_width / 2 + 32, global.room_height / 2, "Layer_Player", obj_SPERM);
// Restaura as paredes no grid da sala [1, 2]
sala_tuto();



