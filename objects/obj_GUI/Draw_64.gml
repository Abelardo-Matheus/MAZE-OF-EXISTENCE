if(global.level_up == true){
	draw_set_alpha(.7);
	draw_rectangle_color(0, 0, display_get_gui_width(), display_get_gui_height(), c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
	
		var _scala_hud = 6;
		var _sprh = sprite_get_height(spr_level_up_hud) * _scala_hud;
		var _sprw = sprite_get_width(spr_level_up_hud) * _scala_hud;
		var _buffer = 50;
		var _xx = 270;
		var _yy = display_get_gui_height()/2;
		
		var _my = device_mouse_y_to_gui(0);
		var _mx = device_mouse_x_to_gui(0);
		
	for(var i = 0; i < upgrade_num; i++){
		var _sprx =  _xx +(_sprw +_buffer) * i;
		if(point_in_rectangle(_mx, _my, _sprx - _sprw/2, _yy - _sprh/2, _sprx + _sprw/2 , _yy + _sprh/2)){
			upgrade_alpha = 1;
			_scala_hud += 1;
		}else{
			upgrade_alpha = .75;
			_scala_hud = 6;
		}
		
		draw_sprite_ext(spr_level_up_hud, -1,_sprx, _yy ,_scala_hud,_scala_hud+1,0,c_white,upgrade_alpha);
	}
	alarm[0]++;
	exit;	
}
desenha_barra_vida();