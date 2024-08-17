/// @description Configuração inicial da fase com geração procedural
randomize();
// Definir o tamanho das células e da room
window_set_fullscreen(false);
global.cell_size = 64;
global.room_width = 1920;
global.room_height = 1088;
global.sala_passada = noone;
global.current_sala = [0, 0];  // Sala inicial é sempre a sala [0, 0]
global.maze_width = (global.room_width div global.cell_size);
global.maze_height = (global.room_height div global.cell_size);

// Criar grids de controle da room
global.maze = ds_grid_create(global.maze_width + 2, global.maze_height + 2);
global.visited = ds_grid_create(global.maze_width + 2, global.maze_height + 2);

global.salas_geradas = gera_salas_procedurais(global.total_rooms);

// Inicialize o minimapa com a cor padrão (branca)
global.minimap = [];
for (var i = 0; i < array_length_1d(global.salas_geradas); i++) {
    global.minimap[i] = c_white;  // Todas as salas começam com cor branca
}
// Carregar a primeira sala gerada

create_random_ovulo(global.salas_geradas);
cria_salas_e_objetos(global.maze_width, global.maze_height, global.maze, global.cell_size);
//criar_portas_gerais(global.current_sala,global.salas_geradas);
criar_portas_gerais(global.current_sala,global.salas_geradas);
create_pontos_em_salas_aleatorias(global.salas_geradas, 10,5); // Criar até 5 pontos em salas aleatórias
recriar_pontos_na_sala_atual(global.current_sala);
instance_create_layer(global.room_width / 2 + 32, global.room_height / 2, "Layer_Player", obj_SPERM);
if (global.current_sala[0] == 0 && global.current_sala[1] == 0) {
   
	
	instance_create_layer(global.room_width/2+32,global.room_height/2-200,"instances",obj_seta);	
}


