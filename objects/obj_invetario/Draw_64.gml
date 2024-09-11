var _guiw = display_get_gui_width();
var _guih = display_get_gui_height();

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);


if(inventario == true){
	draw_set_alpha(0.7);
	draw_set_color(c_black);
	draw_rectangle(0,0,_guiw,_guih,false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	
	
	var _invx = _guiw/2 - inventario_w/2;
	var _invy = _guih/2 - inventario_h/2;
	draw_sprite_ext(spr_iinventario, 0 ,_invx,_invy,escala,escala,0,c_white,1);
	
	var ix = 0;
	var iy = 0;
	for(var i = 0; i< total_slots; i++){
		
		var _slot_x = _invx + comeco_x + ((tamanho_slot_x + buffer)*ix);
		var _slot_y = _invy +comeco_y + ((tamanho_slot_y + buffer)*iy);
		
		
		
		if point_in_rectangle(_mx, _my, _slot_x, _slot_y, _slot_x + tamanho_slot_x, _slot_y +tamanho_slot_y){
			draw_sprite_ext(spr_selecionado,0,_slot_x,_slot_y,escala,escala,0,c_white,1);
			
			if (keyboard_check_pressed(ord("F"))and global.grid_itens[# Infos.item, i] != -1){
				var _inst = instance_create_layer(obj_player.x,obj_player.y,"instances",obj_item);

				_inst.sprite_index = global.grid_itens[# Infos.sprite, i];
				_inst.image_index = global.grid_itens[# Infos.item, i];
				_inst.quantidade = global.grid_itens[# Infos.quantidade, i];
				_inst.nome = global.grid_itens[# Infos.nome, i];
				_inst.descricao = global.grid_itens[# Infos.descricao, i];
				_inst.sala_x = global.current_sala[0];
				_inst.sala_y = global.current_sala[1];
				_inst.pos_x = obj_player.x;
				_inst.pos_y = obj_player.y;
				

				salvar_item(_inst.sala_x,_inst.sala_y,obj_player.x,obj_player.y,_inst);
				
				//esvaziar slot
				global.grid_itens[# Infos.item, i] = -1;
				global.grid_itens[# Infos.quantidade, i] = -1;
				global.grid_itens[# Infos.sprite, i] = -1;
				global.grid_itens[# Infos.nome, i] = -1;
				global.grid_itens[# Infos.descricao, i] = -1;
				global.grid_itens[# Infos.sala_x, i] = -1;
				global.grid_itens[# Infos.sala_y, i] = -1;
				global.grid_itens[# Infos.pos_x, i] = -1;
				global.grid_itens[# Infos.pos_y, i] = -1;
			}
			
			if(mouse_check_button_pressed(mb_left)){
				//caso não tenha item
				if (item_selecionado == -1){
					item_selecionado = global.grid_itens[# Infos.item, i];
					pos_selecionada = i;
				}else{
					// caso seja igual ao do slot stack
					if( item_selecionado == global.grid_itens[# Infos.item, i] and pos_selecionada != i and global.grid_itens[# Infos.sprite, i] == global.grid_itens[# Infos.sprite, pos_selecionada]){
						global.grid_itens[# Infos.quantidade, i] += global.grid_itens[# Infos.quantidade, pos_selecionada];
						global.grid_itens[# Infos.item, pos_selecionada] = -1;
						global.grid_itens[# Infos.quantidade, pos_selecionada] = -1;
						item_selecionado = -1;
						pos_selecionada = -1;
					}else if (global.grid_itens[# Infos.item, i] == -1){
						global.grid_itens[# Infos.item, i] = global.grid_itens[# Infos.item, pos_selecionada];
						global.grid_itens[# Infos.quantidade, i] = global.grid_itens[# Infos.quantidade, pos_selecionada];
						global.grid_itens[# Infos.sprite, i] = global.grid_itens[# Infos.sprite, pos_selecionada];
						global.grid_itens[# Infos.nome, i] = global.grid_itens[# Infos.nome, pos_selecionada];
						global.grid_itens[# Infos.descricao, i] = global.grid_itens[# Infos.descricao, pos_selecionada];
						global.grid_itens[# Infos.sala_x, i] = global.grid_itens[# Infos.sala_x, pos_selecionada];
						global.grid_itens[# Infos.sala_y, i] = global.grid_itens[# Infos.sala_y, pos_selecionada];
						global.grid_itens[# Infos.pos_x, i] = global.grid_itens[# Infos.pos_x, pos_selecionada];
						global.grid_itens[# Infos.pos_y, i] = global.grid_itens[# Infos.pos_y, pos_selecionada];
					
							
						global.grid_itens[# Infos.item, pos_selecionada] = -1;
						global.grid_itens[# Infos.quantidade, pos_selecionada] = -1;
						global.grid_itens[# Infos.sprite, pos_selecionada] = -1;
						global.grid_itens[# Infos.nome, pos_selecionada] = -1;
						global.grid_itens[# Infos.descricao, pos_selecionada] = -1;
						global.grid_itens[# Infos.sala_x, pos_selecionada] = -1;
						global.grid_itens[# Infos.sala_y, pos_selecionada] = -1;
						global.grid_itens[# Infos.pos_x, pos_selecionada] = -1;
						global.grid_itens[# Infos.pos_y, pos_selecionada] = -1;
						item_selecionado = -1;
						pos_selecionada = -1;
						
						
					}else if(global.grid_itens[# Infos.item, pos_selecionada] != global.grid_itens[# Infos.item, i] or global.grid_itens[# Infos.sprite, pos_selecionada] != global.grid_itens[# Infos.sprite, i]){
						var _item = global.grid_itens[# Infos.item, i];
						var _quantidade = global.grid_itens[# Infos.quantidade, i];
						var _sprite = global.grid_itens[# Infos.sprite, i];
						var _nome = global.grid_itens[# Infos.nome, i];
						var _descri = global.grid_itens[# Infos.descricao, i];
						var _sala_x = global.grid_itens[# Infos.sala_x, i];
						var _sala_y = global.grid_itens[# Infos.sala_y, i];
						var _pos_x = global.grid_itens[# Infos.pos_x, i];
						var _pos_y = global.grid_itens[# Infos.pos_y, i];
						
						global.grid_itens[# Infos.item, i] = global.grid_itens[# Infos.item, pos_selecionada];
						global.grid_itens[# Infos.quantidade, i] = global.grid_itens[# Infos.quantidade, pos_selecionada];
						global.grid_itens[# Infos.sprite, i] = global.grid_itens[# Infos.sprite, pos_selecionada];
						global.grid_itens[# Infos.nome, i] = global.grid_itens[# Infos.nome, pos_selecionada];
						global.grid_itens[# Infos.descricao, i] = global.grid_itens[# Infos.descricao, pos_selecionada];
						global.grid_itens[# Infos.sala_x, i] = global.grid_itens[# Infos.sala_x, pos_selecionada];
						global.grid_itens[# Infos.sala_y, i] = global.grid_itens[# Infos.sala_y, pos_selecionada];
						global.grid_itens[# Infos.pos_x, i] = global.grid_itens[# Infos.pos_y, pos_selecionada];
						global.grid_itens[# Infos.pos_y, i] = global.grid_itens[# Infos.pos_y, pos_selecionada];
						
						global.grid_itens[# Infos.item, pos_selecionada] = _item;
						global.grid_itens[# Infos.quantidade, pos_selecionada] = _quantidade;
						global.grid_itens[# Infos.sprite, pos_selecionada] =  _sprite;
						global.grid_itens[# Infos.nome, pos_selecionada] =  _nome;
						global.grid_itens[# Infos.descricao, pos_selecionada] =  _descri;
						global.grid_itens[# Infos.sala_x, pos_selecionada] =  _sala_x;
						global.grid_itens[# Infos.sala_y, pos_selecionada] = _sala_y;
						global.grid_itens[# Infos.pos_x, pos_selecionada] =  _pos_x;
						global.grid_itens[# Infos.pos_y, pos_selecionada] =  _pos_y;
					
						item_selecionado = -1;
						pos_selecionada = -1;
						
					}
					
					//caso slot ja tenha trocar
					
				}
	
				
				//caso ja tenha
				
			}
			
			draw_set_font(fnt_descricao);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			if(global.grid_itens[# Infos.item, i] != -1){
			descricao = global.grid_itens[# Infos.descricao, i];
			draw_text_outlined_wrapped_block(_invx +(238*escala),_invy+(277*escala),_invx +(408*escala+30),_invy+(331*escala+50), c_black, c_white,descricao,30);
			
			draw_set_font(fnt_nomes_itens);
			
			nome = global.grid_itens[# Infos.nome, i];
			draw_text_outlined(_invx + (comeco_x_nome*escala)+110, _invy+(comeco_y_nome*escala)+23, c_black, c_white,nome);
			}
	
			
		}	
		var _sprit = global.grid_itens[# Infos.sprite, i];
		if(global.grid_itens[# Infos.item, i] != -1){
			draw_sprite_ext(_sprit,global.grid_itens[# 0, i], _slot_x, _slot_y, escala,escala,0,c_white,1);
			
			draw_set_font(fnt_numeros);
			draw_set_halign(fa_center);
			draw_text_outlined(_slot_x+tamanho_slot_x-15, _slot_y+tamanho_slot_y- 30, c_black, c_white, global.grid_itens[# Infos.quantidade, i]);
		}
			
		
		
		
		
		ix++;
	if( ix >= slots_h){
		ix = 0;
		iy++;
		}
		
	}
	
	if(mouse_check_button_pressed(mb_right)){
		item_selecionado = -1;
		pos_selecionada = -1;
	}
	
	if(item_selecionado != -1){
		draw_sprite_ext(global.grid_itens[# Infos.sprite, pos_selecionada], item_selecionado, _mx-50, _my-50, escala, escala, 0,c_white, 0.5)
		
	}
	
}





