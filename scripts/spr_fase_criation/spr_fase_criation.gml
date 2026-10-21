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
/// @desc Armazena as salas do jardim para evitar crashes
global.sala_jardim = [];

/// @desc Armazena as posições dos templos criados
global.templos_salas_pos = [];
// ----------------------------------------------

global.sala_boss_brocolis = [];

// Coloca a primeira sala no centro (0 indica a primeira sala)
ds_grid_set(global.room_grid, _start_x, _start_y, 0);

global.salas_criadas = [];
global.salas_layout = {};   // layouts salvos das salas (ver SISTEMA DE SALAS)
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
global.salas_com_moveis         = ds_map_create(); // mobília da casa (scr_casa_moveis)

/// @desc Gerencia a criação inicial de inimigos e itens
function gerar_inimigos_e_itens_para_o_nivel(_salas_geradas, _level) {
    var _quantidade_inimigos = 1 + (_level);
    var _quantidade_itens = 2 + _level;
    
    criar_inimigos_em_salas_aleatorias_alet(_salas_geradas);
    create_slow_em_salas_aleatorias(_salas_geradas, _quantidade_inimigos, _quantidade_itens);
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
// (criar_templo_poder removido: o templo agora é o formato "templo" em global.sala_formatos)
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
// SISTEMA DE SALAS (CÔMODOS) — TIPOS, FORMATOS, LAYOUT, RENDER E SALVAMENTO
// ============================================================================
// [O QUE]: Toda sala da casa é descrita por DADOS, nunca por paredes desenhadas na mão.
//   1. TIPO    (global.sala_tipos)    -> chão, estilo de parede, objeto de colisão e quais formatos pode ter.
//   2. FORMATO (global.sala_formatos) -> uma "planta" em texto ('.' chão, ' ' fora da casa, '#' bloco/pilar)
//                                       esticada para o tamanho da sala. Uma planta 14x8 já basta.
//   3. LAYOUT  (global.salas_layout)  -> a sala pronta (células, portas, variação do piso). É gerado UMA vez
//                                       por fase e fica salvo: voltar na sala mostra exatamente a mesma forma.
// [COMO CRIAR UMA VARIAÇÃO NOVA]:
//   - Novo formato: adicione uma entrada em sala_definir_formatos() e coloque o nome na lista
//     "formatos" dos tipos que podem usá-lo. Nada mais (paredes, portas, colisão e desenho são automáticos).
//   - Novo tipo de cômodo: adicione em sala_definir_tipos() e (opcional) em global.sala_ordem.
// [PADRÃO DE SALVAMENTO]:
//   - A chave de toda sala é get_room_id(coords) -> "x_y".
//   - sala_obter_layout(coords) devolve o layout salvo ou gera/salva na primeira vez.
//   - Tudo é struct/array simples (dá para json_stringify direto no save).
// [DESEMPENHO]: uma sala antes criava ~600 instâncias (1 parede + 1 chão por célula). Agora são
//   1 obj_sala_render (piso + paredes num surface em cache) + poucas caixas de colisão mescladas.

#macro SALA_VAZIO   0   // fora da casa (desenhado escuro)
#macro SALA_CHAO    1
#macro SALA_PAREDE  2   // parede automática em volta do chão
#macro SALA_PORTA   3   // abertura da porta na borda
#macro SALA_BLOCO   4   // parede interna vinda do '#' da planta (pilar, divisória)

#macro SALA_ESTILO_CASA     0
#macro SALA_ESTILO_ROSA     1
#macro SALA_ESTILO_AZULEJO  2
#macro SALA_ESTILO_CIMENTO  3
#macro SALA_ESTILO_TEMPLO   4
#macro SALA_ESTILO_CERCA    5
#macro SALA_FRAMES_ESTILO   24  // tiles por estilo: 0-15 topo (máscara N1 L2 S4 O8) | 16-23 frente (O1 L2 N4)
// spr_parede_top é UMA folha 1536x384: cada LINHA é um estilo, cada COLUNA (64 px) um tile.
// Para um estilo novo: acrescente uma linha de 24 tiles na folha e uma macro SALA_ESTILO_*.

// Índices de porta (iguais à ordem de vizinhos): 0 direita | 1 cima | 2 esquerda | 3 baixo
// Obs.: "cima" é o vizinho [x, y+1] (mesma convenção de criar_portas_gerais / obj_next_room).

#region Definições (tipos e formatos)

/// @desc Inicializa tipos e formatos de sala (chamado em reset_level_data e na inicialização)
function salas() {
    sala_definir_formatos();
    sala_definir_tipos();

    // Ordem em que os cômodos aparecem pela fase (índice 1 = sala inicial [0,0])
    global.sala_ordem = ["sala_estar", "quarto", "cozinha", "banheiro", "quarto2", "fundos", "quarto3", "banheiro2"];
    // O "porao" não entra na ordem: ele é a 1ª sala escura (global.salas_escuras[0]), sem portas,
    // e só se chega nele pela escada dos "fundos" (região Escada mais abaixo).
    // Cômodos sorteados quando a fase tem mais salas que a ordem acima
    global.sala_extras = ["quarto", "quarto2", "quarto3", "sala_estar", "banheiro2"];

    // Compatibilidade com código antigo
    global.room_definitions = { comuns: global.sala_tipos };
    global.common_room_keys = global.sala_ordem;

    if (!variable_global_exists("salas_layout") || !is_struct(global.salas_layout)) global.salas_layout = {};
}

/// @desc Cria a definição de um tipo de sala
function _sala_tipo(_nome, _obj_chao, _spr_chao, _frames_chao, _obj_parede, _estilo, _formatos, _objetos, _cor_vazio = make_colour_rgb(28, 23, 36)) {
    return {
        nome: _nome,
        chao: _obj_chao,            // compat (antes era instanciado por célula)
        spr_chao: _spr_chao,
        chao_frames: _frames_chao,  // frames sorteados por célula (variação do piso)
        parede: _obj_parede,        // objeto de colisão (o player colide com global.sala.parede)
        estilo: _estilo,            // bloco de frames em spr_parede_top
        formatos: _formatos,        // repetir um nome = mais chance
        objetos: _objetos,
        cor_vazio: _cor_vazio
    };
}

function sala_definir_tipos() {
    global.sala_tipos = {
        sala_estar: _sala_tipo("Sala de Estar", obj_chao_tijolo, spr_chao_bebe_2, [0, 1], obj_parede_bebe, SALA_ESTILO_CASA,
                               ["retangulo", "retangulo", "recortado", "cruz", "pilares", "L"], [obj_pontos]),
        quarto:     _sala_tipo("Quarto", obj_chao_tijolo, spr_chao_bebe_2, [4, 5], obj_parede_bebe, SALA_ESTILO_CASA,
                               ["retangulo", "L", "Z", "recortado"], [obj_pontos]),
        quarto2:    _sala_tipo("Quarto do Bebê", obj_chao_tijolo, spr_chao_bebe_2, [6, 7], obj_parede_bebe, SALA_ESTILO_ROSA,
                               ["retangulo", "L", "recortado", "pequeno"], [obj_pontos]),
        quarto3:    _sala_tipo("Quarto 3", obj_chao_tijolo, spr_chao_bebe_2, [2, 3], obj_parede_bebe, SALA_ESTILO_CASA,
                               ["retangulo", "Z", "L", "U"], [obj_pontos, obj_vela]),
        cozinha:    _sala_tipo("Cozinha", obj_chao_cozinha, spr_chao_bebe_cozinha, [0, 1], obj_parede_cozinha, SALA_ESTILO_AZULEJO,
                               ["retangulo", "L", "T", "U"], [obj_pontos]),
        banheiro:   _sala_tipo("Banheiro", obj_chao_banheiro, spr_chao_bebe_banheiro, [0, 1], obj_parede_bebe, SALA_ESTILO_AZULEJO,
                               ["pequeno", "pequeno", "L", "retangulo"], [obj_pontos]),
        banheiro2:  _sala_tipo("Banheiro 2", obj_chao_tijolo, spr_chao_bebe_2, [2, 3], obj_parede_bebe, SALA_ESTILO_AZULEJO,
                               ["pequeno", "L", "recortado"], [obj_pontos]),
        // fundos: escada do porão fica na borda da sala -> só formatos que mantêm as 4 paredes externas
        fundos:     _sala_tipo("Fundos", obj_chao_tijolo, spr_chao_bebe_2, [8, 9], obj_parede_bebe, SALA_ESTILO_CIMENTO,
                               ["retangulo"], [obj_pontos]),
        porao:      _sala_tipo("Porão", obj_chao_tijolo, spr_chao_bebe_2, [8, 9], obj_parede_bebe, SALA_ESTILO_CIMENTO,
                               ["retangulo", "pilares", "dividido", "corredor"], [obj_pontos]),
        templo:     _sala_tipo("Templo", obj_chao_templo, spr_chao_bebe_2, [0, 1], obj_parede_templo, SALA_ESTILO_TEMPLO,
                               ["templo"], []),
        jardim:     _sala_tipo("Jardim", obj_chao_grama, spr_chao, [0], obj_cerca, SALA_ESTILO_CERCA,
                               ["retangulo", "recortado"], [], make_colour_rgb(22, 40, 24))
    };
}

/// @desc Plantas dos formatos. '.' chão | ' ' fora da casa | '#' bloco (pilar/divisória)
///       A planta é esticada para a área interna da sala (qualquer tamanho serve, 14x8 é o padrão).
///       margem: células extras de "fora" em volta | espelhar: pode virar na horizontal/vertical (4 variações grátis)
///       As portas são abertas automaticamente: se a planta não chega até a porta, um corredor é cavado.
function sala_definir_formatos() {
    global.sala_formatos = {
        retangulo: { planta: ["."] },
        pequeno:   { planta: ["."], margem: 2 },
        templo:    { planta: ["."], margem: 3 },
        L: { espelhar: true, planta: [
            "..............",
            "..............",
            "..............",
            "..............",
            "........      ",
            "........      ",
            "........      ",
            "........      "
        ]},
        T: { espelhar: true, planta: [
            "..............",
            "..............",
            "..............",
            "   ........   ",
            "   ........   ",
            "   ........   ",
            "   ........   ",
            "   ........   "
        ]},
        U: { espelhar: true, planta: [
            "....      ....",
            "....      ....",
            "....      ....",
            "..............",
            "..............",
            "..............",
            "..............",
            ".............."
        ]},
        Z: { espelhar: true, planta: [
            "........      ",
            "........      ",
            "........      ",
            "..............",
            "..............",
            "      ........",
            "      ........",
            "      ........"
        ]},
        cruz: { planta: [
            "    ......    ",
            "    ......    ",
            "..............",
            "..............",
            "..............",
            "..............",
            "    ......    ",
            "    ......    "
        ]},
        recortado: { planta: [
            "   ........   ",
            "  ..........  ",
            "..............",
            "..............",
            "..............",
            "..............",
            "  ..........  ",
            "   ........   "
        ]},
        pilares: { planta: [
            "..............",
            "..............",
            "...##....##...",
            "..............",
            "..............",
            "...##....##...",
            "..............",
            ".............."
        ]},
        dividido: { espelhar: true, planta: [
            "......#.......",
            "......#.......",
            "..............",
            "..............",
            "..............",
            "..............",
            "......#.......",
            "......#......."
        ]},
        corredor: { planta: [
            "              ",
            "              ",
            "..............",
            "..............",
            "..............",
            "..............",
            "              ",
            "              "
        ]}
    };
}

#endregion

#region Registro das salas (dados de cada sala da fase)

/// @desc Cria os dados de uma sala específica baseada no index e posição
function criar_salas_lista(_pos_array, _index) {
    if (!variable_global_exists("tipo_sala_index")) global.tipo_sala_index = 0;
    if (!variable_global_exists("sala_tipos")) salas();

    // 1. Tipo pela ordem da casa (index começa em 1)
    var _tipo = "quarto";
    if (_index >= 1 && _index <= array_length(global.sala_ordem)) {
        _tipo = global.sala_ordem[_index - 1];
        global.tipo_sala_index++;
    } else {
        _tipo = global.sala_extras[irandom(array_length(global.sala_extras) - 1)];
    }

    // 2. Templo
    if (global.templo_criado && is_array(global.templos_salas_pos) && array_length(global.templos_salas_pos) > 0
        && array_equals(_pos_array, global.templos_salas_pos[0])) {
        _tipo = "templo";
    }
    // 3. Porão (sala escura ligada pela escada dos fundos)
    if (variable_global_exists("salas_escuras") && is_array(global.salas_escuras) && array_length(global.salas_escuras) > 0
        && array_equals(_pos_array, global.salas_escuras[0])) {
        _tipo = "porao";
    }
    // 4. Jardim
    if (is_array(global.sala_jardim) && array_length(global.sala_jardim) == 2 && array_equals(_pos_array, global.sala_jardim)) {
        _tipo = "jardim";
    }

    var _def = global.sala_tipos[$ _tipo];
    var _formato = _def.formatos[irandom(array_length(_def.formatos) - 1)];
    var _f = global.sala_formatos[$ _formato];
    var _espelha = (_f[$ "espelhar"] ?? false);

    return {
        sala: _pos_array,
        tag: _index,
        tipo: _tipo,
        nome: _def.nome,
        chao: _def.chao,
        spr_chao: _def.spr_chao,
        chao_frames: _def.chao_frames,
        parede: _def.parede,
        estilo: _def.estilo,
        cor_vazio: _def.cor_vazio,
        objetos: _def.objetos,
        formato: _formato,
        espelho_x: _espelha ? (irandom(1) == 1) : false,
        espelho_y: _espelha ? (irandom(1) == 1) : false
    };
}

/// @desc Procura sala por coordenadas [x, y]
function procurar_sala_por_numero(_target_pos) {
    var _len = array_length(global.salas_criadas);
    for (var _i = 0; _i < _len; _i++) {
        var _sala = global.salas_criadas[_i];
        if (array_equals(_sala.sala, _target_pos)) return _sala;
    }
    return { sala: [0, 0], tag: -1, tipo: "none", nome: "", chao: noone, spr_chao: -1, chao_frames: [0], parede: noone,
             estilo: SALA_ESTILO_CASA, cor_vazio: c_black, objetos: [], formato: "retangulo", espelho_x: false, espelho_y: false };
}

/// @desc Debuga as informações da sala no console (Enter na fase)
function escrever_informacoes_sala(_sala) {
    if (!is_struct(_sala) || _sala.tag == -1) {
        show_debug_message("Sala inválida ou não encontrada.");
        return;
    }
    show_debug_message("=== INFO SALA " + get_room_id(_sala.sala) + " ===");
    show_debug_message("Tag: " + string(_sala.tag) + " | Tipo: " + _sala.tipo + " | Formato: " + _sala.formato
        + (_sala.espelho_x ? " (esp X)" : "") + (_sala.espelho_y ? " (esp Y)" : ""));
    show_debug_message("Parede: " + (object_exists(_sala.parede) ? object_get_name(_sala.parede) : "Nenhum"));
    var _L = global.salas_layout[$ get_room_id(_sala.sala)];
    if (is_struct(_L)) show_debug_message(sala_layout_texto(_L));
    show_debug_message("=================");
}

function resetar_salas() {
    global.salas_criadas = [];
    global.tipo_sala_index = 0;
    global.salas_layout = {};
}

function verificar_sala_escura(_sala_atual) {
    if (!variable_global_exists("salas_escuras")) return false;
    var _len = array_length(global.salas_escuras);
    for (var _i = 0; _i < _len; _i++) {
        if (array_equals(global.salas_escuras[_i], _sala_atual)) return true;
    }
    return false;
}

#endregion

#region Layout (geração + salvamento)

/// @desc [x, y, passo_x, passo_y] da célula da porta _d (0 dir | 1 cima | 2 esq | 3 baixo)
function _sala_porta_celula(_d, _w, _h) {
    var _mx = _w div 2, _my = _h div 2;
    switch (_d) {
        case 0: return [_w - 1, _my, -1, 0];
        case 1: return [_mx, 0, 0, 1];
        case 2: return [0, _my, 1, 0];
        default: return [_mx, _h - 1, 0, -1];
    }
}

/// @desc Quais portas a sala precisa: [dir, cima, esq, baixo] conforme vizinhos em global.salas_geradas
function sala_portas_necessarias(_coords) {
    var _p = [false, false, false, false];
    var _off = [[1, 0], [0, 1], [-1, 0], [0, -1]];
    var _salas = (variable_global_exists("salas_geradas") && is_array(global.salas_geradas)) ? global.salas_geradas : [];
    for (var _i = 0; _i < array_length(_salas); _i++) {
        var _v = _salas[_i];
        if (!is_array(_v)) continue;
        for (var _d = 0; _d < 4; _d++) {
            if (_v[0] == _coords[0] + _off[_d][0] && _v[1] == _coords[1] + _off[_d][1]) _p[_d] = true;
        }
    }
    return _p;
}

/// @desc Abre a porta _d e cava um corredor 3x até encontrar chão (ou até o centro)
function _sala_cavar(_L, _d, _ate_centro) {
    var _w = _L.largura, _h = _L.altura, _c = _L.celulas;
    var _mx = _w div 2, _my = _h div 2;
    var _p = _sala_porta_celula(_d, _w, _h);
    var _x = _p[0], _y = _p[1], _dx = _p[2], _dy = _p[3];
    _c[@ _y * _w + _x] = SALA_PORTA;
    _x += _dx; _y += _dy;
    while (_x > 0 && _x < _w - 1 && _y > 0 && _y < _h - 1) {
        if (!_ate_centro && _c[_y * _w + _x] == SALA_CHAO) break;
        for (var _k = -1; _k <= 1; _k++) {
            var _cx = _x + _k * _dy, _cy = _y + _k * _dx;
            if (_cx > 0 && _cx < _w - 1 && _cy > 0 && _cy < _h - 1) {
                _c[@ _cy * _w + _cx] = SALA_CHAO;
                array_push(_L.corredor, _cy * _w + _cx);
            }
        }
        if (_ate_centro && _x == _mx && _y == _my) break;
        _x += _dx; _y += _dy;
    }
}

/// @desc Flood fill (4 direções) sobre chão/porta. Devolve array de bools (alcançável)
function _sala_flood(_L, _sx, _sy) {
    var _w = _L.largura, _h = _L.altura, _c = _L.celulas;
    var _vis = array_create(_w * _h, false);
    var _ini = _sy * _w + _sx;
    if (_c[_ini] != SALA_CHAO && _c[_ini] != SALA_PORTA) return _vis;
    var _pilha = [_ini];
    _vis[_ini] = true;
    while (array_length(_pilha) > 0) {
        var _i = array_pop(_pilha);
        var _x = _i mod _w, _y = _i div _w;
        var _viz = [[_x + 1, _y], [_x - 1, _y], [_x, _y + 1], [_x, _y - 1]];
        for (var _k = 0; _k < 4; _k++) {
            var _nx = _viz[_k][0], _ny = _viz[_k][1];
            if (_nx < 0 || _ny < 0 || _nx >= _w || _ny >= _h) continue;
            var _n = _ny * _w + _nx;
            if (_vis[_n]) continue;
            if (_c[_n] == SALA_CHAO || _c[_n] == SALA_PORTA) { _vis[_n] = true; array_push(_pilha, _n); }
        }
    }
    return _vis;
}

function _sala_abrir_centro(_L) {
    var _w = _L.largura, _mx = _w div 2, _my = _L.altura div 2, _c = _L.celulas;
    for (var _y = _my - 1; _y <= _my + 1; _y++)
        for (var _x = _mx - 1; _x <= _mx + 1; _x++) _c[@ _y * _w + _x] = SALA_CHAO;
}

/// @desc Garante que todas as portas se conectam; remove ilhas de chão inalcançáveis; recalcula paredes
function _sala_finalizar(_L, _forcar_centro) {
    var _w = _L.largura, _h = _L.altura, _c = _L.celulas;
    var _mx = _w div 2, _my = _h div 2;
    var _ativas = [];
    for (var _d = 0; _d < 4; _d++) if (_L.portas[_d]) array_push(_ativas, _d);

    var _ox = _mx, _oy = _my;
    if (_forcar_centro || array_length(_ativas) == 0) {
        _sala_abrir_centro(_L);
    } else {
        var _p0 = _sala_porta_celula(_ativas[0], _w, _h);
        _ox = _p0[0]; _oy = _p0[1];
    }
    var _vis = _sala_flood(_L, _ox, _oy);

    // Alguma porta ficou isolada? Liga todas pelo centro.
    var _isolada = false;
    for (var _i = 0; _i < array_length(_ativas); _i++) {
        var _pc = _sala_porta_celula(_ativas[_i], _w, _h);
        if (!_vis[_pc[1] * _w + _pc[0]]) _isolada = true;
    }
    if (_isolada) {
        _sala_abrir_centro(_L);
        for (var _i = 0; _i < array_length(_ativas); _i++) _sala_cavar(_L, _ativas[_i], true);
        _vis = _sala_flood(_L, _mx, _my);
    }

    // Remove chão inalcançável e recalcula as paredes automáticas
    for (var _i = 0; _i < _w * _h; _i++) {
        if (_c[_i] == SALA_PAREDE) _c[@ _i] = SALA_VAZIO;
        if (_c[_i] == SALA_CHAO && !_vis[_i]) _c[@ _i] = SALA_VAZIO;
    }
    for (var _y = 0; _y < _h; _y++) {
        for (var _x = 0; _x < _w; _x++) {
            if (_c[_y * _w + _x] != SALA_VAZIO) continue;
            var _perto = false;
            for (var _dy = -1; _dy <= 1 && !_perto; _dy++) {
                for (var _dx = -1; _dx <= 1; _dx++) {
                    var _nx = _x + _dx, _ny = _y + _dy;
                    if (_nx < 0 || _ny < 0 || _nx >= _w || _ny >= _h) continue;
                    var _v = _c[_ny * _w + _nx];
                    if (_v == SALA_CHAO || _v == SALA_PORTA) { _perto = true; break; }
                }
            }
            if (_perto) _c[@ _y * _w + _x] = SALA_PAREDE;
        }
    }
}

/// @desc Gera o layout de uma sala a partir do tipo/formato salvos no registro dela
function sala_gerar_layout(_info, _coords) {
    var _w = global._maze_width, _h = global._maze_height;
    var _f = global.sala_formatos[$ _info.formato];
    if (is_undefined(_f)) _f = global.sala_formatos.retangulo;

    var _L = {
        versao: 1,
        id: get_room_id(_coords),
        coords: _coords,
        tipo: _info.tipo,
        formato: _info.formato,
        espelho_x: _info.espelho_x,
        espelho_y: _info.espelho_y,
        largura: _w,
        altura: _h,
        celulas: array_create(_w * _h, SALA_VAZIO),
        variacao: array_create(_w * _h, 0),
        portas: [false, false, false, false],
        corredor: []
    };

    // 1. Planta esticada na área interna (bordas da sala sempre ficam para as paredes)
    var _m = (_f[$ "margem"] ?? 0);
    var _pl = _f.planta;
    var _th = array_length(_pl), _tw = string_length(_pl[0]);
    var _ix0 = 1 + _m, _iy0 = 1 + _m;
    var _iw = _w - 2 - 2 * _m, _ih = _h - 2 - 2 * _m;
    var _c = _L.celulas;
    for (var _cy = 0; _cy < _ih; _cy++) {
        var _ty = (_cy * _th) div _ih;
        if (_L.espelho_y) _ty = _th - 1 - _ty;
        var _linha = _pl[_ty];
        for (var _cx = 0; _cx < _iw; _cx++) {
            var _tx = (_cx * _tw) div _iw;
            if (_L.espelho_x) _tx = _tw - 1 - _tx;
            var _ch = (_tx < string_length(_linha)) ? string_char_at(_linha, _tx + 1) : " ";
            var _v = SALA_VAZIO;
            if (_ch == ".") _v = SALA_CHAO;
            else if (_ch == "#") _v = SALA_BLOCO;
            _c[@ (_iy0 + _cy) * _w + (_ix0 + _cx)] = _v;
        }
    }

    // 2. Portas para os vizinhos (+ corredores se a planta não alcança a porta)
    var _need = sala_portas_necessarias(_coords);
    var _inicial = (_coords[0] == 0 && _coords[1] == 0); // player nasce no centro da sala inicial
    for (var _d = 0; _d < 4; _d++) {
        if (_need[_d]) { _L.portas[_d] = true; _sala_cavar(_L, _d, _inicial); }
    }

    // 3. Conexão, limpeza e paredes automáticas
    _sala_finalizar(_L, _inicial);

    // 4. Variação do piso (fica salva)
    var _nf = array_length(_info.chao_frames);
    for (var _i = 0; _i < _w * _h; _i++) _L.variacao[_i] = irandom(max(0, _nf - 1));

    return _L;
}

/// @desc Se a sala ganhou vizinho depois (templo/jardim), abre a porta que falta no layout salvo
function sala_garantir_portas(_L) {
    var _need = sala_portas_necessarias(_L.coords);
    var _mudou = false;
    for (var _d = 0; _d < 4; _d++) {
        if (_need[_d] && !_L.portas[_d]) { _L.portas[@ _d] = true; _sala_cavar(_L, _d, false); _mudou = true; }
    }
    if (_mudou) _sala_finalizar(_L, false);
    return _L;
}

/// @desc PADRÃO DE ACESSO: devolve o layout salvo da sala; gera e salva se ainda não existe
function sala_obter_layout(_coords) {
    if (!variable_global_exists("salas_layout") || !is_struct(global.salas_layout)) global.salas_layout = {};
    var _id = get_room_id(_coords);
    var _L = global.salas_layout[$ _id];
    if (!is_struct(_L)) {
        _L = sala_gerar_layout(procurar_sala_por_numero(_coords), _coords);
        global.salas_layout[$ _id] = _L;
    }
    return _L;
}

/// @desc Gera e salva o layout de todas as salas da fase (chamar depois de templo/jardim existirem)
function sala_gerar_todos_layouts() {
    for (var _i = 0; _i < array_length(global.salas_criadas); _i++) {
        sala_obter_layout(global.salas_criadas[_i].sala);
    }
}

/// @desc Célula da sala (fora da grade conta como vazio)
function sala_celula(_L, _x, _y) {
    if (_x < 0 || _y < 0 || _x >= _L.largura || _y >= _L.altura) return SALA_VAZIO;
    return _L.celulas[_y * _L.largura + _x];
}

function sala_eh_solida(_v) { return (_v == SALA_PAREDE || _v == SALA_BLOCO); }

/// @desc Posição livre aleatória (centro de uma célula de chão longe _margem células de parede)
function sala_posicao_livre(_coords, _margem = 1) {
    var _L = sala_obter_layout(_coords);
    var _cs = global._cell_size, _w = _L.largura, _h = _L.altura;
    repeat (200) {
        var _x = irandom_range(1, _w - 2), _y = irandom_range(1, _h - 2);
        var _ok = true;
        for (var _dy = -_margem; _dy <= _margem && _ok; _dy++)
            for (var _dx = -_margem; _dx <= _margem; _dx++)
                if (sala_celula(_L, _x + _dx, _y + _dy) != SALA_CHAO) { _ok = false; break; }
        if (_ok) return [_x * _cs + _cs / 2 + irandom_range(-_cs / 4, _cs / 4), _y * _cs + _cs / 2 + irandom_range(-_cs / 4, _cs / 4)];
    }
    return [global.room_width / 2, global.room_height / 2];
}

/// @desc Texto da sala para debug: '.' chão '#' parede 'B' bloco 'P' porta ' ' fora
function sala_layout_texto(_L) {
    var _txt = "";
    var _ch = [" ", ".", "#", "P", "B"];
    for (var _y = 0; _y < _L.altura; _y++) {
        for (var _x = 0; _x < _L.largura; _x++) _txt += _ch[_L.celulas[_y * _L.largura + _x]];
        _txt += "\n";
    }
    return _txt;
}

#endregion

#region Salvamento das casas (mundo aberto)
// [O QUE]: Cada casa do mundo (obj_estrutura) tem uma seed. A 1ª visita gera a casa inteira a partir
//          dela e guarda TUDO em global.casas_salvas["seed"]: quais cômodos existem, formato de cada
//          sala, posição de cada móvel (e se já foi aberto), escada, pontos, inimigos...
//          Nas próximas visitas a casa é restaurada exatamente igual (reset_level_data -> casa_restaurar).
// [COMO] : O save guarda REFERÊNCIAS (arrays, structs e ds_maps), então o que muda dentro da casa
//          (móvel aberto, ponto coletado, inimigo morto) já fica salvo sozinho.
//          Os ds_maps de uma casa salva nunca são limpos: casa_novo_mapa() cria outro para a próxima.

function casa_campos_salvos() {
    return ["salas_geradas", "salas_criadas", "salas_layout", "salas_escuras", "templos_salas_pos",
            "sala_jardim", "templo_criado", "templo_poder", "tipo_sala_index", "minimap"];
}

function casa_mapas_salvos() {
    return ["salas_com_amoeba", "salas_com_inimigos", "salas_com_geladeira", "salas_com_guarda_roupa",
            "sala_com_item_drop", "salas_com_vela", "salas_com_escrivaninha", "salas_com_escada_porao",
            "salas_com_pontos", "salas_com_torretas", "salas_com_slow", "salas_com_paredes",
            "salas_com_fantasma", "salas_com_moveis"];
}

/// @desc Mapa limpo para a próxima casa (nunca apaga um mapa que pertence a uma casa salva)
function casa_novo_mapa(_antigo) {
    if (!variable_global_exists("casas_mapas_presos")) global.casas_mapas_presos = {};
    if (is_real(_antigo) && _antigo >= 0 && ds_exists(_antigo, ds_type_map) && !(global.casas_mapas_presos[$ string(_antigo)] ?? false)) {
        ds_map_clear(_antigo);
        return _antigo;
    }
    return ds_map_create();
}

/// @desc Guarda a casa atual (chamar no fim da geração)
function casa_salvar(_seed) {
    if (_seed == noone) return;
    if (!variable_global_exists("casas_salvas")) global.casas_salvas = {};
    if (!variable_global_exists("casas_mapas_presos")) global.casas_mapas_presos = {};
    var _s = {};
    var _c = casa_campos_salvos();
    for (var _i = 0; _i < array_length(_c); _i++) {
        if (variable_global_exists(_c[_i])) _s[$ _c[_i]] = variable_global_get(_c[_i]);
    }
    var _m = casa_mapas_salvos();
    for (var _i = 0; _i < array_length(_m); _i++) {
        if (!variable_global_exists(_m[_i])) continue;
        var _id = variable_global_get(_m[_i]);
        _s[$ _m[_i]] = _id;
        global.casas_mapas_presos[$ string(_id)] = true;
    }
    global.casas_salvas[$ string(_seed)] = _s;
}

/// @desc Restaura a casa da seed (true se ela já tinha sido visitada)
function casa_restaurar(_seed) {
    if (_seed == noone || !variable_global_exists("casas_salvas")) return false;
    var _s = global.casas_salvas[$ string(_seed)];
    if (!is_struct(_s)) return false;
    var _n = variable_struct_get_names(_s);
    for (var _i = 0; _i < array_length(_n); _i++) variable_global_set(_n[_i], _s[$ _n[_i]]);
    return true;
}

/// @desc Esquece uma casa (a próxima visita gera de novo)
function casa_esquecer(_seed) {
    if (_seed == noone || !variable_global_exists("casas_salvas")) return;
    variable_struct_remove(global.casas_salvas, string(_seed));
}

#endregion

#region Construção na room (colisão + render)

/// @desc Monta a sala atual na room: grid global._maze, caixas de colisão mescladas e o renderizador
function sala_construir(_coords) {
    var _info = procurar_sala_por_numero(_coords);
    var _L = sala_garantir_portas(sala_obter_layout(_coords));
    global.sala = _info;
    escrever_informacoes_sala(_info);
    sala_ajustar_camadas();

    var _w = _L.largura, _h = _L.altura, _c = _L.celulas, _cs = global._cell_size;

    // 1. Grid de navegação (1 = chão) usada por inimigos/labirinto
    if (variable_global_exists("_maze") && ds_exists(global._maze, ds_type_grid)) {
        ds_grid_clear(global._maze, 0);
        for (var _i = 0; _i < _w * _h; _i++) {
            if (_c[_i] == SALA_CHAO || _c[_i] == SALA_PORTA) ds_grid_set(global._maze, _i mod _w, _i div _w, 1);
        }
    }

    // 2. Colisão: retângulos gulosos (uma instância cobre vários blocos de parede)
    var _usado = array_create(_w * _h, false);
    var _obj = object_exists(_info.parede) ? _info.parede : obj_parede_bebe;
    for (var _y = 0; _y < _h; _y++) {
        for (var _x = 0; _x < _w; _x++) {
            var _i = _y * _w + _x;
            if (_usado[_i] || !sala_eh_solida(_c[_i])) continue;
            var _rw = 1;
            while (_x + _rw < _w && !_usado[_i + _rw] && sala_eh_solida(_c[_i + _rw])) _rw++;
            var _rh = 1, _cresce = true;
            while (_cresce && _y + _rh < _h) {
                for (var _k = 0; _k < _rw; _k++) {
                    var _j = (_y + _rh) * _w + _x + _k;
                    if (_usado[_j] || !sala_eh_solida(_c[_j])) { _cresce = false; break; }
                }
                if (_cresce) _rh++;
            }
            for (var _yy = 0; _yy < _rh; _yy++)
                for (var _xx = 0; _xx < _rw; _xx++) _usado[(_y + _yy) * _w + _x + _xx] = true;

            var _col = instance_create_layer(_x * _cs, _y * _cs, "instances", _obj);
            with (_col) {
                mask_index   = spr_parede_mascara;   // 64x64, origem no canto
                image_angle  = 0;
                image_xscale = (_rw * _cs) / 64;
                image_yscale = (_rh * _cs) / 64;
                image_speed  = 0;
                visible      = false;                // o desenho fica no obj_sala_render
            }
        }
    }

    // 3. Renderizador (piso + paredes num surface em cache)
    var _r = instance_create_layer(0, 0, "Instances_floor", obj_sala_render);
    _r.layout = _L;
    _r.info = _info;
    return _L;
}

/// @desc O mundo (player, inimigos, móveis) usa depth = -y do pé, que vai até ~-1100.
///       As camadas de HUD/diálogo ficavam em 0/100 e acabavam ATRÁS dos móveis: aqui elas
///       sobem para bem acima do mundo.
function sala_ajustar_camadas() {
    var _hud = [["Instances_dialogo", -20000], ["Inventario", -19000]];
    for (var _i = 0; _i < array_length(_hud); _i++) {
        if (layer_exists(_hud[_i][0])) layer_depth(layer_get_id(_hud[_i][0]), _hud[_i][1]);
    }
}

/// @desc Tile (0-23) da folha spr_parede_top para a parede em (x, y)
function sala_frame_parede(_L, _x, _y, _estilo) {
    var _s = sala_celula(_L, _x, _y + 1);
    var _n = sala_eh_solida(sala_celula(_L, _x, _y - 1));
    var _e = sala_eh_solida(sala_celula(_L, _x + 1, _y));
    var _o = sala_eh_solida(sala_celula(_L, _x - 1, _y));
    if (_s == SALA_CHAO || _s == SALA_PORTA) {
        return 16 + (_o ? 1 : 0) + (_e ? 2 : 0) + (_n ? 4 : 0);   // frente da parede (visão 3/4)
    }
    return (_n ? 1 : 0) + (_e ? 2 : 0) + (sala_eh_solida(_s) ? 4 : 0) + (_o ? 8 : 0); // topo
}

/// @desc Desenha a sala inteira no surface alvo atual (chamado pelo obj_sala_render)
function sala_desenhar(_L, _info) {
    var _w = _L.largura, _h = _L.altura, _c = _L.celulas, _v = _L.variacao, _cs = global._cell_size;
    draw_clear_alpha(_info.cor_vazio, 1);

    var _spr = _info.spr_chao;
    var _fr = _info.chao_frames, _nf = array_length(_fr);
    var _tem_chao = sprite_exists(_spr);
    var _sx = 1, _sy = 1, _ox = 0, _oy = 0;
    if (_tem_chao) {
        _sx = _cs / sprite_get_width(_spr);
        _sy = _cs / sprite_get_height(_spr);
        _ox = sprite_get_xoffset(_spr) * _sx;
        _oy = sprite_get_yoffset(_spr) * _sy;
    }
    var _ps = _cs / 64;

    for (var _y = 0; _y < _h; _y++) {
        for (var _x = 0; _x < _w; _x++) {
            var _i = _y * _w + _x;
            var _t = _c[_i];
            if (_t == SALA_VAZIO) continue;
            // chão por baixo de tudo (a cerca do jardim é vazada)
            if (_tem_chao) {
                var _f = _fr[_v[_i] mod _nf];
                draw_sprite_ext(_spr, min(_f, sprite_get_number(_spr) - 1), _x * _cs + _ox, _y * _cs + _oy, _sx, _sy, 0, c_white, 1);
            }
            if (sala_eh_solida(_t)) {
                var _tile = sala_frame_parede(_L, _x, _y, _info.estilo);
                draw_sprite_part_ext(spr_parede_top, 0, _tile * 64, _info.estilo * 64, 64, 64, _x * _cs, _y * _cs, _ps, _ps, c_white, 1);
            }
        }
    }
}

/// @desc Draw do obj_sala_render (recria o surface se a GPU o descartar)
function sala_render_draw() {
    if (!is_struct(layout)) return;
    if (!surface_exists(surf)) {
        surf = surface_create(layout.largura * global._cell_size, layout.altura * global._cell_size);
        surface_set_target(surf);
        sala_desenhar(layout, info);
        surface_reset_target();
    }
    draw_surface(surf, 0, 0);
}

#endregion

#region Templo
function carregar_templo(_direcao) {
    // Mantido por compatibilidade: o templo agora é uma sala comum de formato "templo"
    temple_spawn_powerup();
}

/// @desc Coloca o poder básico do templo no centro. O poder sorteado fica salvo na fase
///       (global.templo_poder) e não reaparece depois de coletado.
function temple_spawn_powerup() {
    if (!variable_global_exists("lista_poderes_basicos") || !ds_exists(global.lista_poderes_basicos, ds_type_list)) return;
    var _n = ds_list_size(global.lista_poderes_basicos);
    if (_n == 0) return;
    if (!variable_global_exists("templo_poder") || global.templo_poder < 0 || global.templo_poder >= _n) {
        global.templo_poder = irandom(_n - 1);
    }
    var _p = global.lista_poderes_basicos[| global.templo_poder];
    if (!is_struct(_p)) return;
    global.poder_escolhido = global.templo_poder;
    global.objeto_escolhido = _p;

    // criar_poder usa _coletado/_objeto; os objetos de poder marcam .coletado ao serem pegos
    var _coletado = (_p[$ "coletado"] ?? false) || (_p[$ "_coletado"] ?? false);
    var _obj = _p[$ "_objeto"] ?? (_p[$ "objeto"] ?? noone);
    if (!_coletado && object_exists(_obj)) {
        instance_create_layer(global.room_width / 2, global.room_height / 2, "instances", _obj);
    }
}
#endregion

// ============================================================================
// LEGADO FASE 1 (espermatozoide) — paredes vermelhas antigas, não usadas pela casa
// ============================================================================
#region Legado Fase 1
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

            var _tentativas = 0;
            do {
                var _pos = sala_posicao_livre(_sala, 1);
                _ponto_x = _pos[0];
                _ponto_y = _pos[1];
                _ponto_valido = true;
                _tentativas++;

                for (var _k = 0; _k < ds_list_size(_lista_pontos); _k++) {
                    var _ponto_existente = ds_list_find_value(_lista_pontos, _k);
                    var _distancia = point_distance(_ponto_x, _ponto_y, _ponto_existente[0], _ponto_existente[1]);
                    if (_distancia < 100) {
                        _ponto_valido = false;
                        break;
                    }
                }
            } until (_ponto_valido || _tentativas > 50);

            ds_list_add(_lista_pontos, [_ponto_x, _ponto_y]);
        }
        ds_map_add(global.salas_com_slow, _sala_id, _lista_pontos);
    }
}
#endregion

