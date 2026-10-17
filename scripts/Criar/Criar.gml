// feather disable GM2017
// Helper para gerar o ID da sala consistentemente
function get_room_id(_room_coords) {
    return string(_room_coords[0]) + "_" + string(_room_coords[1]);
}

// --- FUNÇÃO 1: RECRIAR (Respawn) ---
// Recria qualquer mobília baseada no mapa global de dados
function furniture_respawn_in_room(_room_coords, _global_map) {
    var _sala_id = get_room_id(_room_coords);
    
    if (ds_map_exists(_global_map, _sala_id)) {
        var _list = _global_map[? _sala_id];
        var _size = ds_list_size(_list);
        
        for (var _i = 0; _i < _size; _i++) {
            var _data = _list[| _i]; // [_obj, _x, _y, _grupo_id]
            var _inst = instance_create_layer(_data[1], _data[2], "Instances", _data[0]);
            _inst.grupo_id = _data[3]; // Restaura o ID do grupo se for mobília coletiva
        }
    }
}

// --- FUNÇÃO 2: SALVAR (Persistência) ---
// Salva a posição e tipo de todos os objetos de um tipo na sala atual
function furniture_save_state(_room_coords, _global_map, _object_type) {
    var _sala_id = get_room_id(_room_coords);
    
    // Se já existia uma lista para esta sala, destrói para atualizar
    if (ds_map_exists(_global_map, _sala_id)) {
        ds_list_destroy(_global_map[? _sala_id]);
    }
    
    var _list_furniture = ds_list_create();
    
    with (_object_type) {
        // Salva [Objeto, X, Y, ID do Grupo]
        ds_list_add(_list_furniture, [object_index, x, y, variable_instance_exists(id, "grupo_id") ? grupo_id : noone]);
    }

    // Só salva no mapa global se criou alguma mobília
    if (ds_list_size(_list_furniture) > 0) {
        ds_map_add(_global_map, _sala_id, _list_furniture);
    } else {
        ds_list_destroy(_list_furniture); // Limpa memória se vazia
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
	}
}
// --- FUNÇÃO 3: GERADOR DE POSIÇÕES (Procedural) ---
// Define onde ficarão as mobílias em cada sala pela primeira vez
function furniture_generate_positions(_salas_geradas, _global_map, _qtd_max, _tipo_especifico = "qualquer") {
    var _total_rooms = array_length(_salas_geradas);
    
    for (var _i = 0; _i < _total_rooms; _i++) {
        var _coords = _salas_geradas[_i];
        var _sala_id = get_room_id(_coords);
        
        // Se esta sala já tem mobília definida na database global, não gera de novo
        if (ds_map_exists(_global_map, _sala_id)) continue;

        var _sala_info = procurar_sala_por_numero(_coords);
        
        // Filtro opcional por tipo de sala (ex: só gera geladeira se for cozinha)
        if (_tipo_especifico != "qualquer" && _sala_info.tipo != _tipo_especifico) continue;

        var _list_furniture = ds_list_create();
        var _qtd = irandom_range(1, _qtd_max);

        for (var _j = 0; _j < _qtd; _j++) {
            // Sorteia posição livre na grid da sala
            // (Ajuste os valores de 64 e room_width conforme seu tile e tamanho de sala)
            var _px = irandom_range(128, room_width - 128);
            var _py = irandom_range(128, room_height - 128);
            
            // Aqui você sorteia qual objeto de mobília colocar
            var _obj_sorteado = noone;
            
            if (_global_map == global.salas_com_geladeira)    _obj_sorteado = obj_geladeira;
            if (_global_map == global.salas_com_guarda_roupa) _obj_sorteado = obj_guarda_roupa;
            if (_global_map == global.salas_com_escrivaninha) _obj_sorteado = obj_mesa_1;

            if (_obj_sorteado != noone) {
                // Salva [Objeto, X, Y, noone]
                ds_list_add(_list_furniture, [_obj_sorteado, _px, _py, noone]);
            }
        }

        // Só salva no mapa global se criou alguma mobília
        if (ds_list_size(_list_furniture) > 0) {
            ds_map_add(_global_map, _sala_id, _list_furniture);
        } else {
            ds_list_destroy(_list_furniture); // Limpa memória se vazia
        }
    }
}
