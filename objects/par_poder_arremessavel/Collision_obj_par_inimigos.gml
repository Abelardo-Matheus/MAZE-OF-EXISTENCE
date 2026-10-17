// feather disable GM2017
if (inimigo_colisao_ignorar(other)) exit; // fantasma especial sem o item de matar fantasma
var _damage = damage;
other.vida -= _damage;

var _dir = point_direction(obj_player.x,obj_player.y,other.x,other.y);
other.empurrar_dir = _dir;
other.empurrar_veloc = push;
other.state = scr_inimigo_hit;
other.alarm[1] = 5;
other.hit = true;

var _inst = instance_create_layer(x,y,"instances",obj_dano);
_inst.alvo = other;
_inst.dano = _damage;


// (removido: o dano era aplicado DUAS vezes — "other.vida -= _damage" lá em cima já basta)


