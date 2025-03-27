// Tamanho da grid para posicionar as salas (baseado em quantas salas você quer)
var grid_size = global.total_rooms * 2; // Um grid maior que o número de salas
global.room_grid = ds_grid_create(grid_size, grid_size);
var start_x = grid_size div 2;
var start_y = grid_size div 2;
// Inicializa a grid com -1 (indicando que não há sala naquele espaço)
ds_grid_clear(global.room_grid, -1);
global.armamento = 0;
// Lista para ar_mazenar as posições das salas
global.room_positions = ds_list_create();
ds_list_add(global.room_positions, [start_x, start_y]);
global.destino_templo = noone;
global.origem_templo = noone;
global.sala_boss_brocolis = [];
// Coloca a primeira sala no centro
ds_grid_set(global.room_grid, start_x, start_y, 0); // 0 indica a primeira sala
global.salas_criadas = [];
global.current_sala = [0,0];
global.templo_criado = false;
global.tipos_de_salas = ds_map_create();
global.tipos_de_salas_templo = ds_map_create();
global.tipos_de_salas_jardim = ds_map_create();

salas();
global.sala = procurar_sala_por_numero(global.current_sala);
global.templo_criado = false;
global.salas_com_pontos = ds_map_create(); // Cria um mapa global para ar_mazenar as posições dos pontos nas salas
global.salas_com_inimigos = ds_map_create();
global.salas_com_fantasma = ds_map_create();
global.salas_com_torretas = ds_map_create();
global.salas_com_amoeba = ds_map_create();
global.salas_com_slow = ds_map_create();
global.salas_com_paredes = ds_map_create();
global.salas_com_vela =ds_map_create();
global.salas_com_escrivaninha =ds_map_create();
global.salas_com_escada_porao =  ds_map_create();
global.sala_com_item_drop  = ds_map_create();
global.salas_com_geladeira = ds_map_create();
global.salas_com_guarda_roupa = ds_map_create();

function gerar_inimigos_e_itens_para_o_nivel(salas_geradas, level) {
    // Definir a quantidade de inimigos e itens com base no nível
    var quantidade_inimigos = 1 + (level); // Exemplo: começa com 5 inimigos e aumenta 2 por nível
    var quantidade_itens = 2 + level;          // Exemplo: começa com 3 itens e aumenta 1 por nível
    criar_inimigos_em_salas_aleatorias_alet(salas_geradas);
    create_slow_em_salas_aleatorias(salas_geradas, 3, quantidade_itens);
}


#region ponto
function coletar_ponto(ponto_x, ponto_y, current_sala) {
	global.tamanho_player += 0.1;
    // Gerar o ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala tem pontos salvos
    if (ds_map_exists(global.salas_com_pontos, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_pontos, sala_id);

        // Procurar o ponto coletado na lista e removê-lo
        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            if (ponto_pos[0] == ponto_x && ponto_pos[1] == ponto_y) {
                ds_list_delete(lista_pontos, i); // Remover o ponto da lista
                break;
            }
        }
    }

    // Destruir o ponto após coleta
    instance_destroy();
}
function recriar_pontos_na_sala_atual(current_sala) {
    // Gerar um ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala atual tem pontos salvos
    if (ds_map_exists(global.salas_com_pontos, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_pontos, sala_id);

        // Recriar os pontos nas posições salvas, se ainda existirem na lista
        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            var ponto_x = ponto_pos[0];
            var ponto_y = ponto_pos[1];

            // Criar o objeto obj_pontos na posição salva
            instance_create_layer(ponto_x, ponto_y, "instances", obj_pontos);
        }

    } 
}
function create_pontos_em_salas_aleatorias(salas_geradas, quantidade_salas, quantidade_pontos) {
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

    // Para cada sala selecionada, criar pontos
    for (var i = 0; i < array_length_1d(salas_selecionadas); i++) {
        var sala = salas_selecionadas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]); // Gerar um ID único baseado nas coordenadas da sala
        var lista_pontos = ds_list_create(); // Criar uma lista para ar_mazenar as posições dos pontos

        // Criar pontos aleatórios na sala e salvar suas posições
        for (var j = 0; j < quantidade_pontos; j++) {
            var ponto_x = irandom_range(128, room_width - 128); // Gera posições aleatórias
            var ponto_y = irandom_range(128, room_height - 128);

            // Salvar a posição do ponto na lista
            ds_list_add(lista_pontos, [ponto_x, ponto_y]);
        }

        // Ar_mazenar a lista de pontos no mapa global para a sala correspondente
        ds_map_add(global.salas_com_pontos, sala_id, lista_pontos);
    }

   
}
#endregion



#region vela

function coletar_vela(ponto_x, ponto_y, current_sala) {
    // Aumentar o raio da lanterna ao coletar a vela
    global.raio_lanterna += 150;

    // Gerar o ID da sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala tem velas salvas
    if (ds_map_exists(global.salas_com_vela, sala_id)) {
        var vela_pos = ds_map_find_value(global.salas_com_vela, sala_id);

        // Procurar e remover a vela correspondente na lista de velas
        if (vela_pos[0] == ponto_x && vela_pos[1] == ponto_y) {
            ds_map_delete(global.salas_com_vela, sala_id);  // Remove a vela da sala
        }
    }

    // Destruir a vela após coleta
    instance_destroy();
}
#endregion

#region jardim


