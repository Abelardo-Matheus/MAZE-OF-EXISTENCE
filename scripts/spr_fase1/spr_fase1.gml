// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
// Função para limpar todas as instâncias da room, exceto o player e o controlador
// Número de salas que queremos gerar
global.total_rooms = 10; // Ajuste conforme necessário
// Gerar salas procedurais
global.xp = 0;
num_salas = 10;
global.tamanho_player = 1;
global.tamanho_player_max = 5;
global.direcao_templo = 0;
global.vinda_templo = 0;
global.origem_templo = noone;
global.destino_templo = noone;




// Tamanho da grid para posicionar as salas (baseado em quantas salas você quer)
var grid_size = global.total_rooms * 2; // Um grid maior que o número de salas
global.room_grid = ds_grid_create(grid_size, grid_size);

// Inicializa a grid com -1 (indicando que não há sala naquele espaço)
ds_grid_clear(global.room_grid, -1);

// Posição inicial da primeira sala no centro da grid
var start_x = grid_size div 2;
var start_y = grid_size div 2;

// Lista para armazenar as posições das salas
global.room_positions = ds_list_create();
ds_list_add(global.room_positions, [start_x, start_y]);

// Coloca a primeira sala no centro
ds_grid_set(global.room_grid, start_x, start_y, 0); // 0 indica a primeira sala

// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
global.salas_com_pontos = ds_map_create(); // Cria um mapa global para armazenar as posições dos pontos nas salas

// No evento de colisão do obj_pontos com o player ou outro trigger
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

function criar_sala_distante_com_templo(player_sala, salas_geradas) {
    var sala_mais_distante = undefined;
    var maior_distancia = -1;

    // Encontra a sala mais distante do jogador
    for (var i = 0; i < array_length_1d(salas_geradas); i++) {
        var sala_atual = salas_geradas[i];
        var distancia = point_distance(player_sala[0], player_sala[1], sala_atual[0], sala_atual[1]);

        // Verifica se esta é a sala mais distante até agora
        if (distancia > maior_distancia) {
            maior_distancia = distancia;
            sala_mais_distante = sala_atual;
        }
    }

    // Verifica direções disponíveis para criar uma nova sala
    var direcoes = [[1, 0], [-1, 0], [0, 1], [0, -1]]; // Direções: Direita, Esquerda, Cima, Baixo

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

    // Adicionar a nova sala ao array de salas geradas
    if (nova_sala != undefined) {
        array_push(salas_geradas, nova_sala);

        // Armazenar a posição da nova sala como a sala do templo
        global.templo_sala_pos = nova_sala;
	}
}







// Função auxiliar para verificar se uma sala já foi selecionada
function array_contains(array, sala) {
    for (var i = 0; i < array_length_1d(array); i++) {
        if (array[i][0] == sala[0] && array[i][1] == sala[1]) {
            return true;
        }
    }
    return false;
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
    var wall_circular_2 = instance_create_layer(room_w - global.cell_size, 64, "instances", obj_wall_carne_circular);
    with (wall_circular_2) {
        sprite_index = spr_carne_cirular3;

		
    }

    // Canto inferior esquerdo
    var wall_circular_3 = instance_create_layer(64, room_h - global.cell_size, "instances", obj_wall_carne_circular);
    with (wall_circular_3) {
        sprite_index = spr_carne_cirular4;

    }

    // Canto inferior direito
    var wall_circular_4 = instance_create_layer(room_w - global.cell_size, room_h - global.cell_size, "instances", obj_wall_carne_circular);
    with (wall_circular_4) {
        sprite_index = spr_carne_cirular2;

    }
}

