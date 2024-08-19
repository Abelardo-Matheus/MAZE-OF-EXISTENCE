// Desativar todas as instâncias, exceto obj_controle

instance_deactivate_all(true); // Desativa todas as instância
// Reativar o obj_controle manualmente para que ele não seja destruído
instance_activate_object(obj_control_fase_1);

// Evento de colisão com `obj_next_room` ou `obj_prev_room`
if(vinda ==0){
room_goto(TEMPLO);	
}else{
room_goto_previous();
}

    // Carregar a nova sala

    var sala_destino = room_destino;  // Sala que você está indo
	show_debug_message(global.current_sala);
    carregar_sala(sala_destino, room_origem);
	recriar_pontos_na_sala_atual(global.current_sala);


    
	
// Mudar para a sala TEMPLO