// Função para criar o templo e o jardim
function criar_templo_e_jardim(player_sala, salas_geradas) {

    // Inicializa as variáveis globais se ainda não existirem
    if (!variable_global_exists("sala_jardim")) {
        global.sala_jardim = [];
    }
    if (!variable_global_exists("templos_salas_pos")) {
        global.templos_salas_pos = [];
    }
	random_set_seed(global.seed_atual);
    // Passo 1: Criar o templo

    var sala_mais_distante_templo = undefined;
    var maior_distancia_templo = -1;

    // Encontra a sala mais distante do jogador para criar o templo
    for (var i = 0; i < array_length_1d(salas_geradas); i++) {
        var sala_atual = salas_geradas[i];
        var distancia = point_distance(player_sala[0], player_sala[1], sala_atual[0], sala_atual[1]);

        // Verifica se é a sala mais distante até agora
        if (distancia > maior_distancia_templo) {
            maior_distancia_templo = distancia;
            sala_mais_distante_templo = sala_atual;
        }
    }

    // Verifica se encontrou uma sala válida para o templo
    if (sala_mais_distante_templo == undefined) {
        return; // Sai da função se não encontrar uma sala válida
    }

    // Verifica direções disponíveis para criar o templo
    var direcoes = [[1, 0], [-1, 0], [0, 1], [0, -1]];

    // Randomizar as direções
    for (var i = 0; i < array_length_1d(direcoes); i++) {
        var random_index = irandom(array_length_1d(direcoes) - 1);
        var temp = direcoes[i];
        direcoes[i] = direcoes[random_index];
        direcoes[random_index] = temp;
    }

    var nova_sala_templo = undefined;

    // Tenta criar uma nova sala válida para o templo
    for (var j = 0; j < array_length_1d(direcoes); j++) {
        var nova_posicao = [sala_mais_distante_templo[0] + direcoes[j][0], sala_mais_distante_templo[1] + direcoes[j][1]];
        var direcao_valida = true;

        // Verifica se já existe uma sala na nova posição
        for (var k = 0; k < array_length_1d(salas_geradas); k++) {
            if (salas_geradas[k][0] == nova_posicao[0] && salas_geradas[k][1] == nova_posicao[1]) {
                direcao_valida = false;
                break;
            }
        }

        if (direcao_valida) {
            nova_sala_templo = nova_posicao;
            break;
        }
    }

    // Adicionar a nova sala ao array de salas geradas como o templo
    if (nova_sala_templo != undefined) {
        array_push(salas_geradas, nova_sala_templo);
        array_push(global.templos_salas_pos, nova_sala_templo);
        global.templo_criado = true;

        // Criar a sala do templo e adicionar à lista
        var nova_sala_info = criar_salas_lista(nova_sala_templo, array_length_1d(global.salas_criadas) + 1);
        array_push(global.salas_criadas, nova_sala_info);
    }

    // Passo 2: Criar o jardim

    var sala_mais_distante_jardim = undefined;
    var maior_distancia_jardim = -1;

    // Encontra uma sala distante do jogador e do templo para criar o jardim
    for (var i = 0; i < array_length_1d(salas_geradas); i++) {
        var sala_atual = salas_geradas[i];
        var distancia_player = point_distance(player_sala[0], player_sala[1], sala_atual[0], sala_atual[1]);
        var distancia_templo = point_distance(nova_sala_templo[0], nova_sala_templo[1], sala_atual[0], sala_atual[1]);

        // Verifica se é a sala mais distante tanto do jogador quanto do templo
        if (distancia_player > maior_distancia_jardim && distancia_templo > 3) {
            maior_distancia_jardim = distancia_player;
            sala_mais_distante_jardim = sala_atual;
        }
    }

    // Verifica se encontrou uma sala válida para o jardim
    if (sala_mais_distante_jardim == undefined) {
        return; // Sai da função se não encontrar uma sala válida
    }

    // Verifica direções disponíveis para criar o jardim
    for (var i = 0; i < array_length_1d(direcoes); i++) {
        var random_index = irandom(array_length_1d(direcoes) - 1);
        var temp = direcoes[i];
        direcoes[i] = direcoes[random_index];
        direcoes[random_index] = temp;
    }

    var nova_sala_jardim = undefined;

    // Tenta criar uma nova sala válida para o jardim
    for (var j = 0; j < array_length_1d(direcoes); j++) {
        var nova_posicao = [sala_mais_distante_jardim[0] + direcoes[j][0], sala_mais_distante_jardim[1] + direcoes[j][1]];
        var direcao_valida = true;

        // Verifica se já existe uma sala na nova posição
        for (var k = 0; k < array_length_1d(salas_geradas); k++) {
            if (salas_geradas[k][0] == nova_posicao[0] && salas_geradas[k][1] == nova_posicao[1]) {
                direcao_valida = false;
                break;
            }
        }

        if (direcao_valida) {
            nova_sala_jardim = nova_posicao;
            break;
        }
    }

    // Adicionar a nova sala ao array de salas geradas como o jardim
    if (nova_sala_jardim != undefined) {
        array_push(salas_geradas, nova_sala_jardim);
        global.sala_jardim = nova_sala_jardim;

        // Criar a sala do jardim e adicionar à lista
        var nova_sala_info = criar_salas_lista(nova_sala_jardim, array_length_1d(global.salas_criadas) + 1);
        array_push(global.salas_criadas, nova_sala_info);
    }
}


#endregion

function criar_templo_poder(_maze_width, _maze_height, _maze, w, h) {
    // Definir variáveis locais para as coordenadas do meio das paredes
	

    // Criar paredes na linha superior e inferior com base no valor de 'w'
    for (var i = w; i < _maze_width - w; i++) {
        ds_grid_set(_maze, i, w, 0);  // Linha superior
        ds_grid_set(_maze, i, _maze_height - w - 1, 0);  // Linha inferior
    }

    // Criar paredes nas colunas esquerda e direita com base no valor de 'h'
    for (var j = h; j < _maze_height - h; j++) {
        ds_grid_set(_maze, h, j, 0);  // Coluna esquerda
        ds_grid_set(_maze, _maze_width - h - 1, j, 0);  // Coluna direita
    }

    // Coordenadas da parede do meio superior
    global.x_meio_superior = _maze_width / 2;
    global.y_meio_superior = w;
    
    // Coordenadas da parede do meio inferior
    global.x_meio_inferior = _maze_width / 2;
	global.y_meio_inferior = _maze_height - w - 1;

    // Coordenadas da parede do meio esquerda
    global.x_meio_esquerda = h;
    global.y_meio_esquerda = _maze_height / 2;

    // Coordenadas da parede do meio direita
    global.x_meio_direita = _maze_width - h - 1;
    global.y_meio_direita = _maze_height / 2;

    // Mostrar mensagens de depuração (opcional)
   
}
#endregion

#region Sala_escura
function criar_salas_escuras(player_sala, salas_geradas, quantidade_salas) {
    // Inicializa a variável global.salas_escuras, se ainda não existir
    if (!variable_global_exists("salas_escuras")) {
        global.salas_escuras = [];
    }

    var salas_escuras_criadas = 0;

    while (salas_escuras_criadas < quantidade_salas) {
        var sala_mais_distante = undefined;
        var maior_distancia = -1;

        // Encontra a sala mais distante do jogador
        for (var i = 0; i < array_length_1d(salas_geradas); i++) {
            var sala_atual = salas_geradas[i];
            var distancia = point_distance(player_sala[0], player_sala[1], sala_atual[0], sala_atual[1]);

            // Verifica se esta é a sala mais distante até agora e que não está próxima a outro templo
            if (distancia > maior_distancia) {
                var distancia_segura = true;

                // Verifica se a sala está a uma distância segura de todos os templos já criados
                for (var t = 0; t < array_length_1d(global.salas_escuras); t++) {
                    var templo_pos = global.salas_escuras[t];
                    var distancia_templo = point_distance(sala_atual[0], sala_atual[1], templo_pos[0], templo_pos[1]);

                    // Define a distância mínima entre templos como 3 células
                    if (distancia_templo <= 3) {
                        distancia_segura = false;
                        break;
                    }
                }

                // Se a sala é a mais distante do jogador e está a uma distância segura de outros templos
                if (distancia_segura) {
                    maior_distancia = distancia;
                    sala_mais_distante = sala_atual;
                }
            }
        }

        // Verifica se encontrou uma sala válida para ser a sala mais distante
        if (sala_mais_distante == undefined) {
            break; // Sai do loop se não encontrar uma sala válida
        }

        // Verifica direções disponíveis para criar uma nova sala
        var direcoes = [[50, 0], [-50, 0], [0, 50], [0, -50]]; // Direções: Direita, Esquerda, Cima, Baixo

        // Randomizar a ordem das direções
        for (var i = 0; i < array_length_1d(direcoes); i++) {
            var random_index = irandom(array_length_1d(direcoes) - 1);
            var temp = direcoes[i];
            direcoes[i] = direcoes[random_index];
            direcoes[random_index] = temp;
        }

        var nova_sala = undefined;

        for (var j = 0; j < array_length_1d(direcoes); j++) {
            var nova_posicao = [sala_mais_distante[0] + direcoes[j][0], sala_mais_distante[1] + direcoes[j][1]];
            var direcao_valida = true;
            var adjacentes = 0;

            // Verifica se já existe uma sala na nova posição
            for (var k = 0; k < array_length_1d(salas_geradas); k++) {
                if (salas_geradas[k][0] == nova_posicao[0] && salas_geradas[k][1] == nova_posicao[1]) {
                    direcao_valida = false;
                    break;
                }
            }

            // Verificar se a nova sala terá mais de uma adjacente
            for (var d = 0; d < array_length_1d(direcoes); d++) {
                var adjacente_posicao = [nova_posicao[0] + direcoes[d][0], nova_posicao[1] + direcoes[d][1]];
                for (var k = 0; k < array_length_1d(salas_geradas); k++) {
                    if (salas_geradas[k][0] == adjacente_posicao[0] && salas_geradas[k][1] == adjacente_posicao[1]) {
                        adjacentes++;
                    }
                }
            }

            // Se a nova posição é válida e tem no máximo 1 sala adjacente, pode criar a nova sala
            if (direcao_valida && adjacentes <= 1) {
                nova_sala = nova_posicao;
                break;
            }
        }

        // Adicionar a nova sala ao array de salas geradas e à lista de salas escuras
        if (nova_sala != undefined) {
            array_push(salas_geradas, nova_sala);

            // Adicionar a nova sala à lista de salas escuras
            array_push(global.salas_escuras, nova_sala);

            // Adicionar a nova sala à lista de salas criadas (global.salas_criadas)
            var nova_sala_info = criar_salas_lista(nova_sala, array_length_1d(global.salas_criadas) + 1); // Cria as informações da sala
            array_push(global.salas_criadas, nova_sala_info); // Adiciona à lista de salas criadas

            salas_escuras_criadas++;
        } else {
            break; // Se não foi possível criar mais salas, sai do loop
        }
    }
}
#endregion




