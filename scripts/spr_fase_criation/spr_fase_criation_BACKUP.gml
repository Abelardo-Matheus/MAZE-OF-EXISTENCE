// feather disable GM1044
// feather disable GM2017
// ============================================================================
// INICIALIZAÇÃO DE VARIÁVEIS GLOBAIS E GRID
// ============================================================================

// Tamanho da grid para posicionar as salas
var _grid_size = global.total_rooms * 2;
global.room_grid = ds_grid_create(_grid_size, _grid_size);

var _start_x = _grid_size div 2;
var _start_y = _grid_size div 2;

// Inicializa a grid com -1 (indicando que não há sala)
ds_grid_clear(global.room_grid, -1);
global.armamento = 0;

// Lista para armazenar as posições das salas
global.room_positions = ds_list_create();
ds_list_add(global.room_positions, [_start_x, _start_y]);

global.destino_templo = noone;
global.origem_templo = noone;

// --- PREVENÇÃO DE CRASHES (JARDIM E TEMPLO) ---
global.sala_jardim = [];      // Inicializa como array vazio para validações de tipo (Feather)
global.templos_salas_pos = [];   // Inicializa array vazio
// ----------------------------------------------

global.sala_boss_brocolis = [];

// Coloca a primeira sala no centro (0 indica a primeira sala)
ds_grid_set(global.room_grid, _start_x, _start_y, 0);

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
function gerar_inimigos_e_itens_para_o_nivel(_salas_geradas, _level) {
    var _quantidade_inimigos = 1 + (_level);
    var _quantidade_itens = 2 + _level;
    
    criar_inimigos_em_salas_aleatorias_alet(_salas_geradas);
    create_slow_em_salas_aleatorias(_salas_geradas, 3, _quantidade_itens);
}

// ============================================================================
// SISTEMA DE PONTOS
// ============================================================================
#region Pontos

function coletar_ponto(_ponto_x, _ponto_y, _current_sala) {
    global.tamanho_player += 0.1;
    var _sala_id = string(_current_sala[0]) + "_" + string(_current_sala[1]);

    if (ds_map_exists(global.salas_com_pontos, _sala_id)) {
        var _lista_pontos = ds_map_find_value(global.salas_com_pontos, _sala_id);

        for (var _i = 0; _i < ds_list_size(_lista_pontos); _i++) {
            var _ponto_pos = ds_list_find_value(_lista_pontos, _i);
            if (_ponto_pos[0] == _ponto_x && _ponto_pos[1] == _ponto_y) {
                ds_list_delete(_lista_pontos, _i);
                break;
            }
        }
    }
    instance_destroy();
}

function recriar_pontos_na_sala_atual(_current_sala) {
    var _sala_id = string(_current_sala[0]) + "_" + string(_current_sala[1]);

    if (ds_map_exists(global.salas_com_pontos, _sala_id)) {
        var _lista_pontos = ds_map_find_value(global.salas_com_pontos, _sala_id);

        for (var _i = 0; _i < ds_list_size(_lista_pontos); _i++) {
            var _ponto_pos = ds_list_find_value(_lista_pontos, _i);
            instance_create_layer(_ponto_pos[0], _ponto_pos[1], "instances", obj_pontos);
        }
    } 
}

function create_pontos_em_salas_aleatorias(_salas_geradas, _quantidade_salas, _quantidade_pontos) {
    var _salas_selecionadas = [];

    // Selecionar salas aleatórias
    for (var _i = 0; _i < _quantidade_salas; _i++) {
        var _sala_aleatoria = 0;
        do {
            _sala_aleatoria = _salas_geradas[irandom(array_length(_salas_geradas) - 1)];
        } until (!array_contains(_salas_selecionadas, _sala_aleatoria));

        array_push(_salas_selecionadas, _sala_aleatoria);
    }

    // Criar pontos nas salas selecionadas
    for (var _i = 0; _i < array_length(_salas_selecionadas); _i++) {
        var _sala = _salas_selecionadas[_i];
        var _sala_id = string(_sala[0]) + "_" + string(_sala[1]);
        var _lista_pontos = ds_list_create();

        for (var _j = 0; _j < _quantidade_pontos; _j++) {
            var _ponto_x = irandom_range(128, room_width - 128);
            var _ponto_y = irandom_range(128, room_height - 128);
            ds_list_add(_lista_pontos, [_ponto_x, _ponto_y]);
        }
        ds_map_add(global.salas_com_pontos, _sala_id, _lista_pontos);
    }
}
#endregion

// ============================================================================
// SISTEMA DE VELAS
// ============================================================================
#region Vela

function coletar_vela(_ponto_x, _ponto_y, _current_sala) {
    global.raio_lanterna += 150;
    var _sala_id = string(_current_sala[0]) + "_" + string(_current_sala[1]);

    if (ds_map_exists(global.salas_com_vela, _sala_id)) {
        var _vela_pos = ds_map_find_value(global.salas_com_vela, _sala_id);
        if (_vela_pos[0] == _ponto_x && _vela_pos[1] == _ponto_y) {
            ds_map_delete(global.salas_com_vela, _sala_id);
        }
    }
    instance_destroy();
}
#endregion

// ============================================================================
// TEMPLO E JARDIM
// ============================================================================
#region Jardim e Templo

