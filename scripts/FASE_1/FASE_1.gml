global.cell_size = 64;
global.total_rooms = 10; // Ajuste conforme necessário
global.room_width = 1920;
global.room_height = 1088;
global.sala_passada = noone;
global.current_sala = [0, 0];  // Sala inicial é sempre a sala [0, 0]
global.maze_width = (global.room_width div global.cell_size);
global.maze_height = (global.room_height div global.cell_size);
// Inicializar o mapa global para armazenar as paredes das salas
global.salas_com_paredes = ds_map_create();
// Criar grids de controle da room
global.maze = ds_grid_create(global.maze_width+2 , global.maze_height+2);
global.visited = ds_grid_create(global.maze_width+2 , global.maze_height+2 );
global.salas_geradas = gera_salas_procedurais(global.total_rooms);

// Inicialize o minimapa com a cor padrão (branca)
global.minimap = [];
for (var i = 0; i < array_length_1d(global.salas_geradas); i++) {
    global.minimap[i] = c_white;  // Todas as salas começam com cor branca
}

// Gerar salas procedurais
global.xp = 0;
num_salas = 10;
global.tamanho_player = 1;
global.tamanho_player_max = 5;
global.direcao_templo = 0;
global.vinda_templo = 0;
global.origem_templo = noone;
global.destino_templo = noone;
global.distancia_parede_templo = 4; 
global.map = false;
global.full = false;
global.speed_player = 7;
global.dificuldade = 1;
global.tamanho_lab = 128 / global.dificuldade;
global.cell_size = 64;
global.recorde = 0;

//Player_SPERM
global.vida_inicial = 6;