// Função auxiliar para verificar se uma sala já foi selecionada
function array_contains(array, sala) {
    for (var i = 0; i < array_length_1d(array); i++) {
        if (array[i][0] == sala[0] && array[i][1] == sala[1]) {
            return true;
        }
    }
    return false;
}


#region Paredes
function criar_paredes_na_sala(sala_especifica, quantidade_paredes) {
    var sala_id = string(sala_especifica[0]) + "_" + string(sala_especifica[1]); // Gerar um ID único baseado nas coordenadas da sala
    var lista_paredes = ds_list_create(); // Criar uma lista para ar_mazenar as posições das paredes

    // Criar paredes aleatórias na sala e salvar suas posições
    for (var j = 0; j < quantidade_paredes; j++) {
        var parede_x = irandom_range(256, room_width - 256); // Gera posições aleatórias dentro da sala
        var parede_y = irandom_range(256, room_height - 256);

        // Marcar a posição como parede no grid da sala
        ds_grid_set(global._maze, parede_x, parede_y, 1);

        // Salvar a posição da parede na lista
        ds_list_add(lista_paredes, [parede_x, parede_y]);
    }

    // Ar_mazenar a lista de paredes no mapa global para a sala correspondente
    ds_map_add(global.salas_com_paredes, sala_id, lista_paredes);

  
}

function criar_paredes_intances(_maze_width, _maze_height, _maze, _cell_size) {
 
	var sala = procurar_sala_por_numero(global.current_sala); // Procura a sala com tag 2
	escrever_informacoes_sala(sala)

	var direcao = 0;
    for (var i = 0; i <= _maze_width; i++) {
        for (var z = 0; z <= _maze_height; z++) {
            // Se a posição na grid for 0, indica que é uma parede
				
			   
            if (ds_grid_get(_maze, i, z) == 0) {
				var adjacente_cima = (z > 0 && ds_grid_get(_maze, i, z - 1) == 0);
                var adjacente_baixo = (z < _maze_height - 1 && ds_grid_get(_maze, i, z + 1) == 0);
                var adjacente_esquerda = (i > 0 && ds_grid_get(_maze, i - 1, z) == 0);
                var adjacente_direita = (i < _maze_width - 1 && ds_grid_get(_maze, i + 1, z) == 0);
				
				var image_index_in = 0; // Padrão para nenhuma adjacência
                // Criar a instância da parede com ajuste de posição
			
				   // Definir o image_index com base nas adjacências
                if (!adjacente_cima && adjacente_baixo && adjacente_esquerda && !adjacente_direita) {
                    image_index_in = 6;
                } else if (adjacente_direita && adjacente_baixo && !adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 7;
                }else if (!adjacente_direita && adjacente_baixo && adjacente_cima && adjacente_esquerda) {
                    image_index_in = 11;
                }else if (adjacente_direita && adjacente_baixo && adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 12;
                } else if (adjacente_direita && !adjacente_baixo && adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 5;
                } else if (!adjacente_direita && !adjacente_baixo && adjacente_cima && adjacente_esquerda) {
                    image_index_in = 4;
                } else if (!adjacente_direita && adjacente_baixo && adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 8;
                } else if (!adjacente_direita && !adjacente_baixo && adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 8;
                } 
				else if (!adjacente_direita && adjacente_baixo && !adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 8;
                } 
				
				if (i == 0) {
                // Caso seja a borda esquerda
                if (adjacente_cima && adjacente_baixo) {
                    image_index_in = 8; // Substitua por seu índice de sprite desejado para a borda esquerda
                }
            }else if (i == _maze_width - 1 && z > 0 && z < _maze_height - 1 || i == _maze_width - 5 && z > 0 && z < _maze_height - 5 ) {
                // Caso seja a borda direita
                if (adjacente_cima && adjacente_baixo) {
                    image_index_in = 9; // Substitua por seu índice de sprite desejado para a borda direita
                }
            }
			else if (z == _maze_height - 1 && i > 0 && i < _maze_width - 1 ||z == _maze_height - 5 && i > 0 && i < _maze_width - 5 ) {
			 if (adjacente_direita && !adjacente_baixo && !adjacente_cima && adjacente_esquerda) {
			  image_index_in = 10;
				}
				}
				

             
			

                var wall_instance = instance_create_layer(i * _cell_size, z * _cell_size, "instances", sala.parede);
                with (wall_instance) {
                    // Ajustar a origem para centralizar
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
					   image_index = image_index_in;
					   image_angle = direcao;
                }
				var wall_instance2 = instance_create_layer(i * _cell_size, z * _cell_size, "instances_floor", sala.chao);
				 with (wall_instance2) {
                    // Ajustar a origem para centralizar
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
                }
				
            } else {
				
				
                // Se não for uma parede, crie o chão
                var chao_instance = instance_create_layer(i * _cell_size, z * _cell_size, "instances_floor", sala.chao);
                with (chao_instance) {
                    // Centralizar as instâncias de chão
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
                   image_angle = choose(0, 90, 180, 270);  // Rotação aleatória do chão
                }
			
            }
        }
    }
	
}
function criar_paredes_vermelha_intances(_maze_width, _maze_height, _maze, _cell_size) {
    // Iterar por todas as posições da grid
    for (var i = 0; i < _maze_width; i++) {
        for (var z = 0; z < _maze_height; z++) {
            // Se a posição na grid for 0, indica que é uma parede
            if (ds_grid_get(_maze, i, z) == 0) {
                var adjacente_cima = (z > 0 && ds_grid_get(_maze, i, z - 1) == 0);
                var adjacente_baixo = (z < _maze_height - 1 && ds_grid_get(_maze, i, z + 1) == 0);
                var adjacente_esquerda = (i > 0 && ds_grid_get(_maze, i - 1, z) == 0);
                var adjacente_direita = (i < _maze_width - 1 && ds_grid_get(_maze, i + 1, z) == 0);

                var image_index_in = 15; // Padrão para nenhuma adjacência

                // Definir o image_index com base nas adjacências
                if (adjacente_cima && adjacente_baixo && !adjacente_esquerda && !adjacente_direita) {
                    image_index_in = 0;
                } else if (adjacente_esquerda && adjacente_direita && !adjacente_cima && !adjacente_baixo) {
                    image_index_in = 1;
                } else if (adjacente_cima && adjacente_direita && !adjacente_baixo && !adjacente_esquerda) {
                    image_index_in = 7;
                } else if (adjacente_direita && adjacente_baixo && !adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 10;
                } else if (adjacente_baixo && adjacente_esquerda && !adjacente_cima && !adjacente_direita) {
                    image_index_in = 9;
                } else if (adjacente_esquerda && adjacente_cima && !adjacente_baixo && !adjacente_direita) {
                    image_index_in = 8;
                } else if (adjacente_cima && !adjacente_baixo && !adjacente_esquerda && !adjacente_direita) {
                    image_index_in = 14;
                } else if (adjacente_direita && !adjacente_cima && !adjacente_baixo && !adjacente_esquerda) {
                    image_index_in = 11;
                } else if (adjacente_baixo && !adjacente_cima && !adjacente_esquerda && !adjacente_direita) {
                    image_index_in = 12;
                } else if (adjacente_esquerda && !adjacente_cima && !adjacente_baixo && !adjacente_direita) {
                    image_index_in = 13;
                } else if (adjacente_esquerda && adjacente_cima && adjacente_direita && !adjacente_baixo) {
                    image_index_in = 6;
                } else if (adjacente_cima && adjacente_direita && adjacente_baixo && !adjacente_esquerda) {
                    image_index_in = 5;
                } else if (adjacente_direita && adjacente_baixo && adjacente_esquerda && !adjacente_cima) {
                    image_index_in = 4;
                } else if (adjacente_baixo && adjacente_esquerda && adjacente_cima && !adjacente_direita) {
                    image_index_in = 3;
                } else if (adjacente_cima && adjacente_baixo && adjacente_esquerda && adjacente_direita) {
                    image_index_in = 2;
                }

                // Criar a instância da parede com o image_index ajustado
                var wall_instance = instance_create_layer(i * _cell_size, z * _cell_size, "instances", obj_wall_vermelha);
                with (wall_instance) {
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
                    image_index = image_index_in; // Definir o índice da imagem
                }

                // Criar o chão
                var chao = instance_create_layer(i * _cell_size, z * _cell_size, "instances_floor", obj_floor_carne);
                with (chao) {
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
                }
            } else {
                // Criar o chão para áreas não-parede
                var chao_instance = instance_create_layer(i * _cell_size, z * _cell_size, "instances_floor", obj_floor_carne);
                with (chao_instance) {
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
                    //image_angle = choose(0, 90, 180, 270); // Rotação aleatória do chão
                }
            }
        }
    }
}
function criar_parede_circular(){
	
	   // Criar as paredes circulares nos 4 cantos da room
    var room_w = global.room_width;   // Largura da room
    var room_h = global.room_height;  // Altura da room

    // Canto superior esquerdo
    var wall_circular_1 = instance_create_layer(64, 64, "instances", obj_wall_carne_circular);
    with (wall_circular_1) {
        
    }

    // Canto superior direito
    var wall_circular_2 = instance_create_layer(room_w - global._cell_size, 64, "instances", obj_wall_carne_circular);
    with (wall_circular_2) {
        sprite_index = spr_carne_cirular3;

		
    }

    // Canto inferior esquerdo
    var wall_circular_3 = instance_create_layer(64, room_h - global._cell_size, "instances", obj_wall_carne_circular);
    with (wall_circular_3) {
        sprite_index = spr_carne_cirular4;

    }

    // Canto inferior direito
    var wall_circular_4 = instance_create_layer(room_w - global._cell_size, room_h - global._cell_size, "instances", obj_wall_carne_circular);
    with (wall_circular_4) {
        sprite_index = spr_carne_cirular2;

    }
}
function recriar_paredes_na_sala_atual(current_sala) {
    // Gerar um ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala atual tem paredes salvas
    if (ds_map_exists(global.salas_com_paredes, sala_id)) {
        var lista_paredes = ds_map_find_value(global.salas_com_paredes, sala_id);

        // Recriar as paredes nas posições salvas
        for (var i = 0; i < ds_list_size(lista_paredes); i++) {
            var parede_pos = ds_list_find_value(lista_paredes, i);
            var parede_x = parede_pos[0];
            var parede_y = parede_pos[1];

            // Marcar a posição como parede no grid da sala
            ds_grid_set(global._maze, parede_x, parede_y, 1);
			   
        }

        // Mostrar mensagem de depuração (opcional)
       
    } 
}


