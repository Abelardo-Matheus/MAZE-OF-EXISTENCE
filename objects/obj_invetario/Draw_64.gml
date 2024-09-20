	 var _guiw = display_get_gui_width();
	var _guih = display_get_gui_height();

	var _mx = device_mouse_x_to_gui(0);
	var _my = device_mouse_y_to_gui(0);
	var item_esta_sendo_arrastado = item_selecionado != -1; // Verificar se está arrastando um item
	
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
		// Definir variáveis para os slots de status

	
		var ix_s = 0;
		var iy_s = 0;
	
	// Adicionar slots de status ao loop
	for (var i = 0; i < total_slots + 3; i++) { // Considerar os 3 slots adicionais (arma, armadura, bota)
	    var _slot_x, _slot_y;
	 
		 if (i < total_slots) {
	        // Desenhar slots do inventário
	        _slot_x = _invx + comeco_x + ((tamanho_slot_x + buffer) * ix);
	        _slot_y = _invy + comeco_y + ((tamanho_slot_y + buffer) * iy);
	    } else {
	        // Desenhar slots de status (um embaixo do outro)
	        var slot_index = i - total_slots; // Índice para slots de status (0 = arma, 1 = armadura, 2 = bota)
	        _slot_x = _invx + comeco_x_status; // Manter a posição horizontal constante
	        _slot_y = _invy + comeco_y_status + ((tamanho_slot_y + buffer) * slot_index); // Alterar a posição vertical
	    }
		
	
		
			if (i < total_slots && point_in_rectangle(_mx, _my, _slot_x, _slot_y, _slot_x + tamanho_slot_x, _slot_y + tamanho_slot_y)) {
				draw_sprite_ext(spr_selecionado,0,_slot_x,_slot_y,escala,escala,0,c_white,1);
			
				if (keyboard_check_pressed(ord("F"))and global.grid_itens[# Infos.item, i] != -1 ){
					var _inst = instance_create_layer(obj_player.x,obj_player.y,"instances",obj_item);

					_inst.sprite_index = global.grid_itens[# Infos.sprite, i];
					_inst.image_index = global.grid_itens[# Infos.item, i];
					_inst.quantidade = global.grid_itens[# Infos.quantidade, i];
					_inst.nome = global.grid_itens[# Infos.nome, i];
					_inst.descricao = global.grid_itens[# Infos.descricao, i];
					_inst.dano = global.grid_itens[# Infos.dano, i];
					_inst.armadura = global.grid_itens[# Infos.armadura, i];
					_inst.velocidade = global.grid_itens[# Infos.velocidade, i];
					_inst.cura = global.grid_itens[# Infos.cura, i];
					_inst.tipo = global.grid_itens[# Infos.tipo, i];
					_inst.ind = global.grid_itens[# Infos.image_ind, i];
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
					global.grid_itens[# Infos.image_ind, i] = -1;
					global.grid_itens[# Infos.sala_x, i] = -1;
					global.grid_itens[# Infos.sala_y, i] = -1;
					global.grid_itens[# Infos.pos_x, i] = -1;
					global.grid_itens[# Infos.pos_y, i] = -1;
					global.grid_itens[# Infos.tipo, i] = -1;
					global.grid_itens[# Infos.dano, i] = -1;
					global.grid_itens[# Infos.velocidade, i] = -1;
					global.grid_itens[# Infos.cura, i] = -1;
					global.grid_itens[# Infos.armadura, i] = -1;
				}
			
				 if (mouse_check_button_pressed(mb_left)) {
					if (item_selecionado == -1 && i < total_slots){
						item_selecionado = global.grid_itens[# Infos.item, i];
						pos_selecionada = i;
					}else if(item_selecionado != -1){
					
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
							global.grid_itens[# Infos.tipo, i] = global.grid_itens[# Infos.tipo, pos_selecionada];
							global.grid_itens[# Infos.sala_y, i] = global.grid_itens[# Infos.sala_y, pos_selecionada];
							global.grid_itens[# Infos.pos_x, i] = global.grid_itens[# Infos.pos_x, pos_selecionada];
							global.grid_itens[# Infos.cura, i] = global.grid_itens[# Infos.cura, pos_selecionada];
							global.grid_itens[# Infos.pos_y, i] = global.grid_itens[# Infos.pos_y, pos_selecionada];
							global.grid_itens[# Infos.dano, i] = global.grid_itens[# Infos.dano, pos_selecionada];
							global.grid_itens[# Infos.image_ind, i] = global.grid_itens[# Infos.image_ind, pos_selecionada];
							global.grid_itens[# Infos.armadura, i] = global.grid_itens[# Infos.armadura, pos_selecionada];
							global.grid_itens[# Infos.velocidade, i] = global.grid_itens[# Infos.velocidade, pos_selecionada];
					
							
							global.grid_itens[# Infos.item, pos_selecionada] = -1;
							global.grid_itens[# Infos.quantidade, pos_selecionada] = -1;
							global.grid_itens[# Infos.sprite, pos_selecionada] = -1;
							global.grid_itens[# Infos.nome, pos_selecionada] = -1;
							global.grid_itens[# Infos.descricao, pos_selecionada] = -1;
							global.grid_itens[# Infos.sala_x, pos_selecionada] = -1;
							global.grid_itens[# Infos.image_ind, pos_selecionada] = -1;
							global.grid_itens[# Infos.sala_y, pos_selecionada] = -1;
							global.grid_itens[# Infos.tipo, pos_selecionada] = -1;
							global.grid_itens[# Infos.pos_x, pos_selecionada] = -1;
							global.grid_itens[# Infos.pos_y, pos_selecionada] = -1;
							global.grid_itens[# Infos.cura, pos_selecionada] = -1;
							global.grid_itens[# Infos.dano, pos_selecionada] = -1;
							global.grid_itens[# Infos.velocidade, pos_selecionada] = -1;
							global.grid_itens[# Infos.armadura, pos_selecionada] = -1;
							item_selecionado = -1;
							pos_selecionada = -1;
						
						
						}else if(global.grid_itens[# Infos.item, pos_selecionada] != global.grid_itens[# Infos.item, i] or global.grid_itens[# Infos.sprite, pos_selecionada] != global.grid_itens[# Infos.sprite, i]){
							var _item = global.grid_itens[# Infos.item, i];
							var _quantidade = global.grid_itens[# Infos.quantidade, i];
							var _sprite = global.grid_itens[# Infos.sprite, i];
							var _nome = global.grid_itens[# Infos.nome, i];
							var _cura = global.grid_itens[# Infos.cura, i];
							var _descri = global.grid_itens[# Infos.descricao, i];
							var _sala_x = global.grid_itens[# Infos.sala_x, i];
							var _sala_y = global.grid_itens[# Infos.sala_y, i];
							var _pos_x = global.grid_itens[# Infos.pos_x, i];
							var _tipo = global.grid_itens[# Infos.tipo, i];
							var _ind = global.grid_itens[# Infos.image_ind, i];
							var _pos_y = global.grid_itens[# Infos.pos_y, i];
							var _dano = global.grid_itens[# Infos.dano, i];
							var _armadura = global.grid_itens[# Infos.armadura, i];
							var _velocidade = global.grid_itens[# Infos.velocidade, i];
						
							global.grid_itens[# Infos.item, i] = global.grid_itens[# Infos.item, pos_selecionada];
							global.grid_itens[# Infos.quantidade, i] = global.grid_itens[# Infos.quantidade, pos_selecionada];
							global.grid_itens[# Infos.sprite, i] = global.grid_itens[# Infos.sprite, pos_selecionada];
							global.grid_itens[# Infos.nome, i] = global.grid_itens[# Infos.nome, pos_selecionada];
							global.grid_itens[# Infos.descricao, i] = global.grid_itens[# Infos.descricao, pos_selecionada];
							global.grid_itens[# Infos.image_ind, i] = global.grid_itens[# Infos.image_ind, pos_selecionada];
							global.grid_itens[# Infos.tipo, i] = global.grid_itens[# Infos.tipo, pos_selecionada];
							global.grid_itens[# Infos.sala_x, i] = global.grid_itens[# Infos.sala_x, pos_selecionada];
							global.grid_itens[# Infos.sala_y, i] = global.grid_itens[# Infos.sala_y, pos_selecionada];
							global.grid_itens[# Infos.cura, i] = global.grid_itens[# Infos.cura, pos_selecionada];
							global.grid_itens[# Infos.pos_x, i] = global.grid_itens[# Infos.pos_y, pos_selecionada];
							global.grid_itens[# Infos.pos_y, i] = global.grid_itens[# Infos.pos_y, pos_selecionada];
							global.grid_itens[# Infos.dano, i] = global.grid_itens[# Infos.dano, pos_selecionada];
							global.grid_itens[# Infos.velocidade, i] = global.grid_itens[# Infos.velocidade, pos_selecionada];
							global.grid_itens[# Infos.armadura, i] = global.grid_itens[# Infos.armadura, pos_selecionada];
						
							global.grid_itens[# Infos.item, pos_selecionada] = _item;
							global.grid_itens[# Infos.quantidade, pos_selecionada] = _quantidade;
							global.grid_itens[# Infos.sprite, pos_selecionada] =  _sprite;
							global.grid_itens[# Infos.nome, pos_selecionada] =  _nome;
							global.grid_itens[# Infos.descricao, pos_selecionada] =  _descri;
							global.grid_itens[# Infos.sala_x, pos_selecionada] =  _sala_x;
							global.grid_itens[# Infos.tipo, pos_selecionada] =  _tipo;
							global.grid_itens[# Infos.image_ind, pos_selecionada] =  _ind;
							global.grid_itens[# Infos.sala_y, pos_selecionada] = _sala_y;
							global.grid_itens[# Infos.pos_x, pos_selecionada] =  _pos_x;
							global.grid_itens[# Infos.pos_y, pos_selecionada] =  _pos_y;
							global.grid_itens[# Infos.cura, pos_selecionada] =  _cura;
							global.grid_itens[# Infos.dano, pos_selecionada] =  _dano;
							global.grid_itens[# Infos.armadura, pos_selecionada] =  _armadura;
							global.grid_itens[# Infos.velocidade, pos_selecionada] =  _velocidade;
					
							item_selecionado = -1;
							pos_selecionada = -1;
						
						}
					
						//caso slot ja tenha trocar
					
					}
	
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
			
	
			
	
          
	            if (i >= total_slots && point_in_rectangle(_mx, _my, _slot_x, _slot_y, _slot_x + tamanho_slot_x, _slot_y + tamanho_slot_y)) {
	                draw_sprite_ext(spr_selecionado, 0, _slot_x, _slot_y, escala, escala, 0, c_white, 1);
			   
                 
	                // Verificar se o item pode ser equipado nos slots de status
	                if (mouse_check_button_released(mb_left) && item_esta_sendo_arrastado) {
						var item_tipo = global.grid_itens[# Infos.tipo, pos_selecionada];
						show_debug_message(item_tipo)
	                    if (i == total_slots && item_tipo == "arma" && slot_arma == -1) {
	    slot_arma = i;

	     // Transferir todas as informações do item do inventário para o slot de status
		global.grid_itens[# Infos.item, slot_arma] = global.grid_itens[# Infos.item, pos_selecionada];
		global.grid_itens[# Infos.quantidade, slot_arma] = global.grid_itens[# Infos.quantidade, pos_selecionada];
	    global.grid_itens[# Infos.sprite, slot_arma] = global.grid_itens[# Infos.sprite, pos_selecionada];
	    global.grid_itens[# Infos.image_ind, slot_arma] = global.grid_itens[# Infos.image_ind, pos_selecionada];
	    global.grid_itens[# Infos.nome, slot_arma] = global.grid_itens[# Infos.nome, pos_selecionada];
	    global.grid_itens[# Infos.descricao, slot_arma] = global.grid_itens[# Infos.descricao, pos_selecionada];
	    global.grid_itens[# Infos.dano, slot_arma] = global.grid_itens[# Infos.dano, pos_selecionada];
	    global.grid_itens[# Infos.armadura, slot_arma] = global.grid_itens[# Infos.armadura, pos_selecionada];
	    global.grid_itens[# Infos.velocidade, slot_arma] = global.grid_itens[# Infos.velocidade, pos_selecionada];
	    global.grid_itens[# Infos.cura, slot_arma] = global.grid_itens[# Infos.cura, pos_selecionada];
	    global.grid_itens[# Infos.tipo, slot_arma] = global.grid_itens[# Infos.tipo, pos_selecionada];
		
	    // Esvaziar o slot do inventário
	    global.grid_itens[# Infos.item, pos_selecionada] = -1;
	    global.grid_itens[# Infos.quantidade, pos_selecionada] = -1;
	    global.grid_itens[# Infos.sprite, pos_selecionada] = -1;
	    global.grid_itens[# Infos.nome, pos_selecionada] = -1;
	    global.grid_itens[# Infos.descricao, pos_selecionada] = -1;
	    global.grid_itens[# Infos.image_ind, pos_selecionada] = -1;
	    global.grid_itens[# Infos.sala_x, pos_selecionada] = -1;
	    global.grid_itens[# Infos.sala_y, pos_selecionada] = -1;
	    global.grid_itens[# Infos.pos_x, pos_selecionada] = -1;
	    global.grid_itens[# Infos.pos_y, pos_selecionada] = -1;
	    global.grid_itens[# Infos.tipo, pos_selecionada] = -1;
	    global.grid_itens[# Infos.dano, pos_selecionada] = -1;
	    global.grid_itens[# Infos.velocidade, pos_selecionada] = -1;
	    global.grid_itens[# Infos.cura, pos_selecionada] = -1;
	    global.grid_itens[# Infos.armadura, pos_selecionada] = -1;
	    // Transferir o image_index corretamente para o slot de status

		item_selecionado = -1;
		pos_selecionada = -1;
	} else if (i == total_slots + 1 && item_tipo == "armadura" && slot_armadura == -1) {
	    slot_armadura = i;    
	    // Transferir o image_index corretamente para o slot de statu
		global.grid_itens[# Infos.item, slot_armadura] = global.grid_itens[# Infos.item, pos_selecionada];
		global.grid_itens[# Infos.quantidade, slot_armadura] = global.grid_itens[# Infos.quantidade, pos_selecionada];
	    global.grid_itens[# Infos.sprite, slot_armadura] = global.grid_itens[# Infos.sprite, pos_selecionada];
	    global.grid_itens[# Infos.image_ind, slot_armadura] = global.grid_itens[# Infos.image_ind, pos_selecionada];
	    global.grid_itens[# Infos.nome, slot_armadura] = global.grid_itens[# Infos.nome, pos_selecionada];
	    global.grid_itens[# Infos.descricao, slot_armadura] = global.grid_itens[# Infos.descricao, pos_selecionada];
	    global.grid_itens[# Infos.dano, slot_armadura] = global.grid_itens[# Infos.dano, pos_selecionada];
	    global.grid_itens[# Infos.armadura, slot_armadura] = global.grid_itens[# Infos.armadura, pos_selecionada];
	    global.grid_itens[# Infos.velocidade, slot_armadura] = global.grid_itens[# Infos.velocidade, pos_selecionada];
	    global.grid_itens[# Infos.cura, slot_armadura] = global.grid_itens[# Infos.cura, pos_selecionada];
	    global.grid_itens[# Infos.tipo, slot_armadura] = global.grid_itens[# Infos.tipo, pos_selecionada];

	    // Esvaziar o slot do inventário
	    global.grid_itens[# Infos.item, pos_selecionada] = -1;
	    global.grid_itens[# Infos.quantidade, pos_selecionada] = -1;
	    global.grid_itens[# Infos.sprite, pos_selecionada] = -1;
	    global.grid_itens[# Infos.nome, pos_selecionada] = -1;
	    global.grid_itens[# Infos.descricao, pos_selecionada] = -1;
	    global.grid_itens[# Infos.image_ind, pos_selecionada] = -1;
	    global.grid_itens[# Infos.sala_x, pos_selecionada] = -1;
	    global.grid_itens[# Infos.sala_y, pos_selecionada] = -1;
	    global.grid_itens[# Infos.pos_x, pos_selecionada] = -1;
	    global.grid_itens[# Infos.pos_y, pos_selecionada] = -1;
	    global.grid_itens[# Infos.tipo, pos_selecionada] = -1;
	    global.grid_itens[# Infos.dano, pos_selecionada] = -1;
	    global.grid_itens[# Infos.velocidade, pos_selecionada] = -1;
	    global.grid_itens[# Infos.cura, pos_selecionada] = -1;
	    global.grid_itens[# Infos.armadura, pos_selecionada] = -1;
	    item_selecionado = -1;
	    pos_selecionada = -1;
	} else if (i == total_slots + 2 && item_tipo == "bota" && slot_bota == -1) {
	    slot_bota = i;
    
	    // Transferir o image_index corretamente para o slot de status
		global.grid_itens[# Infos.item, slot_bota] = global.grid_itens[# Infos.sprite, pos_selecionada];
		global.grid_itens[# Infos.quantidade, slot_bota] = global.grid_itens[# Infos.quantidade, pos_selecionada];
	     global.grid_itens[# Infos.sprite, slot_bota] = global.grid_itens[# Infos.sprite, pos_selecionada];
	    global.grid_itens[# Infos.image_ind, slot_bota] = global.grid_itens[# Infos.image_ind, pos_selecionada];
	    global.grid_itens[# Infos.nome, slot_bota] = global.grid_itens[# Infos.nome, pos_selecionada];
	    global.grid_itens[# Infos.descricao, slot_bota] = global.grid_itens[# Infos.descricao, pos_selecionada];
	    global.grid_itens[# Infos.dano, slot_bota] = global.grid_itens[# Infos.dano, pos_selecionada];
	    global.grid_itens[# Infos.armadura, slot_bota] = global.grid_itens[# Infos.armadura, pos_selecionada];
	    global.grid_itens[# Infos.velocidade, slot_bota] = global.grid_itens[# Infos.velocidade, pos_selecionada];
	    global.grid_itens[# Infos.cura, slot_bota] = global.grid_itens[# Infos.cura, pos_selecionada];
	    global.grid_itens[# Infos.tipo, slot_bota] = global.grid_itens[# Infos.tipo, pos_selecionada];

	    // Esvaziar o slot do inventário
	    global.grid_itens[# Infos.item, pos_selecionada] = -1;
	    global.grid_itens[# Infos.quantidade, pos_selecionada] = -1;
	    global.grid_itens[# Infos.sprite, pos_selecionada] = -1;
	    global.grid_itens[# Infos.nome, pos_selecionada] = -1;
	    global.grid_itens[# Infos.descricao, pos_selecionada] = -1;
	    global.grid_itens[# Infos.image_ind, pos_selecionada] = -1;
	    global.grid_itens[# Infos.sala_x, pos_selecionada] = -1;
	    global.grid_itens[# Infos.sala_y, pos_selecionada] = -1;
	    global.grid_itens[# Infos.pos_x, pos_selecionada] = -1;
	    global.grid_itens[# Infos.pos_y, pos_selecionada] = -1;
	    global.grid_itens[# Infos.tipo, pos_selecionada] = -1;
	    global.grid_itens[# Infos.dano, pos_selecionada] = -1;
	    global.grid_itens[# Infos.velocidade, pos_selecionada] = -1;
	    global.grid_itens[# Infos.cura, pos_selecionada] = -1;
	    global.grid_itens[# Infos.armadura, pos_selecionada] = -1;
	    item_selecionado = -1;
	    pos_selecionada = -1;
	}else {
	                        show_debug_message("Este item não pode ser equipado nesse slot!");
                        
	                        // Voltar o item para o slot de origem
	                        global.grid_itens[# Infos.item, pos_selecionada] = item_selecionado;
                        
	                        // Resetar as variáveis de seleção
	                        item_selecionado = -1;
	                        pos_selecionada = -1;
	                    }
	
		
					}
		

				if (i == total_slots && slot_arma != -1) {
				draw_set_font(fnt_descricao);
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
			
				descricao = global.grid_itens[# Infos.descricao, slot_arma];
		
				draw_text_outlined_wrapped_block(_invx +(238*escala),_invy+(277*escala),_invx +(408*escala+30),_invy+(331*escala+50), c_black, c_white,descricao,30);
				draw_set_font(fnt_nomes_itens);
				nome = global.grid_itens[# Infos.nome, slot_arma];
				draw_text_outlined(_invx + (comeco_x_nome*escala)+110, _invy+(comeco_y_nome*escala)+23, c_black, c_white,nome);
			
				}else if(i == total_slots+1 && slot_armadura != -1){
					draw_set_font(fnt_descricao);
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
			
				descricao = global.grid_itens[# Infos.descricao, slot_armadura];
			
				draw_text_outlined_wrapped_block(_invx +(238*escala),_invy+(277*escala),_invx +(408*escala+30),_invy+(331*escala+50), c_black, c_white,descricao,30);
				draw_set_font(fnt_nomes_itens);
				nome = global.grid_itens[# Infos.nome, slot_armadura];
				draw_text_outlined(_invx + (comeco_x_nome*escala)+110, _invy+(comeco_y_nome*escala)+23, c_black, c_white,nome);
				}else if(i == total_slots+2 && slot_bota != -1){
						draw_set_font(fnt_descricao);
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
			
				descricao = global.grid_itens[# Infos.descricao, slot_bota];
			
				draw_text_outlined_wrapped_block(_invx +(238*escala),_invy+(277*escala),_invx +(408*escala+30),_invy+(331*escala+50), c_black, c_white,descricao,30);
				draw_set_font(fnt_nomes_itens);
				nome = global.grid_itens[# Infos.nome, slot_bota];
				draw_text_outlined(_invx + (comeco_x_nome*escala)+110, _invy+(comeco_y_nome*escala)+23, c_black, c_white,nome);
				}
	
   

    // Detect right-click on status slot
    if (i >= total_slots && mouse_check_button_pressed(mb_right) && !item_esta_sendo_arrastado ) {
		slot_item = -1;
        if (i == total_slots && slot_arma != -1) {
            slot_item = slot_arma;
        }else if (i == total_slots + 1 && slot_armadura != -1) {
            slot_item = slot_armadura;
        }else if (i == total_slots + 2 && slot_bota != -1) {
            slot_item = slot_bota;
        }

        if (slot_item != -1) {
            // Find an empty inventory slot
            for (var j = 0; j < total_slots; j++) {
                if (global.grid_itens[# Infos.item, j] == -1) {
                    // Move the item from status slot to the empty inventory slot
					
                    global.grid_itens[# Infos.item, j] = global.grid_itens[# Infos.item, slot_item];
					global.grid_itens[# Infos.quantidade, j] = global.grid_itens[# Infos.quantidade, slot_item];
                    global.grid_itens[# Infos.sprite, j] = global.grid_itens[# Infos.sprite, slot_item];
                    global.grid_itens[# Infos.nome, j] = global.grid_itens[# Infos.nome, slot_item];
                    global.grid_itens[# Infos.descricao, j] = global.grid_itens[# Infos.descricao, slot_item];
                    global.grid_itens[# Infos.image_ind, j] = global.grid_itens[# Infos.image_ind, slot_item];
                    global.grid_itens[# Infos.tipo, j] = global.grid_itens[# Infos.tipo, slot_item];
                    global.grid_itens[# Infos.dano, j] = global.grid_itens[# Infos.dano, slot_item];
                    global.grid_itens[# Infos.armadura, j] = global.grid_itens[# Infos.armadura, slot_item];
                    global.grid_itens[# Infos.velocidade, j] = global.grid_itens[# Infos.velocidade, slot_item];
                    global.grid_itens[# Infos.cura, j] = global.grid_itens[# Infos.cura, slot_item];
                    show_debug_message("Item moved to inventory slot: " + string(j));
show_debug_message("Item: " + string(global.grid_itens[# Infos.item, slot_item]));
show_debug_message("Quantidade: " + string(global.grid_itens[# Infos.quantidade, slot_item]));
show_debug_message("Sprite: " + string(global.grid_itens[# Infos.sprite, j]));
show_debug_message("Nome: " + global.grid_itens[# Infos.nome, j]);
show_debug_message("Descricao: " + global.grid_itens[# Infos.descricao, j]);
show_debug_message("Image Index: " + string(global.grid_itens[# Infos.image_ind, j]));
show_debug_message("Tipo: " + global.grid_itens[# Infos.tipo, j]);
show_debug_message("Dano: " + string(global.grid_itens[# Infos.dano, j]));
show_debug_message("Armadura: " + string(global.grid_itens[# Infos.armadura, j]));
show_debug_message("Velocidade: " + string(global.grid_itens[# Infos.velocidade, j]));
show_debug_message("Cura: " + string(global.grid_itens[# Infos.cura, j]));
                    // Clear the status slot
                    global.grid_itens[# Infos.item, slot_item] = -1;
                    global.grid_itens[# Infos.sprite, slot_item] = -1;
					global.grid_itens[# Infos.quantidade, slot_item] = -1;
                    global.grid_itens[# Infos.nome, slot_item] = -1;
					global.grid_itens[# Infos.image_ind, slot_item] = -1;
                    global.grid_itens[# Infos.descricao, slot_item] = -1;
                    global.grid_itens[# Infos.tipo, slot_item] = -1;
                    global.grid_itens[# Infos.dano, slot_item] = -1;
                    global.grid_itens[# Infos.armadura, slot_item] = -1;
                    global.grid_itens[# Infos.velocidade, slot_item] = -1;
                    global.grid_itens[# Infos.cura, slot_item] = -1;

                    // Clear the slot indicator
                    if (i == total_slots) slot_arma = -1;
                    else if (i == total_slots + 1) slot_armadura = -1;
                    else if (i == total_slots + 2) slot_bota = -1;

                    break;
                }
            }
        
    }

    // Continue with your existing drawing and interaction logic here...
}

            
	        }
	     // Desenhar os itens equipados nos slots de status corretamente com seus image_index
	        if (i == total_slots && slot_arma != -1) {
	            // Desenhar o sprite da arma no slot de status
	            var sprite_arma = global.grid_itens[# Infos.sprite, slot_arma];
	            var image_index_arma = global.grid_itens[# Infos.image_ind, slot_arma];
	            if (sprite_arma != -1 && image_index_arma != -1) {
	                draw_sprite_ext(sprite_arma, image_index_arma, _slot_x, _slot_y, escala, escala, 0, c_white, 1);
	            }
	        } else if (i == total_slots + 1 && slot_armadura != -1) {
	            // Desenhar o sprite da armadura no slot de status
	            var sprite_armadura = global.grid_itens[# Infos.sprite, slot_armadura];
	            var image_index_armadura = global.grid_itens[# Infos.image_ind, slot_armadura];
	            if (sprite_armadura != -1 && image_index_armadura != -1) {
	                draw_sprite_ext(sprite_armadura, image_index_armadura, _slot_x, _slot_y, escala, escala, 0, c_white, 1);
	            }
	        } else if (i == total_slots + 2 && slot_bota != -1) {
	            // Desenhar o sprite da bota no slot de status
	            var sprite_bota = global.grid_itens[# Infos.sprite, slot_bota];
	            var image_index_bota = global.grid_itens[# Infos.image_ind, slot_bota];
	            if (sprite_bota != -1 && image_index_bota != -1) {
	                draw_sprite_ext(sprite_bota, image_index_bota, _slot_x, _slot_y, escala, escala, 0, c_white, 1);
	            }
	        }

			var _sprit = global.grid_itens[# Infos.sprite, i];
			if(global.grid_itens[# Infos.item, i] != -1){
				draw_sprite_ext(_sprit,global.grid_itens[# Infos.image_ind, i], _slot_x, _slot_y, escala,escala,0,c_white,1);
				draw_set_font(fnt_numeros);
				draw_set_halign(fa_center);
				draw_text_outlined(_slot_x+tamanho_slot_x-15, _slot_y+tamanho_slot_y- 30, c_black, c_white, global.grid_itens[# Infos.quantidade, i]);
			}
			
     
			
       
		
			ix++;
		if( ix >= slots_h){
			ix = 0;
			iy++;
			}
		
		// Atualizar índices de status (slots verticais)
	    if (i >= total_slots) {
	        ix_s++;
	        if (ix_s >= slot_status_h) {
	            ix_s = 0;
	            iy_s++;
	        }
	    }
		
	
		
		
		}
	
	

	
		if(item_selecionado != -1){
			draw_sprite_ext(global.grid_itens[# Infos.sprite, pos_selecionada],  global.grid_itens[# Infos.image_ind, pos_selecionada], _mx-50, _my-50, escala, escala, 0,c_white, 0.5)
		
		}
		draw_set_font(fnt_status);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_color(c_black);
		var vida_string = "LIFE: " + string(global.vida) + "/" + string(global.vida_max);
		var ataque = "ATK: " +  string(global.ataque);
		var velo = "SPD: " + string( global.speed_player);
		var armadura = "DEF: " +  string(global.armadura_bebe);
		draw_text(_invx +(370 * escala), _invy +(183 * escala),ataque)
	
		draw_text(_invx +(370 * escala), _invy +(183 * escala + 35),velo);
	
		draw_text(_invx +(370 * escala), _invy +(183 * escala + 70),vida_string);
	
		draw_text(_invx +(370 * escala), _invy +(183 * escala + 105),armadura);
	
		draw_sprite_ext(spr_sombra,0,_invx +(443 * escala), _invy +(155 * escala ),3,3,0,c_white,1);
		draw_sprite_ext(spr_player_baixo_parado,obj_player.image_index,_invx +(442 * escala), _invy +(126 * escala ),4,4,0,c_white,1);

	
	

	
	
	}