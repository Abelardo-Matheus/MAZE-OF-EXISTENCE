if(global.level_up == true){
	alarm[0]++;
	image_speed = 0;
	exit;	
}else{
	image_speed = 1;
}

image_xscale = escala;
image_yscale = escala;
script_execute(state);


if (vida <= 0) {
	remover_inimigo_por_id(global.current_sala, inimigo_id);
	var _xp = instance_create_layer(x, y, "instances", obj_xp_um);
	_xp.xp_multiplicador = lvl_inimigo*10 + (vida/100);
    instance_destroy();
	obj_player.alarm[6] =  3;
	criar_item_aleatorio_passivos_pe(x,y,depth,100);
}

if (instance_exists(obj_camera)and !global.day_night_cycle.is_day){
var _border = 64;
if(y < global.cmy - _border){
	y = global.cmy + global.cmh + _border;
}
if(y > global.cmy + global.cmh + _border){
	y = global.cmy - _border;
}
if(x < global.cmx - _border){
	x = global.cmx + global.cmw + _border;	
}
if(x > global.cmx + global.cmw + _border){
	x = global.cmx - _border;
}
}






