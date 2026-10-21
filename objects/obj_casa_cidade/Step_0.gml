// feather disable GM2017
/// @desc Entrada (F) e transparência vêm do obj_estrutura; aqui só a animação
event_inherited();

anim = (anim + anim_vel) mod 4;
var _noite = variable_global_exists("day_night_cycle") && global.day_night_cycle.current_light <= 0.7;
image_index = floor(anim) + (_noite ? 4 : 0);
