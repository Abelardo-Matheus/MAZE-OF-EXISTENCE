if(other.tomar_dano == true){
global.vida -= damage;
instance_destroy();
var _inst = instance_create_layer(x,y,"instances",obj_dano);
_inst.alvo = other;
other.alarm[2] = 10;
other.alarm[3] = 100;
_inst.dano = damage;
_inst.cor = c_red;
other.tomar_dano = false;
}












