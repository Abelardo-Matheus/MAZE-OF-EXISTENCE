
other.vida -= global.ataque;
audio_play_sound(snd_damage, 1, false);
var _dir = point_direction(obj_player.x,obj_player.y,other.x,other.y);
other.alarm[6] = 5;
other.hit = true;
	var _inst = instance_create_layer(x,y,"instances",obj_dano);
_inst.alvo = other;
_inst.dano = global.ataque;
instance_destroy();