function criar_templo_e_jardim(_player_sala, _salas_geradas) {
    // Inicialização segura
    if (!variable_global_exists("sala_jardim")) global.sala_jardim = [];
    if (!variable_global_exists("templos_salas_pos")) global.templos_salas_pos = [];
    
    // feather disable once GM1041
    random_set_seed(global.seed_atual);

    // --- Passo 1: Criar o templo ---
    var _sala_mais_distante_templo = undefined;
    var _maior_distancia_templo = -1;

    for (var _i = 0; _i < array_length(_salas_geradas); _i++) {
        var _sala_atual = _salas_geradas[_i];
        var _distancia = point_distance(real(_player_sala[0]), real(_player_sala[1]), real(_sala_atual[0]), real(_sala_atual[1]));

        if (_distancia > _maior_distancia_templo) {
            _maior_distancia_templo = _distancia;
            _sala_mais_distante_templo = _sala_atual;
        }
    }

    if (_sala_mais_distante_templo == undefined) return;

    var _direcoes = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    // Embaralhar direções
    for (var _i = 0; _i < array_length(_direcoes); _i++) {
        var _random_index = irandom(array_length(_direcoes) - 1);
        var _temp = _direcoes[_i];
        _direcoes[_i] = _direcoes[_random_index];
        _direcoes[_random_index] = _temp;
    }

    var _nova_sala_templo = undefined;

    for (var _j = 0; _j < array_length(_direcoes); _j++) {
        var _nova_posicao = [_sala_mais_distante_templo[0] + _direcoes[_j][0], _sala_mais_distante_templo[1] + _direcoes[_j][1]];
        var _direcao_valida = true;

        for (var _k = 0; _k < array_length(_salas_geradas); _k++) {
            if (_salas_geradas[_k][0] == _nova_posicao[0] && _salas_geradas[_k][1] == _nova_posicao[1]) {
                _direcao_valida = false;
                break;
            }
        }

        if (_direcao_valida) {
            _nova_sala_templo = _nova_posicao;
            break;
        }
    }

    if (_nova_sala_templo != undefined) {
        array_push(_salas_geradas, _nova_sala_templo);
        array_push(global.templos_salas_pos, _nova_sala_templo);
        global.templo_criado = true;

        var _nova_sala_info = criar_salas_lista(_nova_sala_templo, array_length(global.salas_criadas) + 1);
        array_push(global.salas_criadas, _nova_sala_info);
    }

    // --- Passo 2: Criar o jardim ---
    var _sala_mais_distante_jardim = undefined;
    var _maior_distancia_jardim = -1;

    for (var _i = 0; _i < array_length(_salas_geradas); _i++) {
        var _sala_atual = _salas_geradas[_i];
        var _distancia_player = point_distance(real(_player_sala[0]), real(_player_sala[1]), real(_sala_atual[0]), real(_sala_atual[1]));
        
        // Adicionando verificação para _nova_sala_templo antes de usar point_distance
        var _distancia_templo = 0;
        if (_nova_sala_templo != undefined) {
            _distancia_templo = point_distance(real(_nova_sala_templo[0]), real(_nova_sala_templo[1]), real(_sala_atual[0]), real(_sala_atual[1]));
        }

        if (_distancia_player > _maior_distancia_jardim && _distancia_templo > 3) {
            _maior_distancia_jardim = _distancia_player;
            _sala_mais_distante_jardim = _sala_atual;
        }
    }

    if (_sala_mais_distante_jardim == undefined) return;

    // Re-embaralhar direções
    for (var _i = 0; _i < array_length(_direcoes); _i++) {
        var _random_index = irandom(array_length(_direcoes) - 1);
        var _temp = _direcoes[_i];
        _direcoes[_i] = _direcoes[_random_index];
        _direcoes[_random_index] = _temp;
    }

    var _nova_sala_jardim = undefined;

    for (var _j = 0; _j < array_length(_direcoes); _j++) {
        var _nova_posicao = [_sala_mais_distante_jardim[0] + _direcoes[_j][0], _sala_mais_distante_jardim[1] + _direcoes[_j][1]];
        var _direcao_valida = true;

        for (var _k = 0; _k < array_length(_salas_geradas); _k++) {
            if (_salas_geradas[_k][0] == _nova_posicao[0] && _salas_geradas[_k][1] == _nova_posicao[1]) {
                _direcao_valida = false;
                break;
            }
        }

        if (_direcao_valida) {
            _nova_sala_jardim = _nova_posicao;
            break;
        }
    }

    if (_nova_sala_jardim != undefined) {
        array_push(_salas_geradas, _nova_sala_jardim);
        global.sala_jardim = _nova_sala_jardim;

        var _nova_sala_info = criar_salas_lista(_nova_sala_jardim, array_length(global.salas_criadas) + 1);
        array_push(global.salas_criadas, _nova_sala_info);
    }
}

function criar_templo_poder(_maze_width, _maze_height, _maze, _w, _h) {
    // Paredes superior e inferior
    for (var _i = _w; _i < _maze_width - _w; _i++) {
        ds_grid_set(_maze, _i, _w, 0);
        ds_grid_set(_maze, _i, _maze_height - _w - 1, 0);
    }

    // Paredes laterais
    for (var _j = _h; _j < _maze_height - _h; _j++) {
        ds_grid_set(_maze, _h, _j, 0);
        ds_grid_set(_maze, _maze_width - _h - 1, _j, 0);
    }

    global.x_meio_superior = _maze_width / 2;
    global.y_meio_superior = _w;
    global.x_meio_inferior = _maze_width / 2;
    global.y_meio_inferior = _maze_height - _w - 1;
    global.x_meio_esquerda = _h;
    global.y_meio_esquerda = _maze_height / 2;
    global.x_meio_direita = _maze_width - _h - 1;
    global.y_meio_direita = _maze_height / 2;
}
#endregion

// ============================================================================
// SALAS ESCURAS
// ============================================================================
#region Sala Escura

function criar_salas_escuras(_player_sala, _salas_geradas, _quantidade_salas) {
    if (!variable_global_exists("salas_escuras")) global.salas_escuras = [];

    var _salas_escuras_criadas = 0;

    while (_salas_escuras_criadas < _quantidade_salas) {
        var _sala_mais_distante = undefined;
        var _maior_distancia = -1;

        for (var _i = 0; _i < array_length(_salas_geradas); _i++) {
            var _sala_atual = _salas_geradas[_i];
            var _distancia = point_distance(_player_sala[0], _player_sala[1], _sala_atual[0], _sala_atual[1]);

            if (_distancia > _maior_distancia) {
                var _distancia_segura = true;

                for (var _t = 0; _t < array_length(global.salas_escuras); _t++) {
                    var _templo_pos = global.salas_escuras[_t];
                    var _distancia_templo = point_distance(_sala_atual[0], _sala_atual[1], _templo_pos[0], _templo_pos[1]);

                    if (_distancia_templo <= 3) {
                        _distancia_segura = false;
                        break;
                    }
                }

                if (_distancia_segura) {
                    _maior_distancia = _distancia;
                    _sala_mais_distante = _sala_atual;
                }
            }
        }

        if (_sala_mais_distante == undefined) break;

        var _direcoes = [[50, 0], [-50, 0], [0, 50], [0, -50]]; 
        // Embaralhar direções
        for (var _i = 0; _i < array_length(_direcoes); _i++) {
            var _random_index = irandom(array_length(_direcoes) - 1);
            var _temp = _direcoes[_i];
            _direcoes[_i] = _direcoes[_random_index];
            _direcoes[_random_index] = _temp;
        }

        var _nova_sala = undefined;

        for (var _j = 0; _j < array_length(_direcoes); _j++) {
            var _nova_posicao = [_sala_mais_distante[0] + _direcoes[_j][0], _sala_mais_distante[1] + _direcoes[_j][1]];
            var _direcao_valida = true;
            var _adjacentes = 0;

            for (var _k = 0; _k < array_length(_salas_geradas); _k++) {
                if (_salas_geradas[_k][0] == _nova_posicao[0] && _salas_geradas[_k][1] == _nova_posicao[1]) {
                    _direcao_valida = false;
                    break;
                }
            }

            for (var _d = 0; _d < array_length(_direcoes); _d++) {
                var _adjacente_posicao = [_nova_posicao[0] + _direcoes[_d][0], _nova_posicao[1] + _direcoes[_d][1]];
                for (var _k = 0; _k < array_length(_salas_geradas); _k++) {
                    if (_salas_geradas[_k][0] == _adjacente_posicao[0] && _salas_geradas[_k][1] == _adjacente_posicao[1]) {
                        _adjacentes++;
                    }
                }
            }

            if (_direcao_valida && _adjacentes <= 1) {
                _nova_sala = _nova_posicao;
                break;
            }
        }

        if (_nova_sala != undefined) {
            array_push(_salas_geradas, _nova_sala);
            array_push(global.salas_escuras, _nova_sala);
            var _nova_sala_info = criar_salas_lista(_nova_sala, array_length(global.salas_criadas) + 1);
            array_push(global.salas_criadas, _nova_sala_info);
            _salas_escuras_criadas++;
        } else {
            break;
        }
    }
}
#endregion