function criar_paredes_borda(_maze_width, _maze_height, _maze) {
    // Criar paredes na linha superior e inferior
    for (var i = 0; i <= _maze_width; i++) {
        ds_grid_set(_maze, i, 0, 0);  // Linha superior
        ds_grid_set(_maze, i, _maze_height - 1, 0);  // Linha inferior
    }

    // Criar paredes nas colunas esquerda e direita
    for (var j = 0; j <= _maze_height; j++) {
        ds_grid_set(_maze, 0, j, 0);  // Coluna esquerda
        ds_grid_set(_maze, _maze_width - 1, j, 0);  // Coluna direita
    }
	if(global.fase = 1){
	criar_parede_circular();
	}
}
#endregion

#region chao
function criar_chao_room_inteira(_maze_width,_maze_height,_maze) {
    var i, j;

    // Preencher todas as células da grid com chão
    for (i = 0; i < _maze_width; i++) {
        for (j = 0; j < _maze_height; j++) {
            ds_grid_set(_maze, i, j, 1); // 1 indica chão
        }
    }
}


#endregion

#region SLOW_TAPETE
function recriar_slow_na_sala_atual(current_sala) {
    // Gerar um ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala atual tem pontos salvos
    if (ds_map_exists(global.salas_com_slow, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_slow, sala_id);

        // Recriar os pontos nas posições salvas, se ainda existirem na lista
        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            var ponto_x = ponto_pos[0];
            var ponto_y = ponto_pos[1];

            // Criar o objeto obj_pontos na posição salva
            instance_create_layer(ponto_x, ponto_y, "Instances_Abaixo_moveis", global.slow);
        }

    } 
}
function create_slow_em_salas_aleatorias(salas_geradas, quantidade_salas, quantidade_slow) {
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
        var sala_id = string(sala[0]) + "_" + string(sala[1]); // Gerar um ID único baseado nas coordenadas da sala
        var lista_pontos = ds_list_create(); // Criar uma lista para ar_mazenar as posições dos slows

        // Criar slows aleatórios na sala e salvar suas posições
        for (var j = 0; j < quantidade_slow; j++) {
            var ponto_valido = false;
            var ponto_x, ponto_y;

            // Tentar gerar uma posição válida para o slow
            do {
                ponto_x = irandom_range(128, room_width - 128); // Gera posições aleatórias
                ponto_y = irandom_range(128, room_height - 128);

                ponto_valido = true;

                // Verificar se há algum slow próximo
                for (var k = 0; k < ds_list_size(lista_pontos); k++) {
                    var ponto_existente = ds_list_find_value(lista_pontos, k);
                    var distancia = point_distance(ponto_x, ponto_y, ponto_existente[0], ponto_existente[1]);

                    // Defina a distância mínima entre slows, por exemplo, 100 pixels
                    if (distancia < 100) {
                        ponto_valido = false;
                        break;
                    }
                }
            } until (ponto_valido);

            // Salvar a posição do slow na lista
            ds_list_add(lista_pontos, [ponto_x, ponto_y]);
        }

        // Ar_mazenar a lista de pontos no mapa global para a sala correspondente
        ds_map_add(global.salas_com_slow, sala_id, lista_pontos);
    }
}
#endregion

#region Escada
function recriar_escada_na_sala_atual(current_sala) {
    // Gerar um ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se há uma vela salva na sala
    if (ds_map_exists(global.salas_com_escada_porao, sala_id)) {
        var vela_pos = ds_map_find_value(global.salas_com_escada_porao, sala_id);
        var vela_x = vela_pos[0];
        var vela_y = vela_pos[1];

        instance_create_layer(vela_x, vela_y, "Instances_moveis", obj_escada_porao);
    }
}

