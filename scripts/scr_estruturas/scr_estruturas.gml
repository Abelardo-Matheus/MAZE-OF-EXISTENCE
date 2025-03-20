
// Inicializa a lista global de estruturas
if (!variable_global_exists("posicoes_estruturas")) {
    global.posicoes_estruturas = ds_list_create();
}

function recriar_estruturas() {
	
	
    // Verifica se a lista de estruturas existe e não está vazia
    if (ds_exists(global.posicoes_estruturas, ds_type_list) && ds_list_size(global.posicoes_estruturas) > 0) {
        // Percorre a lista de estruturas
        for (var i = 0; i < ds_list_size(global.posicoes_estruturas); i++) {
            var estrutura_info = global.posicoes_estruturas[| i]; // Acessa a sublista [pos_x, pos_y, seed]
            var pos_x = estrutura_info[0]; // Posição X da estrutura
            var pos_y = estrutura_info[1]; // Posição Y da estrutura
            var seed = estrutura_info[2]; // Seed da estrutura

            // Cria a estrutura na posição salva e atribui a seed
            var casa = instance_create_depth(pos_x, pos_y, 0, obj_estrutura);
            casa.seed = seed; // Atribui a seed à estrutura
        }
    }
}

function scr_estruturas() {
    // Verifica se o jogador está se movendo e se as estruturas já foram criadas
    if (!global.estruturas_criadas) {
        // Obtém a posição do jogador
        var jogador_x = obj_player.x;
        var jogador_y = obj_player.y;

        // Gera estruturas aleatoriamente ao redor do jogador
        for (var i = 0; i < quantidade_estruturas; i++) {
            var pos_x, pos_y;
            var tentativas = 0;
            var posicao_valida = false;

            // Tenta encontrar uma posição válida para a estrutura
            while (!posicao_valida && tentativas < 100) {
				randomize();
                pos_x = jogador_x + random_range(-raio_geracao, raio_geracao);
                pos_y = jogador_y + random_range(-raio_geracao, raio_geracao);

                // Verifica se a posição está longe o suficiente de outras estruturas
                posicao_valida = true;
                for (var j = 0; j < ds_list_size(global.posicoes_estruturas); j++) {
                    var estrutura_info = global.posicoes_estruturas[| j]; // Acessa a sublista [pos_x, pos_y, seed]
                    var estrutura_x = estrutura_info[0]; // Posição X da estrutura existente
                    var estrutura_y = estrutura_info[1]; // Posição Y da estrutura existente

                    // Verifica a distância entre a nova estrutura e as estruturas existentes
                    if (point_distance(pos_x, pos_y, estrutura_x, estrutura_y) < distancia_minima) {
                        posicao_valida = false;
                        break;
                    }
                }

                tentativas++;
            }

            // Se encontrou uma posição válida, cria a estrutura e salva a posição e a seed
            if (posicao_valida) {
				
                var seed = random_get_seed(); // Gera uma seed única
                var casa = instance_create_depth(pos_x, pos_y, 0, obj_estrutura);
                casa.seed = seed; // Atribui a seed à estrutura
				global.pos_x_map = pos_x;
				global.pos_y_map = pos_y;
				

                // Adiciona uma sublista [pos_x, pos_y, seed] à lista global
                ds_list_add(global.posicoes_estruturas, [pos_x, pos_y, seed]);
            }
        }

        global.estruturas_criadas = true;
    }

    // Verifica se o jogador está se movendo para gerar mais estruturas
    if (point_distance(obj_player.x, obj_player.y, x, y) > raio_geracao / 2 ) {
        global.estruturas_criadas = false; // Permite a geração de mais estruturas
        x = obj_player.x; // Atualiza a posição do controle para o centro do jogador
        y = obj_player.y;
    }
}


function filhos(){
	random_set_seed(seed);
    var objetos_no_projeto = [obj_casa_1, obj_casa_2, obj_casa_3, obj_casa_4];
    var indice_aleatorio = irandom(array_length(objetos_no_projeto) - 1);
    var filho_selecionado = filhos[indice_aleatorio];
    instance_change(filho_selecionado, true);
	
}