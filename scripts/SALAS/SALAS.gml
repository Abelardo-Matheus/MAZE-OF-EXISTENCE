// Exemplo de estrutura para armazenar tipos de salas
global.tipos_de_salas = ds_map_create();


function salas(){
	var banheiro2 = ds_map_create();
ds_map_add(banheiro2, "nome", "banheiro2");
ds_map_add(banheiro2, "chao", obj_chao_tijolo);
ds_map_add(banheiro2, "parede", obj_parede_bebe);
ds_map_add(banheiro2, "objetos", [obj_pontos]);

var porao = ds_map_create();
ds_map_add(porao, "nome", "porao");
ds_map_add(porao, "chao", obj_chao_tijolo);
ds_map_add(porao, "parede", obj_parede_bebe);
ds_map_add(porao, "objetos", [obj_pontos]);

var quarto3 = ds_map_create();
ds_map_add(quarto3, "nome", "quarto3");
ds_map_add(quarto3, "chao", obj_chao_tijolo);
ds_map_add(quarto3, "parede", obj_parede_bebe);
ds_map_add(quarto3, "objetos", [obj_pontos]);

var quarto2 = ds_map_create();
ds_map_add(quarto2, "nome", "quarto2");
ds_map_add(quarto2, "chao", obj_chao_tijolo);
ds_map_add(quarto2, "parede", obj_parede_bebe);
ds_map_add(quarto2, "objetos", [obj_pontos]);

var quarto = ds_map_create();
ds_map_add(quarto, "nome", "quarto");
ds_map_add(quarto, "chao", obj_chao_tijolo);
ds_map_add(quarto, "parede", obj_parede_bebe);
ds_map_add(quarto, "objetos", [obj_pontos]);

var banheiro = ds_map_create();
ds_map_add(banheiro, "nome", "banheiro");
ds_map_add(banheiro, "chao", obj_chao_banheiro);
ds_map_add(banheiro, "parede", obj_parede_bebe);
ds_map_add(banheiro, "objetos", [obj_pontos]);

var cozinha = ds_map_create();
ds_map_add(cozinha, "nome", "cozinha");
ds_map_add(cozinha, "chao", obj_chao_cozinha);
ds_map_add(cozinha, "parede", obj_parede_cozinha);
ds_map_add(cozinha, "objetos", [obj_pontos]);

var sala_estar = ds_map_create();
ds_map_add(sala_estar, "nome", "Sala de Estar");
ds_map_add(sala_estar, "chao", obj_chao_tijolo);
ds_map_add(sala_estar, "parede", obj_parede_bebe);
ds_map_add(sala_estar, "objetos", [obj_pontos]);


ds_map_add(global.tipos_de_salas, "sala_estar", sala_estar);
ds_map_add(global.tipos_de_salas, "cozinha", cozinha);
ds_map_add(global.tipos_de_salas, "banheiro", banheiro);
ds_map_add(global.tipos_de_salas, "quarto", quarto);
ds_map_add(global.tipos_de_salas, "quarto2", quarto2);
ds_map_add(global.tipos_de_salas, "quarto3", quarto3);
ds_map_add(global.tipos_de_salas, "porao", porao);
ds_map_add(global.tipos_de_salas, "banheiro2", banheiro2);
}

function criar_salas_lista(sala_atual, numero) {
      var tipos_disponiveis = get_ds_map_keys(global.tipos_de_salas);
    var tipo_sala = tipos_disponiveis[irandom(array_length_1d(tipos_disponiveis) - 1)];

    var detalhes_sala = ds_map_find_value(global.tipos_de_salas, tipo_sala);

    return {
        sala: sala_atual,
        tag: numero,
        tipo: tipo_sala,
        chao: ds_map_find_value(detalhes_sala, "chao"),
        parede: ds_map_find_value(detalhes_sala, "parede"),
        objetos: ds_map_find_value(detalhes_sala, "objetos")
    };
}
// Função para procurar uma sala específica pelo número (tag)
function procurar_sala_por_numero(sala_current) {
    for (var i = 0; i < array_length_1d(global.salas_criadas); i++) {
        var sala = global.salas_criadas[i];

        // Comparar os elementos do array sala_current com os elementos do array sala.sala
        if (sala.sala[0] == sala_current[0] && sala.sala[1] == sala_current[1]) {
            return sala; // Retorna a sala se a posição corresponder
        }
    }
    return noone; // Retorna noone se nenhuma sala for encontrada com a posição dada
}

function get_ds_map_keys(map) {
    var keys = [];
    var key = ds_map_find_first(map);

    while (key != undefined) {
        array_push(keys, key);
        key = ds_map_find_next(map, key);
    }

    return keys;
}
// Função para escrever as informações da sala, incluindo o nome dos objetos
function escrever_informacoes_sala(sala) {
    if (sala != noone) {
        show_debug_message("Tag: " + string(sala.tag));
        show_debug_message("Tipo: " + sala.tipo);
        show_debug_message("Textura do Chão: " + object_get_name(sala.chao));
        show_debug_message("Textura da Parede: " + object_get_name(sala.parede));

        for (var i = 0; i < array_length_1d(sala.objetos); i++) {
            show_debug_message("Objeto " + string(i) + ": " + object_get_name(sala.objetos[i]));
        }
    } else {
        show_debug_message("Sala não encontrada.");
    }
}