function create_escada_porao_em_fundos(salas_geradas) {
	random_set_seed(global.seed_atual);
    for (var i = 0; i < array_length_1d(salas_geradas); i++) {
        var sala = salas_geradas[i];
        var sala_detalhes = procurar_sala_por_numero(sala);

        // Se for uma sala do tipo "fundos"
        if (sala_detalhes.tipo == "fundos") {
            var sala_id = string(sala[0]) + "_" + string(sala[1]);
            var margem = global._cell_size; // Distância mínima da borda da sala

            // Escolher uma parede aleatória para a escada (esquerda, direita, cima, baixo)
            var lado = irandom(3);
            var escada_x, escada_y;

           switch (lado) {
    case 0: // Parede esquerda
        escada_x = margem - 5;
        if (irandom(1) == 0) {
            escada_y = irandom_range(margem, (room_height / 2) - 100); // Parte superior
        } else {
            escada_y = irandom_range((room_height / 2) + 100, room_height - margem); // Parte inferior
        }
        global.direcao_escada_porao = 1;
        global.direcao_escada = 1;
        break;
    case 1: // Parede direita
        escada_x = room_width - margem + 5;
        if (irandom(1) == 0) {
            escada_y = irandom_range(margem, (room_height / 2) - 100); // Parte superior
        } else {
            escada_y = irandom_range((room_height / 2) + 100, room_height - margem); // Parte inferior
        }
        global.direcao_escada_porao = 0;
        global.direcao_escada = 2;
        break;
    case 2: // Parede superior
        escada_y = margem + 37;
        if (irandom(1) == 0) {
            escada_x = irandom_range(margem, (room_width / 2) - 100); // Parte esquerda
        } else {
            escada_x = irandom_range((room_width / 2) + 100, room_width - margem); // Parte direita
        }
        global.direcao_escada_porao = 2;
        global.direcao_escada = 4;
        break;
    case 3: // Parede inferior
        escada_y = room_height - margem - 37;
        if (irandom(1) == 0) {
            escada_x = irandom_range(margem, (room_width / 2) - 100); // Parte esquerda
        } else {
            escada_x = irandom_range((room_width / 2) + 100, room_width - margem); // Parte direita
        }
        global.direcao_escada_porao = 3;
        global.direcao_escada = 3;
        break;
}


            // Armazenar a posição da escada
            ds_map_add(global.salas_com_escada_porao, sala_id, [escada_x, escada_y]);

        }
    }
}
#endregion

