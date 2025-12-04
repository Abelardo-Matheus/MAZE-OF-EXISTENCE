// ============================================================================
// INICIALIZAÇÃO DE VARIÁVEIS GLOBAIS E GRID
// ============================================================================

// Tamanho da grid para posicionar as salas
var grid_size = global.total_rooms * 2;
global.room_grid = ds_grid_create(grid_size, grid_size);

var start_x = grid_size div 2;
var start_y = grid_size div 2;

// Inicializa a grid com -1 (indicando que não há sala)
ds_grid_clear(global.room_grid, -1);
global.armamento = 0;

// Lista para armazenar as posições das salas
global.room_positions = ds_list_create();
ds_list_add(global.room_positions, [start_x, start_y]);

global.destino_templo = noone;
global.origem_templo = noone;

// --- PREVENÇÃO DE CRASHES (JARDIM E TEMPLO) ---
global.sala_jardim = noone;      // Inicializa como noone para validações seguras
global.templos_salas_pos = [];   // Inicializa array vazio
// ----------------------------------------------

global.sala_boss_brocolis = [];

// Coloca a primeira sala no centro (0 indica a primeira sala)
ds_grid_set(global.room_grid, start_x, start_y, 0);

global.salas_criadas = [];
global.current_sala = [0, 0];
global.templo_criado = false;

// Mapas de tipos
global.tipos_de_salas = ds_map_create();
global.tipos_de_salas_templo = ds_map_create();
global.tipos_de_salas_jardim = ds_map_create();

// Inicializa definições de salas
salas();

global.sala = procurar_sala_por_numero(global.current_sala);
global.templo_criado = false;

// Mapas de conteúdo das salas
global.salas_com_pontos         = ds_map_create();
global.salas_com_inimigos       = ds_map_create();
global.salas_com_fantasma       = ds_map_create();
global.salas_com_torretas       = ds_map_create();
global.salas_com_amoeba         = ds_map_create();
global.salas_com_slow           = ds_map_create();
global.salas_com_paredes        = ds_map_create();
global.salas_com_vela           = ds_map_create();
global.salas_com_escrivaninha   = ds_map_create();
global.salas_com_escada_porao   = ds_map_create();
global.sala_com_item_drop       = ds_map_create();
global.salas_com_geladeira      = ds_map_create();
global.salas_com_guarda_roupa   = ds_map_create();

/// @desc Gerencia a criação inicial de inimigos e itens
function gerar_inimigos_e_itens_para_o_nivel(salas_geradas, level) {
    var quantidade_inimigos = 1 + (level);
    var quantidade_itens = 2 + level;
    
    criar_inimigos_em_salas_aleatorias_alet(salas_geradas);
    create_slow_em_salas_aleatorias(salas_geradas, 3, quantidade_itens);
}

// ============================================================================
// SISTEMA DE PONTOS
// ============================================================================
#region Pontos

function coletar_ponto(ponto_x, ponto_y, current_sala) {
    global.tamanho_player += 0.1;
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    if (ds_map_exists(global.salas_com_pontos, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_pontos, sala_id);

        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            if (ponto_pos[0] == ponto_x && ponto_pos[1] == ponto_y) {
                ds_list_delete(lista_pontos, i);
                break;
            }
        }
    }
    instance_destroy();
}

function recriar_pontos_na_sala_atual(current_sala) {
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    if (ds_map_exists(global.salas_com_pontos, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_pontos, sala_id);

        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            instance_create_layer(ponto_pos[0], ponto_pos[1], "instances", obj_pontos);
        }
    } 
}

function create_pontos_em_salas_aleatorias(salas_geradas, quantidade_salas, quantidade_pontos) {
    var salas_selecionadas = [];

    // Selecionar salas aleatórias
    for (var i = 0; i < quantidade_salas; i++) {
        var sala_aleatoria;
        do {
            sala_aleatoria = salas_geradas[irandom(array_length(salas_geradas) - 1)];
        } until (!array_contains(salas_selecionadas, sala_aleatoria));

        array_push(salas_selecionadas, sala_aleatoria);
    }

    // Criar pontos nas salas selecionadas
    for (var i = 0; i < array_length(salas_selecionadas); i++) {
        var sala = salas_selecionadas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]);
        var lista_pontos = ds_list_create();

        for (var j = 0; j < quantidade_pontos; j++) {
            var ponto_x = irandom_range(128, room_width - 128);
            var ponto_y = irandom_range(128, room_height - 128);
            ds_list_add(lista_pontos, [ponto_x, ponto_y]);
        }
        ds_map_add(global.salas_com_pontos, sala_id, lista_pontos);
    }
}
#endregion

// ============================================================================
// SISTEMA DE VELAS
// ============================================================================
#region Vela

function coletar_vela(ponto_x, ponto_y, current_sala) {
    global.raio_lanterna += 150;
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    if (ds_map_exists(global.salas_com_vela, sala_id)) {
        var vela_pos = ds_map_find_value(global.salas_com_vela, sala_id);
        if (vela_pos[0] == ponto_x && vela_pos[1] == ponto_y) {
            ds_map_delete(global.salas_com_vela, sala_id);
        }
    }
    instance_destroy();
}
#endregion

// ============================================================================
// TEMPLO E JARDIM
// ============================================================================
#region Jardim e Templo