function criar_paredes_borda(maze_width, maze_height, maze) {
    // Criar paredes na linha superior e inferior
    for (var i = 0; i <= maze_width; i++) {
        ds_grid_set(maze, i, 0, 0);  // Linha superior
        ds_grid_set(maze, i, maze_height - 1, 0);  // Linha inferior
    }

    // Criar paredes nas colunas esquerda e direita
    for (var j = 0; j <= maze_height; j++) {
        ds_grid_set(maze, 0, j, 0);  // Coluna esquerda
        ds_grid_set(maze, maze_width - 1, j, 0);  // Coluna direita
    }
	criar_parede_circular();
}
function criar_paredes_borda_sem_circular(maze_width, maze_height, maze) {
    // Criar paredes na linha superior e inferior
    for (var i = 0; i <= maze_width-1; i++) {
        ds_grid_set(maze, i, 0, 0);  // Linha superior
        ds_grid_set(maze, i, maze_height - 1, 0);  // Linha inferior
    }

    // Criar paredes nas colunas esquerda e direita
    for (var j = 0; j <= maze_height-1; j++) {
        ds_grid_set(maze, 0, j, 0);  // Coluna esquerda
        ds_grid_set(maze, maze_width - 1, j, 0);  // Coluna direita
    }

}


function criar_chao_room_inteira(maze_width,maze_height,maze) {
    var i, j;

    // Preencher todas as células da grid com chão
    for (i = 0; i < maze_width; i++) {
        for (j = 0; j < maze_height; j++) {
            ds_grid_set(maze, i, j, 1); // 1 indica chão
        }
    }
}
	
function criar_paredes_intances(maze_width, maze_height, maze, cell_size) {
    // Iterar por todas as posições da grid
    for (var i = 0; i <= maze_width; i++) {
        for (var z = 0; z <= maze_height; z++) {
            // Se a posição na grid for 0, indica que é uma parede
            if (ds_grid_get(maze, i, z) == 0) {
                // Criar a instância da parede com ajuste de posição
                var wall_instance = instance_create_layer(i * cell_size, z * cell_size, "instances", obj_wall_carne);
                with (wall_instance) {
                    // Ajustar a origem para centralizar
                    x = i * cell_size + (cell_size / 2);
                    y = z * cell_size + (cell_size / 2);
                }
				var wall_instance2 = instance_create_layer(i * cell_size, z * cell_size, "instances_floor", obj_floor_carne);
				 with (wall_instance2) {
                    // Ajustar a origem para centralizar
                    x = i * cell_size + (cell_size / 2);
                    y = z * cell_size + (cell_size / 2);
                }
				
            } else {
				
				
                // Se não for uma parede, crie o chão
                var chao_instance = instance_create_layer(i * cell_size, z * cell_size, "instances_floor", obj_floor_carne);
                with (chao_instance) {
                    // Centralizar as instâncias de chão
                    x = i * cell_size + (cell_size / 2);
                    y = z * cell_size + (cell_size / 2);
                    image_angle = choose(0, 90, 180, 270);  // Rotação aleatória do chão
                }
			
            }
        }
    }
	
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
            ds_grid_set(global.maze, parede_x, parede_y, 1);
			   
        }

        // Mostrar mensagem de depuração (opcional)
       
    } 
}
function create_pontos_em_salas_aleatorias(salas_geradas, quantidade_salas, quantidade_pontos) {
    // Criar um array para armazenar as salas que terão pontos
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
        var lista_pontos = ds_list_create(); // Criar uma lista para armazenar as posições dos pontos

        // Criar pontos aleatórios na sala e salvar suas posições
        for (var j = 0; j < quantidade_pontos; j++) {
            var ponto_x = irandom_range(128, room_width - 128); // Gera posições aleatórias
            var ponto_y = irandom_range(128, room_height - 128);

            // Salvar a posição do ponto na lista
            ds_list_add(lista_pontos, [ponto_x, ponto_y]);
        }

        // Armazenar a lista de pontos no mapa global para a sala correspondente
        ds_map_add(global.salas_com_pontos, sala_id, lista_pontos);
    }

   
}
function criar_paredes_na_sala(sala_especifica, quantidade_paredes) {
    var sala_id = string(sala_especifica[0]) + "_" + string(sala_especifica[1]); // Gerar um ID único baseado nas coordenadas da sala
    var lista_paredes = ds_list_create(); // Criar uma lista para armazenar as posições das paredes

    // Criar paredes aleatórias na sala e salvar suas posições
    for (var j = 0; j < quantidade_paredes; j++) {
        var parede_x = irandom_range(256, room_width - 256); // Gera posições aleatórias dentro da sala
        var parede_y = irandom_range(256, room_height - 256);

        // Marcar a posição como parede no grid da sala
        ds_grid_set(global.maze, parede_x, parede_y, 1);

        // Salvar a posição da parede na lista
        ds_list_add(lista_paredes, [parede_x, parede_y]);
    }

    // Armazenar a lista de paredes no mapa global para a sala correspondente
    ds_map_add(global.salas_com_paredes, sala_id, lista_paredes);

  
}