function array_contains(_array, _sala) {
    for (var _i = 0; _i < array_length(_array); _i++) {
        if (_array[_i][0] == _sala[0] && _array[_i][1] == _sala[1]) {
            return true;
        }
    }
    return false;
}

// ============================================================================
// PAREDES E ESTRUTURA
// ============================================================================
#region Paredes

function criar_paredes_na_sala(_sala_especifica, _quantidade_paredes) {
    var _sala_id = string(_sala_especifica[0]) + "_" + string(_sala_especifica[1]);
    var _lista_paredes = ds_list_create();

    for (var _j = 0; _j < _quantidade_paredes; _j++) {
        var _parede_x = irandom_range(256, room_width - 256);
        var _parede_y = irandom_range(256, room_height - 256);

        ds_grid_set(global._maze, _parede_x, _parede_y, 1);
        ds_list_add(_lista_paredes, [_parede_x, _parede_y]);
    }
    ds_map_add(global.salas_com_paredes, _sala_id, _lista_paredes);
}

function criar_paredes_intances(_maze_width, _maze_height, _maze, _cell_size) {
    var _sala = procurar_sala_por_numero(global.current_sala);
    escrever_informacoes_sala(_sala);

    var _direcao = 0;
    for (var _i = 0; _i <= _maze_width; _i++) {
        for (var _z = 0; _z <= _maze_height; _z++) {
            
            if (ds_grid_get(_maze, _i, _z) == 0) {
                var _adjacente_cima = (_z > 0 && ds_grid_get(_maze, _i, _z - 1) == 0);
                var _adjacente_baixo = (_z < _maze_height - 1 && ds_grid_get(_maze, _i, _z + 1) == 0);
                var _adjacente_esquerda = (_i > 0 && ds_grid_get(_maze, _i - 1, _z) == 0);
                var _adjacente_direita = (_i < _maze_width - 1 && ds_grid_get(_maze, _i + 1, _z) == 0);
                
                var _image_index_in = 0;

                // Lógica de tileset / bitmasking manual
                if (!_adjacente_cima && _adjacente_baixo && _adjacente_esquerda && !_adjacente_direita) {
                    _image_index_in = 6;
                } else if (_adjacente_direita && _adjacente_baixo && !_adjacente_cima && !_adjacente_esquerda) {
                    _image_index_in = 7;
                } else if (!_adjacente_direita && _adjacente_baixo && _adjacente_cima && _adjacente_esquerda) {
                    _image_index_in = 11;
                } else if (_adjacente_direita && _adjacente_baixo && _adjacente_cima && !_adjacente_esquerda) {
                    _image_index_in = 12;
                } else if (_adjacente_direita && !_adjacente_baixo && _adjacente_cima && !_adjacente_esquerda) {
                    _image_index_in = 5;
                } else if (!_adjacente_direita && !_adjacente_baixo && _adjacente_cima && _adjacente_esquerda) {
                    _image_index_in = 4;
                } else if (!_adjacente_direita && _adjacente_baixo && _adjacente_cima && !_adjacente_esquerda) {
                    _image_index_in = 8;
                } else if (!_adjacente_direita && !_adjacente_baixo && _adjacente_cima && !_adjacente_esquerda) {
                    _image_index_in = 8;
                } else if (!_adjacente_direita && _adjacente_baixo && !_adjacente_cima && !_adjacente_esquerda) {
                    _image_index_in = 8;
                }
                
                // Bordas específicas
                if (_i == 0) {
                    if (_adjacente_cima && _adjacente_baixo) _image_index_in = 8;
                } else if (_i == _maze_width - 1 && _z > 0 && _z < _maze_height - 1 || _i == _maze_width - 5 && _z > 0 && _z < _maze_height - 5) {
                    if (_adjacente_cima && _adjacente_baixo) _image_index_in = 9;
                } else if (_z == _maze_height - 1 && _i > 0 && _i < _maze_width - 1 || _z == _maze_height - 5 && _i > 0 && _i < _maze_width - 5) {
                    if (_adjacente_direita && !_adjacente_baixo && !_adjacente_cima && _adjacente_esquerda) _image_index_in = 10;
                }

                var _wall_instance = instance_create_layer(_i * _cell_size, _z * _cell_size, "instances", real(_sala.parede));
                with (_wall_instance) {
                    x = _i * _cell_size + (_cell_size / 2);
                    y = _z * _cell_size + (_cell_size / 2);
                    image_index = _image_index_in;
                    image_angle = _direcao;
                }
                
                var _wall_instance2 = instance_create_layer(_i * _cell_size, _z * _cell_size, "instances_floor", real(_sala.chao));
                with (_wall_instance2) {
                    x = _i * _cell_size + (_cell_size / 2);
                    y = _z * _cell_size + (_cell_size / 2);
                }
                
            } else {
                var _chao_instance = instance_create_layer(_i * _cell_size, _z * _cell_size, "instances_floor", real(_sala.chao));
                with (_chao_instance) {
                    x = _i * _cell_size + (_cell_size / 2);
                    y = _z * _cell_size + (_cell_size / 2);
                    image_angle = choose(0, 90, 180, 270);
                }
            }
        }
    }
}

