// feather disable GM2017
// HORDA: aplica o golpe em todos da horda dentro da hitbox antes de sumir
calcular_critico();
horde_hit_instance(id, global.ataque, 20 + global.ataque, obj_player.x, obj_player.y, -1, -1, (global.critico == 1));

instance_destroy();













