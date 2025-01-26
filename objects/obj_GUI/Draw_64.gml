if(global.level_up == true){
	draw_set_alpha(.7);
	draw_rectangle_color(0, 0, display_get_gui_width(), display_get_gui_height(), c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
	
		var _scala_hud = 1;
		var _scala_up = 1;
		var _sprh = sprite_get_height(spr_level_up_hud) * _scala_hud;
		var _sprw = sprite_get_width(spr_level_up_hud) * _scala_hud;
		var _buffer = 50;
		var _buffer_2 = 23
		var _buffer_3 = 0;
		var _xx = 270;
		var _yy = display_get_gui_height()/2;
		
		var _my = device_mouse_y_to_gui(0);
		var _mx = device_mouse_x_to_gui(0);
		
	for(var i = 0; i < global.upgrade_num; i++){
		var _sprx =  _xx +(_sprw +_buffer) * i;
		var _y = global.upgrades_list[| i];
		var _name = global.upgrades_grid[# Upgrades.Name, _y];
		var _descrption = global.upgrades_grid[# Upgrades.description, _y];
		if(point_in_rectangle(_mx, _my, _sprx - _sprw/2, _yy - _sprh/2, _sprx + _sprw/2 , _yy + _sprh/2)){
			upgrade_alpha = 1;
			_scala_hud += .2;
			_buffer_2 = -8;
			_buffer_3 = 65;

		}else{
			upgrade_alpha = .75;
			_scala_hud = 1;
			_buffer_2 = 23;
			_buffer_3= 0;
		}
		
		draw_sprite_ext(spr_level_up_hud, -1,_sprx, _yy ,_scala_hud,_scala_hud,0,c_white,upgrade_alpha);
		draw_sprite_ext(spr_ups_vamp, _y, _sprx, _yy-(_sprh/4)+_buffer_2,_scala_hud,_scala_hud,0,c_white,upgrade_alpha);
		
		
		draw_set_font(fnt_nomes_up);
		draw_set_color(c_black);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_colour_outline(_sprx,_yy-(_sprh/2)-_buffer_3 , _name, 4, c_white, 8, 100, 100);
		
		
		draw_set_font(fnt_descricao);
		draw_text_colour_outline_escalado(_sprx,_yy+(_sprh/4)-90, _descrption, 3, c_white, 7, 30, 300,_scala_hud,_scala_hud);




	}
	alarm[0]++;
	exit;	
}
desenha_barra_vida();