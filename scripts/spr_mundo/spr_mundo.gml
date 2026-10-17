// feather disable GM2017
/// @desc Inicialização e Lógica de Geração Procedural por Chunks
/// [O QUE]: Inicializa as estruturas de dados globais (Mapas e Listas) e define as funções de geração de mundo baseada na posição do player.

// ============================================================================
// FUNÇÃO PRINCIPAL: CHAMA A GERAÇÃO PARA O BLOCO ATUAL E OS 8 VIZINHOS (3x3)
// ============================================================================
function gerar_estruturas(_obj_struct, _quantidade_estruturas, _distancia_minima) 
{
    // Pega a posição atual do player no grid de blocos
    var _bloco_atual_x = floor(obj_player.x / global.tamanho_bloco);
    var _bloco_atual_y = floor(obj_player.y / global.tamanho_bloco);

    // Percorre o bloco atual e os 8 blocos vizinhos (Grid 3x3)
    for (var _bx = _bloco_atual_x - 1; _bx <= _bloco_atual_x + 1; _bx++) 
    {
        for (var _by = _bloco_atual_y - 1; _by <= _bloco_atual_y + 1; _by++) 
        {
            gerar_estruturas_para_bloco(_bx, _by, _obj_struct, _quantidade_estruturas, _distancia_minima);
        }
    }
}

// ============================================================================
// FUNÇÃO DE RECONSTRUÇÃO (Load/Retorno)
// ============================================================================
function recriar_estruturas() 
{
    // ==========================================
    // 1. Recria Estruturas Padrão (Casas, Boss, Vendedor)
    // ==========================================
    var _total = ds_list_size(global.posicoes_estruturas);
    for (var _i = 0; _i < _total; _i++) 
    {
        var _info = global.posicoes_estruturas[| _i];
        
        var _px      = _info[0];
        var _py      = _info[1];
        var _seed    = _info[2];
        var _obj     = _info[3]; 
        var _spr     = _info[4]; 
        var _nome    = _info[5]; 
        var _escala_minimapa = _info[6]; 

        // O objeto nasce e usa sua PRÓPRIA lógica de escala baseada na seed
        var _inst = instance_create_depth(_px, _py, 0, _obj, { seed: _seed });
        
        // Tratamento especial APENAS para o Boss se precisar forçar um sprite diferente do minimapa
        if (_spr != noone && _obj == obj_secondary_boss) { 
            _inst.sprite_index = _spr; 
        }

        _inst.nome = _nome;
        _inst.escala_mini = _escala_minimapa; // Guarda a escala apenas para uso no minimapa
    }
    
    // ==========================================
    // 2. Recria as Árvores
    // ==========================================
    var _total_arvores = ds_list_size(global.posicoes_arvores);
    for (var _i = 0; _i < _total_arvores; _i++) 
    {
        var _a_info = global.posicoes_arvores[| _i];
        var _inst = instance_create_depth(_a_info[0], _a_info[1], 0, obj_arvore, {});
		_inst.seed = _a_info[2];
    }

    // ==========================================
    // 3. Recria as Pedras
    // ==========================================
    var _total_pedras = ds_list_size(global.posicoes_pedras);
    for (var _i = 0; _i < _total_pedras; _i++) 
    {
        var _p_info = global.posicoes_pedras[| _i];
        var _inst = instance_create_depth(_p_info[0], _p_info[1], 0, obj_rock, {});
		_inst.seed = _p_info[2];
    }

    // ==========================================
    // 4. Recria Grupos de Inimigos
    // ==========================================
    var _total_grupos = ds_list_size(global.posicoes_grupos_inimigos);
    for (var _i = 0; _i < _total_grupos; _i++) 
    {
        var _g_info = global.posicoes_grupos_inimigos[| _i];
        var _inst = instance_create_depth(_g_info[0], _g_info[1], 0, obj_grupo_inimigos, {});
		_inst.seed = _g_info[2];
    }
}