#region INIMIGOS
function recriar_inimigos_na_sala_atual(current_sala) {
    // Gerar um ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala atual tem pontos salvos
    if (ds_map_exists(global.salas_com_fantasma, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_fantasma, sala_id);

        // Recriar os pontos nas posições salvas, se ainda existirem na lista
        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            var ponto_x = ponto_pos[0];
            var ponto_y = ponto_pos[1];

            // Criar o objeto obj_pontos na posição salva
            instance_create_layer(ponto_x, ponto_y, "instances", obj_inimigo_fantasma);
        }

    } 
}
function create_inimigos_em_salas_escuras(quantidade_inimigos) {
    // Para cada sala escura, criar inimigos
    for (var i = 0; i < array_length_1d(global.salas_escuras); i++) {
        var sala = global.salas_escuras[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]); // Gerar um ID único baseado nas coordenadas da sala
        var lista_inimigo = ds_list_create(); // Criar uma lista para armazenar as posições dos inimigos

        // Criar inimigos aleatórios na sala e salvar suas posições
        for (var j = 0; j < quantidade_inimigos; j++) {
            var inimigo_x = irandom_range(128, room_width - 128); // Gera posições aleatórias
            var inimigo_y = irandom_range(128, room_height - 128);

            // Salvar a posição do inimigo na lista
            ds_list_add(lista_inimigo, [inimigo_x, inimigo_y]);

   
        }

        // Armazenar a lista de inimigos no mapa global para a sala correspondente
        ds_map_add(global.salas_com_fantasma, sala_id, lista_inimigo);
    }
}
function recriar_amoebas_na_sala_atual(current_sala) {
    // Gerar um ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala atual tem pontos salvos
    if (ds_map_exists(global.salas_com_amoeba, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_amoeba, sala_id);

        // Recriar os pontos nas posições salvas, se ainda existirem na lista
        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            var ponto_x = ponto_pos[0];
            var ponto_y = ponto_pos[1];

            // Criar o objeto obj_pontos na posição salva
            instance_create_layer(ponto_x, ponto_y, "instances", obj_amoeba);
        }

    } 
}
function create_amoeba_em_salas_aleatorias(salas_geradas, quantidade_salas, quantidade_pontos) {
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

    // Para cada sala selecionada, criar pontos
    for (var i = 0; i < array_length_1d(salas_selecionadas); i++) {
        var sala = salas_selecionadas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]); // Gerar um ID único baseado nas coordenadas da sala
        var lista_pontos = ds_list_create(); // Criar uma lista para ar_mazenar as posições dos pontos

        // Criar pontos aleatórios na sala e salvar suas posições
        for (var j = 0; j < quantidade_pontos; j++) {
            var ponto_x = irandom_range(128, room_width - 128); // Gera posições aleatórias
            var ponto_y = irandom_range(128, room_height - 128);

            // Salvar a posição do ponto na lista
            ds_list_add(lista_pontos, [ponto_x, ponto_y]);
        }

        // Ar_mazenar a lista de pontos no mapa global para a sala correspondente
        ds_map_add(global.salas_com_amoeba, sala_id, lista_pontos);
    }

   
}
function recriar_inimigos_na_sala_atual_alet(current_sala) {
    // Gerar um ID único para a sala atual baseado nas coordenadas da sala
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala atual tem inimigos salvos no ds_map
    if (ds_map_exists(global.salas_com_inimigos, sala_id)) {
        var lista_inimigos = ds_map_find_value(global.salas_com_inimigos, sala_id);

        // Recriar os inimigos nas posições salvas
        for (var i = 0; i < ds_list_size(lista_inimigos); i++) {
            var inimigo_info = ds_list_find_value(lista_inimigos, i);
            var inimigo_id = inimigo_info[0];   // ID do inimigo
            var inimigo_tipo = inimigo_info[1]; // Tipo do inimigo
            var inimigo_x = inimigo_info[2];    // Posição X
            var inimigo_y = inimigo_info[3];    // Posição Y
            var inimigo_vida = inimigo_info[4]; // Vida do inimigo
            var inimigo_dano = inimigo_info[5]; // Dano do inimigo
            var inimigo_veloc_perse = inimigo_info[6]; // Velocidade de perseguição
            var inimigo_dist_aggro = inimigo_info[7];  // Distância de aggro
            var inimigo_dist_desaggro = inimigo_info[8]; // Distância de desaggro
            var inimigo_escala = inimigo_info[9]; // Escala do inimigo
            var inimigo_veloc = inimigo_info[10]; // Velocidade de movimento
			var max_vida = inimigo_info[11];

            // Criar o inimigo na posição salva
            var inimigo = instance_create_layer(inimigo_x, inimigo_y, "instances", inimigo_tipo);

            // Configurar os parâmetros do inimigo com base nos valores salvos
            inimigo.inimigo_id = inimigo_id; // Atribuir o ID ao inimigo recriado
            inimigo.vida = inimigo_vida;
            inimigo.dano = inimigo_dano;
            inimigo.veloc_perse = inimigo_veloc_perse;
            inimigo.dist_aggro = inimigo_dist_aggro;
            inimigo.dist_desaggro = inimigo_dist_desaggro;
            inimigo.escala = inimigo_escala;
            inimigo.veloc = inimigo_veloc; // Ajustar velocidade de movimento
			inimigo.max_vida = max_vida;
        }
    }
}
// Função para embaralhar o array de salas
function shuffle_array(array) {
    for (var i = array_length_1d(array) - 1; i > 0; i--) {
        var j = irandom(i);
        var temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return array;
}


function criar_inimigos_em_salas_aleatorias_alet(salas_geradas) {
    randomize();
    // Listas de inimigos com base no tipo
    var inimigos_faceis = [obj_amoeba]; // Exemplo de inimigos fáceis
    var inimigos_medios = [obj_amoeba_azul,obj_amoeba_laranja]; // Exemplo de inimigos médios
    var inimigos_dificeis = [obj_amoeba_vermelha,obj_amoeba_rosa,obj_torreta]; // Exemplo de inimigos difíceis
    var lvl = global.level_fase - 1;
    // Definir a quantidade de inimigos com base no nível do jogador
    var quantidade_inimigos = lvl + 2; // Exemplo: mais inimigos à medida que o nível sobe
	var quantidade_salas = lvl + 2;
    // Criar arrays para armazenar salas que terão inimigos
    var salas_selecionadas = [];
	var inimigo_id = 0;
    // Garantir que temos salas suficientes para selecionar
    if (array_length_1d(salas_geradas) < quantidade_salas) {
        quantidade_salas = array_length_1d(salas_geradas);
    }
	
	// Embaralhar as salas e selecionar as primeiras 'quantidade_salas'
    salas_geradas = shuffle_array(salas_geradas); 
    var salas_selecionadas = salas_geradas;
    // Distribuir os inimigos pelas salas selecionadas
    for (var i = 0; i < array_length_1d(salas_selecionadas); i++) {
        var sala = salas_selecionadas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]); // ID único da sala
        lista_inimigos = ds_list_create(); // Lista para armazenar inimigos na sala
		

        // Determinar a quantidade de inimigos por dificuldade baseada no nível
        // Determinar a quantidade de inimigos por dificuldade baseada no nível
		var inimigos_facil_qtd = quantidade_inimigos * (max(5 - lvl, 1) / 5);  // Mais inimigos fáceis nos níveis iniciais
		var inimigos_medio_qtd = quantidade_inimigos * (lvl > 2 ? min((lvl - 2) / 6, 0.3) : 0);  // Menos inimigos médios até lvl 3
		var inimigos_dificil_qtd = quantidade_inimigos * (lvl > 5 ? min((lvl - 5) / 10, 0.2) : 0);  // Inimigos difíceis começam a aparecer mais no lvl 6

		
        // Função auxiliar para adicionar parâmetros e salvar informações do inimigo
        function salvar_inimigo(inimigo_id, inimigo_tipo, inimigo_x, inimigo_y, vida, dano, veloc_perse, dist_aggro, dist_desaggro, escala, veloc, max_vida) {
            ds_list_add(lista_inimigos, [inimigo_id, inimigo_tipo, inimigo_x, inimigo_y, vida, dano, veloc_perse, dist_aggro, dist_desaggro, escala, veloc, max_vida]);
        }

        // Criar inimigos fáceis
        for (var j = 0; j < inimigos_facil_qtd; j++) {
            var inimigo_x = irandom_range(128, room_width - 128);
            var inimigo_y = irandom_range(128, room_height - 128);

            // Escolher inimigo fácil aleatório
            var inimigo_tipo = inimigos_faceis[irandom(array_length_1d(inimigos_faceis) - 1)];
			inimigo_id += 1;
            // Criar o inimigo fácil na posição aleatória e ajustar os parâmetros
            var inimigo = instance_create_layer(inimigo_x, inimigo_y, "instances", inimigo_tipo);
            inimigo.vida = 10 + (lvl * 2); // Vida proporcional ao nível
            inimigo.dano = 5 + lvl; // Dano proporcional ao nível
            inimigo.veloc_perse = 1; // Velocidade de perseguição para fácil
            inimigo.dist_aggro = 200; // Distância de aggro
            inimigo.dist_desaggro = 300; // Distância de desaggro
            inimigo.escala = 3; // Escala para fácil
            inimigo.veloc = 0.8; // Velocidade de movimento padrão
			inimigo.inimigo_id = inimigo_id;
			inimigo.max_vida = 10 + (lvl * 2);
            // Salvar as informações do inimigo
            salvar_inimigo(inimigo_id,inimigo_tipo, inimigo_x, inimigo_y, inimigo.vida, inimigo.dano, inimigo.veloc_perse, inimigo.dist_aggro, inimigo.dist_desaggro, inimigo.escala, inimigo.veloc, inimigo.max_vida);
        }

        // Criar inimigos médios
        for (var j = 0; j < inimigos_medio_qtd; j++) {
            var inimigo_x = irandom_range(128, room_width - 128);
            var inimigo_y = irandom_range(128, room_height - 128);

            var inimigo_tipo = inimigos_medios[irandom(array_length_1d(inimigos_medios) - 1)];
			inimigo_id += 1;
            var inimigo = instance_create_layer(inimigo_x, inimigo_y, "instances", inimigo_tipo);
            inimigo.vida = 20 + (lvl * 3);
            inimigo.dano = 10 + (lvl * 1.5);
            inimigo.veloc_perse = 3; // Velocidade de perseguição para médio
            inimigo.dist_aggro = 400; // Distância de aggro aumentada
            inimigo.dist_desaggro = 500; // Distância de desaggro aumentada
            inimigo.escala = 4; // Escala para médio
            inimigo.veloc = 3; // Velocidade de movimento aumentada
			inimigo.inimigo_id = inimigo_id;
			inimigo.max_vida = 20 + (lvl * 3);
             salvar_inimigo(inimigo_id,inimigo_tipo, inimigo_x, inimigo_y, inimigo.vida, inimigo.dano, inimigo.veloc_perse, inimigo.dist_aggro, inimigo.dist_desaggro, inimigo.escala, inimigo.veloc, inimigo.max_vida);
        }

        // Criar inimigos difíceis
        for (var j = 0; j < inimigos_dificil_qtd; j++) {
            var inimigo_x = irandom_range(128, room_width - 128);
            var inimigo_y = irandom_range(128, room_height - 128);

            var inimigo_tipo = inimigos_dificeis[irandom(array_length_1d(inimigos_dificeis) - 1)];
			inimigo_id += 1;
            var inimigo = instance_create_layer(inimigo_x, inimigo_y, "instances", inimigo_tipo);
            inimigo.vida = 30 + (lvl * 5);
            inimigo.dano = 15 + (lvl * 2);
            inimigo.veloc_perse = 5; // Velocidade de perseguição para difícil
            inimigo.dist_aggro = 700; // Distância de aggro aumentada
            inimigo.dist_desaggro = 800; // Distância de desaggro aumentada
            inimigo.escala = 5; // Escala para difícil
            inimigo.veloc = 5; // Velocidade de movimento aumentada
			inimigo.inimigo_id = inimigo_id;
			inimigo.max_vida = 30 + (lvl * 5);
             salvar_inimigo(inimigo_id,inimigo_tipo, inimigo_x, inimigo_y, inimigo.vida, inimigo.dano, inimigo.veloc_perse, inimigo.dist_aggro, inimigo.dist_desaggro, inimigo.escala, inimigo.veloc, inimigo.max_vida);
        }

        // Armazenar a lista de inimigos no mapa global para essa sala
        ds_map_add(global.salas_com_inimigos, sala_id, lista_inimigos);
    }	
	

}