function criar_paredes_vermelha_intances(maze_width, maze_height, maze, cell_size) {
    // Iterar por todas as posições da grid
    for (var i = 0; i < maze_width; i++) {
        for (var z = 0; z < maze_height; z++) {
            // Se a posição na grid for 0, indica que é uma parede
            if (ds_grid_get(maze, i, z) == 0) {
                var adjacente_cima = (z > 0 && ds_grid_get(maze, i, z - 1) == 0);
                var adjacente_baixo = (z < maze_height - 1 && ds_grid_get(maze, i, z + 1) == 0);
                var adjacente_esquerda = (i > 0 && ds_grid_get(maze, i - 1, z) == 0);
                var adjacente_direita = (i < maze_width - 1 && ds_grid_get(maze, i + 1, z) == 0);

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
                var wall_instance = instance_create_layer(i * cell_size, z * cell_size, "instances", obj_wall_vermelha);
                with (wall_instance) {
                    x = i * cell_size + (cell_size / 2);
                    y = z * cell_size + (cell_size / 2);
                    image_index = image_index_in; // Definir o índice da imagem
                }

                // Criar o chão
                var chao = instance_create_layer(i * cell_size, z * cell_size, "instances_floor", obj_floor_carne);
                with (chao) {
                    x = i * cell_size + (cell_size / 2);
                    y = z * cell_size + (cell_size / 2);
                }
            } else {
                // Criar o chão para áreas não-parede
                var chao_instance = instance_create_layer(i * cell_size, z * cell_size, "instances_floor", obj_floor_carne);
                with (chao_instance) {
                    x = i * cell_size + (cell_size / 2);
                    y = z * cell_size + (cell_size / 2);
                    image_angle = choose(0, 90, 180, 270); // Rotação aleatória do chão
                }
            }
        }
    }
}


function create_random_ovulo(salas_geradas) {
    var sala_ovulo;
    
    // Iterar sobre as salas geradas e encontrar uma sala distante de (0, 0) e que não seja (0, 0)
    for (var i = 0; i < array_length_1d(salas_geradas); i++) {
        var indice_sala_ovulo = irandom(array_length_1d(salas_geradas) - 1);
        sala_ovulo = salas_geradas[indice_sala_ovulo];

        // Garantir que a sala não seja (0, 0) e que esteja distante de (0, 0)
        if ((sala_ovulo[0] != 0 || sala_ovulo[1] != 0) && (abs(sala_ovulo[0]) > 1 || abs(sala_ovulo[1]) > 1)) {
            // Encontrou uma sala válida
            break;
        }
    }

    // Armazenar a posição da sala onde o óvulo foi colocado
    global.ovulo_sala_pos = sala_ovulo;
    
    // Mostrar mensagem de depuração (opcional)
    show_debug_message("Óvulo criado na sala: " + string(sala_ovulo[0]) + ", " + string(sala_ovulo[1]));
}