// ============================================================================
// 1. INICIALIZAÇÃO GERAL (Coloque no Create do Controlador)
// ============================================================================
function inicializar_gerador_mundo() 
{
    // Listas de Posições (Memória do Jogo)
    if (!variable_global_exists("posicoes_estruturas")) global.posicoes_estruturas = ds_list_create(); 
    if (!variable_global_exists("posicoes_arvores"))    global.posicoes_arvores = ds_list_create(); 
    if (!variable_global_exists("posicoes_pedras"))     global.posicoes_pedras = ds_list_create(); 
    if (!variable_global_exists("posicoes_bichos"))     global.posicoes_bichos = ds_list_create(); 
    if (!variable_global_exists("posicoes_grupos_inimigos")) global.posicoes_grupos_inimigos = ds_list_create(); 
    if (!variable_global_exists("posicoes_monstros")) global.posicoes_monstros = ds_list_create();
    
    // Mapas de Controle
    if (!variable_global_exists("blocos_gerados"))       global.blocos_gerados = ds_map_create(); 
    if (!variable_global_exists("blocos_gerados_grupo")) global.blocos_gerados_grupo = ds_map_create(); 
    
    // NOVO: Mapa para guardar qual Bioma pertence a qual bloco
    if (!variable_global_exists("mapa_biomas"))          global.mapa_biomas = ds_map_create(); 

    // NOVO: Spatial Hashing para Colisões na Geração (Alta Performance)
    if (!variable_global_exists("grid_colisao_geracao")) global.grid_colisao_geracao = ds_map_create();

    // NOVO: Spatial Hashing para Entidades do Mundo (Virtualização)
    if (!variable_global_exists("grid_entidades_mundo")) global.grid_entidades_mundo = ds_map_create();
    if (!variable_global_exists("instancias_ativas"))    global.instancias_ativas = ds_map_create();
    if (!variable_global_exists("entidades_mortas"))     global.entidades_mortas = ds_map_create();

    // Fila de Processamento
    if (!variable_global_exists("fila_de_chunks"))       global.fila_de_chunks = []; 

    global.tamanho_bloco = 4000; 

    // NOVO: semente do clima (temperatura/umidade) que decide os biomas
    if (!variable_global_exists("semente_terreno")) global.semente_terreno = irandom_range(1, 9999);
    terreno_inicializar();
    global.ultimo_bloco = [infinity, infinity]; 
    global.ultimo_tile = [infinity, infinity]; 
    
    // Profiling (Debug)
    if (!variable_global_exists("debug_tempo_total")) global.debug_tempo_total = 0;
}

/// @desc Registra uma entidade em um bloco específico para virtualização
function registrar_entidade_no_bloco(_bx, _by, _tipo_lista, _dados) {
    var _key = string(_bx) + "," + string(_by);
    if (!ds_map_exists(global.grid_entidades_mundo, _key)) {
        global.grid_entidades_mundo[? _key] = ds_list_create();
    }
    // Formato: [tipo_lista, dados_completos]
    ds_list_add(global.grid_entidades_mundo[? _key], [_tipo_lista, _dados]);
}

/// @desc Registra uma posição na grid de colisão da geração
function registrar_posicao_geracao(_x, _y) {
    var _gx = floor(_x / 500); // Células de 500px para colisão
    var _gy = floor(_y / 500);
    var _key = string(_gx) + "," + string(_gy);
    
    if (!ds_map_exists(global.grid_colisao_geracao, _key)) {
        global.grid_colisao_geracao[? _key] = ds_list_create();
    }
    ds_list_add(global.grid_colisao_geracao[? _key], [_x, _y]);
}

/// @desc Verifica se uma posição conflita com algo já gerado (Spatial Hashing)
function posicao_conflitante_geracao(_x, _y, _dist_minima) {
    var _gx = floor(_x / 500);
    var _gy = floor(_y / 500);
    
    // Checa a célula atual e as 8 vizinhas
    for (var _i = -1; _i <= 1; _i++) {
        for (var _j = -1; _j <= 1; _j++) {
            var _key = string(_gx + _i) + "," + string(_gy + _j);
            var _list = global.grid_colisao_geracao[? _key];
            
            if (!is_undefined(_list)) {
                var _size = ds_list_size(_list);
                for (var _k = 0; _k < _size; _k++) {
                    var _pos = _list[| _k];
                    if (point_distance(_x, _y, _pos[0], _pos[1]) < _dist_minima) return true;
                }
            }
        }
    }
    return false;
}

