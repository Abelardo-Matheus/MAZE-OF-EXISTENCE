function limpar_sala_jardim() {
    // Construir o ID único da sala (String)
    var _room_id = string(global.sala_jardim[0]) + "_" + string(global.sala_jardim[1]);

    // CONFIGURAÇÃO: Lista de todos os ds_maps que devem ser limpos
    var _maps_to_clean = [
        global.salas_com_inimigos,
        global.salas_com_torretas,
        global.salas_com_pontos,
        global.salas_com_slow,
        global.salas_com_escada_porao,
        global.salas_com_escrivaninha
    ];

    // Iterar sobre a lista e limpar a entrada em cada mapa
    var _len = array_length(_maps_to_clean);
    
    for (var i = 0; i < _len; i++) {
        var _current_map = _maps_to_clean[i];
        
        // Verifica se a chave existe antes de deletar
        if (ds_map_exists(_current_map, _room_id)) {
            ds_map_delete(_current_map, _room_id);
        }
    }
}