function create_random_bomb() {
    var x_bomb, y_bomb;

    do {
        x_bomb = irandom(maze_width - 1) + 1; // Garantir que esteja dentro dos limites
        y_bomb = irandom(maze_height - 1) + 1;
    } until (ds_grid_get(global.maze, x_bomb, y_bomb) == 1); // Continua até encontrar um local de chão

    // Cria a bomba no local encontrado
    instance_create_layer(x_bomb * cell_size, y_bomb * cell_size, "Layer_Enemies", obj_bomba);
}

function create_random_enemy() {
    var enemy_x, enemy_y;

    // Buscar a instância de obj_lab
    var lab = instance_find(Obj_lab, 0);

    // Verifica se a referência ao obj_lab foi definida corretamente
    if (lab != noone) {
        do {
            // Gera coordenadas aleatórias dentro dos limites do labirinto
            enemy_x = irandom(lab.maze_width - 1) + 1;
            enemy_y = irandom(lab.maze_height - 1) + 1;
        } until (ds_grid_get(global.maze, enemy_x, enemy_y) == 1); // Continua até encontrar um local de chão

        // Cria o inimigo no local encontrado
        instance_create_layer(enemy_x * lab.cell_size+32, enemy_y * lab.cell_size+32, "Layer_Enemies", obj_enemy);
    }
}
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
	
    var salas = []; // Array para armazenar as salas
    var sala_atual = [0, 0]; // Começamos na coordenada (0, 0)
    array_push(salas, sala_atual); // Adicionar a primeira sala

    var direcoes = [[1, 0], [-1, 0], [0, 1], [0, -1]]; // Direções fixas: Direita, Esquerda, Baixo, Cima
    var tentativas_max = 30; // Limitar o número de tentativas de encontrar uma nova direção

    for (var i = 1; i < num_salas; i++) {
		randomize();
        var nova_sala;
        var encontrou = false;
        var tentativas = 0;

        // Tentar encontrar uma nova sala válida
        while (!encontrou && tentativas < tentativas_max) {
            var sala_anterior = salas[irandom(i - 1)]; // Escolhe uma sala existente para expandir

            // Verificar se a sala anterior já tem 3 salas adjacentes
            if (conta_salas_adjacentes(salas, sala_anterior) < 3) {
                // Escolher uma direção aleatória
                var direcao = direcoes[irandom(3)];

                // Definir a coordenada da nova sala diretamente conectada (sem offset)
                nova_sala = [sala_anterior[0] + direcao[0], sala_anterior[1] + direcao[1]];

                // Verificar se essa nova sala já existe no array
                encontrou = true;
                for (var j = 0; j < array_length_1d(salas); j++) {
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
        }
    }

    // Depuração: Mostrar a lista de salas geradas
    show_debug_message("Salas geradas:");
    for (var i = 0; i < array_length_1d(salas); i++) {
        show_debug_message("Sala " + string(i) + " - X: " + string(salas[i][0]) + ", Y: " + string(salas[i][1]));
    }

    return salas; // Retornar o array de salas geradas
}



function cria_salas_e_objetos(maze_width, maze_height, maze, cell_size) {
	

    // Criar o layout da sala (paredes, chão, etc.)
    criar_chao_room_inteira(global.maze_width, global.maze_height, global.maze);
    criar_paredes_borda(global.maze_width, global.maze_height, global.maze);
    criar_paredes_intances(global.maze_width, global.maze_height, global.maze, global.cell_size);
	
	
    // Verificar se a sala atual é a sala onde o óvulo deve ser criado
    
}



function criar_portas_gerais(sala_atual, salas_geradas) {
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
                var parede_direita = instance_position(global.room_width - 32, (global.room_height / 2), obj_wall_carne);

                if (parede_direita != noone) {
                    instance_destroy(parede_direita);
                }
				var parede_direita2 = instance_position(global.room_width +32 , (global.room_height / 2), obj_wall_carne);

                if (parede_direita2 != noone) {
                    instance_destroy(parede_direita2);
                }
                var porta_direita = instance_create_layer(global.room_width+32 , (global.room_height / 2), "instances", obj_next_room);
                with (porta_direita) {
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 2;
                }
            }

            // Criar porta na esquerda
            if (x_vizinho == sala_atual[0] - 1 && y_vizinho == sala_atual[1]) {
                var parede_esquerda = instance_position(0,(global.room_height / 2), obj_wall_carne);
                if (parede_esquerda != noone) {
                    instance_destroy(parede_esquerda);
                }
                var porta_esquerda = instance_create_layer(-32, (global.room_height / 2), "instances", obj_next_room);
                with (porta_esquerda) {
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 4;
                }
            }

            // Criar porta acima
            if (x_vizinho == sala_atual[0] && y_vizinho == sala_atual[1] + 1) {
                var parede_acima = instance_position((global.room_width / 2)+16,  32, obj_wall_carne);
                if (parede_acima != noone) {
					
					instance_destroy(parede_acima);
                }
                var porta_acima = instance_create_layer((global.room_width / 2)+32, -32, "instances", obj_next_room);
                with (porta_acima) {
					image_xscale = 1.1;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 1;
                }
            }

            // Criar porta abaixo
            if (x_vizinho == sala_atual[0] && y_vizinho == sala_atual[1] - 1) {
                var parede_abaixo = instance_position((global.room_width / 2)+16,global.room_height - 10, obj_wall_carne);
                if (parede_abaixo != noone) {
                   
					instance_destroy(parede_abaixo);
					
                }
				var parede_abaixo2 = instance_position((global.room_width / 2)+16,global.room_height + 32, obj_wall_carne);
                if (parede_abaixo2 != noone) {
                   
					instance_destroy(parede_abaixo2);
					
                }
                var porta_abaixo = instance_create_layer((global.room_width / 2)+32,  global.room_height +32 , "instances", obj_next_room);
                with (porta_abaixo) {
					
					image_xscale = 1.1;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
					direcao = 3;
                }
            }
        }
    }
}
function criar_portas_templo(sala_atual, salas_geradas,vindas) {
    var room_x = sala_atual[0];
    var room_y = sala_atual[1];

    // Verifica cada sala vizinha em torno da sala atual e cria as portas correspondentes
    for (var i = 0; i < array_length_1d(salas_geradas); i++) {
        var sala_vizinha = salas_geradas[i];

        if (is_array(sala_vizinha)) {
            var x_vizinho = sala_vizinha[0];
            var y_vizinho = sala_vizinha[1];

            // Verificar se a sala atual é vizinha à sala do templo
            if ((abs(sala_atual[0] - global.templo_sala_pos[0]) == 1 && sala_atual[1] == global.templo_sala_pos[1]) ||
                (abs(sala_atual[1] - global.templo_sala_pos[1]) == 1 && sala_atual[0] == global.templo_sala_pos[0])) {

                // Se a sala atual está à direita do templo
                if (sala_atual[0] == global.templo_sala_pos[0] - 1 && sala_atual[1] == global.templo_sala_pos[1]) {
                    var parede_direita = instance_position(global.room_width - 32, (global.room_height / 2), obj_wall_carne);
                    if (parede_direita != noone) {
                        instance_destroy(parede_direita);
                    }
					  var porta_direita = instance_position(global.room_width + 32, (global.room_height / 2), obj_next_room);
                    if( porta_direita != noone) {
                        instance_destroy(porta_direita);
                    }
                    var porta_templo = instance_create_layer(global.room_width + 32, (global.room_height / 2), "instances", obj_goto_templo);
					with (porta_templo) {

                    global.destino_templo = sala_vizinha;
                    global.origem_templo = sala_atual;
					global.direcao_templo = 2;
					global.vinda_templo = vindas;
                }
                }

                // Se a sala atual está à esquerda do templo
                if (sala_atual[0] == global.templo_sala_pos[0] + 1 && sala_atual[1] == global.templo_sala_pos[1]) {
                    var parede_esquerda = instance_position(0, (global.room_height / 2), obj_wall_carne);
                    if (parede_esquerda != noone) {
                        instance_destroy(parede_esquerda);
                    }
					  var porta_esquerda = instance_position(-32, (global.room_height / 2), obj_next_room);
                    if (porta_esquerda != noone) {
                        instance_destroy(porta_esquerda);
                    }
					
                    var porta_templo = instance_create_layer(-32, (global.room_height / 2), "instances", obj_goto_templo);
					with (porta_templo) {

                    global.destino_templo = sala_vizinha;
                    global.origem_templo = sala_atual;
					global.direcao_templo = 4;
					global.vinda_templo = vindas;
                }
				}

                // Se a sala atual está abaixo do templo
                if (sala_atual[0] == global.templo_sala_pos[0] && sala_atual[1] == global.templo_sala_pos[1] - 1) {
                    var parede_acima = instance_position((global.room_width / 2) + 16, 32, obj_wall_carne);
                    if (parede_acima != noone) {
                        instance_destroy(parede_acima);
                    }
					 var porta_acima = instance_position((global.room_width / 2) + 32, -32, obj_next_room);
                    if (porta_acima != noone) {
                        instance_destroy(porta_acima);
                    }
                    var porta_templo = instance_create_layer((global.room_width / 2) + 32, -32, "instances", obj_goto_templo);
					with (porta_templo) {

                    global.destino_templo = sala_vizinha;
                    global.origem_templo = sala_atual;
					global.direcao_templo = 1;
					global.vinda_templo = vindas;
                }
				}

                // Se a sala atual está acima do templo
                if (sala_atual[0] == global.templo_sala_pos[0] && sala_atual[1] == global.templo_sala_pos[1] + 1) {
                    var parede_abaixo = instance_position((global.room_width / 2) + 16, global.room_height - 10, obj_wall_carne);
                    if (parede_abaixo != noone) {
                        instance_destroy(parede_abaixo);
                    }
					var porta_abaixo = instance_position((global.room_width / 2) + 32, global.room_height +32, obj_next_room);
                    if (porta_abaixo != noone) {
                        instance_destroy(porta_abaixo);
                    }
                    var porta_templo = instance_create_layer((global.room_width / 2) + 32, global.room_height + 32, "instances", obj_goto_templo);
					with (porta_templo) {

                    global.destino_templo = sala_vizinha;
                    global.origem_templo = sala_atual;
					global.direcao_templo = 3;
					global.vinda_templo = vindas;
                }
            } 
        }
    }
				}
		}
	




