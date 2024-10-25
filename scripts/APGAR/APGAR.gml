function limpar_sala_jardim() {
    // Verificar se a sala atual é a sala do jardim
   

        // Limpar qualquer dado armazenado em ds_maps globais para a sala de jardim
        var sala_id = string(global.sala_jardim[0]) + "_" + string(global.sala_jardim[1]);

        if (ds_map_exists(global.salas_com_inimigos, sala_id)) {
            ds_map_delete(global.salas_com_inimigos, sala_id);
        }

        if (ds_map_exists(global.salas_com_torretas, sala_id)) {
            ds_map_delete(global.salas_com_torretas, sala_id);
        }

        if (ds_map_exists(global.salas_com_pontos, sala_id)) {
            ds_map_delete(global.salas_com_pontos, sala_id);
        }

        if (ds_map_exists(global.salas_com_slow, sala_id)) {
            ds_map_delete(global.salas_com_slow, sala_id);
        }

        if (ds_map_exists(global.salas_com_escada_porao, sala_id)) {
            ds_map_delete(global.salas_com_escada_porao, sala_id);
        }
		
		 if (ds_map_exists(global.salas_com_escrivaninha, sala_id)) {
            ds_map_delete(global.salas_com_escrivaninha, sala_id);
        }


        // Você pode adicionar aqui a exclusão de outros objetos que deseja remover do jardim
    
}