#region Escada
// [O QUE]: Escada dos "fundos" (desce) <-> "porao" (sobe). Fica encostada numa parede de cima, sempre
//          virada pra dentro do cômodo (a entrada é a parte de baixo do sprite). Chegue perto e aperte E
//          para trocar de sala.
//          Cada lado guarda em global.salas_com_escada_porao["x_y"] = { x, y, destino, sobe }.
//          x = centro da escada, y = topo (encostado na parede).
// [COMO] : create_escada_porao_em_fundos() em reset_level_data (antes da mobília, que desvia dela);
//          recriar_escada_na_sala_atual() no carregar_sala; obj_escada_porao (End Step) chama escada_porao_checar().

#macro ESCADA_LARGURA 128   // spr_escada_porao_top: 128x128, origem no meio de cima
#macro ESCADA_ALTURA  128

/// @desc Célula de chão encostada numa parede de cima (para a escada). Devolve [x centro, y topo] em pixels.
function sala_ponto_encostado_cima(_coords) {
    var _L = sala_obter_layout(_coords);
    var _w = _L.largura, _h = _L.altura, _cs = global._cell_size, _mx = _w div 2;
    var _cand = [];
    for (var _y = 1; _y < _h - 3; _y++) {
        for (var _x = 2; _x < _w - 2; _x++) {
            if (abs(_x - _mx) <= 3) continue;                       // longe da porta de cima
            if (!sala_eh_solida(sala_celula(_L, _x, _y - 1))) continue;
            var _ok = true;
            for (var _dx = -1; _dx <= 1 && _ok; _dx++)
                for (var _dy = 0; _dy <= 3; _dy++)                  // escada (2) + espaço pra entrar (2)
                    if (sala_celula(_L, _x + _dx, _y + _dy) != SALA_CHAO) { _ok = false; break; }
            if (!_ok) continue;
            for (var _k = 0; _k < array_length(_L.corredor); _k++) if (_L.corredor[_k] == _y * _w + _x) { _ok = false; break; }
            if (_ok) array_push(_cand, [_x, _y]);
        }
    }
    if (array_length(_cand) == 0) return [global.room_width / 2, global.room_height / 2 - ESCADA_ALTURA];
    var _c = _cand[irandom(array_length(_cand) - 1)];
    return [_c[0] * _cs + _cs / 2, _c[1] * _cs];
}

