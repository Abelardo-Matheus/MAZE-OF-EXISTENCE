// Helper para gerar o ID da sala consistentemente
function get_room_id(_room_coords) {
    return string(_room_coords[0]) + "_" + string(_room_coords[1]);
}

// --- FUNÇÃO 1: RECRIAR (Respawn) ---
// Recria qualquer mobília baseada no mapa global e objeto fornecido
function furniture_respawn_in_room(_current_sala_coords, _global_map, _obj_index) {
    var _sala_id = get_room_id(_current_sala_coords);

    // Verifica se existem dados salvos para esta sala neste mapa específico
    if (ds_map_exists(_global_map, _sala_id)) {
        var _list_points = ds_map_find_value(_global_map, _sala_id);

        for (var i = 0; i < ds_list_size(_list_points); i++) {
            var _data = ds_list_find_value(_list_points, i);
            var _px = _data[0];
            var _py = _data[1];
            var _is_open = _data[2];

            // Cria o objeto genérico passado no argumento _obj_index
            var _inst = instance_create_layer(_px, _py, "Instances_moveis", _obj_index);
            
            // Aplica o estado salvo
            _inst.aberto = _is_open;
        }
    }
}

// --- FUNÇÃO 2: ATUALIZAR ESTADO (Save State) ---
// Marca qualquer mobília como aberta/fechada no mapa global
function furniture_update_state(_x, _y, _current_sala_coords, _global_map, _is_open) {
    var _sala_id = get_room_id(_current_sala_coords);

    if (ds_map_exists(_global_map, _sala_id)) {
        var _list_points = ds_map_find_value(_global_map, _sala_id);

        for (var i = 0; i < ds_list_size(_list_points); i++) {
            var _data = ds_list_find_value(_list_points, i);

            // Encontra a mobília pela posição X e Y
            if (_data[0] == _x && _data[1] == _y) {
                _data[2] = _is_open; // Atualiza o estado
                ds_list_replace(_list_points, i, _data);
                break; 
            }
        }
        // Não é estritamente necessário replace o mapa se a lista é a mesma referência, 
        // mas garante integridade em algumas versões do GM.
        ds_map_replace(_global_map, _sala_id, _list_points);
    }
}

// --- FUNÇÃO 3: GERAR (Create/Procedural) ---
// Gera posições para qualquer mobília, com filtro opcional de tipo de sala
function furniture_generate_positions(_salas_geradas, _global_map, _amount, _required_room_type = undefined) {
    randomize();

    for (var i = 0; i < array_length(_salas_geradas); i++) {
        var _sala_coords = _salas_geradas[i];
        
        // Se um tipo de sala for exigido (ex: "cozinha"), verifica antes
        if (_required_room_type != undefined) {
            var _sala_detalhes = procurar_sala_por_numero(_sala_coords);
            if (_sala_detalhes.tipo != _required_room_type) continue; // Pula se não for o tipo certo
        }

        var _sala_id = get_room_id(_sala_coords);
        var _list_furniture = ds_list_create();

        for (var j = 0; j < _amount; j++) {
            var _px, _py, _valid;
            var _attempts = 0;

            // Tenta achar uma posição válida (com limite de tentativas para evitar loop infinito)
            do {
                _px = irandom_range(300, room_width - 300);
                _py = irandom_range(300, room_height - 300);
                _valid = true;
                _attempts++;

                // Verifica distância de outras mobílias desta lista
                for (var k = 0; k < ds_list_size(_list_furniture); k++) {
                    var _existing = ds_list_find_value(_list_furniture, k);
                    if (point_distance(_px, _py, _existing[0], _existing[1]) < 100) {
                        _valid = false;
                        break;
                    }
                }
            } until (_valid || _attempts > 50);

            if (_valid) {
                // Adiciona: [X, Y, Aberto(false)]
                ds_list_add(_list_furniture, [_px, _py, false]);
            }
        }

        // Só adiciona ao mapa se realmente criou alguma mobília
        if (ds_list_size(_list_furniture) > 0) {
            ds_map_add(_global_map, _sala_id, _list_furniture);
        } else {
            ds_list_destroy(_list_furniture); // Limpa memória se vazia
        }
    }
}