function criar_paredes_vermelha_intances(_maze_width, _maze_height, _maze, _cell_size) {
    for (var _i = 0; _i < _maze_width; _i++) {
        for (var _z = 0; _z < _maze_height; _z++) {
            if (ds_grid_get(_maze, _i, _z) == 0) {
                var _adjacente_cima = (_z > 0 && ds_grid_get(_maze, _i, _z - 1) == 0);
                var _adjacente_baixo = (_z < _maze_height - 1 && ds_grid_get(_maze, _i, _z + 1) == 0);
                var _adjacente_esquerda = (_i > 0 && ds_grid_get(_maze, _i - 1, _z) == 0);
                var _adjacente_direita = (_i < _maze_width - 1 && ds_grid_get(_maze, _i + 1, _z) == 0);

                var _image_index_in = 15;

                // Lógica detalhada para paredes vermelhas
                if (_adjacente_cima && _adjacente_baixo && !_adjacente_esquerda && !_adjacente_direita) {
                    _image_index_in = 0;
                } else if (_adjacente_esquerda && _adjacente_direita && !_adjacente_cima && !_adjacente_baixo) {
                    _image_index_in = 1;
                } else if (_adjacente_cima && _adjacente_direita && !_adjacente_baixo && !_adjacente_esquerda) {
                    _image_index_in = 7;
                } else if (_adjacente_direita && _adjacente_baixo && !_adjacente_cima && !_adjacente_esquerda) {
                    _image_index_in = 10;
                } else if (_adjacente_baixo && _adjacente_esquerda && !_adjacente_cima && !_adjacente_direita) {
                    _image_index_in = 9;
                } else if (_adjacente_esquerda && _adjacente_cima && !_adjacente_baixo && !_adjacente_direita) {
                    _image_index_in = 8;
                } else if (_adjacente_cima && !_adjacente_baixo && !_adjacente_esquerda && !_adjacente_direita) {
                    _image_index_in = 14;
                } else if (_adjacente_direita && !_adjacente_cima && !_adjacente_baixo && !_adjacente_esquerda) {
                    _image_index_in = 11;
                } else if (_adjacente_baixo && !_adjacente_cima && !_adjacente_esquerda && !_adjacente_direita) {
                    _image_index_in = 12;
                } else if (_adjacente_esquerda && !_adjacente_cima && !_adjacente_baixo && !_adjacente_direita) {
                    _image_index_in = 13;
                } else if (_adjacente_esquerda && _adjacente_cima && _adjacente_direita && !_adjacente_baixo) {
                    _image_index_in = 6;
                } else if (_adjacente_cima && _adjacente_direita && _adjacente_baixo && !_adjacente_esquerda) {
                    _image_index_in = 5;
                } else if (_adjacente_direita && _adjacente_baixo && _adjacente_esquerda && !_adjacente_cima) {
                    _image_index_in = 4;
                } else if (_adjacente_baixo && _adjacente_esquerda && _adjacente_cima && !_adjacente_direita) {
                    _image_index_in = 3;
                } else if (_adjacente_cima && _adjacente_baixo && _adjacente_esquerda && _adjacente_direita) {
                    _image_index_in = 2;
                }

                var _wall_instance = instance_create_layer(_i * _cell_size, _z * _cell_size, "instances", obj_wall_vermelha);
                with (_wall_instance) {
                    x = _i * _cell_size + (_cell_size / 2);
                    y = _z * _cell_size + (_cell_size / 2);
                    image_index = _image_index_in;
                }

                var _chao = instance_create_layer(_i * _cell_size, _z * _cell_size, "instances_floor", obj_floor_carne);
                with (_chao) {
                    x = _i * _cell_size + (_cell_size / 2);
                    y = _z * _cell_size + (_cell_size / 2);
                }
            } else {
                var _chao_instance = instance_create_layer(_i * _cell_size, _z * _cell_size, "instances_floor", obj_floor_carne);
                with (_chao_instance) {
                    x = _i * _cell_size + (_cell_size / 2);
                    y = _z * _cell_size + (_cell_size / 2);
                }
            }
        }
    }
}

function criar_parede_circular() {
    var _room_w = global.room_width;
    var _room_h = global.room_height;

    // Cantos
    instance_create_layer(64, 64, "instances", obj_wall_carne_circular);
    
    var _wall_circular_2 = instance_create_layer(_room_w - global._cell_size, 64, "instances", obj_wall_carne_circular);
    with (_wall_circular_2) sprite_index = spr_carne_cirular3;

    var _wall_circular_3 = instance_create_layer(64, _room_h - global._cell_size, "instances", obj_wall_carne_circular);
    with (_wall_circular_3) sprite_index = spr_carne_cirular4;

    var _wall_circular_4 = instance_create_layer(_room_w - global._cell_size, _room_h - global._cell_size, "instances", obj_wall_carne_circular);
    with (_wall_circular_4) sprite_index = spr_carne_cirular2;
}

function recriar_paredes_na_sala_atual(_current_sala) {
    var _sala_id = string(_current_sala[0]) + "_" + string(_current_sala[1]);

    if (ds_map_exists(global.salas_com_paredes, _sala_id)) {
        var _lista_paredes = ds_map_find_value(global.salas_com_paredes, _sala_id);

        for (var _i = 0; _i < ds_list_size(_lista_paredes); _i++) {
            var _parede_pos = ds_list_find_value(_lista_paredes, _i);
            ds_grid_set(global._maze, _parede_pos[0], _parede_pos[1], 1);
        }
    } 
}

function criar_paredes_borda(_maze_width, _maze_height, _maze) {
    // Paredes superior e inferior
    for (var _i = 0; _i <= _maze_width; _i++) {
        ds_grid_set(_maze, _i, 0, 0);
        ds_grid_set(_maze, _i, _maze_height - 1, 0);
    }
    // Paredes laterais
    for (var _j = 0; _j <= _maze_height; _j++) {
        ds_grid_set(_maze, 0, _j, 0);
        ds_grid_set(_maze, _maze_width - 1, _j, 0);
    }
    
    // Correção: uso de == para comparação
    if (global.fase == 1) {
        criar_parede_circular();
    }
}
#endregion

#region Chao
function criar_chao_room_inteira(_maze_width, _maze_height, _maze) {
    for (var _i = 0; _i < _maze_width; _i++) {
        for (var _j = 0; _j < _maze_height; _j++) {
            ds_grid_set(_maze, _i, _j, 1); // 1 indica chão
        }
    }
}
#endregion

// ============================================================================
// OBJETOS ESPECIAIS (SLOW, ESCADA)
// ============================================================================
#region Slow Tapete

function recriar_slow_na_sala_atual(_current_sala) {
    var _sala_id = string(_current_sala[0]) + "_" + string(_current_sala[1]);

    if (ds_map_exists(global.salas_com_slow, _sala_id)) {
        var _lista_pontos = ds_map_find_value(global.salas_com_slow, _sala_id);

        for (var _i = 0; _i < ds_list_size(_lista_pontos); _i++) {
            var _ponto_pos = ds_list_find_value(_lista_pontos, _i);
            instance_create_layer(_ponto_pos[0], _ponto_pos[1], "Instances_Abaixo_moveis", global.slow);
        }
    } 
}