function recriar_escada_na_sala_atual(_current_sala) {
    var _sala_id = get_room_id(_current_sala);
    if (!ds_map_exists(global.salas_com_escada_porao, _sala_id)) return;
    var _e = global.salas_com_escada_porao[? _sala_id];
    if (!is_struct(_e)) return;
    // embaixo do player (é um buraco no chão / degraus)
    var _inst = instance_create_layer(_e.x, _e.y, "Instances_Abaixo_moveis", obj_escada_porao);
    _inst.destino = _e.destino;
    _inst.sobe = _e[$ "sobe"] ?? false;
    _inst.image_index = _inst.sobe ? 1 : 0;

    // corrimãos laterais sólidos: só dá pra entrar pela frente
    var _obj = (is_struct(global.sala) && object_exists(global.sala.parede)) ? global.sala.parede : obj_parede_bebe;
    var _lados = [_e.x - ESCADA_LARGURA / 2, _e.x + ESCADA_LARGURA / 2 - 14];
    for (var _i = 0; _i < 2; _i++) {
        var _c = instance_create_layer(_lados[_i], _e.y, "instances", _obj);
        with (_c) {
            mask_index = spr_parede_mascara;
            image_angle = 0;
            image_xscale = 14 / 64;
            image_yscale = ESCADA_ALTURA / 64;
            visible = false;
        }
    }
}

