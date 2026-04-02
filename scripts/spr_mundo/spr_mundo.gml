/// @desc Inicialização e Lógica de Geração Procedural por Chunks com BIOMAS

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

    // Fila de Processamento
    if (!variable_global_exists("fila_de_chunks"))       global.fila_de_chunks = []; 

    global.tamanho_bloco = 4000; 
    global.ultimo_bloco = [infinity, infinity]; 
    global.ultimo_tile = [infinity, infinity]; 
    
    // Profiling (Debug)
    if (!variable_global_exists("debug_tempo_total")) global.debug_tempo_total = 0;
}

// ============================================================================
// 2. SISTEMA DE BIOMAS (Caminhada Aleatória para Áreas Irregulares)
// ============================================================================
function definir_bioma_do_cluster(start_bx, start_by)
{
    var _id_inicial = string(start_bx) + "," + string(start_by);
    
    // Se o bloco já tem um bioma, ignoramos
    if (ds_map_exists(global.mapa_biomas, _id_inicial)) return;

    // Sorteia um bioma e o tamanho da área (2 a 8 blocos)
    var _tipos_biomas = ["floresta", "cidade", "vazia", "floresta_negra"]; // ADICIONE NOVOS AQUI
    var _bioma_escolhido = _tipos_biomas[irandom(array_length(_tipos_biomas) - 1)];
    var _tamanho_cluster = irandom_range(2, 8);

    var _cx = start_bx;
    var _cy = start_by;

    // Faz a "Caminhada Aleatória" pintando os blocos
    for (var i = 0; i < _tamanho_cluster; i++) 
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
        for (var bx = _chunk_x_atual - 1; bx <= _chunk_x_atual + 1; bx++) 
        {
            for (var by = _chunk_y_atual - 1; by <= _chunk_y_atual + 1; by++) 
            {
                // NOVO: Antes de mandar para a fila, garante que essa região tem um bioma
                definir_bioma_do_cluster(bx, by);
                array_push(global.fila_de_chunks, [bx, by]);
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
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 200); // <-- NOVA CHAMADA AQUI
                break;

            case "cidade":
                gerar_estruturas_para_bloco(_bx, _by, obj_estrutura, irandom_range(4, 10), 300);
                gerar_estruturas_para_bloco(_bx, _by, obj_poste, irandom_range(3, 6), 200);
                gerar_estruturas_para_bloco(_bx, _by, par_npc_vendedor_um, 1, 400);
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 300); // <-- NOVA CHAMADA AQUI
                break;

            case "floresta_negra":
                gerar_estruturas_para_bloco(_bx, _by, obj_grupo_inimigos, irandom_range(3, 8), 400);
                gerar_cobertura_cenario(_bx, _by, obj_arvore, irandom_range(30, 60), global.posicoes_arvores, 100);
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 200); // <-- NOVA CHAMADA AQUI
                break;

            case "vazia":
                gerar_estruturas_para_bloco(_bx, _by, obj_secondary_boss, 1, 1000); 
                gerar_cobertura_cenario(_bx, _by, obj_rock, irandom_range(50, 100), global.posicoes_pedras, 50);
                gerar_monstros_para_bloco(_bx, _by, _meu_bioma, 500); // <-- NOVA CHAMADA AQUI
                break;
        }

        global.debug_tempo_total = (get_timer() - _tempo_inicio) / 1000;
    }
}

// ============================================================================
// 4. FUNÇÃO DE ESTRUTURAS
// ============================================================================
function gerar_estruturas_para_bloco(bx, by, obj_struct, quantidade_estruturas, distancia_minima) 
{
    var _bloco_id = "struct_" + object_get_name(obj_struct) + "_" + string(bx) + "," + string(by);
    if (ds_map_exists(global.blocos_gerados, _bloco_id)) return;
    ds_map_add(global.blocos_gerados, _bloco_id, true);

    var _centro_x = (bx + 0.5) * global.tamanho_bloco;
    var _centro_y = (by + 0.5) * global.tamanho_bloco;

    var _estruturas_geradas = 0;
    var _tentativas = 0;
    var _max_tentativas = quantidade_estruturas * 3; 

    while (_estruturas_geradas < quantidade_estruturas && _tentativas < _max_tentativas) 
    {
        var _pos_x = _centro_x + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);
        var _pos_y = _centro_y + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);
        var _posicao_valida = true;

        var _total_estruturas = ds_list_size(global.posicoes_estruturas);
        for (var j = 0; j < _total_estruturas; j++) 
        {
            var _info = global.posicoes_estruturas[| j];
            if (point_distance(_pos_x, _pos_y, _info[0], _info[1]) < distancia_minima) 
            {
                _posicao_valida = false; break;
            }
        }
        
        if (_posicao_valida) 
        {
            randomize(); 
            var _seed = random_get_seed();
            
            // =====================================================
            // MÁGICA DOS FILHOS: Decide qual casa é ANTES de nascer!
            // =====================================================
            var _obj_a_criar = obj_struct;

            if (obj_struct == obj_estrutura) 
            {
                var _objetos_casas = [obj_casa_1, obj_casa_2, obj_casa_3, obj_casa_4];
                var _indice = abs(_seed) mod array_length(_objetos_casas);
                _obj_a_criar = _objetos_casas[_indice];
            }

            // INJEÇÃO DE SEED DIRETO NO OBJETO FILHO!
            // O objeto nasce e usa a escala que estiver definida dentro dele mesmo (seu próprio Create)
            var _nova_est = instance_create_depth(_pos_x, _pos_y, 0, _obj_a_criar, { seed: _seed });

            var _spr = noone; 
            var _nome = "Outro"; 

            // Continua usando o obj_struct original só para decidir o ícone do minimapa
            switch (obj_struct) {
                case obj_estrutura:       _spr = spr_casa_mini_map;      _nome = "Casa"; break;
                case obj_poste:           _spr = spr_poste_mini_map;     _nome = "Poste"; break;
                case obj_grupo_inimigos:  _spr = spr_grupoini_mini_map;  _nome = "Grupo Inimigos"; break;
                case par_npc_vendedor_um: _spr = spr_vendedor;           _nome = "Vendedor"; break;
                case obj_secondary_boss:  _spr = spr_boss_mini_map;      _nome = "BOSS"; break;
            }

            // =====================================================
            // NORMALIZAÇÃO DA ESCALA DO MINIMAPA
            // =====================================================
            var _escala_minimapa = 1;
            
            if (_spr != noone) 
            {
                // Defina aqui o tamanho base que TODOS os ícones devem ter no minimapa!
                // Ex: Se colocar 64, todos os sprites vão ser redimensionados para parecerem ter 64 pixels.
                var _tamanho_alvo = 10; 
                
                var _largura_real = sprite_get_width(_spr);
                
                // Evita divisão por zero
                if (_largura_real > 0) {
                    _escala_minimapa = _tamanho_alvo / _largura_real;
                }
            }

            // IMPORTANTE: Salva a `_escala_minimapa` normalizada na lista
            ds_list_add(global.posicoes_estruturas, [_pos_x, _pos_y, _seed, _obj_a_criar, _spr, _nome, _escala_minimapa]);
            
            instance_deactivate_object(_nova_est);
            _estruturas_geradas++;
        }
        _tentativas++;
    }
}