function create_slow_em_salas_aleatorias(_salas_geradas, _quantidade_salas, _quantidade_slow) {
    var _salas_selecionadas = [];

    for (var _i = 0; _i < _quantidade_salas; _i++) {
        var _sala_aleatoria = 0;
        do {
            _sala_aleatoria = _salas_geradas[irandom(array_length(_salas_geradas) - 1)];
        } until (!array_contains(_salas_selecionadas, _sala_aleatoria));

        array_push(_salas_selecionadas, _sala_aleatoria);
    }

    for (var _i = 0; _i < array_length(_salas_selecionadas); _i++) {
        var _sala = _salas_selecionadas[_i];
        var _sala_id = string(_sala[0]) + "_" + string(_sala[1]);
        var _lista_pontos = ds_list_create();

        for (var _j = 0; _j < _quantidade_slow; _j++) {
            var _ponto_valido = false;
            var _ponto_x = 0, _ponto_y = 0;

            do {
                _ponto_x = irandom_range(128, room_width - 128);
                _ponto_y = irandom_range(128, room_height - 128);
                _ponto_valido = true;

                for (var _k = 0; _k < ds_list_size(_lista_pontos); _k++) {
                    var _ponto_existente = ds_list_find_value(_lista_pontos, _k);
                    var _distancia = point_distance(_ponto_x, _ponto_y, _ponto_existente[0], _ponto_existente[1]);
                    if (_distancia < 100) {
                        _ponto_valido = false;
                        break;
                    }
                }
            } until (_ponto_valido);

            ds_list_add(_lista_pontos, [_ponto_x, _ponto_y]);
        }
        ds_map_add(global.salas_com_slow, _sala_id, _lista_pontos);
    }
}
#endregion

#region Escada
function recriar_escada_na_sala_atual(_current_sala) {
    var _sala_id = string(_current_sala[0]) + "_" + string(_current_sala[1]);

    if (ds_map_exists(global.salas_com_escada_porao, _sala_id)) {
        var _vela_pos = ds_map_find_value(global.salas_com_escada_porao, _sala_id);
        instance_create_layer(_vela_pos[0], _vela_pos[1], "Instances_moveis", obj_escada_porao);
    }
}

function create_escada_porao_em_fundos(_salas_geradas) {
    // feather disable once GM1041
    random_set_seed(global.seed_atual);
    
    for (var _i = 0; _i < array_length(_salas_geradas); _i++) {
        var _sala = _salas_geradas[_i];
        var _sala_detalhes = procurar_sala_por_numero(_sala);

        if (_sala_detalhes.tipo == "fundos") {
            var _sala_id = string(_sala[0]) + "_" + string(_sala[1]);
            var _margem = global._cell_size;
            var _lado = irandom(3);
            var _escada_x = 0, _escada_y = 0;

            switch (_lado) {
                case 0: // Esquerda
                    _escada_x = _margem - 5;
                    _escada_y = (irandom(1) == 0) ? irandom_range(_margem, (room_height / 2) - 100) : irandom_range((room_height / 2) + 100, room_height - _margem);
                    global.direcao_escada_porao = 1;
                    global.direcao_escada = 1;
                    break;
                case 1: // Direita
                    _escada_x = room_width - _margem + 5;
                    _escada_y = (irandom(1) == 0) ? irandom_range(_margem, (room_height / 2) - 100) : irandom_range((room_height / 2) + 100, room_height - _margem);
                    global.direcao_escada_porao = 0;
                    global.direcao_escada = 2;
                    break;
                case 2: // Cima
                    _escada_y = _margem + 37;
                    _escada_x = (irandom(1) == 0) ? irandom_range(_margem, (room_width / 2) - 100) : irandom_range((room_width / 2) + 100, room_width - _margem);
                    global.direcao_escada_porao = 2;
                    global.direcao_escada = 4;
                    break;
                case 3: // Baixo
                    _escada_y = room_height - _margem - 37;
                    _escada_x = (irandom(1) == 0) ? irandom_range(_margem, (room_width / 2) - 100) : irandom_range((room_width / 2) + 100, room_width - _margem);
                    global.direcao_escada_porao = 3;
                    global.direcao_escada = 3;
                    break;
            }
            ds_map_add(global.salas_com_escada_porao, _sala_id, [_escada_x, _escada_y]);
        }
    }
}
#endregion

// ============================================================================
// INIMIGOS E TORRETAS
// ============================================================================
#region Inimigos

function recriar_inimigos_na_sala_atual(_current_sala) {
    var _sala_id = string(_current_sala[0]) + "_" + string(_current_sala[1]);

    if (ds_map_exists(global.salas_com_fantasma, _sala_id)) {
        var _lista_pontos = ds_map_find_value(global.salas_com_fantasma, _sala_id);

        for (var _i = 0; _i < ds_list_size(_lista_pontos); _i++) {
            var _ponto_pos = ds_list_find_value(_lista_pontos, _i);
            instance_create_layer(_ponto_pos[0], _ponto_pos[1], "instances", obj_inimigo_fantasma);
        }
    } 
}

function create_inimigos_em_salas_escuras(_quantidade_inimigos) {
    for (var _i = 0; _i < array_length(global.salas_escuras); _i++) {
        var _sala = global.salas_escuras[_i];
        var _sala_id = string(_sala[0]) + "_" + string(_sala[1]);
        var _lista_inimigo = ds_list_create();

        for (var _j = 0; _j < _quantidade_inimigos; _j++) {
            var _inimigo_x = irandom_range(128, room_width - 128);
            var _inimigo_y = irandom_range(128, room_height - 128);
            ds_list_add(_lista_inimigo, [_inimigo_x, _inimigo_y]);
        }
        ds_map_add(global.salas_com_fantasma, _sala_id, _lista_inimigo);
    }
}

function recriar_amoebas_na_sala_atual(_current_sala) {
    var _sala_id = string(_current_sala[0]) + "_" + string(_current_sala[1]);

    if (ds_map_exists(global.salas_com_amoeba, _sala_id)) {
        var _lista_pontos = ds_map_find_value(global.salas_com_amoeba, _sala_id);

        for (var _i = 0; _i < ds_list_size(_lista_pontos); _i++) {
            var _ponto_pos = ds_list_find_value(_lista_pontos, _i);
            instance_create_layer(_ponto_pos[0], _ponto_pos[1], "instances", obj_amoeba);
        }
    } 
}

function create_amoeba_em_salas_aleatorias(_salas_geradas, _quantidade_salas, _quantidade_pontos) {
    var _salas_selecionadas = [];

    for (var _i = 0; _i < _quantidade_salas; _i++) {
        var _sala_aleatoria = 0;
        do {
            _sala_aleatoria = _salas_geradas[irandom(array_length(_salas_geradas) - 1)];
        } until (!array_contains(_salas_selecionadas, _sala_aleatoria));

        array_push(_salas_selecionadas, _sala_aleatoria);
    }

    for (var _i = 0; _i < array_length(_salas_selecionadas); _i++) {
        var _sala = _salas_selecionadas[_i];
        var _sala_id = string(_sala[0]) + "_" + string(_sala[1]);
        var _lista_pontos = ds_list_create();

        for (var _j = 0; _j < _quantidade_pontos; _j++) {
            var _ponto_x = irandom_range(128, room_width - 128);
            var _ponto_y = irandom_range(128, room_height - 128);
            ds_list_add(_lista_pontos, [_ponto_x, _ponto_y]);
        }
        ds_map_add(global.salas_com_amoeba, _sala_id, _lista_pontos);
    }
}