// ============================================================================
// 2. SISTEMA DE BIOMAS (Caminhada Aleatória para Áreas Irregulares)
// ============================================================================
function definir_bioma_do_cluster(_start_bx, _start_by)
{
    var _id_inicial = string(_start_bx) + "," + string(_start_by);
    
    // O jogador sempre começa numa floresta
    if (!ds_map_exists(global.mapa_biomas, "0,0")) global.mapa_biomas[? "0,0"] = "floresta";

    // Se o bloco já tem um bioma, ignoramos
    if (ds_map_exists(global.mapa_biomas, _id_inicial)) return;

    // O bioma vem do CLIMA da região (script TERRENO): neve longe do deserto,
    // pântano perto da floresta etc. Biomas: floresta, cidade, vazia, floresta_negra,
    // deserto, neve, pantano, vulcanico, prado, cristalino
    var _bioma_escolhido = terreno_escolher_bioma(_start_bx, _start_by);
    var _tamanho_cluster = irandom_range(2, 8);

    var _cx = _start_bx;
    var _cy = _start_by;

    // Faz a "Caminhada Aleatória" pintando os blocos
    for (var _i = 0; _i < _tamanho_cluster; _i++) 
    {
        var _cluster_id = string(_cx) + "," + string(_cy);
        
        // Só pinta se o bloco ainda não tiver dono
        if (!ds_map_exists(global.mapa_biomas, _cluster_id)) {
            global.mapa_biomas[? _cluster_id] = _bioma_escolhido;
        }

        // Anda para um lado aleatório para pintar o próximo bloco na próxima rodada do loop
        var _direcao = choose(0, 1, 2, 3);
        if (_direcao == 0) _cx += 1;
        else if (_direcao == 1) _cx -= 1;
        else if (_direcao == 2) _cy += 1;
        else if (_direcao == 3) _cy -= 1;
    }
}

// ============================================================================
// 3. GERENCIADOR DO MUNDO (Coloque no Step do Controlador)
// ============================================================================
function gerenciar_mundo_procedural() 
{
    if (!instance_exists(obj_player)) return;

    var _chunk_x_atual = floor(obj_player.x / global.tamanho_bloco);
    var _chunk_y_atual = floor(obj_player.y / global.tamanho_bloco);

    if (_chunk_x_atual != global.ultimo_bloco[0] || _chunk_y_atual != global.ultimo_bloco[1]) 
    {
        for (var _bx = _chunk_x_atual - 1; _bx <= _chunk_x_atual + 1; _bx++) 
        {
            for (var _by = _chunk_y_atual - 1; _by <= _chunk_y_atual + 1; _by++) 
            {
                // NOVO: Antes de mandar para a fila, garante que essa região tem um bioma
                definir_bioma_do_cluster(_bx, _by);
                array_push(global.fila_de_chunks, [_bx, _by]);
            }
        }
        global.ultimo_bloco[0] = _chunk_x_atual;
        global.ultimo_bloco[1] = _chunk_y_atual;
    }

    // PROCESSAMENTO DA FILA (Onde a mágica da separação acontece)
    if (array_length(global.fila_de_chunks) > 0)
    {
        var _bloco_da_vez = array_shift(global.fila_de_chunks);
        var _bx = _bloco_da_vez[0];
        var _by = _bloco_da_vez[1];
        
        var _bloco_id = string(_bx) + "," + string(_by);
        
        // Se o bloco já foi gerado fisicamente, pula pro próximo
        if (ds_map_exists(global.blocos_gerados, "check_" + _bloco_id)) return;
        ds_map_add(global.blocos_gerados, "check_" + _bloco_id, true);

        var _tempo_inicio = get_timer();

        // Descobre qual é o bioma deste bloco exato
        var _meu_bioma = global.mapa_biomas[? _bloco_id];

        // ========================================================
        // O MODULADOR DE BIOMAS
        // ========================================================
        switch (_meu_bioma) 
        {
            case "floresta":
                gerar_cobertura_cenario(_bx, _by, obj_arvore, irandom_range(200, 250), global.posicoes_arvores, 1);
                gerar_cobertura_cenario(_bx, _by, obj_rock, irandom_range(5, 20), global.posicoes_pedras, 50);
                gerar_fauna_para_bloco(_bx, _by, irandom_range(5, 15));
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 200); 
                break;

            case "cidade":
                gerar_estruturas_para_bloco(_bx, _by, obj_estrutura, irandom_range(4, 10), 300);
                gerar_estruturas_para_bloco(_bx, _by, obj_poste, irandom_range(3, 6), 200);
                gerar_estruturas_para_bloco(_bx, _by, obj_par_npc_vendedor_um, 1, 400);
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 300); 
                break;

            case "floresta_negra":
                gerar_estruturas_para_bloco(_bx, _by, obj_grupo_inimigos, irandom_range(3, 8), 400);
                gerar_cobertura_cenario(_bx, _by, obj_arvore, irandom_range(30, 60), global.posicoes_arvores, 100);
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 200); 
                break;

            case "vazia":
                gerar_estruturas_para_bloco(_bx, _by, obj_secondary_boss, 1, 1000); 
                gerar_cobertura_cenario(_bx, _by, obj_rock, irandom_range(50, 100), global.posicoes_pedras, 50);
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 500); 
                break;

            // ---------------- BIOMAS NOVOS ----------------
            case "deserto":
                gerar_cobertura_cenario(_bx, _by, obj_rock, irandom_range(20, 40), global.posicoes_pedras, 80);
                gerar_cobertura_cenario(_bx, _by, obj_arvore, irandom_range(5, 15), global.posicoes_arvores, 150);
                gerar_fauna_para_bloco(_bx, _by, irandom_range(4, 10));
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 400);
                break;

            case "neve":
                gerar_cobertura_cenario(_bx, _by, obj_arvore, irandom_range(40, 80), global.posicoes_arvores, 100);
                gerar_cobertura_cenario(_bx, _by, obj_rock, irandom_range(10, 25), global.posicoes_pedras, 80);
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 300);
                break;

            case "pantano":
                gerar_cobertura_cenario(_bx, _by, obj_arvore, irandom_range(80, 120), global.posicoes_arvores, 60);
                gerar_estruturas_para_bloco(_bx, _by, obj_grupo_inimigos, irandom_range(1, 3), 400);
                gerar_fauna_para_bloco(_bx, _by, irandom_range(5, 12));
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 250);
                break;

            case "vulcanico":
                gerar_cobertura_cenario(_bx, _by, obj_rock, irandom_range(40, 80), global.posicoes_pedras, 60);
                gerar_cobertura_cenario(_bx, _by, obj_arvore, irandom_range(5, 15), global.posicoes_arvores, 150);
                gerar_estruturas_para_bloco(_bx, _by, obj_grupo_inimigos, irandom_range(2, 5), 400);
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 300);
                break;

            case "prado":
                gerar_cobertura_cenario(_bx, _by, obj_arvore, irandom_range(15, 30), global.posicoes_arvores, 120);
                gerar_cobertura_cenario(_bx, _by, obj_rock, irandom_range(3, 8), global.posicoes_pedras, 80);
                gerar_fauna_para_bloco(_bx, _by, irandom_range(15, 25));
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 400);
                break;

            case "cristalino":
                gerar_cobertura_cenario(_bx, _by, obj_rock, irandom_range(30, 60), global.posicoes_pedras, 70);
                gerar_estruturas_para_bloco(_bx, _by, obj_grupo_inimigos, irandom_range(1, 3), 400);
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 350);
                break;
        }

        global.debug_tempo_total = (get_timer() - _tempo_inicio) / 1000;
    }
}