// ============================================================================
// 5. FUNÇÃO DE CENÁRIO 
// ============================================================================
function gerar_cobertura_cenario(bx, by, obj, quantidade, lista_global, dist_minima) 
{
    var _bloco_id = "cenario_" + object_get_name(obj) + "_" + string(bx) + "," + string(by);
    if (ds_map_exists(global.blocos_gerados, _bloco_id)) return;
    ds_map_add(global.blocos_gerados, _bloco_id, true);

    var _inicio_x = bx * global.tamanho_bloco;
    var _inicio_y = by * global.tamanho_bloco;

    var _celulas_por_lado = ceil(sqrt(quantidade));
    if (_celulas_por_lado == 0) return; // Segurança
    
    var _tamanho_celula = global.tamanho_bloco / _celulas_por_lado;

    for (var i = 0; i < _celulas_por_lado; i++) 
    {
        for (var j = 0; j < _celulas_por_lado; j++) 
        {
            if (random(100) < 80) 
            {
                var _pos_x = _inicio_x + (i * _tamanho_celula) + random_range(50, _tamanho_celula - 50);
                var _pos_y = _inicio_y + (j * _tamanho_celula) + random_range(50, _tamanho_celula - 50);
                var _pode_criar = true;

                var _total_estruturas = ds_list_size(global.posicoes_estruturas);
                for (var k = 0; k < _total_estruturas; k++) 
                {
                    var _info = global.posicoes_estruturas[| k];
                    if (point_distance(_pos_x, _pos_y, _info[0], _info[1]) < dist_minima) 
                    {
                        _pode_criar = false; break; 
                    }
                }

                if (_pode_criar) 
                {
                    var _seed = abs((_pos_x * 73856093) ^ (_pos_y * 19349663));
                    
                    // INJEÇÃO DE SEED
                    var _inst = instance_create_depth(_pos_x, _pos_y, 0, obj, { seed: _seed });

                    ds_list_add(lista_global, [_pos_x, _pos_y, _seed, 1]);
                    instance_deactivate_object(_inst); 
                }
            }
        }
    }
}

// ============================================================================
// 6. FUNÇÃO DE BICHOS
// ============================================================================
function gerar_fauna_para_bloco(bx, by, quantidade_tentativas) 
{
    var _bloco_id = "fauna_" + string(bx) + "," + string(by);
    if (ds_map_exists(global.blocos_gerados, _bloco_id)) return;
    ds_map_add(global.blocos_gerados, _bloco_id, true);

    var _inicio_x = bx * global.tamanho_bloco;
    var _inicio_y = by * global.tamanho_bloco;

    for (var i = 0; i < quantidade_tentativas; i++) 
    {
        var _pos_x = _inicio_x + random(global.tamanho_bloco);
        var _pos_y = _inicio_y + random(global.tamanho_bloco);
        
        var _seed = abs((_pos_x * 73856) ^ (_pos_y * 19349));
        random_set_seed(_seed);

        var _chance = random(100);
        var _spr = spr_ant; 
        var _vel = 0.5;
        var _esc = 0.2;

        if (_chance < 50)      { _spr = spr_ant; _vel = 0.5; _esc = random_range(0.15, 0.25); } 
        else if (_chance < 80) { _spr = spr_besouro; _vel = 0.3; _esc = random_range(0.3, 0.4); } 
        else if (_chance < 95) { _spr = spr_barata; _vel = 1.2; _esc = random_range(0.2, 0.3); } 
        else                   { _spr = spr_escorpiao; _vel = 0.8; _esc = random_range(0.4, 0.5); }

        // INJEÇÃO DE SEED
        var _bicho = instance_create_depth(_pos_x, _pos_y, 0, obj_bicho_ambiente, { seed: _seed });
        _bicho.sprite_index = _spr; 
        _bicho.vel_maxima = _vel;
        _bicho.image_xscale = _esc; 
        _bicho.image_yscale = _esc;

        ds_list_add(global.posicoes_bichos, [_pos_x, _pos_y, _seed, _spr]);
        randomize(); 
        instance_deactivate_object(_bicho); 
    }
}