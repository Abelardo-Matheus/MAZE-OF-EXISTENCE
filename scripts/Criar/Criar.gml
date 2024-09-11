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

function criar_item_aleatorio_passivo(pos_x,pos_y) {
    // Escolher entre itens passivos e ativos
    var tipo_item = irandom(1); // 0 para passivo, 1 para ativo

    var item_nome, item_descricao, item_sprite, item_quantidade,sprite_ind;

        // Escolher item ativo aleatório
        var item_index = irandom(itens_ativos.Altura - 1);
		show_debug_message(item_index)
        switch (item_index) {
            case 2:
                item_nome = "Banana";
                item_descricao = "Uma banana fresca, carregada de potássio. Perfeita para recarregar suas energias!";
                item_sprite = spr_itens_invent_consumiveis;
                item_quantidade = irandom_range(1, 3);
				sprite_ind = 2;
                break;
            case 1:
                item_nome = "Maçã";
                item_descricao = "Uma maçã suculenta, deliciosa e crocante. Ideal para um lanche rápido e saudável.";
                item_sprite = spr_itens_invent_consumiveis;
                item_quantidade = irandom_range(1, 3);
				sprite_ind = 1;
                break;
			case 0:
                item_nome = "Batata";
                item_descricao = "Uma batata robusta, pronta para ser cozida ou assada. A fonte perfeita de energia natural.";
                item_sprite = spr_itens_invent_consumiveis;
                item_quantidade = irandom_range(1, 3);
				sprite_ind = 0;
                break;
			case 3:
                item_nome = "Uva";
                item_descricao = "Um cacho de uvas doces, pequenas e cheias de sabor. Uma explosão de doçura a cada mordida.";
                item_sprite = spr_itens_invent_consumiveis;
                item_quantidade = irandom_range(1, 3 );
				sprite_ind = 3;
                break;
			case 4:
                item_nome = "Vitamina";
                item_descricao = "Uma dose poderosa de vitaminas, embalada em uma pequena pílula. Essencial para manter sua vitalidade.";
                item_sprite = spr_itens_invent_consumiveis;
                item_quantidade = irandom_range(1, 3);
				sprite_ind = 4;
                break;
			case 5:
                item_nome = "Leite";
                item_descricao = "Um copo de leite fresco e nutritivo, perfeito para fortalecer seus ossos e garantir um dia saudável."
                item_sprite = spr_itens_invent_consumiveis;
				sprite_ind = 5;
                item_quantidade = irandom_range(1, 3);
                break;
		}

    var _inst = instance_create_layer(pos_x, pos_y, "instances", obj_item);
    _inst.sprite_index = item_sprite;
    _inst.quantidade = item_quantidade;
    _inst.nome = item_nome;
    _inst.descricao = item_descricao;
    _inst.sala_x = global.current_sala[0];
    _inst.sala_y = global.current_sala[1];
    _inst.pos_x = pos_x;
    _inst.pos_y = pos_y;
	_inst.image_index = sprite_ind;


} 

