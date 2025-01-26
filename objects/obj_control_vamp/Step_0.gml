if(global.level_up == true){
	alarm[0]++;
	exit;	
}

var _side = irandom(1);

if(alarm[0] <= 0){
	if(_side == 0){
		var _xx = irandom_range(global.cmx, global.cmx + global.cmw);
		var _yy = choose(global.cmy - 64, global.cmy +global.cmh + 64);
	
		var _inimigoA = instance_create_layer(_xx, _yy, "instances", obj_amoeba);
		_inimigoA.dist_aggro = 2000;
		_inimigoA.dist_desaggro =2000;
		_inimigoA.escala = 1.5;

	}if(_side == 1){
		var _xx = choose(global.cmx - 64, global.cmx + global.cmw + 64);
		var _yy = irandom_range(global.cmy, global.cmy + global.cmh);
		
		var _inimigoB = instance_create_layer(_xx, _yy, "instances", obj_amoeba);
		_inimigoB.dist_aggro = 2000;
		_inimigoB.dist_desaggro =2000
		_inimigoB.escala = 1.5;
	}
	
	alarm[0] = spaw_timer;
}

