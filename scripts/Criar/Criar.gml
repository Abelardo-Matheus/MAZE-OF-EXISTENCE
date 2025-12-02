
#region ESCRIVANINHA
function recriar__escrivaninha_na_sala_atual(current_sala) {
    // Gerar um ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala atual tem escrivaninhas salvas
    if (ds_map_exists(global.salas_com_escrivaninha, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_escrivaninha, sala_id);

        // Recriar as escrivaninhas nas posições salvas
        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            var ponto_x = ponto_pos[0];
            var ponto_y = ponto_pos[1];
            var aberta = ponto_pos[2]; // Pega o estado de "aberta"

            // Criar o objeto escrivaninha na posição salva
            var _inst = instance_create_layer(ponto_x, ponto_y, "Instances_moveis", obj_mesa_1);

            // Definir a variável 'aberta' se estiver definida como aberta
            if (aberta == true) {
                _inst.aberto = true;
            } else {
                _inst.aberto = false;
            }
        }
    } 
}


function create_escrivaninha(salas_geradas, quantidade_salas, quantidade_escriv) {
 // Criar um array para armazenar as salas que terão escrivaninhas
    var salas_selecionadas = [];

    // Selecionar um número específico de salas aleatórias
    for (var i = 0; i < quantidade_salas; i++) {
        var sala_aleatoria;

        // Garantir que a sala selecionada ainda não foi escolhida
        do {
            sala_aleatoria = salas_geradas[irandom(array_length_1d(salas_geradas) - 1)];
        } until (!array_contains(salas_selecionadas, sala_aleatoria));

        array_push(salas_selecionadas, sala_aleatoria); // Adicionar sala selecionada à lista
    }

    // Para cada sala selecionada, criar escrivaninhas
    for (var i = 0; i < array_length_1d(salas_selecionadas); i++) {
        var sala = salas_selecionadas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]); 
        var lista_escrivaninha = ds_list_create(); 

        for (var j = 0; j < quantidade_escriv; j++) {
            ponto_valido = false;
            var ponto_x, ponto_y;

            do {
                ponto_x = irandom_range(300, room_width - 300); 
                ponto_y = irandom_range(300, room_height - 300);

                ponto_valido = true;

                for (var k = 0; k < ds_list_size(lista_escrivaninha); k++) {
                    var ponto_existente = ds_list_find_value(lista_escrivaninha, k);
                    var distancia = point_distance(ponto_x, ponto_y, ponto_existente[0], ponto_existente[1]);

                    if (distancia < 100) {
                        ponto_valido = false;
                        break;
                    }
                }
            } until (ponto_valido);

            // Salvar a posição da escrivaninha e sua variável aberta (true para aberta)
            ds_list_add(lista_escrivaninha, [ponto_x, ponto_y, false]); // "true" representa a escrivaninha aberta
        }

        // Armazenar a lista de escrivaninhas no mapa global para a sala correspondente
        ds_map_add(global.salas_com_escrivaninha, sala_id, lista_escrivaninha);
    }
}
function definir_escrivaninha_aberta(ponto_x, ponto_y, current_sala) {
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala tem escrivaninhas salvas
    if (ds_map_exists(global.salas_com_escrivaninha, sala_id)) {
        var lista_escrivaninha = ds_map_find_value(global.salas_com_escrivaninha, sala_id);

        // Procurar a escrivaninha e marcá-la como aberta
        for (var i = 0; i < ds_list_size(lista_escrivaninha); i++) {
            var escriv_info = ds_list_find_value(lista_escrivaninha, i);

            if (escriv_info[0] == ponto_x && escriv_info[1] == ponto_y) {
                escriv_info[2] = true; // Marcar como aberta
                ds_list_replace(lista_escrivaninha, i, escriv_info); // Atualizar a lista
                break;
            }
        }

        ds_map_replace(global.salas_com_escrivaninha, sala_id, lista_escrivaninha); // Salvar as alterações
    }
}
#endregion
#region Geladeira
function recriar__geladeira_na_sala_atual(current_sala) {
    // Gerar um ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala atual tem escrivaninhas salvas
    if (ds_map_exists(global.salas_com_geladeira, sala_id)) {
        var lista_geladeira = ds_map_find_value(global.salas_com_geladeira, sala_id);

        // Recriar as escrivaninhas nas posições salvas
        for (var i = 0; i < ds_list_size(lista_geladeira); i++) {
            var ponto_pos = ds_list_find_value(lista_geladeira, i);
            var ponto_x = ponto_pos[0];
            var ponto_y = ponto_pos[1];
            var aberta = ponto_pos[2]; // Pega o estado de "aberta"

            // Criar o objeto escrivaninha na posição salva
            var _inst = instance_create_layer(ponto_x, ponto_y, "Instances_moveis", obj_geladeira);

            // Definir a variável 'aberta' se estiver definida como aberta
            if (aberta == true) {
                _inst.aberto = true;
            } else {
                _inst.aberto = false;
            }
        }
    } 
}


