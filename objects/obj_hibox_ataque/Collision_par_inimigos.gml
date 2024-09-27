
   other.vida -= global.ataque;

var _dir = point_direction(obj_player.x,obj_player.y,other.x,other.y);
other.empurrar_dir = _dir;
other.empurrar_veloc = 10;
other.state = scr_inimigo_hit;
other.alarm[1] = 5;
other.hit = true;
var _inst = instance_create_layer(x,y,"instances",obj_dano);
_inst.alvo = other;
_inst.dano = global.ataque;