function criar_templo_e_jardim(player_sala, salas_geradas) {
    // Inicialização segura
    if (!variable_global_exists("sala_jardim")) global.sala_jardim = [];
    if (!variable_global_exists("templos_salas_pos")) global.templos_salas_pos = [];
    
    random_set_seed(global.seed_atual);

    // --- Passo 1: Criar o templo ---
    var sala_mais_distante_templo = undefined;
    var maior_distancia_templo = -1;

    for (var i = 0; i < array_length(salas_geradas); i++) {
        var sala_atual = salas_geradas[i];
        var distancia = point_distance(player_sala[0], player_sala[1], sala_atual[0], sala_atual[1]);

        if (distancia > maior_distancia_templo) {
            maior_distancia_templo = distancia;
            sala_mais_distante_templo = sala_atual;
        }
    }

    if (sala_mais_distante_templo == undefined) return;

    var direcoes = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    // Embaralhar direções
    for (var i = 0; i < array_length(direcoes); i++) {
        var random_index = irandom(array_length(direcoes) - 1);
        var temp = direcoes[i];
        direcoes[i] = direcoes[random_index];
        direcoes[random_index] = temp;
    }

    var nova_sala_templo = undefined;

    for (var j = 0; j < array_length(direcoes); j++) {
        var nova_posicao = [sala_mais_distante_templo[0] + direcoes[j][0], sala_mais_distante_templo[1] + direcoes[j][1]];
        var direcao_valida = true;

        for (var k = 0; k < array_length(salas_geradas); k++) {
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

    if (nova_sala_templo != undefined) {
        array_push(salas_geradas, nova_sala_templo);
        array_push(global.templos_salas_pos, nova_sala_templo);
        global.templo_criado = true;

        var nova_sala_info = criar_salas_lista(nova_sala_templo, array_length(global.salas_criadas) + 1);
        array_push(global.salas_criadas, nova_sala_info);
    }

    // --- Passo 2: Criar o jardim ---
    var sala_mais_distante_jardim = undefined;
    var maior_distancia_jardim = -1;

    for (var i = 0; i < array_length(salas_geradas); i++) {
        var sala_atual = salas_geradas[i];
        var distancia_player = point_distance(player_sala[0], player_sala[1], sala_atual[0], sala_atual[1]);
        var distancia_templo = point_distance(nova_sala_templo[0], nova_sala_templo[1], sala_atual[0], sala_atual[1]);

        if (distancia_player > maior_distancia_jardim && distancia_templo > 3) {
            maior_distancia_jardim = distancia_player;
            sala_mais_distante_jardim = sala_atual;
        }
    }

    if (sala_mais_distante_jardim == undefined) return;

    // Re-embaralhar direções
    for (var i = 0; i < array_length(direcoes); i++) {
        var random_index = irandom(array_length(direcoes) - 1);
        var temp = direcoes[i];
        direcoes[i] = direcoes[random_index];
        direcoes[random_index] = temp;
    }

    var nova_sala_jardim = undefined;

    for (var j = 0; j < array_length(direcoes); j++) {
        var nova_posicao = [sala_mais_distante_jardim[0] + direcoes[j][0], sala_mais_distante_jardim[1] + direcoes[j][1]];
        var direcao_valida = true;

        for (var k = 0; k < array_length(salas_geradas); k++) {
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

    if (nova_sala_jardim != undefined) {
        array_push(salas_geradas, nova_sala_jardim);
        global.sala_jardim = nova_sala_jardim;

        var nova_sala_info = criar_salas_lista(nova_sala_jardim, array_length(global.salas_criadas) + 1);
        array_push(global.salas_criadas, nova_sala_info);
    }
}

function criar_templo_poder(_maze_width, _maze_height, _maze, w, h) {
    // Paredes superior e inferior
    for (var i = w; i < _maze_width - w; i++) {
        ds_grid_set(_maze, i, w, 0);
        ds_grid_set(_maze, i, _maze_height - w - 1, 0);
    }

    // Paredes laterais
    for (var j = h; j < _maze_height - h; j++) {
        ds_grid_set(_maze, h, j, 0);
        ds_grid_set(_maze, _maze_width - h - 1, j, 0);
    }

    global.x_meio_superior = _maze_width / 2;
    global.y_meio_superior = w;
    global.x_meio_inferior = _maze_width / 2;
    global.y_meio_inferior = _maze_height - w - 1;
    global.x_meio_esquerda = h;
    global.y_meio_esquerda = _maze_height / 2;
    global.x_meio_direita = _maze_width - h - 1;
    global.y_meio_direita = _maze_height / 2;
}
#endregion

// ============================================================================
// SALAS ESCURAS
// ============================================================================
#region Sala Escura

function criar_salas_escuras(player_sala, salas_geradas, quantidade_salas) {
    if (!variable_global_exists("salas_escuras")) global.salas_escuras = [];

    var salas_escuras_criadas = 0;

    while (salas_escuras_criadas < quantidade_salas) {
        var sala_mais_distante = undefined;
        var maior_distancia = -1;

        for (var i = 0; i < array_length(salas_geradas); i++) {
            var sala_atual = salas_geradas[i];
            var distancia = point_distance(player_sala[0], player_sala[1], sala_atual[0], sala_atual[1]);

            if (distancia > maior_distancia) {
                var distancia_segura = true;

                for (var t = 0; t < array_length(global.salas_escuras); t++) {
                    var templo_pos = global.salas_escuras[t];
                    var distancia_templo = point_distance(sala_atual[0], sala_atual[1], templo_pos[0], templo_pos[1]);

                    if (distancia_templo <= 3) {
                        distancia_segura = false;
                        break;
                    }
                }

                if (distancia_segura) {
                    maior_distancia = distancia;
                    sala_mais_distante = sala_atual;
                }
            }
        }

        if (sala_mais_distante == undefined) break;

        var direcoes = [[50, 0], [-50, 0], [0, 50], [0, -50]]; 
        // Embaralhar direções
        for (var i = 0; i < array_length(direcoes); i++) {
            var random_index = irandom(array_length(direcoes) - 1);
            var temp = direcoes[i];
            direcoes[i] = direcoes[random_index];
            direcoes[random_index] = temp;
        }

        var nova_sala = undefined;

        for (var j = 0; j < array_length(direcoes); j++) {
            var nova_posicao = [sala_mais_distante[0] + direcoes[j][0], sala_mais_distante[1] + direcoes[j][1]];
            var direcao_valida = true;
            var adjacentes = 0;

            for (var k = 0; k < array_length(salas_geradas); k++) {
                if (salas_geradas[k][0] == nova_posicao[0] && salas_geradas[k][1] == nova_posicao[1]) {
                    direcao_valida = false;
                    break;
                }
            }

            for (var d = 0; d < array_length(direcoes); d++) {
                var adjacente_posicao = [nova_posicao[0] + direcoes[d][0], nova_posicao[1] + direcoes[d][1]];
                for (var k = 0; k < array_length(salas_geradas); k++) {
                    if (salas_geradas[k][0] == adjacente_posicao[0] && salas_geradas[k][1] == adjacente_posicao[1]) {
                        adjacentes++;
                    }
                }
            }

            if (direcao_valida && adjacentes <= 1) {
                nova_sala = nova_posicao;
                break;
            }
        }

        if (nova_sala != undefined) {
            array_push(salas_geradas, nova_sala);
            array_push(global.salas_escuras, nova_sala);
            var nova_sala_info = criar_salas_lista(nova_sala, array_length(global.salas_criadas) + 1);
            array_push(global.salas_criadas, nova_sala_info);
            salas_escuras_criadas++;
        } else {
            break;
        }
    }
}
#endregion

function array_contains(array, sala) {
    for (var i = 0; i < array_length(array); i++) {
        if (array[i][0] == sala[0] && array[i][1] == sala[1]) {
            return true;
        }
    }
    return false;
}

// ============================================================================
// PAREDES E ESTRUTURA
// ============================================================================
#region Paredes

function criar_paredes_na_sala(sala_especifica, quantidade_paredes) {
    var sala_id = string(sala_especifica[0]) + "_" + string(sala_especifica[1]);
    var lista_paredes = ds_list_create();

    for (var j = 0; j < quantidade_paredes; j++) {
        var parede_x = irandom_range(256, room_width - 256);
        var parede_y = irandom_range(256, room_height - 256);

        ds_grid_set(global._maze, parede_x, parede_y, 1);
        ds_list_add(lista_paredes, [parede_x, parede_y]);
    }
    ds_map_add(global.salas_com_paredes, sala_id, lista_paredes);
}

function criar_paredes_intances(_maze_width, _maze_height, _maze, _cell_size) {
    var sala = procurar_sala_por_numero(global.current_sala);
    escrever_informacoes_sala(sala);

    var direcao = 0;
    for (var i = 0; i <= _maze_width; i++) {
        for (var z = 0; z <= _maze_height; z++) {
            
            if (ds_grid_get(_maze, i, z) == 0) {
                var adjacente_cima = (z > 0 && ds_grid_get(_maze, i, z - 1) == 0);
                var adjacente_baixo = (z < _maze_height - 1 && ds_grid_get(_maze, i, z + 1) == 0);
                var adjacente_esquerda = (i > 0 && ds_grid_get(_maze, i - 1, z) == 0);
                var adjacente_direita = (i < _maze_width - 1 && ds_grid_get(_maze, i + 1, z) == 0);
                
                var image_index_in = 0;

                // Lógica de tileset / bitmasking manual
                if (!adjacente_cima && adjacente_baixo && adjacente_esquerda && !adjacente_direita) {
                    image_index_in = 6;
                } else if (adjacente_direita && adjacente_baixo && !adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 7;
                } else if (!adjacente_direita && adjacente_baixo && adjacente_cima && adjacente_esquerda) {
                    image_index_in = 11;
                } else if (adjacente_direita && adjacente_baixo && adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 12;
                } else if (adjacente_direita && !adjacente_baixo && adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 5;
                } else if (!adjacente_direita && !adjacente_baixo && adjacente_cima && adjacente_esquerda) {
                    image_index_in = 4;
                } else if (!adjacente_direita && adjacente_baixo && adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 8;
                } else if (!adjacente_direita && !adjacente_baixo && adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 8;
                } else if (!adjacente_direita && adjacente_baixo && !adjacente_cima && !adjacente_esquerda) {
                    image_index_in = 8;
                }
                
                // Bordas específicas
                if (i == 0) {
                    if (adjacente_cima && adjacente_baixo) image_index_in = 8;
                } else if (i == _maze_width - 1 && z > 0 && z < _maze_height - 1 || i == _maze_width - 5 && z > 0 && z < _maze_height - 5) {
                    if (adjacente_cima && adjacente_baixo) image_index_in = 9;
                } else if (z == _maze_height - 1 && i > 0 && i < _maze_width - 1 || z == _maze_height - 5 && i > 0 && i < _maze_width - 5) {
                    if (adjacente_direita && !adjacente_baixo && !adjacente_cima && adjacente_esquerda) image_index_in = 10;
                }

                var wall_instance = instance_create_layer(i * _cell_size, z * _cell_size, "instances", sala.parede);
                with (wall_instance) {
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
                    image_index = image_index_in;
                    image_angle = direcao;
                }
                
                var wall_instance2 = instance_create_layer(i * _cell_size, z * _cell_size, "instances_floor", sala.chao);
                with (wall_instance2) {
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
                }
                
            } else {
                var chao_instance = instance_create_layer(i * _cell_size, z * _cell_size, "instances_floor", sala.chao);
                with (chao_instance) {
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
                    image_angle = choose(0, 90, 180, 270);
                }
            }
        }
    }
}

function criar_paredes_vermelha_intances(_maze_width, _maze_height, _maze, _cell_size) {
    for (var i = 0; i < _maze_width; i++) {
        for (var z = 0; z < _maze_height; z++) {
            if (ds_grid_get(_maze, i, z) == 0) {
                var adjacente_cima = (z > 0 && ds_grid_get(_maze, i, z - 1) == 0);
                var adjacente_baixo = (z < _maze_height - 1 && ds_grid_get(_maze, i, z + 1) == 0);
                var adjacente_esquerda = (i > 0 && ds_grid_get(_maze, i - 1, z) == 0);
                var adjacente_direita = (i < _maze_width - 1 && ds_grid_get(_maze, i + 1, z) == 0);

                var image_index_in = 15;

                // Lógica detalhada para paredes vermelhas
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

                var wall_instance = instance_create_layer(i * _cell_size, z * _cell_size, "instances", obj_wall_vermelha);
                with (wall_instance) {
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
                    image_index = image_index_in;
                }

                var chao = instance_create_layer(i * _cell_size, z * _cell_size, "instances_floor", obj_floor_carne);
                with (chao) {
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
                }
            } else {
                var chao_instance = instance_create_layer(i * _cell_size, z * _cell_size, "instances_floor", obj_floor_carne);
                with (chao_instance) {
                    x = i * _cell_size + (_cell_size / 2);
                    y = z * _cell_size + (_cell_size / 2);
                }
            }
        }
    }
}

function criar_parede_circular() {
    var room_w = global.room_width;
    var room_h = global.room_height;

    // Cantos
    instance_create_layer(64, 64, "instances", obj_wall_carne_circular);
    
    var wall_circular_2 = instance_create_layer(room_w - global._cell_size, 64, "instances", obj_wall_carne_circular);
    with (wall_circular_2) sprite_index = spr_carne_cirular3;

    var wall_circular_3 = instance_create_layer(64, room_h - global._cell_size, "instances", obj_wall_carne_circular);
    with (wall_circular_3) sprite_index = spr_carne_cirular4;

    var wall_circular_4 = instance_create_layer(room_w - global._cell_size, room_h - global._cell_size, "instances", obj_wall_carne_circular);
    with (wall_circular_4) sprite_index = spr_carne_cirular2;
}

function recriar_paredes_na_sala_atual(current_sala) {
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    if (ds_map_exists(global.salas_com_paredes, sala_id)) {
        var lista_paredes = ds_map_find_value(global.salas_com_paredes, sala_id);

        for (var i = 0; i < ds_list_size(lista_paredes); i++) {
            var parede_pos = ds_list_find_value(lista_paredes, i);
            ds_grid_set(global._maze, parede_pos[0], parede_pos[1], 1);
        }
    } 
}

function criar_paredes_borda(_maze_width, _maze_height, _maze) {
    // Paredes superior e inferior
    for (var i = 0; i <= _maze_width; i++) {
        ds_grid_set(_maze, i, 0, 0);
        ds_grid_set(_maze, i, _maze_height - 1, 0);
    }
    // Paredes laterais
    for (var j = 0; j <= _maze_height; j++) {
        ds_grid_set(_maze, 0, j, 0);
        ds_grid_set(_maze, _maze_width - 1, j, 0);
    }
    
    // Correção: uso de == para comparação
    if (global.fase == 1) {
        criar_parede_circular();
    }
}
#endregion

#region Chao
function criar_chao_room_inteira(_maze_width, _maze_height, _maze) {
    for (var i = 0; i < _maze_width; i++) {
        for (var j = 0; j < _maze_height; j++) {
            ds_grid_set(_maze, i, j, 1); // 1 indica chão
        }
    }
}
#endregion

// ============================================================================
// OBJETOS ESPECIAIS (SLOW, ESCADA)
// ============================================================================
#region Slow Tapete

function recriar_slow_na_sala_atual(current_sala) {
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    if (ds_map_exists(global.salas_com_slow, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_slow, sala_id);

        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            instance_create_layer(ponto_pos[0], ponto_pos[1], "Instances_Abaixo_moveis", global.slow);
        }
    } 
}

function create_slow_em_salas_aleatorias(salas_geradas, quantidade_salas, quantidade_slow) {
    var salas_selecionadas = [];

    for (var i = 0; i < quantidade_salas; i++) {
        var sala_aleatoria;
        do {
            sala_aleatoria = salas_geradas[irandom(array_length(salas_geradas) - 1)];
        } until (!array_contains(salas_selecionadas, sala_aleatoria));

        array_push(salas_selecionadas, sala_aleatoria);
    }

    for (var i = 0; i < array_length(salas_selecionadas); i++) {
        var sala = salas_selecionadas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]);
        var lista_pontos = ds_list_create();

        for (var j = 0; j < quantidade_slow; j++) {
            var ponto_valido = false;
            var ponto_x, ponto_y;

            do {
                ponto_x = irandom_range(128, room_width - 128);
                ponto_y = irandom_range(128, room_height - 128);
                ponto_valido = true;

                for (var k = 0; k < ds_list_size(lista_pontos); k++) {
                    var ponto_existente = ds_list_find_value(lista_pontos, k);
                    var distancia = point_distance(ponto_x, ponto_y, ponto_existente[0], ponto_existente[1]);
                    if (distancia < 100) {
                        ponto_valido = false;
                        break;
                    }
                }
            } until (ponto_valido);

            ds_list_add(lista_pontos, [ponto_x, ponto_y]);
        }
        ds_map_add(global.salas_com_slow, sala_id, lista_pontos);
    }
}
#endregion

#region Escada
function recriar_escada_na_sala_atual(current_sala) {
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    if (ds_map_exists(global.salas_com_escada_porao, sala_id)) {
        var vela_pos = ds_map_find_value(global.salas_com_escada_porao, sala_id);
        instance_create_layer(vela_pos[0], vela_pos[1], "Instances_moveis", obj_escada_porao);
    }
}

function create_escada_porao_em_fundos(salas_geradas) {
    random_set_seed(global.seed_atual);
    
    for (var i = 0; i < array_length(salas_geradas); i++) {
        var sala = salas_geradas[i];
        var sala_detalhes = procurar_sala_por_numero(sala);

        if (sala_detalhes.tipo == "fundos") {
            var sala_id = string(sala[0]) + "_" + string(sala[1]);
            var margem = global._cell_size;
            var lado = irandom(3);
            var escada_x, escada_y;

            switch (lado) {
                case 0: // Esquerda
                    escada_x = margem - 5;
                    escada_y = (irandom(1) == 0) ? irandom_range(margem, (room_height / 2) - 100) : irandom_range((room_height / 2) + 100, room_height - margem);
                    global.direcao_escada_porao = 1;
                    global.direcao_escada = 1;
                    break;
                case 1: // Direita
                    escada_x = room_width - margem + 5;
                    escada_y = (irandom(1) == 0) ? irandom_range(margem, (room_height / 2) - 100) : irandom_range((room_height / 2) + 100, room_height - margem);
                    global.direcao_escada_porao = 0;
                    global.direcao_escada = 2;
                    break;
                case 2: // Cima
                    escada_y = margem + 37;
                    escada_x = (irandom(1) == 0) ? irandom_range(margem, (room_width / 2) - 100) : irandom_range((room_width / 2) + 100, room_width - margem);
                    global.direcao_escada_porao = 2;
                    global.direcao_escada = 4;
                    break;
                case 3: // Baixo
                    escada_y = room_height - margem - 37;
                    escada_x = (irandom(1) == 0) ? irandom_range(margem, (room_width / 2) - 100) : irandom_range((room_width / 2) + 100, room_width - margem);
                    global.direcao_escada_porao = 3;
                    global.direcao_escada = 3;
                    break;
            }
            ds_map_add(global.salas_com_escada_porao, sala_id, [escada_x, escada_y]);
        }
    }
}
#endregion

// ============================================================================
// INIMIGOS E TORRETAS
// ============================================================================
#region Inimigos

function recriar_inimigos_na_sala_atual(current_sala) {
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    if (ds_map_exists(global.salas_com_fantasma, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_fantasma, sala_id);

        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            instance_create_layer(ponto_pos[0], ponto_pos[1], "instances", obj_inimigo_fantasma);
        }
    } 
}