function create_geladeira(salas_geradas, quantidade_salas, quantidade_escriv) {

	randomize();
	
	for (var i = 0; i < array_length_1d(salas_geradas); i++) {
        var sala = salas_geradas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]); 
        var lista_geladeira = ds_list_create(); 
		var sala_detalhes = procurar_sala_por_numero(sala);
		if (sala_detalhes.tipo == "cozinha") {
        for (var j = 0; j < quantidade_escriv; j++) {
            ponto_valido = false;
            var ponto_x, ponto_y,ponto_valido;

            do {
                ponto_x = irandom_range(300, room_width - 300); 
                ponto_y = irandom_range(300, room_height - 300);

                ponto_valido = true;

                for (var k = 0; k < ds_list_size(lista_geladeira); k++) {
                    var ponto_existente = ds_list_find_value(lista_geladeira, k);
                    var distancia = point_distance(ponto_x, ponto_y, ponto_existente[0], ponto_existente[1]);

                    if (distancia < 100) {
                        ponto_valido = false;
                        break;
                    }
                }
            } until (ponto_valido);

            // Salvar a posição da escrivaninha e sua variável aberta (true para aberta)
            ds_list_add(lista_geladeira, [ponto_x, ponto_y, false]); // "true" representa a escrivaninha aberta
        }
		 }
        // Armazenar a lista de escrivaninhas no mapa global para a sala correspondente
        ds_map_add(global.salas_com_geladeira, sala_id, lista_geladeira);
   
	}
}
function definir_geladeira_aberta(ponto_x, ponto_y, current_sala) {
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala tem escrivaninhas salvas
    if (ds_map_exists(global.salas_com_geladeira, sala_id)) {
        var lista_geladeira = ds_map_find_value(global.salas_com_geladeira, sala_id);

        // Procurar a escrivaninha e marcá-la como aberta
        for (var i = 0; i < ds_list_size(lista_geladeira); i++) {
            var escriv_info = ds_list_find_value(lista_geladeira, i);

            if (escriv_info[0] == ponto_x && escriv_info[1] == ponto_y) {
                escriv_info[2] = true; // Marcar como aberta
                ds_list_replace(lista_geladeira, i, escriv_info); // Atualizar a lista
                break;
            }
        }

        ds_map_replace(global.salas_com_geladeira, sala_id, lista_geladeira); // Salvar as alterações
    }
}
#endregion
#region Guarda_roupa
function recriar_guarda_roupa_na_sala_atual(current_sala) {
    // Gerar um ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala atual tem escrivaninhas salvas
    if (ds_map_exists(global.salas_com_guarda_roupa, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_guarda_roupa, sala_id);

        // Recriar as escrivaninhas nas posições salvas
        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            var ponto_x = ponto_pos[0];
            var ponto_y = ponto_pos[1];
            var aberta = ponto_pos[2]; // Pega o estado de "aberta"

            // Criar o objeto escrivaninha na posição salva
            var _inst = instance_create_layer(ponto_x, ponto_y, "Instances_moveis", obj_guarda_roupa);

            // Definir a variável 'aberta' se estiver definida como aberta
            if (aberta == true) {
                _inst.aberto = true;
            } else {
                _inst.aberto = false;
            }
        }
    } 
}


function create_guarda_roupa(salas_geradas, quantidade_salas, quantidade_escriv) {

	randomize();
	
	for (var i = 0; i < array_length_1d(salas_geradas); i++) {
        var sala = salas_geradas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]); 
        var lista_geladeira = ds_list_create(); 
		var sala_detalhes = procurar_sala_por_numero(sala);
		if (sala_detalhes.tipo == "quarto") {
        for (var j = 0; j < quantidade_escriv; j++) {
            ponto_valido = false;
            var ponto_x, ponto_y,ponto_valido;

            do {
                ponto_x = irandom_range(300, room_width - 300); 
                ponto_y = irandom_range(300, room_height - 300);

                ponto_valido = true;

                for (var k = 0; k < ds_list_size(lista_geladeira); k++) {
                    var ponto_existente = ds_list_find_value(lista_geladeira, k);
                    var distancia = point_distance(ponto_x, ponto_y, ponto_existente[0], ponto_existente[1]);

                    if (distancia < 100) {
                        ponto_valido = false;
                        break;
                    }
                }
            } until (ponto_valido);

            // Salvar a posição da escrivaninha e sua variável aberta (true para aberta)
            ds_list_add(lista_geladeira, [ponto_x, ponto_y, false]); // "true" representa a escrivaninha aberta
        }
		 }
        // Armazenar a lista de escrivaninhas no mapa global para a sala correspondente
        ds_map_add(global.salas_com_guarda_roupa, sala_id, lista_geladeira);
   
	}
}
function definir_guarda_roupa_aberta(ponto_x, ponto_y, current_sala) {
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala tem escrivaninhas salvas
    if (ds_map_exists(global.salas_com_guarda_roupa, sala_id)) {
        var lista_escrivaninha = ds_map_find_value(global.salas_com_guarda_roupa, sala_id);

        // Procurar a escrivaninha e marcá-la como aberta
        for (var i = 0; i < ds_list_size(lista_escrivaninha); i++) {
            var escriv_info = ds_list_find_value(lista_escrivaninha, i);

            if (escriv_info[0] == ponto_x && escriv_info[1] == ponto_y) {
                escriv_info[2] = true; // Marcar como aberta
                ds_list_replace(lista_escrivaninha, i, escriv_info); // Atualizar a lista
                break;
            }
        }

        ds_map_replace(global.salas_com_guarda_roupa, sala_id, lista_escrivaninha); // Salvar as alterações
    }
}
#endregion