/// @desc Liga a primeira sala "fundos" ao porão (global.salas_escuras[0])
function create_escada_porao_em_fundos(_salas_geradas) {
    if (!variable_global_exists("salas_escuras") || !is_array(global.salas_escuras) || array_length(global.salas_escuras) == 0) return;
    var _porao = global.salas_escuras[0];
    for (var _i = 0; _i < array_length(_salas_geradas); _i++) {
        var _sala = _salas_geradas[_i];
        if (procurar_sala_por_numero(_sala).tipo != "fundos") continue;
        var _a = sala_ponto_encostado_cima(_sala);
        var _b = sala_ponto_encostado_cima(_porao);
        global.salas_com_escada_porao[? get_room_id(_sala)]  = { x: _a[0], y: _a[1], destino: _porao, sobe: false };
        global.salas_com_escada_porao[? get_room_id(_porao)] = { x: _b[0], y: _b[1], destino: _sala,  sobe: true };
        return;
    }
}

/// @desc End Step do obj_escada_porao: com o player PERTO da escada, mostra o botão e entra apertando E.
///       "Perto" = pé do player a até ESCADA_ALCANCE px do retângulo da escada (na frente ou em cima dela).
#macro ESCADA_ALCANCE 56
function escada_porao_checar(_escada) {
    if (!instance_exists(obj_player)) return;
    var _p = obj_player;
    var _l = _escada.x - ESCADA_LARGURA / 2, _r = _escada.x + ESCADA_LARGURA / 2;
    var _t = _escada.y, _b = _escada.y + ESCADA_ALTURA;
    var _pe = _p.bbox_bottom;
    var _dist = point_distance(_p.x, _pe, clamp(_p.x, _l, _r), clamp(_pe, _t, _b));
    if (_dist > ESCADA_ALCANCE) return;
    _p.desenha_botao = true;                                  // aviso acima da cabeça...
    _p.botao_frame = 0;                                       // ...com a tecla E (spr_botoes frame 0)
    if (keyboard_check_pressed(ord("E"))) escada_porao_usar(_escada);
}

