
if(other.tomar_dano == true){
var _dir = point_direction(x,y,other.x,other.y);
other.empurrar_dir = _dir;
other.state = scr_personagem_hit;
other.alarm[2] = 10;
other.alarm[3] = 180;
other.tomar_dano = false;
global.vida -= 5;
var _inst = instance_create_layer(x,y,"instances",obj_dano);
_inst.alvo = other;
_inst.dano = 5;
_inst.cor = c_red;


}