// ============================================================================
// 4. FUNÇÃO DE ESTRUTURAS
// ============================================================================
function gerar_estruturas_para_bloco(_bx, _by, _obj_struct, _quantidade_estruturas, _distancia_minima) 
{
    var _bloco_id = "struct_" + object_get_name(_obj_struct) + "_" + string(_bx) + "," + string(_by);
    if (ds_map_exists(global.blocos_gerados, _bloco_id)) return;
    ds_map_add(global.blocos_gerados, _bloco_id, true);

    var _centro_x = (_bx + 0.5) * global.tamanho_bloco;
    var _centro_y = (_by + 0.5) * global.tamanho_bloco;

    var _estruturas_geradas = 0;
    var _tentativas = 0;
    var _max_tentativas = _quantidade_estruturas * 3; 

    while (_estruturas_geradas < _quantidade_estruturas && _tentativas < _max_tentativas) 
    {
        var _pos_x = _centro_x + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);
        var _pos_y = _centro_y + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);

        // PERFORMANCE: Spatial Hashing em vez de loop global
        if (!posicao_conflitante_geracao(_pos_x, _pos_y, _distancia_minima)) 
        {
            randomize(); 
            var _seed = random_get_seed();
            var _obj_a_criar = _obj_struct;

            if (_obj_struct == obj_estrutura) 
            {
                var _objetos_casas = [obj_casa_1, obj_casa_2, obj_casa_3, obj_casa_4];
                var _indice = abs(_seed) mod array_length(_objetos_casas);
                _obj_a_criar = _objetos_casas[_indice];
            }

            var _spr = noone; 
            var _nome = "Outro"; 

            switch (_obj_struct) {
                case obj_estrutura:       _spr = spr_casa_mini_map;      _nome = "Casa"; break;
                case obj_poste:           _spr = spr_poste_mini_map;     _nome = "Poste"; break;
                case obj_grupo_inimigos:  _spr = spr_grupoini_mini_map;  _nome = "Grupo Inimigos"; break;
                case obj_par_npc_vendedor_um: _spr = spr_vendedor;           _nome = "Vendedor"; break;
                case obj_secondary_boss:  _spr = spr_boss_mini_map;      _nome = "BOSS"; break;
            }

            var _escala_minimapa = 1;
            if (_spr != noone) {
                var _tamanho_alvo = 10; 
                var _largura_real = sprite_get_width(_spr);
                if (_largura_real > 0) _escala_minimapa = _tamanho_alvo / _largura_real;
            }

            // VIRTUALIZAÇÃO: Apenas salva os dados. O obj_otimizador criará o objeto real.
            var _dados = [_pos_x, _pos_y, _seed, _obj_a_criar, _spr, _nome, _escala_minimapa];
            ds_list_add(global.posicoes_estruturas, _dados);
            registrar_entidade_no_bloco(_bx, _by, "estrutura", _dados);
            registrar_posicao_geracao(_pos_x, _pos_y);

            _estruturas_geradas++;
        }
        _tentativas++;
    }
}

