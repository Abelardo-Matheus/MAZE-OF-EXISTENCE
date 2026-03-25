// 1. Dá o dano e Knockback
other.vida -= damage;

var _dir = point_direction(obj_player.x, obj_player.y, other.x, other.y);
other.empurrar_dir = _dir;
other.empurrar_veloc = push; // Note que no script vc chama de push_force
other.state = scr_inimigo_hit;
other.alarm[1] = 5;
other.hit = true;

var _inst = instance_create_layer(x, y, "Instances", obj_dano);
_inst.alvo = other;
_inst.dano = damage;

// 2. Estoura e some imediatamente!
// Se tiver um obj_explosao_visual, você pode criá-lo aqui antes de destruir
instance_destroy();