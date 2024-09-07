function resetar_variaveis_globais() {
	global.current_sala = [0, 0];
	resetar_salas();
    // Limpar e recriar global.salas_com_pontos

	
	 if (ds_exists(global.salas_com_vela,ds_type_map)) {
        ds_map_clear(global.salas_com_vela);
    } else {
        global.salas_com_vela = ds_map_create();
    }
	
	 if (ds_exists(global.salas_com_escrivaninha,ds_type_map)) {
        ds_map_clear(global.salas_com_escrivaninha);
    } else {
        global.salas_com_escrivaninha = ds_map_create();
    }
	
	
	

	
	 if (ds_exists(global.salas_com_escada_porao,ds_type_map)) {
        ds_map_clear(global.salas_com_escada_porao);
    } else {
        global.salas_com_escada_porao = ds_map_create();
    }

    if (ds_exists(global.salas_com_pontos,ds_type_map)) {
        ds_map_clear(global.salas_com_pontos);
    } else {
        global.salas_com_pontos = ds_map_create();
    }
	
	 if (ds_exists(global.room_positions,ds_type_list)) {
        ds_list_clear(global.room_positions);
    } else {
        global.room_positions = ds_list_create();
    }


    // Limpar e recriar global.salas_com_inimigos
    if (ds_exists(global.salas_com_inimigos,ds_type_map)) {
        ds_map_clear(global.salas_com_inimigos);
    } else {
        global.salas_com_inimigos = ds_map_create();
    }

    // Limpar e recriar global.salas_com_torretas
    if (ds_exists(global.salas_com_torretas,ds_type_map)) {
        ds_map_clear(global.salas_com_torretas);
    } else {
        global.salas_com_torretas = ds_map_create();
    }

    // Limpar e recriar global.salas_com_slow
    if (ds_exists(global.salas_com_slow,ds_type_map)) {
        ds_map_clear(global.salas_com_slow);
    } else {
        global.salas_com_slow = ds_map_create();
    }
	if (is_array(global.salas_geradas)) {
        array_resize(global.salas_geradas, 0); // Limpa o array
    } else {
        global.salas_geradas = []; // Cria um array vazio
    }

    // Limpar e recriar global.salas_com_paredes
    if (ds_exists(global.salas_com_paredes,ds_type_map)) {
        ds_map_clear(global.salas_com_paredes);
    } else {
        global.salas_com_paredes = ds_map_create();
    }
   
    // Resetar a variável global.templos_salas_pos (array)
    if (is_array(global.templos_salas_pos)) {
        array_resize(global.templos_salas_pos, 0); // Limpa o array
    } else {
        global.templos_salas_pos = []; // Cria um array vazio
    }
	if (is_array(global.salas_escuras)) {
        array_resize(global.salas_escuras, 0); // Limpa o array
    } else {
     	global.salas_escuras = [];
    }


	

}