/// @desc Usa a escada: carrega a sala do outro lado e coloca o player na frente da escada de lá
function escada_porao_usar(_escada) {
    if (!variable_global_exists("escada_cooldown")) global.escada_cooldown = 0;
    if (current_time < global.escada_cooldown) return;
    var _dest = _escada.destino;
    if (!is_array(_dest)) return;
    global.escada_cooldown = current_time + 700; // evita voltar na mesma hora

    carregar_sala(_dest, global.current_sala);

    var _chegada = instance_find(obj_escada_porao, 0);
    if (instance_exists(_chegada) && instance_exists(obj_player)) {
        obj_player.x = _chegada.x;
        obj_player.y = _chegada.y + ESCADA_ALTURA + 24;   // logo na frente, olhando pra dentro do cômodo
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
            var _pos = sala_posicao_livre(_sala, 1);
            ds_list_add(_lista_inimigo, [_pos[0], _pos[1]]);
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
            var _pos = sala_posicao_livre(_sala, 1);
            ds_list_add(_lista_pontos, [_pos[0], _pos[1]]);
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
    // (sem randomize(): a casa inteira sai da seed dela — ver Salvamento das casas)
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
            var _pos = sala_posicao_livre(_sala, 1);
            var _ix = _pos[0], _iy = _pos[1];
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
            
    //_salvar_inimigo(_lista_inimigos, _inimigo_id, _itype, _ix, _iy, _inst.vida, _inst.dano, _inst.veloc_perse, _inst.dist_aggro, _inst.dist_desaggro, _inst.escala, _inst.veloc, _inst.max_vida);
        }

        // Criar médios
        for (var _j = 0; _j < _inimigos_medio_qtd; _j++) {
            var _pos = sala_posicao_livre(_sala, 1);
            var _ix = _pos[0], _iy = _pos[1];
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

    //_salvar_inimigo(_lista_inimigos, _inimigo_id, _itype, _ix, _iy, _inst.vida, _inst.dano, _inst.veloc_perse, _inst.dist_aggro, _inst.dist_desaggro, _inst.escala, _inst.veloc, _inst.max_vida);
        }

        // Criar difíceis
        for (var _j = 0; _j < _inimigos_dificil_qtd; _j++) {
            var _pos = sala_posicao_livre(_sala, 1);
            var _ix = _pos[0], _iy = _pos[1];
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

    //_salvar_inimigo(_lista_inimigos, _inimigo_id, _itype, _ix, _iy, _inst.vida, _inst.dano, _inst.veloc_perse, _inst.dist_aggro, _inst.dist_desaggro, _inst.escala, _inst.veloc, _inst.max_vida);
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
            var _pos = sala_posicao_livre(_sala, 1);
            ds_list_add(_lista_pontos, [_pos[0], _pos[1]]);
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
        }
    }
    return _salas;
}

