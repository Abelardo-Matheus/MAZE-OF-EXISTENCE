dist_aggro =  global.dist_aggro_amoeba;
dist_desaggro = global.dist_desaggro_amoeba;
sprite_normal = spr_amoeba_vermelha;
sprite_parado = spr_amoeba_vermelha_parada;
event_inherited();

if(vida <=0){
	repeat(3)
	var _int = instance_create_layer(x,y,"instances",obj_amoeba_laranja);
	_int.vida = vida/2;
	_int.escala = escala - 0.5;
	_int.dano = dano/2;
}

