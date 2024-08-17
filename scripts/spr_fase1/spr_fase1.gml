// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
// Função para limpar todas as instâncias da room, exceto o player e o controlador
// Número de salas que queremos gerar
global.total_rooms = 20; // Ajuste conforme necessário
// Gerar salas procedurais
num_salas = 10;


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
function Troca_parede_GOTO_TEMPLO(room_middle_x,room_bottom_y) {
    // Definir as coordenadas da posição inferior central
  

    // Encontrar a parede mais próxima dessa posição
	
    var middle_wall_instance = instance_nearest(room_middle_x, room_bottom_y, obj_wall_carne);
    
    if (middle_wall_instance != noone) {
        // Destruir a parede do meio inferior
        with (middle_wall_instance) {
            instance_destroy();
        }

        // Criar o objeto obj_goto_templo na mesma posição
        instance_create_layer(room_middle_x, room_bottom_y, "instances", obj_goto_templo);
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

    
}





function clear_room() {
    // Limpar todas as instâncias, exceto obj_SPERM, obj_control_fase_1 e as paredes da borda (obj_wall_carne)
    with (all) {
        if (object_index != obj_control_fase_1 ) {
            instance_destroy();
        }
    }
}