function carregar_sala(sala_atual, sala_origem_array) {
    // Verificar se sala_origem_array é um array


    clear_room();  // Limpar a sala antes de recriar objetos

    // Recriar o layout da sala atual
    cria_salas_e_objetos(global.maze_width, global.maze_height, global.maze, global.cell_size);
	
	global.sala_passada = sala_origem_array;
    // Atualizar a sala atual
    global.current_sala = sala_atual;

    // Criar as portas com base nas salas vizinhas

	
	
	 criar_portas_gerais(sala_atual, global.salas_geradas);
	 criar_portas_templo(sala_atual,global.salas_geradas,global.vinda_templo);
	

	 sala_tuto();

    
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

    // Exibe uma mensagem de depuração com a quantidade de pontos criados (opcional)
    show_debug_message("Criados " + string(quantidade) + " pontos aleatórios na sala.");
}


function sala_tuto(){
		if (global.current_sala[0] == 0 && global.current_sala[1] == 0) {
		show_debug_message(global.current_sala);
	instance_create_layer(global.room_width/2,global.room_height/2,"instances",obj_setas);	
}

}




function clear_room() {
	
    // Limpar todas as instâncias, exceto obj_SPERM, obj_control_fase_1 e as paredes da borda (obj_wall_carne)
    with (all) {
        if (object_index != obj_control_fase_1 ) {
            instance_destroy();
        }
			
    }
}