function recriar_inimigos_na_sala_atual_alet(_current_sala) {
    var _sala_id = string(_current_sala[0]) + "_" + string(_current_sala[1]);

    if (ds_map_exists(global.salas_com_inimigos, _sala_id)) {
        var _lista_inimigos = ds_map_find_value(global.salas_com_inimigos, _sala_id);

        for (var _i = 0; _i < ds_list_size(_lista_inimigos); _i++) {
            var _inimigo_info = ds_list_find_value(_lista_inimigos, _i);
            
            var _inimigo = instance_create_layer(_inimigo_info[2], _inimigo_info[3], "instances", _inimigo_info[1]);
            
            _inimigo.inimigo_id      = _inimigo_info[0];
            _inimigo.vida            = _inimigo_info[4];
            _inimigo.dano            = _inimigo_info[5];
            _inimigo.veloc_perse     = _inimigo_info[6];
            _inimigo.dist_aggro      = _inimigo_info[7];
            _inimigo.dist_desaggro   = _inimigo_info[8];
            _inimigo.escala          = _inimigo_info[9];
            _inimigo.veloc           = _inimigo_info[10];
            _inimigo.max_vida        = _inimigo_info[11];
        }
    }
}

function shuffle_array(_array) {
    for (var _i = array_length(_array) - 1; _i > 0; _i--) {
        var _j = irandom(_i);
        var _temp = _array[_i];
        _array[_i] = _array[_j];
        _array[_j] = _temp;
    }
    return _array;
}

function criar_inimigos_em_salas_aleatorias_alet(_salas_geradas) {
    randomize();
    var _inimigos_faceis = [obj_amoeba];
    var _inimigos_medios = [obj_amoeba_azul, obj_amoeba_laranja];
    var _inimigos_dificeis = [obj_amoeba_vermelha, obj_amoeba_rosa, obj_torreta];
    
    var _lvl = global.level_fase - 1;
    var _quantidade_inimigos = _lvl + 2;
    var _quantidade_salas = _lvl + 2;
    var _inimigo_id = 0;

    if (array_length(_salas_geradas) < _quantidade_salas) {
        _quantidade_salas = array_length(_salas_geradas);
    }
    
    var _salas_geradas_shuffled = shuffle_array(_salas_geradas);
    var _salas_selecionadas = _salas_geradas_shuffled;

    for (var _i = 0; _i < array_length(_salas_selecionadas); _i++) {
        var _sala = _salas_selecionadas[_i];
        var _sala_id = string(_sala[0]) + "_" + string(_sala[1]);
        var _lista_inimigos = ds_list_create();

        var _inimigos_facil_qtd = _quantidade_inimigos * (max(5 - _lvl, 1) / 5);
        var _inimigos_medio_qtd = _quantidade_inimigos * (_lvl > 2 ? min((_lvl - 2) / 6, 0.3) : 0);
        var _inimigos_dificil_qtd = _quantidade_inimigos * (_lvl > 5 ? min((_lvl - 5) / 10, 0.2) : 0);

        // Helper interno para salvar
        var _salvar_inimigo = function(__lista, __id, __tipo, __x, __y, __vida, __dano, __vp, __da, __dd, __esc, __vel, __vmax) {
             ds_list_add(__lista, [__id, __tipo, __x, __y, __vida, __dano, __vp, __da, __dd, __esc, __vel, __vmax]);
        };

        // Criar fáceis
        for (var _j = 0; _j < _inimigos_facil_qtd; _j++) {
            var _ix = irandom_range(128, room_width - 128);
            var _iy = irandom_range(128, room_height - 128);
            var _itype = _inimigos_faceis[irandom(array_length(_inimigos_faceis) - 1)];
            _inimigo_id++;
            
            var _inst = instance_create_layer(_ix, _iy, "instances", _itype);
            _inst.vida = 10 + (_lvl * 2);
            _inst.dano = 5 + _lvl;
            _inst.veloc_perse = 1;
            _inst.dist_aggro = 200;
            _inst.dist_desaggro = 300;
            _inst.escala = 3;
            _inst.veloc = 0.8;
            _inst.inimigo_id = _inimigo_id;
            _inst.max_vida = 10 + (_lvl * 2);
            
            _salvar_inimigo(_lista_inimigos, _inimigo_id, _itype, _ix, _iy, _inst.vida, _inst.dano, _inst.veloc_perse, _inst.dist_aggro, _inst.dist_desaggro, _inst.escala, _inst.veloc, _inst.max_vida);
        }

        // Criar médios
        for (var _j = 0; _j < _inimigos_medio_qtd; _j++) {
            var _ix = irandom_range(128, room_width - 128);
            var _iy = irandom_range(128, room_height - 128);
            var _itype = _inimigos_medios[irandom(array_length(_inimigos_medios) - 1)];
            _inimigo_id++;

            var _inst = instance_create_layer(_ix, _iy, "instances", _itype);
            _inst.vida = 20 + (_lvl * 3);
            _inst.dano = 10 + (_lvl * 1.5);
            _inst.veloc_perse = 3;
            _inst.dist_aggro = 400;
            _inst.dist_desaggro = 500;
            _inst.escala = 4;
            _inst.veloc = 3;
            _inst.inimigo_id = _inimigo_id;
            _inst.max_vida = 20 + (_lvl * 3);

            _salvar_inimigo(_lista_inimigos, _inimigo_id, _itype, _ix, _iy, _inst.vida, _inst.dano, _inst.veloc_perse, _inst.dist_aggro, _inst.dist_desaggro, _inst.escala, _inst.veloc, _inst.max_vida);
        }

        // Criar difíceis
        for (var _j = 0; _j < _inimigos_dificil_qtd; _j++) {
            var _ix = irandom_range(128, room_width - 128);
            var _iy = irandom_range(128, room_height - 128);
            var _itype = _inimigos_dificeis[irandom(array_length(_inimigos_dificeis) - 1)];
            _inimigo_id++;

            var _inst = instance_create_layer(_ix, _iy, "instances", _itype);
            _inst.vida = 30 + (_lvl * 5);
            _inst.dano = 15 + (_lvl * 2);
            _inst.veloc_perse = 5;
            _inst.dist_aggro = 700;
            _inst.dist_desaggro = 800;
            _inst.escala = 5;
            _inst.veloc = 5;
            _inst.inimigo_id = _inimigo_id;
            _inst.max_vida = 30 + (_lvl * 5);

            _salvar_inimigo(_lista_inimigos, _inimigo_id, _itype, _ix, _iy, _inst.vida, _inst.dano, _inst.veloc_perse, _inst.dist_aggro, _inst.dist_desaggro, _inst.escala, _inst.veloc, _inst.max_vida);
        }

        ds_map_add(global.salas_com_inimigos, _sala_id, _lista_inimigos);
    }   
}