function create_inimigos_em_salas_escuras(quantidade_inimigos) {
    for (var i = 0; i < array_length(global.salas_escuras); i++) {
        var sala = global.salas_escuras[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]);
        var lista_inimigo = ds_list_create();

        for (var j = 0; j < quantidade_inimigos; j++) {
            var inimigo_x = irandom_range(128, room_width - 128);
            var inimigo_y = irandom_range(128, room_height - 128);
            ds_list_add(lista_inimigo, [inimigo_x, inimigo_y]);
        }
        ds_map_add(global.salas_com_fantasma, sala_id, lista_inimigo);
    }
}

function recriar_amoebas_na_sala_atual(current_sala) {
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    if (ds_map_exists(global.salas_com_amoeba, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_amoeba, sala_id);

        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            instance_create_layer(ponto_pos[0], ponto_pos[1], "instances", obj_amoeba);
        }
    } 
}

function create_amoeba_em_salas_aleatorias(salas_geradas, quantidade_salas, quantidade_pontos) {
    var salas_selecionadas = [];

    for (var i = 0; i < quantidade_salas; i++) {
        var sala_aleatoria;
        do {
            sala_aleatoria = salas_geradas[irandom(array_length(salas_geradas) - 1)];
        } until (!array_contains(salas_selecionadas, sala_aleatoria));

        array_push(salas_selecionadas, sala_aleatoria);
    }

    for (var i = 0; i < array_length(salas_selecionadas); i++) {
        var sala = salas_selecionadas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]);
        var lista_pontos = ds_list_create();

        for (var j = 0; j < quantidade_pontos; j++) {
            var ponto_x = irandom_range(128, room_width - 128);
            var ponto_y = irandom_range(128, room_height - 128);
            ds_list_add(lista_pontos, [ponto_x, ponto_y]);
        }
        ds_map_add(global.salas_com_amoeba, sala_id, lista_pontos);
    }
}