// ============================================================================
// SISTEMA DE PORTAS
// ============================================================================
// As aberturas já vêm no layout (SALA_PORTA); aqui só se cria o gatilho obj_next_room.

function criar_portas_gerais(_sala_atual, _salas_geradas) {
    var _visivel = !(is_struct(global.sala) && global.sala.tipo == "templo");

    for (var _i = 0; _i < array_length(_salas_geradas); _i++) {
        var _sala_vizinha = _salas_geradas[_i];
        if (!is_array(_sala_vizinha)) continue;
        var _x_vizinho = _sala_vizinha[0];
        var _y_vizinho = _sala_vizinha[1];

        // Direita
        if (_x_vizinho == _sala_atual[0] + 1 && _y_vizinho == _sala_atual[1]) {
            var _porta_direita = instance_create_layer(global.room_width - 5, (global.room_height / 2), "instances", obj_next_room);
            with (_porta_direita) {
                image_angle -= 90;
                image_yscale = -1;
                room_destino = _sala_vizinha;
                room_origem = _sala_atual;
                direcao = 2;
                visible = _visivel;
            }
        }
        // Esquerda
        if (_x_vizinho == _sala_atual[0] - 1 && _y_vizinho == _sala_atual[1]) {
            var _porta_esquerda = instance_create_layer(5, (global.room_height / 2), "instances", obj_next_room);
            with (_porta_esquerda) {
                image_angle += 90;
                image_yscale = -1;
                room_destino = _sala_vizinha;
                room_origem = _sala_atual;
                direcao = 4;
                visible = _visivel;
            }
        }
        // Cima
        if (_x_vizinho == _sala_atual[0] && _y_vizinho == _sala_atual[1] + 1) {
            var _porta_acima = instance_create_layer((global.room_width / 2) + 32, 10, "instances", obj_next_room);
            with (_porta_acima) {
                image_yscale = -1;
                room_destino = _sala_vizinha;
                room_origem = _sala_atual;
                direcao = 1;
                visible = _visivel;
            }
        }
        // Baixo
        if (_x_vizinho == _sala_atual[0] && _y_vizinho == _sala_atual[1] - 1) {
            var _porta_abaixo = instance_create_layer((global.room_width / 2) + 32, global.room_height - 10, "instances", obj_next_room);
            with (_porta_abaixo) {
                image_xscale = 1;
                room_destino = _sala_vizinha;
                room_origem = _sala_atual;
                direcao = 3;
                visible = _visivel;
            }
        }
    }
}