function remover_inimigo_por_id(sala, inimigo_id) {
    var sala_id = string(sala[0]) + "_" + string(sala[1]);
	

    if (ds_map_exists(global.salas_com_inimigos, sala_id)) {
        var lista_inimigos = ds_map_find_value(global.salas_com_inimigos, sala_id);
		
        for (var i = 0; i < ds_list_size(lista_inimigos); i++) {
            var inimigo_info = ds_list_find_value(lista_inimigos, i);
	
            if (inimigo_info[0] == inimigo_id) {
                ds_list_delete(lista_inimigos, i); 
        
                break;
            }
        }
    } 
}



#endregion

#region TORRETA

function create_torretas_em_salas_aleatorias(salas_geradas, quantidade_salas, quantidade_pontos) {
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

    // Para cada sala selecionada, criar pontos
    for (var i = 0; i < array_length_1d(salas_selecionadas); i++) {
        var sala = salas_selecionadas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]); // Gerar um ID único baseado nas coordenadas da sala
        var lista_pontos = ds_list_create(); // Criar uma lista para ar_mazenar as posições dos pontos

        // Criar pontos aleatórios na sala e salvar suas posições
        for (var j = 0; j < quantidade_pontos; j++) {
            var ponto_x = irandom_range(128, room_width - 128); // Gera posições aleatórias
            var ponto_y = irandom_range(128, room_height - 128);

            // Salvar a posição do ponto na lista
            ds_list_add(lista_pontos, [ponto_x, ponto_y]);
        }

        // Ar_mazenar a lista de pontos no mapa global para a sala correspondente
        ds_map_add(global.salas_com_torretas, sala_id, lista_pontos);
    }
	
	

   
}

function recriar_torreta_na_sala_atual(current_sala) {
    // Gerar um ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala atual tem pontos salvos
    if (ds_map_exists(global.salas_com_torretas, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_torretas, sala_id);

        // Recriar os pontos nas posições salvas, se ainda existirem na lista
        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            var ponto_x = ponto_pos[0];
            var ponto_y = ponto_pos[1];

            // Criar o objeto obj_pontos na posição salva
            instance_create_layer(ponto_x, ponto_y, "instances", obj_torreta);
        }

    } 
}
#endregion






function conta_salas_adjacentes(salas, sala_atual) {
    var direcoes = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    var contador = 0;

    // Verifica cada direção em relação à sala atual
    for (var d = 0; d < 4; d++) {
        var adjacente_x = sala_atual[0] + direcoes[d][0];
        var adjacente_y = sala_atual[1] + direcoes[d][1];

        // Contar quantas salas adjacentes existem
        for (var i = 0; i < array_length_1d(salas); i++) {
            if (salas[i][0] == adjacente_x && salas[i][1] == adjacente_y) {
                contador++;
            }
        }
    }
    return contador; // Retorna o número de salas adjacentes
}

function gera_salas_procedurais(num_salas) {
    // Define a seed atual para garantir que a geração seja consistente
    random_set_seed(global.seed_atual);
    var salas = []; // Array para armazenar as salas
    var sala_atual = [0, 0]; // Começamos na coordenada (0, 0)
    array_push(salas, sala_atual); // Adicionar a primeira sala
    criar_salas_lista(sala_atual, 0); // Função para processar a sala (se necessário)

    var direcoes = [[1, 0], [-1, 0], [0, 1], [0, -1]]; // Direções fixas: Direita, Esquerda, Baixo, Cima
    var tentativas_max = 100; // Limitar o número de tentativas de encontrar uma nova direção

    for (var i = 1; i < num_salas; i++) {
        var nova_sala;
        var encontrou = false;
        var tentativas = 0;

        // Tentar encontrar uma nova sala válida
        while (!encontrou && tentativas < tentativas_max) {
            var sala_anterior = salas[irandom(array_length(salas) - 1)]; // Escolhe uma sala existente para expandir

            // Verificar se a sala anterior já tem 3 salas adjacentes
            if (conta_salas_adjacentes(salas, sala_anterior) < 3) {
                // Escolher uma direção aleatória
                var direcao = direcoes[irandom(3)];

                // Definir a coordenada da nova sala diretamente conectada (sem offset)
                nova_sala = [sala_anterior[0] + direcao[0], sala_anterior[1] + direcao[1]];

                // Verificar se essa nova sala já existe no array
                encontrou = true;
                for (var j = 0; j < array_length(salas); j++) {
                    if (salas[j][0] == nova_sala[0] && salas[j][1] == nova_sala[1]) {
                        encontrou = false;
                        break;
                    }
                }
            }

            tentativas++; // Contar tentativas para evitar loops infinitos
        }

        // Adicionar a nova sala ao array se encontrou uma posição válida
        if (encontrou) {
            array_push(salas, nova_sala);
            criar_salas_lista(nova_sala, i + 1); // Função para processar a nova sala (se necessário)
        }
    }

    return salas; // Retornar o array de salas geradas
}



function cria_salas_e_objetos(_maze_width, _maze_height, _maze, _cell_size) {

    criar_chao_room_inteira(global._maze_width, global._maze_height, global._maze);
    criar_paredes_borda(global._maze_width, global._maze_height, global._maze);
    criar_paredes_intances(global._maze_width, global._maze_height, global._maze, global._cell_size);
}


function criar_instancias_paredes_e_chao_v2(_maze_width, _maze_height, _maze, obj_parede, obj_chao, layer) {
    var i, j;

    // Percorrer a grid e criar instâncias baseadas no valor de cada célula
    for (i = 0; i < _maze_width; i++) {
        for (j = 0; j < _maze_height; j++) {
            var valor_celula = ds_grid_get(_maze, i, j);

            // Converter as coordenadas da grid para coordenadas de pixels
            var x_pos = i * global._block_size;
            var y_pos = j * global._block_size;

            // Criar a instância de chão (0) ou parede (1)
            if (valor_celula == 0) {
                // Criar instância de chão
                instance_create_layer(x_pos, y_pos, layer, obj_chao);
            } else if (valor_celula == 1) {
                // Criar instância de parede
                instance_create_layer(x_pos, y_pos, layer, obj_parede);
            }
        }
    }
}





function criar_portas_gerais_templo(sala_atual, salas_geradas) {
    var room_x = sala_atual[0];
    var room_y = sala_atual[1];

    // Verifica cada sala vizinha em torno da sala atual e cria as portas correspondentes
    for (var i = 0; i < array_length_1d(salas_geradas); i++) {
        var sala_vizinha = salas_geradas[i];

        if (is_array(sala_vizinha)) {
            var x_vizinho = sala_vizinha[0];
            var y_vizinho = sala_vizinha[1];

            // Criar porta na direita
            if (x_vizinho == sala_atual[0] + 1 && y_vizinho == sala_atual[1]) {
                var parede_direita = instance_position(global.room_width - 32, (global.room_height / 2), global.sala.parede);

                if (parede_direita != noone) {
                    instance_destroy(parede_direita);
                }
				var parede_direita2 = instance_position(global.room_width +32 , (global.room_height / 2), global.sala.parede);

                if (parede_direita2 != noone) {
                    instance_destroy(parede_direita2);
                }
				
                var porta_direita = instance_create_layer(global.room_width-10 , (global.room_height / 2), "instances", obj_next_room);
                with (porta_direita) {
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 2;
					image_yscale = 4
					visible = false;
                }
            }
		
            // Criar porta na esquerda
            if (x_vizinho == sala_atual[0] - 1 && y_vizinho == sala_atual[1]) {
                var parede_esquerda = instance_position(0,(global.room_height / 2), global.sala.parede);
                if (parede_esquerda != noone) {
                    instance_destroy(parede_esquerda);
                }
                var porta_esquerda = instance_create_layer(+10, (global.room_height / 2), "instances", obj_next_room);
                with (porta_esquerda) {
					image_yscale = 4
					visible = false;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 4;
					
                }
            }
	

            // Criar porta acima
            if (x_vizinho == sala_atual[0] && y_vizinho == sala_atual[1] + 1) {
                var parede_acima = instance_position((global.room_width / 2)+16,  32, global.sala.parede);
                if (parede_acima != noone) {
					
					instance_destroy(parede_acima);
                }
                var porta_acima = instance_create_layer((global.room_width / 2), 10, "instances", obj_next_room);
                with (porta_acima) {
					image_xscale = 3;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 1;
					visible = false;
                }
            }
			

            // Criar porta abaixo
            if (x_vizinho == sala_atual[0] && y_vizinho == sala_atual[1] - 1) {
                var parede_abaixo = instance_position((global.room_width / 2)+16,global.room_height + 32, global.sala.parede);
                if (parede_abaixo != noone) {
                   
					instance_destroy(parede_abaixo);
					
                }
				var parede_abaixo2 = instance_position((global.room_width / 2)+16,global.room_height + 32, global.sala.parede);
                if (parede_abaixo2 != noone) {
                   
					instance_destroy(parede_abaixo2);
					
                }
                var porta_abaixo = instance_create_layer((global.room_width / 2),  global.room_height -10 , "instances", obj_next_room);
                with (porta_abaixo) {
					visible = false;
					image_xscale = 3;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 3;
					visible = false;
                }
				
            }
        }
	}
    }