function recriar_inimigos_na_sala_atual_alet(current_sala) {
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    if (ds_map_exists(global.salas_com_inimigos, sala_id)) {
        var lista_inimigos = ds_map_find_value(global.salas_com_inimigos, sala_id);

        for (var i = 0; i < ds_list_size(lista_inimigos); i++) {
            var inimigo_info = ds_list_find_value(lista_inimigos, i);
            
            var inimigo = instance_create_layer(inimigo_info[2], inimigo_info[3], "instances", inimigo_info[1]);
            
            inimigo.inimigo_id      = inimigo_info[0];
            inimigo.vida            = inimigo_info[4];
            inimigo.dano            = inimigo_info[5];
            inimigo.veloc_perse     = inimigo_info[6];
            inimigo.dist_aggro      = inimigo_info[7];
            inimigo.dist_desaggro   = inimigo_info[8];
            inimigo.escala          = inimigo_info[9];
            inimigo.veloc           = inimigo_info[10];
            inimigo.max_vida        = inimigo_info[11];
        }
    }
}

function shuffle_array(array) {
    for (var i = array_length(array) - 1; i > 0; i--) {
        var j = irandom(i);
        var temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return array;
}

function criar_inimigos_em_salas_aleatorias_alet(salas_geradas) {
    randomize();
    var inimigos_faceis = [obj_amoeba];
    var inimigos_medios = [obj_amoeba_azul, obj_amoeba_laranja];
    var inimigos_dificeis = [obj_amoeba_vermelha, obj_amoeba_rosa, obj_torreta];
    
    var lvl = global.level_fase - 1;
    var quantidade_inimigos = lvl + 2;
    var quantidade_salas = lvl + 2;
    var inimigo_id = 0;

    if (array_length(salas_geradas) < quantidade_salas) {
        quantidade_salas = array_length(salas_geradas);
    }
    
    salas_geradas = shuffle_array(salas_geradas);
    var salas_selecionadas = salas_geradas;

    for (var i = 0; i < array_length(salas_selecionadas); i++) {
        var sala = salas_selecionadas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]);
        var lista_inimigos = ds_list_create();

        var inimigos_facil_qtd = quantidade_inimigos * (max(5 - lvl, 1) / 5);
        var inimigos_medio_qtd = quantidade_inimigos * (lvl > 2 ? min((lvl - 2) / 6, 0.3) : 0);
        var inimigos_dificil_qtd = quantidade_inimigos * (lvl > 5 ? min((lvl - 5) / 10, 0.2) : 0);

        // Helper interno para salvar
        var salvar_inimigo = function(_lista, _id, _tipo, _x, _y, _vida, _dano, _vp, _da, _dd, _esc, _vel, _vmax) {
             ds_list_add(_lista, [_id, _tipo, _x, _y, _vida, _dano, _vp, _da, _dd, _esc, _vel, _vmax]);
        };

        // Criar fáceis
        for (var j = 0; j < inimigos_facil_qtd; j++) {
            var ix = irandom_range(128, room_width - 128);
            var iy = irandom_range(128, room_height - 128);
            var itype = inimigos_faceis[irandom(array_length(inimigos_faceis) - 1)];
            inimigo_id++;
            
            var inst = instance_create_layer(ix, iy, "instances", itype);
            inst.vida = 10 + (lvl * 2);
            inst.dano = 5 + lvl;
            inst.veloc_perse = 1;
            inst.dist_aggro = 200;
            inst.dist_desaggro = 300;
            inst.escala = 3;
            inst.veloc = 0.8;
            inst.inimigo_id = inimigo_id;
            inst.max_vida = 10 + (lvl * 2);
            
            salvar_inimigo(lista_inimigos, inimigo_id, itype, ix, iy, inst.vida, inst.dano, inst.veloc_perse, inst.dist_aggro, inst.dist_desaggro, inst.escala, inst.veloc, inst.max_vida);
        }

        // Criar médios
        for (var j = 0; j < inimigos_medio_qtd; j++) {
            var ix = irandom_range(128, room_width - 128);
            var iy = irandom_range(128, room_height - 128);
            var itype = inimigos_medios[irandom(array_length(inimigos_medios) - 1)];
            inimigo_id++;

            var inst = instance_create_layer(ix, iy, "instances", itype);
            inst.vida = 20 + (lvl * 3);
            inst.dano = 10 + (lvl * 1.5);
            inst.veloc_perse = 3;
            inst.dist_aggro = 400;
            inst.dist_desaggro = 500;
            inst.escala = 4;
            inst.veloc = 3;
            inst.inimigo_id = inimigo_id;
            inst.max_vida = 20 + (lvl * 3);

            salvar_inimigo(lista_inimigos, inimigo_id, itype, ix, iy, inst.vida, inst.dano, inst.veloc_perse, inst.dist_aggro, inst.dist_desaggro, inst.escala, inst.veloc, inst.max_vida);
        }

        // Criar difíceis
        for (var j = 0; j < inimigos_dificil_qtd; j++) {
            var ix = irandom_range(128, room_width - 128);
            var iy = irandom_range(128, room_height - 128);
            var itype = inimigos_dificeis[irandom(array_length(inimigos_dificeis) - 1)];
            inimigo_id++;

            var inst = instance_create_layer(ix, iy, "instances", itype);
            inst.vida = 30 + (lvl * 5);
            inst.dano = 15 + (lvl * 2);
            inst.veloc_perse = 5;
            inst.dist_aggro = 700;
            inst.dist_desaggro = 800;
            inst.escala = 5;
            inst.veloc = 5;
            inst.inimigo_id = inimigo_id;
            inst.max_vida = 30 + (lvl * 5);

            salvar_inimigo(lista_inimigos, inimigo_id, itype, ix, iy, inst.vida, inst.dano, inst.veloc_perse, inst.dist_aggro, inst.dist_desaggro, inst.escala, inst.veloc, inst.max_vida);
        }

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

#region Torreta
function create_torretas_em_salas_aleatorias(salas_geradas, quantidade_salas, quantidade_pontos) {
    var salas_selecionadas = [];

    for (var i = 0; i < quantidade_salas; i++) {
        var sala_aleatoria;
        do {
            sala_aleatoria = salas_geradas[irandom(array_length(salas_geradas) - 1)];
        } until (!array_contains(salas_selecionadas, sala_aleatoria));
        array_push(salas_selecionadas, sala_aleatoria);
    }

    for (var i = 0; i < array_length(salas_selecionadas); i++) {
        var sala = salas_selecionadas[i];
        var sala_id = string(sala[0]) + "_" + string(sala[1]);
        var lista_pontos = ds_list_create();

        for (var j = 0; j < quantidade_pontos; j++) {
            var ponto_x = irandom_range(128, room_width - 128);
            var ponto_y = irandom_range(128, room_height - 128);
            ds_list_add(lista_pontos, [ponto_x, ponto_y]);
        }
        ds_map_add(global.salas_com_torretas, sala_id, lista_pontos);
    }
}

function recriar_torreta_na_sala_atual(current_sala) {
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    if (ds_map_exists(global.salas_com_torretas, sala_id)) {
        var lista_pontos = ds_map_find_value(global.salas_com_torretas, sala_id);

        for (var i = 0; i < ds_list_size(lista_pontos); i++) {
            var ponto_pos = ds_list_find_value(lista_pontos, i);
            instance_create_layer(ponto_pos[0], ponto_pos[1], "instances", obj_torreta);
        }
    } 
}
#endregion

// ============================================================================
// GERAÇÃO PROCEDURAL
// ============================================================================

function conta_salas_adjacentes(salas, sala_atual) {
    var direcoes = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    var contador = 0;

    for (var d = 0; d < 4; d++) {
        var adjacente_x = sala_atual[0] + direcoes[d][0];
        var adjacente_y = sala_atual[1] + direcoes[d][1];

        for (var i = 0; i < array_length(salas); i++) {
            if (salas[i][0] == adjacente_x && salas[i][1] == adjacente_y) {
                contador++;
            }
        }
    }
    return contador;
}

function gera_salas_procedurais(num_salas) {
    random_set_seed(global.seed_atual);
    var salas = [];
    var sala_atual = [0, 0];
    array_push(salas, sala_atual);
    criar_salas_lista(sala_atual, 0);

    var direcoes = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    var tentativas_max = 100;

    for (var i = 1; i < num_salas; i++) {
        var nova_sala;
        var encontrou = false;
        var tentativas = 0;

        while (!encontrou && tentativas < tentativas_max) {
            var sala_anterior = salas[irandom(array_length(salas) - 1)];

            if (conta_salas_adjacentes(salas, sala_anterior) < 3) {
                var direcao = direcoes[irandom(3)];
                nova_sala = [sala_anterior[0] + direcao[0], sala_anterior[1] + direcao[1]];
                encontrou = true;

                for (var j = 0; j < array_length(salas); j++) {
                    if (salas[j][0] == nova_sala[0] && salas[j][1] == nova_sala[1]) {
                        encontrou = false;
                        break;
                    }
                }
            }
            tentativas++;
        }

        if (encontrou) {
            array_push(salas, nova_sala);
            criar_salas_lista(nova_sala, i + 1);
        }
    }
    return salas;
}

function cria_salas_e_objetos(_maze_width, _maze_height, _maze, _cell_size) {
    criar_chao_room_inteira(global._maze_width, global._maze_height, global._maze);
    criar_paredes_borda(global._maze_width, global._maze_height, global._maze);
    criar_paredes_intances(global._maze_width, global._maze_height, global._maze, global._cell_size);
}

// ============================================================================
// SISTEMA DE PORTAS
// ============================================================================

function criar_portas_gerais_templo(sala_atual, salas_geradas) {
    for (var i = 0; i < array_length(salas_geradas); i++) {
        var sala_vizinha = salas_geradas[i];
        if (is_array(sala_vizinha)) {
            var x_vizinho = sala_vizinha[0];
            var y_vizinho = sala_vizinha[1];

            // Direita
            if (x_vizinho == sala_atual[0] + 1 && y_vizinho == sala_atual[1]) {
                var pd1 = instance_position(global.room_width - 32, (global.room_height / 2), global.sala.parede);
                if (pd1 != noone) instance_destroy(pd1);
                var pd2 = instance_position(global.room_width + 32, (global.room_height / 2), global.sala.parede);
                if (pd2 != noone) instance_destroy(pd2);

                var porta_direita = instance_create_layer(global.room_width - 10, (global.room_height / 2), "instances", obj_next_room);
                with (porta_direita) {
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
                    direcao = 2;
                    image_yscale = 4;
                    visible = false;
                }
            }
            // Esquerda
            if (x_vizinho == sala_atual[0] - 1 && y_vizinho == sala_atual[1]) {
                var pe = instance_position(0, (global.room_height / 2), global.sala.parede);
                if (pe != noone) instance_destroy(pe);

                var porta_esquerda = instance_create_layer(10, (global.room_height / 2), "instances", obj_next_room);
                with (porta_esquerda) {
                    image_yscale = 4;
                    visible = false;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
                    direcao = 4;
                }
            }
            // Cima
            if (x_vizinho == sala_atual[0] && y_vizinho == sala_atual[1] + 1) {
                var pa = instance_position((global.room_width / 2) + 16, 32, global.sala.parede);
                if (pa != noone) instance_destroy(pa);

                var porta_acima = instance_create_layer((global.room_width / 2), 10, "instances", obj_next_room);
                with (porta_acima) {
                    image_xscale = 3;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
                    direcao = 1;
                    visible = false;
                }
            }
            // Baixo
            if (x_vizinho == sala_atual[0] && y_vizinho == sala_atual[1] - 1) {
                var pb1 = instance_position((global.room_width / 2) + 16, global.room_height + 32, global.sala.parede);
                if (pb1 != noone) instance_destroy(pb1);
                var pb2 = instance_position((global.room_width / 2) + 16, global.room_height + 32, global.sala.parede); // Verifique se essa lógica duplicada é intencional
                if (pb2 != noone) instance_destroy(pb2);

                var porta_abaixo = instance_create_layer((global.room_width / 2), global.room_height - 10, "instances", obj_next_room);
                with (porta_abaixo) {
                    visible = false;
                    image_xscale = 3;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
                    direcao = 3;
                }
            }
        }
    }
}

function criar_portas_gerais(sala_atual, salas_geradas) {
    var sala = procurar_sala_por_numero(global.current_sala);

    for (var i = 0; i < array_length(salas_geradas); i++) {
        var sala_vizinha = salas_geradas[i];

        if (is_array(sala_vizinha)) {
            var x_vizinho = sala_vizinha[0];
            var y_vizinho = sala_vizinha[1];

            // Direita
            if (x_vizinho == sala_atual[0] + 1 && y_vizinho == sala_atual[1]) {
                var pd1 = instance_position(global.room_width - 1, (global.room_height / 2), sala.parede);
                if (pd1 != noone) instance_destroy(pd1);
                var pd2 = instance_position(global.room_width + 32, (global.room_height / 2), sala.parede);
                if (pd2 != noone) instance_destroy(pd2);

                var porta_direita = instance_create_layer(global.room_width - 5, (global.room_height / 2), "instances", obj_next_room);
                with (porta_direita) {
                    image_angle -= 90;
                    image_yscale = -1;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
                    direcao = 2;
                }
            }
            // Esquerda
            if (x_vizinho == sala_atual[0] - 1 && y_vizinho == sala_atual[1]) {
                var pe = instance_position(0, (global.room_height / 2), sala.parede);
                if (pe != noone) instance_destroy(pe);

                var porta_esquerda = instance_create_layer(5, (global.room_height / 2), "instances", obj_next_room);
                with (porta_esquerda) {
                    image_angle += 90;
                    image_yscale = -1;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
                    direcao = 4;
                }
            }
            // Cima
            if (x_vizinho == sala_atual[0] && y_vizinho == sala_atual[1] + 1) {
                var pa = instance_position((global.room_width / 2) + 16, 32, sala.parede);
                if (pa != noone) instance_destroy(pa);

                var porta_acima = instance_create_layer((global.room_width / 2) + 32, 10, "instances", obj_next_room);
                with (porta_acima) {
                    image_yscale = -1;
                    room_destino = sala_vizinha;
                    room_origem = sala_atual;
                    direcao = 1;
                }
            }
            // Baixo
            if (x_vizinho == sala_atual[0] && y_vizinho == sala_atual[1] - 1) {
                var pb1 = instance_position((global.room_width / 2) + 16, global.room_height - 10, sala.parede);
                if (pb1 != noone) instance_destroy(pb1);
                var pb2 = instance_position((global.room_width / 2) + 16, global.room_height + 32, sala.parede);
                if (pb2 != noone) instance_destroy(pb2);

                var porta_abaixo = instance_create_layer((global.room_width / 2) + 32, global.room_height - 10, "instances", obj_next_room);
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

// ============================================================================
// CARREGAMENTO E RESPAWN
// ============================================================================

function recriar_bosses() {
    global.sala = procurar_sala_por_numero(global.current_sala);
    if (global.sala.tipo == "jardim" && global.brocolis_vivo) {
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
    
    // Recriar mobílias
    furniture_respawn_in_room(sala_atual, global.salas_com_escrivaninha, obj_mesa_1);
    furniture_respawn_in_room(sala_atual, global.salas_com_geladeira, obj_geladeira);
    furniture_respawn_in_room(sala_atual, global.salas_com_guarda_roupa, obj_guarda_roupa);
    
    recriar_inimigos_na_sala_atual(global.current_sala);
    recriar_slow_na_sala_atual(global.current_sala);
    recriar_escada_na_sala_atual(global.current_sala);
    recriar_item_dropado(global.current_sala[0], global.current_sala[1]);
    recriar_inimigos_na_sala_atual_alet(global.current_sala);
    recriar_bosses();
    sala_tuto(); 
}

function carregar_sala_templo(sala_atual, sala_origem_array, direcao) {
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
        var max_tentativas = 100;

        do {
            ponto_x = irandom_range(64, room_width - 64);
            ponto_y = irandom_range(64, room_height - 64);
            tentativas++;
        } until (!position_meeting(ponto_x, ponto_y, obj_wall_carne) || tentativas >= max_tentativas);
        
        instance_create_layer(ponto_x, ponto_y, "instances", obj_pontos);
    }
}

function sala_tuto() {
    if (global.current_sala[0] == 0 && global.current_sala[1] == 0) {
        instance_create_layer(global.room_width / 2, global.room_height / 2, "instances", obj_setas);
    }
}

function clear_room() {
    if (global.fase == 0) {
        with (all) {
            if (object_index != ojb_control_fase_bebe && object_index != obj_iluminacao && !persistent) {
                instance_destroy();
            }   
        }
    }
    if (global.fase == 1) {
        with (all) {
            if (object_index != obj_control_fase_1 && object_index != obj_iluminacao && !persistent) {
                instance_destroy();
            }   
        }
    }
}