/// @desc Compat: o templo usa o mesmo sistema de portas
function criar_portas_gerais_templo(_sala_atual, _salas_geradas) {
    criar_portas_gerais(_sala_atual, _salas_geradas);
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
    // Couve (cozinha), Bicho-Papão (quarto) e Livro de Dever de Casa — scr_boss_infancia
    boss_infancia_spawnar();
}

function carregar_sala(_sala_atual, _sala_origem_array) {
    clear_room();
    if (global.seed_atual != noone) random_set_seed(real(global.seed_atual));
    global.current_sala = _sala_atual;
    global.sala_passada = _sala_origem_array;

    // Forma, paredes, colisão e desenho vêm do layout salvo da sala
    sala_construir(_sala_atual);

    var _salas = is_array(global.salas_geradas) ? global.salas_geradas : [];
    criar_portas_gerais(_sala_atual, _salas);
    recriar_pontos_na_sala_atual(global.current_sala);

    casa_recriar_moveis(_sala_atual); // móveis + tapetes do cômodo (scr_casa_moveis)

    recriar_inimigos_na_sala_atual(global.current_sala);
    recriar_slow_na_sala_atual(global.current_sala);
    recriar_escada_na_sala_atual(global.current_sala);
    recriar_inimigos_na_sala_atual_alet(global.current_sala);
    recriar_bosses();
}

function carregar_sala_templo(_sala_atual, _sala_origem_array, _direcao) {
    carregar_sala(_sala_atual, _sala_origem_array);
    carregar_templo(_direcao);
}

function criar_random_pontos(_quantidade) {
    for (var _i = 0; _i < _quantidade; _i++) {
        var _p = sala_posicao_livre(global.current_sala, 1);
        instance_create_layer(_p[0], _p[1], "instances", obj_pontos);
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
