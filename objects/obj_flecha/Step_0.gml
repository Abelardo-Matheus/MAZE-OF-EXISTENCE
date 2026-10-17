// feather disable GM2017


var _inst = instance_create_layer(x,y,"instances", obj_flecha_efeito);
_inst.sprite_index = sprite_index;

_inst.direction = direction;
_inst.image_angle = image_angle;

// HORDA: acerta um inimigo e some (igual ao Collision_par_inimigos)
if (horde_hit_instance(id, global.ataque, 20 + global.ataque, obj_player.x, obj_player.y, -1, 1) > 0) {
    instance_destroy();
}
