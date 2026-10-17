// feather disable GM2017
/// @desc obj_horde — Create
/// [O QUE]: Gerenciador único da horda noturna. Criado pelo obj_control_vamp.
/// [COMO] : Pré-aloca todos os arrays (pool) uma única vez. Os tipos de inimigo são
///          gerados sob demanda a partir de global.night_waves.
_horde_init();
spawn_x = 0;
spawn_y = 0;
grid_total = 0;