function remover_inimigo_por_id(_sala, _inimigo_id) {
    var _sala_id = string(_sala[0]) + "_" + string(_sala[1]);
    var _map = global.salas_com_inimigos;

    if (ds_map_exists(_map, _sala_id)) {
        var _lista_inimigos = ds_map_find_value(_map, _sala_id);
        
        for (var _i = 0; _i < ds_list_size(_lista_inimigos); _i++) {
            var _inimigo_info = ds_list_find_value(_lista_inimigos, _i);
            if (_inimigo_info[0] == _inimigo_id) {
                ds_list_delete(_lista_inimigos, _i); 
                break;
            }
        }
    } 
}
#endregion

#region Torreta
function create_torretas_em_salas_aleatorias(_salas_geradas, _quantidade_salas, _quantidade_pontos) {
    var _salas_selecionadas = [];

    for (var _i = 0; _i < _quantidade_salas; _i++) {
        var _sala_aleatoria = 0;
        do {
            _sala_aleatoria = _salas_geradas[irandom(array_length(_salas_geradas) - 1)];
        } until (!array_contains(_salas_selecionadas, _sala_aleatoria));
        array_push(_salas_selecionadas, _sala_aleatoria);
    }

    for (var _i = 0; _i < array_length(_salas_selecionadas); _i++) {
        var _sala = _salas_selecionadas[_i];
        var _sala_id = string(_sala[0]) + "_" + string(_sala[1]);
        var _lista_pontos = ds_list_create();

        for (var _j = 0; _j < _quantidade_pontos; _j++) {
            var _ponto_x = irandom_range(128, room_width - 128);
            var _ponto_y = irandom_range(128, room_height - 128);
            ds_list_add(_lista_pontos, [_ponto_x, _ponto_y]);
        }
        ds_map_add(global.salas_com_torretas, _sala_id, _lista_pontos);
    }
}

function recriar_torreta_na_sala_atual(_current_sala) {
    var _sala_id = string(_current_sala[0]) + "_" + string(_current_sala[1]);

    if (ds_map_exists(global.salas_com_torretas, _sala_id)) {
        var _lista_pontos = ds_map_find_value(global.salas_com_torretas, _sala_id);

        for (var _i = 0; _i < ds_list_size(_lista_pontos); _i++) {
            var _ponto_pos = ds_list_find_value(_lista_pontos, _i);
            instance_create_layer(_ponto_pos[0], _ponto_pos[1], "instances", obj_torreta);
        }
    } 
}
#endregion

// ============================================================================
// GERAÇÃO PROCEDURAL
// ============================================================================

function conta_salas_adjacentes(_salas, _sala_atual) {
    var _direcoes = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    var _contador = 0;

    for (var _d = 0; _d < 4; _d++) {
        var _adjacente_x = _sala_atual[0] + _direcoes[_d][0];
        var _adjacente_y = _sala_atual[1] + _direcoes[_d][1];

        for (var _i = 0; _i < array_length(_salas); _i++) {
            if (_salas[_i][0] == _adjacente_x && _salas[_i][1] == _adjacente_y) {
                _contador++;
            }
        }
    }
    return _contador;
}

function gera_salas_procedurais(_num_salas) {
    if (global.seed_atual != noone) random_set_seed(real(global.seed_atual));
    var _salas = [];
    var _sala_atual = [0, 0];
    array_push(_salas, _sala_atual);
    criar_salas_lista(_sala_atual, 0);

    var _direcoes = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    var _tentativas_max = 100;

    for (var _i = 1; _i < _num_salas; _i++) {
        var _nova_sala = 0;
        var _encontrou = false;
        var _tentativas = 0;

        while (!_encontrou && _tentativas < _tentativas_max) {
            var _sala_anterior = _salas[irandom(array_length(_salas) - 1)];

            if (conta_salas_adjacentes(_salas, _sala_anterior) < 3) {
                var _direcao = _direcoes[irandom(3)];
                _nova_sala = [_sala_anterior[0] + _direcao[0], _sala_anterior[1] + _direcao[1]];
                _encontrou = true;

                for (var _j = 0; _j < array_length(_salas); _j++) {
                    if (_salas[_j][0] == _nova_sala[0] && _salas[_j][1] == _nova_sala[1]) {
                        _encontrou = false;
                        break;
                    }
                }
            }
            _tentativas++;
        }

        if (_encontrou) {
            array_push(_salas, _nova_sala);
            criar_salas_lista(_nova_sala, _i + 1);
        }
    }
    return _salas;
}

function cria_salas_e_objetos(_maze_width, _maze_height, _maze, _cell_size) {
    criar_chao_room_inteira(global._maze_width, global._maze_height, global._maze);
    criar_paredes_borda(global._maze_width, global._maze_height, global._maze);
    criar_paredes_intances(global._maze_width, global._maze_height, global._maze, global._cell_size);
}

// ============================================================================
// SISTEMA DE PORTAS
// ============================================================================

function criar_portas_gerais_templo(_sala_atual, _salas_geradas) {
    for (var _i = 0; _i < array_length(_salas_geradas); _i++) {
        var _sala_vizinha = _salas_geradas[_i];
        if (is_array(_sala_vizinha)) {
            var _x_vizinho = _sala_vizinha[0];
            var _y_vizinho = _sala_vizinha[1];

            // Direita
            if (_x_vizinho == _sala_atual[0] + 1 && _y_vizinho == _sala_atual[1]) {
               
                var _pd1 = instance_position(global.room_width - 32, (global.room_height / 2), global.sala.parede);
                if (_pd1 != noone) instance_destroy(_pd1);
               
                var _pd2 = instance_position(global.room_width + 32, (global.room_height / 2), global.sala.parede);
                if (_pd2 != noone) instance_destroy(_pd2);

                var _porta_direita = instance_create_layer(global.room_width - 10, (global.room_height / 2), "instances", obj_next_room);
                with (_porta_direita) {
                    room_destino = _sala_vizinha;
                    room_origem = _sala_atual;
                    direcao = 2;
                    image_yscale = 4;
                    visible = false;
                }
            }
            // Esquerda
            if (_x_vizinho == _sala_atual[0] - 1 && _y_vizinho == _sala_atual[1]) {
               
                var _pe = instance_position(0, (global.room_height / 2), global.sala.parede);
                if (_pe != noone) instance_destroy(_pe);

                var _porta_esquerda = instance_create_layer(10, (global.room_height / 2), "instances", obj_next_room);
                with (_porta_esquerda) {
                    image_yscale = 4;
                    visible = false;
                    room_destino = _sala_vizinha;
                    room_origem = _sala_atual;
                    direcao = 4;
                }
            }
            // Cima
            if (_x_vizinho == _sala_atual[0] && _y_vizinho == _sala_atual[1] + 1) {
               
                var _pa = instance_position((global.room_width / 2) + 16, 32, global.sala.parede);
                if (_pa != noone) instance_destroy(_pa);

                var _porta_acima = instance_create_layer((global.room_width / 2), 10, "instances", obj_next_room);
                with (_porta_acima) {
                    image_xscale = 3;
                    room_destino = _sala_vizinha;
                    room_origem = _sala_atual;
                    direcao = 1;
                    visible = false;
                }
            }
            // Baixo
            if (_x_vizinho == _sala_atual[0] && _y_vizinho == _sala_atual[1] - 1) {
               
                var _pb1 = instance_position((global.room_width / 2) + 16, global.room_height + 32, global.sala.parede);
                if (_pb1 != noone) instance_destroy(_pb1);
               
                var _pb2 = instance_position((global.room_width / 2) + 16, global.room_height + 32, global.sala.parede); // Verifique se essa lógica duplicada é intencional
                if (_pb2 != noone) instance_destroy(_pb2);

                var _porta_abaixo = instance_create_layer((global.room_width / 2), global.room_height - 10, "instances", obj_next_room);
                with (_porta_abaixo) {
                    visible = false;
                    image_xscale = 3;
                    room_destino = _sala_vizinha;
                    room_origem = _sala_atual;
                    direcao = 3;
                }
            }
        }
    }
}

