// Função para resetar todas as fases e recriar de acordo com o nível
function resetar_fase_por_level() {
	randomize();
	global.level_fase ++;
    // Destruir as grids antigas, se existirem
    if (ds_exists(global._maze, ds_type_grid)) {
        ds_grid_destroy(global._maze);
    }
    if (ds_exists(global.visited, ds_type_grid)) {
        ds_grid_destroy(global.visited);
    }
	salas();
	
    // Criar as grids novamente
    global._maze = ds_grid_create(global._maze_width + 2, global._maze_height + 2);
    global.visited = ds_grid_create(global._maze_width + 2, global._maze_height + 2);

    // Limpar arrays de salas e criar novas salas
    global.salas_geradas = gera_salas_procedurais(global.total_rooms);
    global.salas_criadas = [];
	
    // Criar salas distantes com templos
    criar_salas_distantes_com_templos(global.current_sala, global.salas_geradas, 1);

    // Para cada sala gerada, criar a sala e armazená-la
    for (var i = 0; i < array_length_1d(global.salas_geradas); i++) {
        var sala_info = criar_salas_lista(global.salas_geradas[i], i + 1);
        array_push(global.salas_criadas, sala_info);
    }

    // Gerar inimigos e itens com base no nível atual
    gerar_inimigos_e_itens_para_o_nivel(global.salas_geradas, global.level_fase);
	
    // Criar os objetos específicos nas salas
    create_escrivaninha(global.salas_geradas, 3, 1);
    create_geladeira(global.salas_geradas, 1, 1);
    create_guarda_roupa(global.salas_geradas, 1, 1);
    recriar__geladeira_na_sala_atual(global.current_sala);
	create_escada_porao_em_fundos(global.salas_geradas);
    criar_salas_escuras(global.current_sala, global.salas_geradas, 3);
    create_pontos_em_salas_aleatorias(global.salas_geradas, 10, 5);  // Criar até 5 pontos em salas aleatórias

    // Recarregar a sala atual
    carregar_sala(global.current_sala, global.current_sala);
    
    // Criar inimigos em salas escuras
    create_inimigos_em_salas_escuras(2);
	
	sala_tuto();
    
    global.minimap = [];
    for (var i = 0; i < array_length_1d(global.salas_geradas); i++) {
        global.minimap[i] = c_white;  // Todas as salas começam com cor branca
    }
}



function resetar_variaveis_globais() {
	global.current_sala = [0, 0];
	resetar_salas();
	
	if (ds_exists(global.salas_com_amoeba,ds_type_map)) {
        ds_map_clear(global.salas_com_amoeba);
    } else {
        global.salas_com_amoeba = ds_map_create();
    }
	
	if (ds_exists(global.salas_com_inimigos,ds_type_map)) {
        ds_map_clear(global.salas_com_inimigos);
    } else {
        global.salas_com_inimigos = ds_map_create();
    }
	
	
	
	if (ds_exists(global.salas_com_geladeira,ds_type_map)) {
        ds_map_clear(global.salas_com_geladeira);
    } else {
        global.salas_com_geladeira = ds_map_create();
    }

	
	if (ds_exists(global.salas_com_guarda_roupa,ds_type_map)) {
        ds_map_clear(global.salas_com_guarda_roupa);
    } else {
        global.salas_com_guarda_roupa = ds_map_create();
    }

	 if (ds_exists(global.sala_com_item_drop,ds_type_map)) {
        ds_map_clear(global.sala_com_item_drop);
    } else {
        global.sala_com_item_drop = ds_map_create();
    }
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
	
	
	 if (ds_exists(global.salas_com_fantasma,ds_type_map)) {
        ds_map_clear(global.salas_com_fantasma);
    } else {
        global.salas_com_fantasma = ds_map_create();
    }
	
	


	global.templo_criado = false;
    global.inimigo_id_count = 0; // Reiniciar o contador de IDs de inimigos
}