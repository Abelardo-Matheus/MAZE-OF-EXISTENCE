calcular_critico();
other.vida -= global.ataque;

var _dir = point_direction(obj_player.x,obj_player.y,other.x,other.y);
other.alarm[6] = 5;
other.hit = true;
if(global.critico == 1){
var _inst = instance_create_layer(x,y,"instances",obj_dano);
_inst.alvo = other;
_inst.dano = global.ataque;
_inst.cor = c_red;
_inst.fonte = fnt_dano_crit;
}else{
	var _inst = instance_create_layer(x,y,"instances",obj_dano);
_inst.alvo = other;
_inst.dano = global.ataque;
}



