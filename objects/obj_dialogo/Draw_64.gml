if(inicializar = true){
	var _guiw = display_get_gui_width();
	var _guih = display_get_gui_height();

	var _xx = 0;
	var _yy = _guih - 200;
	var _c = c_black;
	var _sprite = texto_grid[# infos.retrato, pagina];
	var _text = string_copy( texto_grid[# infos.texto, pagina], 0, caracter);

	if(texto_grid[# infos.lado, pagina] == 0){
	draw_rectangle_color(_xx + 200, _yy, _guiw, _guih, _c, _c, _c, _c, false);
	draw_set_font(fnt_dialogos);
	draw_text_ext(_xx+ 232,_yy+32, _text, 32, _guiw - 264);
	draw_text(_xx + 216, _yy - 32, texto_grid[# infos.nome, pagina])
	draw_sprite_ext(_sprite, 0 , 100, _guih, 6, 6, 0 , c_white, 1);
	}else{
	draw_rectangle_color(_xx, _yy, _guiw - 200, _guih, _c, _c, _c, _c, false);
	var _stgw = string_width(texto_grid[# infos.nome, pagina]);
	draw_set_font(fnt_dialogos);
	draw_text_ext(_xx+32,_yy+32, _text, 32, _guiw - 264);
	draw_text(_guiw - 216 - _stgw, _yy - 32, texto_grid[# infos.nome, pagina])
	draw_sprite_ext(_sprite, 0 , _guiw-100, _guih, -6, 6, 0 , c_white, 1);
	}
	if(op_draw ){
		var _opx = _xx + 32;
		var _opy = _yy - 48;
		var _opsep = 48;
		var _op_borda = 6;
		
		op_selecionada += keyboard_check_pressed(ord("W")) - keyboard_check_pressed(ord("S"));
		op_selecionada = clamp(op_selecionada, 0, op_num - 1);
		
		for(var i = 0; i< op_num; i++){
			draw_set_font(fnt_escolhas);
			var _stringw = string_width(op[i]);
			draw_sprite_ext(spr_bloco, 0,_opx, _opy - (_opsep * i),(_stringw+_op_borda*2)/16,1,0,c_white,1);
			draw_text(_opx+_op_borda, _opy - (_opsep * i)-3, op[i]);
			
			if(op_selecionada = i){
				draw_sprite(spr_seletor, 0,_xx+15, _opy - (_opsep * i)+15)
			}
			
		}
		
		if(keyboard_check_pressed(ord("E"))){
			var _dialogo = instance_create_layer(x , y, "Instances_dialogo", obj_dialogo);
			_dialogo.npc_nome = op_resposta[op_selecionada];
			instance_destroy();
			
		}
	}
}










