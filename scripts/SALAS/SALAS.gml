
global.tipos_de_salas = ds_map_create();
global.tipos_de_salas_templo = ds_map_create();
global.tipos_de_salas_jardim = ds_map_create();


function salas(){
var banheiro2 = ds_map_create();
ds_map_add(banheiro2, "nome", "banheiro2");
ds_map_add(banheiro2, "chao", obj_chao_tijolo);
ds_map_add(banheiro2, "parede", obj_parede_bebe);
ds_map_add(banheiro2, "objetos", [obj_pontos]);

var fundos = ds_map_create();
ds_map_add(fundos, "nome", "fundos");
ds_map_add(fundos, "chao", obj_chao_tijolo);
ds_map_add(fundos, "parede", obj_parede_bebe);
ds_map_add(fundos, "objetos", [obj_pontos]);

var porao = ds_map_create();
ds_map_add(porao, "nome", "porao");
ds_map_add(porao, "chao", obj_chao_tijolo);
ds_map_add(porao, "parede", obj_parede_bebe);
ds_map_add(porao, "objetos", [obj_pontos]);

var quarto3 = ds_map_create();
ds_map_add(quarto3, "nome", "quarto3");
ds_map_add(quarto3, "chao", obj_chao_tijolo);
ds_map_add(quarto3, "parede", obj_parede_bebe);
ds_map_add(quarto3, "objetos", [obj_pontos,obj_vela]);

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


var templo = ds_map_create();
ds_map_add(templo, "nome", "templo");
ds_map_add(templo, "chao", obj_chao_templo);
ds_map_add(templo, "parede", obj_parede_templo);
ds_map_add(templo, "objetos", noone);

var jardim = ds_map_create();
ds_map_add(jardim, "nome", "jardim");
ds_map_add(jardim, "chao", obj_chao_grama);
ds_map_add(jardim, "parede", obj_cerca);
ds_map_add(jardim, "objetos", noone);



ds_map_add(global.tipos_de_salas, "sala_estar", sala_estar);
ds_map_add(global.tipos_de_salas, "fundos", fundos);
ds_map_add(global.tipos_de_salas, "cozinha", cozinha);
ds_map_add(global.tipos_de_salas, "banheiro", banheiro);
ds_map_add(global.tipos_de_salas, "quarto", quarto);
ds_map_add(global.tipos_de_salas, "quarto2", quarto2);
ds_map_add(global.tipos_de_salas, "quarto3", quarto3);
ds_map_add(global.tipos_de_salas, "porao", porao);
ds_map_add(global.tipos_de_salas, "banheiro2", banheiro2);




ds_map_add(global.tipos_de_salas_templo, "templo", templo);


ds_map_add(global.tipos_de_salas_jardim, "jardim", jardim);
}



function criar_salas_lista(sala_atual, numero) {
    // Variável global para rastrear quais tipos de sala já foram atribuídos
    if (!variable_global_exists("tipos_salas_usadas")) {
        global.tipos_salas_usadas = [];
        global.tipo_sala_index = 0; // Índice para rastrear o tipo de sala atual
    }

    var tipo_sala;
	
    // Verificar se ainda existem tipos de salas disponíveis não usados
    var tipos_disponiveis = get_ds_map_keys(global.tipos_de_salas);

    if (numero < array_length_1d(tipos_disponiveis)) {
        // Pega o tipo de sala na sequência do índice
        tipo_sala = tipos_disponiveis[numero];
		var detalhes_sala = ds_map_find_value(global.tipos_de_salas, tipo_sala);
        global.tipo_sala_index++; // Incrementar o índice para a próxima sala
    }else {
        // Se todos os tipos de sala já foram usados, definir como "quarto"
        tipo_sala = "quarto";
    }
	 var detalhes_sala = ds_map_find_value(global.tipos_de_salas, tipo_sala);
	if (global.templo_criado) {
		
    // Verificar se a sala atual é um templo
    if (sala_atual == global.templos_salas_pos[0]) {
        tipo_sala = "templo";
       
        // Pegar a lista de tipos de salas disponíveis para templos
        var tipos_disponiveis_templo = get_ds_map_keys(global.tipos_de_salas_templo);
        
        // Definir os detalhes da sala com base no tipo selecionado
        var detalhes_sala = ds_map_find_value(global.tipos_de_salas_templo, tipos_disponiveis_templo[0]);
    }
    
    // Verificar se a sala atual é um jardim
    if (sala_atual == global.sala_jardim) {
        tipo_sala = "jardim";
        
        // Pegar a lista de tipos de salas disponíveis para jardim
        var tipos_disponiveis_jardim = get_ds_map_keys(global.tipos_de_salas_jardim);
        
        // Definir os detalhes da sala com base no tipo selecionado
        var detalhes_sala = ds_map_find_value(global.tipos_de_salas_jardim, tipos_disponiveis_jardim[0]);
    }
}

	
		
    // Obter detalhes do tipo de sala
   

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
function resetar_salas() {
    // Verifica se existe a lista de salas criadas
    if (global.salas_criadas != undefined) {
        // Percorre todas as salas na lista
        for (var i = 0; i < array_length_1d(global.salas_criadas); i++) {
            var sala = global.salas_criadas[i];

            // Reinicializa as propriedades da sala
            sala.sala = [0, 0];  // Posição padrão ou redefinir como desejado
            sala.tag = 0;         // Redefine a tag (pode ser incrementada ou ajustada conforme necessário)
            sala.tipo = "";       // Remove o tipo ou redefina
            sala.chao = noone;    // Remove o chão
            sala.parede = noone;  // Remove a parede
            sala.objetos = [];    // Limpa a lista de objetos
        }
    }

    // Opcional: Redefinir a lista inteira (se preferir limpar completamente)
    global.salas_criadas = [];
}
function verificar_sala_escura(sala_atual) {
    // Percorre todas as salas escuras ar_mazenadas
    for (var i = 0; i < array_length_1d(global.salas_escuras); i++) {
        var sala_escura = global.salas_escuras[i];

        // Verifica se a sala atual corresponde à sala escura
        if (sala_escura[0] == sala_atual[0] && sala_escura[1] == sala_atual[1]) {
            return true; // Sala escura encontrada
        }
    }
    return false; // Sala escura não encontrada
}
