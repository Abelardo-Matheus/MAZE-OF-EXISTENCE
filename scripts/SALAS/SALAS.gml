/// @desc Inicializa o banco de dados de tipos de salas
function salas() {
    // Helper Constructor para criar definições de sala rapidamente
    var RoomDef = function(_nome, _chao, _parede, _objetos) constructor {
        name = _nome;
        floor_sprite = _chao;
        wall_sprite = _parede;
        objects = _objetos;
    };

    // 1. Inicializa o Mapa Global de Definições
    global.room_definitions = {};

    // 2. Definindo Salas Comuns (Armazenamos em uma Struct para acesso rápido por string)
    global.room_definitions.comuns = {
        "banheiro2": new RoomDef("banheiro2", obj_chao_tijolo, obj_parede_bebe, [obj_pontos]),
        "fundos":    new RoomDef("fundos",    obj_chao_tijolo, obj_parede_bebe, [obj_pontos]),
        "porao":     new RoomDef("porao",     obj_chao_tijolo, obj_parede_bebe, [obj_pontos]),
        "quarto3":   new RoomDef("quarto3",   obj_chao_tijolo, obj_parede_bebe, [obj_pontos, obj_vela]),
        "quarto2":   new RoomDef("quarto2",   obj_chao_tijolo, obj_parede_bebe, [obj_pontos]),
        "quarto":    new RoomDef("quarto",    obj_chao_tijolo, obj_parede_bebe, [obj_pontos]),
        "banheiro":  new RoomDef("banheiro",  obj_chao_banheiro, obj_parede_bebe, [obj_pontos]),
        "cozinha":   new RoomDef("cozinha",   obj_chao_cozinha, obj_parede_cozinha, [obj_pontos]),
        "sala_estar":new RoomDef("Sala de Estar", obj_chao_tijolo, obj_parede_bebe, [obj_pontos])
    };

    // 3. Definindo Salas Especiais
    global.room_definitions.templo = {
        "templo": new RoomDef("templo", obj_chao_templo, obj_parede_templo, [])
    };

    global.room_definitions.jardim = {
        "jardim": new RoomDef("jardim", obj_chao_grama, obj_cerca, [])
    };

    // 4. Lista de chaves ordenada para garantir a ordem de sorteio (Maps não garantem ordem)
    global.common_room_keys = variable_struct_get_names(global.room_definitions.comuns);
}

/// @desc Cria os dados de uma sala específica baseada no index e posição
function criar_salas_lista(_pos_array, _index) {
    // Inicialização segura de variáveis globais
    if (!variable_global_exists("tipo_sala_index")) {
        global.tipo_sala_index = 0;
    }

    var _selected_key = "quarto"; // Default fallback
    var _source_struct = global.room_definitions.comuns;

    // Lógica 1: Seleção de Salas Comuns
    if (_index < array_length(global.common_room_keys)) {
        _selected_key = global.common_room_keys[_index];
        global.tipo_sala_index++;
    }

    // Lógica 2: Sobrescrita para Templo
    if (global.templo_criado && array_equals(_pos_array, global.templos_salas_pos[0])) {
        _source_struct = global.room_definitions.templo;
        var _keys = variable_struct_get_names(_source_struct);
        _selected_key = _keys[0];
    }

   // Lógica 3: Sobrescrita para Jardim 
    // 1. Verifica se é um array antes de comparar (impede erro se for 'noone')
    if (is_array(global.sala_jardim)) { 
        if (array_equals(_pos_array, global.sala_jardim)) {
            _source_struct = global.room_definitions.jardim;
            var _keys = variable_struct_get_names(_source_struct);
            if (array_length(_keys) > 0) _selected_key = _keys[0];
        }
    }

    // Recupera a definição da struct
    var _def = variable_struct_get(_source_struct, _selected_key);

    // Retorna Struct limpa (Substitui o DS Map de retorno)
    return {
        sala: _pos_array,
        tag: _index,
        tipo: _selected_key,
        chao: _def.floor_sprite,
        parede: _def.wall_sprite,
        objetos: _def.objects
    };
}

/// @desc Procura sala por coordenadas [x, y]
function procurar_sala_por_numero(_target_pos) {
    var _len = array_length(global.salas_criadas);
    
    for (var i = 0; i < _len; i++) {
        var _sala = global.salas_criadas[i];
        // Otimização: Comparar arrays diretamente
        if (array_equals(_sala.sala, _target_pos)) {
            return _sala;
        }
    }
    
    // Retorna struct vazia/padrão ao invés de recursão perigosa
    return { sala: [0,0], tag: -1, tipo: "none", chao: noone, parede: noone, objetos: [] };
}

/// @desc Debuga as informações da sala no console
function escrever_informacoes_sala(_sala) {
    if (is_struct(_sala) && _sala.tag != -1) {
        show_debug_message("=== INFO SALA ===");
        show_debug_message("Tag: " + string(_sala.tag));
        show_debug_message("Tipo: " + _sala.tipo);
        
        var _chao_name = object_exists(_sala.chao) ? object_get_name(_sala.chao) : "Nenhum";
        var _parede_name = object_exists(_sala.parede) ? object_get_name(_sala.parede) : "Nenhum";
        
        show_debug_message("Chão: " + _chao_name);
        show_debug_message("Parede: " + _parede_name);

        if (is_array(_sala.objetos)) {
            for (var i = 0; i < array_length(_sala.objetos); i++) {
                var _obj_name = object_get_name(_sala.objetos[i]);
                show_debug_message("Obj " + string(i) + ": " + _obj_name);
            }
        }
        show_debug_message("=================");
    } else {
        show_debug_message("Sala inválida ou não encontrada.");
    }
}

function resetar_salas() {
    // Com structs, o Garbage Collector do GameMaker limpa a memória automaticamente
    // Basta zerar o array.
    global.salas_criadas = [];
    global.tipo_sala_index = 0;
}

function verificar_sala_escura(_sala_atual) {
    var _len = array_length(global.salas_escuras);
    for (var i = 0; i < _len; i++) {
        if (array_equals(global.salas_escuras[i], _sala_atual)) {
            return true;
        }
    }
    return false;
}