function criar_portas_gerais(_sala_atual, _salas_geradas) {
    var _sala = procurar_sala_por_numero(global.current_sala);

    for (var _i = 0; _i < array_length(_salas_geradas); _i++) {
        var _sala_vizinha = _salas_geradas[_i];

        if (is_array(_sala_vizinha)) {
            var _x_vizinho = _sala_vizinha[0];
            var _y_vizinho = _sala_vizinha[1];

            // Direita
            if (_x_vizinho == _sala_atual[0] + 1 && _y_vizinho == _sala_atual[1]) {
                var _pd1 = instance_position(global.room_width - 1, (global.room_height / 2), _sala.parede);
                if (_pd1 != noone) instance_destroy(_pd1);
                var _pd2 = instance_position(global.room_width + 32, (global.room_height / 2), _sala.parede);
                if (_pd2 != noone) instance_destroy(_pd2);

                var _porta_direita = instance_create_layer(global.room_width - 5, (global.room_height / 2), "instances", obj_next_room);
                with (_porta_direita) {
                    image_angle -= 90;
                    image_yscale = -1;
                    room_destino = _sala_vizinha;
                    room_origem = _sala_atual;
                    direcao = 2;
                }
            }
            // Esquerda
            if (_x_vizinho == _sala_atual[0] - 1 && _y_vizinho == _sala_atual[1]) {
                var _pe = instance_position(0, (global.room_height / 2), _sala.parede);
                if (_pe != noone) instance_destroy(_pe);

                var _porta_esquerda = instance_create_layer(5, (global.room_height / 2), "instances", obj_next_room);
                with (_porta_esquerda) {
                    image_angle += 90;
                    image_yscale = -1;
                    room_destino = _sala_vizinha;
                    room_origem = _sala_atual;
                    direcao = 4;
                }
            }
            // Cima
            if (_x_vizinho == _sala_atual[0] && _y_vizinho == _sala_atual[1] + 1) {
                var _pa = instance_position((global.room_width / 2) + 16, 32, _sala.parede);
                if (_pa != noone) instance_destroy(_pa);

                var _porta_acima = instance_create_layer((global.room_width / 2) + 32, 10, "instances", obj_next_room);
                with (_porta_acima) {
                    image_yscale = -1;
                    room_destino = _sala_vizinha;
                    room_origem = _sala_atual;
                    direcao = 1;
                }
            }
            // Baixo
            if (_x_vizinho == _sala_atual[0] && _y_vizinho == _sala_atual[1] - 1) {
                var _pb1 = instance_position((global.room_width / 2) + 16, global.room_height - 10, _sala.parede);
                if (_pb1 != noone) instance_destroy(_pb1);
                var _pb2 = instance_position((global.room_width / 2) + 16, global.room_height + 32, _sala.parede);
                if (_pb2 != noone) instance_destroy(_pb2);

                var _porta_abaixo = instance_create_layer((global.room_width / 2) + 32, global.room_height - 10, "instances", obj_next_room);
                with (_porta_abaixo) {
                    image_xscale = 1;
                    room_destino = _sala_vizinha;
                    room_origem = _sala_atual;
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

function carregar_sala(_sala_atual, _sala_origem_array) {
    clear_room(); 
    if (global.seed_atual != noone) random_set_seed(real(global.seed_atual));
    global.current_sala = _sala_atual;
    global.sala_passada = _sala_origem_array;
    
    cria_salas_e_objetos(real(global._maze_width), real(global._maze_height), global._maze, real(global._cell_size));
    
    var _salas = is_array(global.salas_geradas) ? global.salas_geradas : [];
    criar_portas_gerais(_sala_atual, _salas);
    recriar_pontos_na_sala_atual(global.current_sala);
    
    // Recriar mobílias
    furniture_respawn_in_room(_sala_atual, global.salas_com_escrivaninha);
    furniture_respawn_in_room(_sala_atual, global.salas_com_geladeira);
    furniture_respawn_in_room(_sala_atual, global.salas_com_guarda_roupa);
    
    recriar_inimigos_na_sala_atual(global.current_sala);
    recriar_slow_na_sala_atual(global.current_sala);
    recriar_escada_na_sala_atual(global.current_sala);
    recriar_item_dropado(global.current_sala[0], global.current_sala[1]);
    recriar_inimigos_na_sala_atual_alet(global.current_sala);
    recriar_bosses();
    sala_tuto(); 
}

function carregar_sala_templo(_sala_atual, _sala_origem_array, _direcao) {
    clear_room(); 
    carregar_templo(_direcao);
    global.sala_passada = _sala_origem_array;
    global.current_sala = _sala_atual;
    
    var _salas = is_array(global.salas_geradas) ? global.salas_geradas : [];
    criar_portas_gerais_templo(_sala_atual, _salas);
}

function criar_random_pontos(_quantidade) {
    for (var _i = 0; _i < _quantidade; _i++) {
        var _ponto_x = 0, _ponto_y = 0;
        var _tentativas = 0;
        var _max_tentativas = 100;

        do {
            _ponto_x = irandom_range(64, room_width - 64);
            _ponto_y = irandom_range(64, room_height - 64);
            _tentativas++;
        } until (!position_meeting(_ponto_x, _ponto_y, obj_wall_carne) || _tentativas >= _max_tentativas);
        
        instance_create_layer(_ponto_x, _ponto_y, "instances", obj_pontos);
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