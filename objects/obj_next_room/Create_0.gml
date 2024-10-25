/// Create Event do obj_next_room
room_destino = noone; // Definir o destino da próxima sala
room_origem =noone;
index = false;


// Contar o número total de inimigos na sala (todos os inimigos que têm 'par_inimigos' como parente)
var total_inimigos = instance_number(par_inimigos)+instance_number(par_boss);

