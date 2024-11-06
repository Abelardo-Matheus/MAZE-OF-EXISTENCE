function action_end(){
	with(obj_cutscene){
	action++;
		if(action >= array_length(cutscene_data)){
			instance_destroy();
		}
	} 
}
function scr_cutscenes_wait(_secs){
	timer ++;
	if(timer >= (room_speed*_secs)){
		timer = 0;
		action_end();
	}
}

function scr_cutscenes_move_obj(_id, _x, _y, _relative, _spd){
	if(obj_cutscene.x_dest == -1){
		if(!_relative){
		obj_cutscene.x_dest = _x;
		obj_cutscene.y_dest = _y;
		}else{
			obj_cutscene.x_dest = _id.x+_x;
			obj_cutscene.y_dest = _id.y+_y;
		}
	}
	
	
	var _xx = obj_cutscene.x_dest;
	var _yy = obj_cutscene.y_dest;
	
	with(_id){
		if(point_distance(x, y, _xx, _yy) >= _spd){
			var _dir = point_direction(x, y, _xx, _yy);
			var _hspd = lengthdir_x(_spd, _dir);
			var _vspd = lengthdir_y(_spd, _dir)
		
			x += _hspd;
			y += _vspd;
		}else{
			 x = _xx;
			 y = _yy;
		 
			 obj_cutscene.x_dest = -1;
			 obj_cutscene.y_dest = -1;
			 action_end();
		}
	}
}


function scr_play_sound_cutscene(_snd, _loop){
	audio_play_sound(_snd, 1 , _loop);
	action_end();
}
function scr_stop_sound_cutscene(_snd){
	audio_stop_sound(_snd);
	action_end();
}

function scr_create_instance_cutescene(_x, _y, _layer, _obj){
	instance_create_layer(_x, _y, _layer, _obj);
	action_end();
}

function scr_destroy_instance_cutescene(_obj){
	instance_destroy(_obj)
	action_end();
}

function scr_xscale_cutescene(_id, _xcale){
	if (_xcale != undefined){
		_id.image_xscale = _xcale;
	}else {
		_id.image_xscale *= -1;
	}
	action_end();
	
}

function scr_cutscene_change_spr(_id, _spr){
	_id.image_index = 0;
	_id.sprite_index = _spr;
	action_end();
}

function scr_cutscene_change_variable(_id, _varstring, _value){
	variable_instance_set(_id, _varstring, _value);
	action_end();
	
}
function scr_acaba_cut(_obj){
	   _obj.cutscene_active = false;    
}
function start_cutscene(new_cutscene) {
	 obj_cutscene.cutscene_data = new_cutscene;  
     obj_cutscene.cutscene_active = true;    
}