function criar_portas_gerais(sala_atual, salas_geradas) {
    var room_x = sala_atual[0];
    var room_y = sala_atual[1];
	var sala = procurar_sala_por_numero(global.current_sala);
    // Verifica cada sala vizinha em torno da sala atual e cria as portas correspondentes
    for (var i = 0; i < array_length_1d(salas_geradas); i++) {
        var sala_vizinha = salas_geradas[i];

        if (is_array(sala_vizinha)) {
            var x_vizinho = sala_vizinha[0];
            var y_vizinho = sala_vizinha[1];

            // Criar porta na direita
            if (x_vizinho == sala_atual[0] + 1 && y_vizinho == sala_atual[1]) {
                var parede_direita = instance_position(global.room_width-1 , (global.room_height / 2),sala.parede);

                if (parede_direita != noone) {
                    instance_destroy(parede_direita);
                }
				var parede_direita2 = instance_position(global.room_width +32 , (global.room_height / 2), sala.parede);

                if (parede_direita2 != noone) {
                    instance_destroy(parede_direita2);
                }
                var porta_direita = instance_create_layer(global.room_width-5 , (global.room_height / 2), "instances", obj_next_room);
                with (porta_direita) {
					image_angle -= 90;
					image_yscale = -1;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 2;
                }
            }

            // Criar porta na esquerda
            if (x_vizinho == sala_atual[0] - 1 && y_vizinho == sala_atual[1]) {
                var parede_esquerda = instance_position(0,(global.room_height / 2), sala.parede);
                if (parede_esquerda != noone) {
                    instance_destroy(parede_esquerda);
                }
                var porta_esquerda = instance_create_layer(5, (global.room_height / 2), "instances", obj_next_room);
                with (porta_esquerda) {
					image_angle += 90;
					image_yscale = -1;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 4;
                }
            }

            // Criar porta acima
            if (x_vizinho == sala_atual[0] && y_vizinho == sala_atual[1] + 1) {
                var parede_acima = instance_position((global.room_width / 2)+16,  32, sala.parede);
                if (parede_acima != noone) {
					
					instance_destroy(parede_acima);
                }
                var porta_acima = instance_create_layer((global.room_width / 2)+32, +10, "instances", obj_next_room);
                with (porta_acima) {
					image_yscale = -1;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 1;
                }
            }

            // Criar porta abaixo
            if (x_vizinho == sala_atual[0] && y_vizinho == sala_atual[1] - 1) {
                var parede_abaixo = instance_position((global.room_width / 2)+16,global.room_height - 10, sala.parede);
                if (parede_abaixo != noone) {
                   
					instance_destroy(parede_abaixo);
					
                }
				var parede_abaixo2 = instance_position((global.room_width / 2)+16,global.room_height + 32, sala.parede);
                if (parede_abaixo2 != noone) {
                   
					instance_destroy(parede_abaixo2);
					
                }
                var porta_abaixo = instance_create_layer((global.room_width / 2)+32,  global.room_height -10, "instances", obj_next_room);
                with (porta_abaixo) {
					
					image_xscale = 1;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 3;
                }
            }
        }
    }
}

function recriar_booses(){
	
	global.sala = procurar_sala_por_numero(global.current_sala);
	if(global.sala.tipo == "jardim" && global.brocolis_vivo){
	global.sala_boss_brocolis = global.sala;
	instance_create_layer(global.room_width / 2 + 32, global.room_height / 2, "Layer_Player", obj_boss_brocolis);
	}
}



function carregar_sala(sala_atual, sala_origem_array) {
    clear_room(); 
	random_set_seed(global.seed_atual);
	global.current_sala = sala_atual;
	global.sala_passada = sala_origem_array;
    cria_salas_e_objetos(global._maze_width, global._maze_height, global._maze, global._cell_size);
	criar_portas_gerais(sala_atual, global.salas_geradas);
	recriar_pontos_na_sala_atual(global.current_sala);
	recriar__escrivaninha_na_sala_atual(global.current_sala);
	recriar_inimigos_na_sala_atual(global.current_sala);
	recriar_slow_na_sala_atual(global.current_sala);
	recriar_guarda_roupa_na_sala_atual(global.current_sala);
	recriar_escada_na_sala_atual(global.current_sala);
	recriar_item_dropado(global.current_sala[0],global.current_sala[1]);
	recriar__geladeira_na_sala_atual(global.current_sala);
	recriar_inimigos_na_sala_atual_alet(global.current_sala);
	recriar_booses();
	sala_tuto(); 
}
function carregar_sala_templo(sala_atual, sala_origem_array,direcao) {
    clear_room(); 
	carregar_templo(direcao);
	global.sala_passada = sala_origem_array;
    global.current_sala = sala_atual;
	criar_portas_gerais_templo(sala_atual, global.salas_geradas);

	
}
function criar_random_pontos(quantidade) {
	
    for (var i = 0; i < quantidade; i++) {
        var ponto_x, ponto_y;
        var tentativas = 0;
        var max_tentativas = 100;  // Limite de tentativas para evitar loops infinitos

        do {
            // Gerar posições aleatórias dentro dos limites da room
            ponto_x = irandom_range(64, room_width - 64); // Gera um valor aleatório dentro dos limites da sala, com uma margem
            ponto_y = irandom_range(64, room_height - 64);
            tentativas++;
        } until (!position_meeting(ponto_x, ponto_y, obj_wall_carne) || tentativas >= max_tentativas);
        // Criar o objeto obj_pontos na posição aleatória
        instance_create_layer(ponto_x, ponto_y, "instances", obj_pontos);
    }

}


function sala_tuto(){
		if (global.current_sala[0] == 0 && global.current_sala[1] == 0) {
	instance_create_layer(global.room_width/2,global.room_height/2,"instances",obj_setas);	
}

}



function clear_room() {
	
	if(global.fase == 0){
		with (all) {
        if (object_index != ojb_control_fase_bebe && object_index != obj_iluminacao && !persistent) {
            instance_destroy();
        }	
    }
	}if(global.fase == 1){
		with (all) {
        if (object_index != obj_control_fase_1 && object_index != obj_iluminacao && !persistent) {
            instance_destroy();
        }	
    }
		
	}
    // Limpar todas as instâncias, exceto obj_SPERM, obj_control_fase_1 e as paredes da borda (obj_wall_carne)
    
}

