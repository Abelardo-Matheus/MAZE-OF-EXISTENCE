function recriar__escrivaninha_na_sala_atual(current_sala) {
    // Gerar um ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala atual tem pontos salvos
    if (ds_map_exists(global.salas_com_escrivaninha, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_escrivaninha, sala_id);

        // Recriar os pontos nas posições salvas, se ainda existirem na lista
        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            var ponto_x = ponto_pos[0];
            var ponto_y = ponto_pos[1];

            // Criar o objeto obj_pontos na posição salva
            instance_create_layer(ponto_x, ponto_y, "Instances_moveis", obj_mesa_1);
        }

    } 
}

function create_escrivaninha(salas_geradas, quantidade_salas, quantidade_escriv) {
      // Criar um array para ar_mazenar as salas que terão pontos
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

    // Para cada sala selecionada, criar slows
    for (var i = 0; i < array_length_1d(salas_selecionadas); i++) {
        var sala = salas_selecionadas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]); 
        var lista_escrivaninha = ds_list_create(); 

    
        for (var j = 0; j < quantidade_escriv; j++) {
            var ponto_valido = false;
            var ponto_x, ponto_y;

            do {
                ponto_x = irandom_range(300, room_width - 300); 
                ponto_y = irandom_range(300, room_height - 300);

                ponto_valido = true;

                for (var k = 0; k < ds_list_size(lista_escrivaninha); k++) {
                    var ponto_existente = ds_list_find_value(lista_escrivaninha, k);
                    var distancia = point_distance(ponto_x, ponto_y, ponto_existente[0], ponto_existente[1]);

                    // Defina a distância mínima entre slows, por exemplo, 100 pixels
                    if (distancia < 100) {
                        ponto_valido = false;
                        break;
                    }
                }
            } until (ponto_valido);

            // Salvar a posição do slow na lista
            ds_list_add(lista_escrivaninha, [ponto_x, ponto_y]);
        }

        // Ar_mazenar a lista de pontos no mapa global para a sala correspondente
        ds_map_add(global.salas_com_escrivaninha, sala_id, lista_escrivaninha);
    }
}