// ============================================================================
// 5. FUNÇÃO DE CENÁRIO 
// ============================================================================
function gerar_cobertura_cenario(_bx, _by, _obj, _quantidade, _lista_global, _dist_minima) 
{
    var _bloco_id = "cenario_" + object_get_name(_obj) + "_" + string(_bx) + "," + string(_by);
    if (ds_map_exists(global.blocos_gerados, _bloco_id)) return;
    ds_map_add(global.blocos_gerados, _bloco_id, true);

    var _inicio_x = _bx * global.tamanho_bloco;
    var _inicio_y = _by * global.tamanho_bloco;

    var _celulas_por_lado = ceil(sqrt(_quantidade));
    if (_celulas_por_lado == 0) return; 

    var _tamanho_celula = global.tamanho_bloco / _celulas_por_lado;

    // Identifica o tipo de cenário para a virtualização
    var _tipo = (_obj == obj_arvore) ? "arvore" : "pedra";

    for (var _i = 0; _i < _celulas_por_lado; _i++) 
    {
        for (var _j = 0; _j < _celulas_por_lado; _j++) 
        {
            if (random(100) < 80) 
            {
                var _pos_x = _inicio_x + (_i * _tamanho_celula) + random_range(50, _tamanho_celula - 50);
                var _pos_y = _inicio_y + (_j * _tamanho_celula) + random_range(50, _tamanho_celula - 50);

                // PERFORMANCE: Spatial Hashing
                if (!posicao_conflitante_geracao(_pos_x, _pos_y, _dist_minima)) 
                {
                    var _seed = abs((_pos_x * 73856093) ^ (_pos_y * 19349663));

                    // VIRTUALIZAÇÃO: Apenas dados
                    var _dados = [_pos_x, _pos_y, _seed];
                    ds_list_add(_lista_global, _dados);
                    registrar_entidade_no_bloco(_bx, _by, _tipo, _dados);
                    registrar_posicao_geracao(_pos_x, _pos_y);
                }
            }
        }
    }
}

// ============================================================================
// 6. FUNÇÃO DE BICHOS
// ============================================================================
function gerar_fauna_para_bloco(_bx, _by, _quantidade_tentativas) 
{
    var _bloco_id = "fauna_" + string(_bx) + "," + string(_by);
    if (ds_map_exists(global.blocos_gerados, _bloco_id)) return;
    ds_map_add(global.blocos_gerados, _bloco_id, true);

    var _inicio_x = _bx * global.tamanho_bloco;
    var _inicio_y = _by * global.tamanho_bloco;

    for (var _i = 0; _i < _quantidade_tentativas; _i++) 
    {
        var _pos_x = _inicio_x + random(global.tamanho_bloco);
        var _pos_y = _inicio_y + random(global.tamanho_bloco);

        var _seed = abs((_pos_x * 73856) ^ (_pos_y * 19349));
        random_set_seed(_seed);

        var _chance = random(100);
        var _spr = spr_ant; 
        var _vel = 0.5;

        if (_chance < 50)      { _spr = spr_ant; _vel = 0.5; } 
        else if (_chance < 80) { _spr = spr_besouro; _vel = 0.3; } 
        else if (_chance < 95) { _spr = spr_barata; _vel = 1.2; } 
        else                   { _spr = spr_escorpiao; _vel = 0.8; }

        // VIRTUALIZAÇÃO: Apenas dados
        var _dados = [_pos_x, _pos_y, _seed, _spr, _vel];
        ds_list_add(global.posicoes_bichos, _dados);
        registrar_entidade_no_bloco(_bx, _by, "fauna", _dados);
        registrar_posicao_geracao(_pos_x, _pos_y);

        randomize(); 
    }
}
