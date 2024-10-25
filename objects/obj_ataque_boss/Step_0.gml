if (fim_animation()){
	var _dir = 0;
	repeat(4){
		var _inst = instance_create_layer(x, y, "instances", obj_projetil_boss);
		_inst.speed = 3;
		_inst.direction = _dir;
		_dir +=90;
		_inst.damage = 15;
	}
	
	instance_destroy();
}