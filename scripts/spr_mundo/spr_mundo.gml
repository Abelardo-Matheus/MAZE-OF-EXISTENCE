// ============================================================================
// SCRIPT: scr_gerador_mundo
// DESCRIÇÃO: Gerencia a criação procedural de estruturas (Chunks) e o chão infinito.
// ============================================================================

/// @desc Inicializa as variáveis necessárias para o gerador (Chame no Create do seu Controlador)
function inicializar_gerador_mundo() 
{
	if (!variable_global_exists("posicoes_bichos")) {
    global.posicoes_bichos = ds_list_create(); 
}

    if (!variable_global_exists("ultimo_bloco")) {
        global.ultimo_bloco = [infinity, infinity]; 
    }
    
    if (!variable_global_exists("ultimo_tile")) {
        global.ultimo_tile = [infinity, infinity]; 
    }

    // ==========================================
    // NOVO: Fila de processamento para zerar o lag
    // ==========================================
    if (!variable_global_exists("fila_de_chunks")) {
        global.fila_de_chunks = []; 
    }
}


/// @desc Roda a lógica de geração de mundo (Chame no STEP do Player ou Controlador)
function gerenciar_mundo_procedural() 
{
    // Segurança: Só roda se o player existir
    if (!instance_exists(obj_player)) return;

    // ========================================================
    // 1. SISTEMA DE CHUNKS (Descobre em qual bloco o player está)
    // ========================================================
    var _chunk_x_atual = floor(obj_player.x / global.tamanho_bloco);
    var _chunk_y_atual = floor(obj_player.y / global.tamanho_bloco);

    // Só roda se o jogador MUDOU de bloco (entrou em uma nova área)
    if (_chunk_x_atual != global.ultimo_bloco[0] || _chunk_y_atual != global.ultimo_bloco[1]) 
    {
        // Em vez de gerar os 9 blocos de uma vez dando lag, nós colocamos eles na "Fila"
        for (var bx = _chunk_x_atual - 1; bx <= _chunk_x_atual + 1; bx++) 
        {
            for (var by = _chunk_y_atual - 1; by <= _chunk_y_atual + 1; by++) 
            {
                array_push(global.fila_de_chunks, [bx, by]);
            }
        }

        // Atualiza a memória
        global.ultimo_bloco[0] = _chunk_x_atual;
        global.ultimo_bloco[1] = _chunk_y_atual;
    }

    // ========================================================
    // 2. O SEGREDO DO ZERO LAG: PROCESSA APENAS 1 BLOCO POR FRAME!
    // ========================================================
    if (array_length(global.fila_de_chunks) > 0)
    {
        // Pega o primeiro bloco da fila e tira ele do array (array_shift)
        var _bloco_da_vez = array_shift(global.fila_de_chunks);
        var _bx = _bloco_da_vez[0];
        var _by = _bloco_da_vez[1];

        // Gera as estruturas DIRETAMENTE e SOMENTE para este bloco
		
        gerar_estruturas_para_bloco(_bx, _by, obj_estrutura, 10, 100);
        gerar_estruturas_para_bloco(_bx, _by, obj_poste, 5, 100);
        gerar_estruturas_para_bloco(_bx, _by, obj_secondary_boss, 2, 100); 
        gerar_estruturas_para_bloco(_bx, _by, obj_grupo_inimigos, 10, 100);
        gerar_estruturas_para_bloco(_bx, _by, par_npc_vendedor_um, 2, 100);
		gerar_fauna_para_bloco(_bx, _by, 1000);
        


		// Gerar Árvores
		gerar_cobertura_cenario(_bx, _by, obj_arvore, 1000, global.posicoes_arvores);

		// Gerar Pedras
		gerar_cobertura_cenario(_bx, _by, obj_rock, 200, global.posicoes_pedras);

    }
}

// ============================================================================
// FUNÇÃO PARA GERAR BICHINHOS PELO MAPA (ZERO LAG)
// ============================================================================
function gerar_fauna_para_bloco(bx, by, quantidade_tentativas) 
{
    var _bloco_id = "fauna_" + string(bx) + "," + string(by);
    if (ds_map_exists(global.blocos_gerados, _bloco_id)) return;
    ds_map_add(global.blocos_gerados, _bloco_id, true);

    var _inicio_x = bx * global.tamanho_bloco;
    var _inicio_y = by * global.tamanho_bloco;

    randomize(); 

    for (var i = 0; i < quantidade_tentativas; i++) 
    {
        var _pos_x = _inicio_x + random(global.tamanho_bloco);
        var _pos_y = _inicio_y + random(global.tamanho_bloco);
        
        var _seed = abs((_pos_x * 73856) ^ (_pos_y * 19349));
        random_set_seed(_seed);

        // ========================================================
        // TABELA DE PORCENTAGEM DOS INSETOS
        // ========================================================
        var _chance = random(100);
        var _spr_escolhido = spr_ant; 
        var _velocidade_base = 0.5;
        var _escala_base = 0.2;

        if (_chance < 50) {
            // 50% de chance: FORMIGA
            _spr_escolhido = spr_ant;
            _velocidade_base = 0.5;
            _escala_base = random_range(0.15, 0.25);
        } 
        else if (_chance < 80) {
            // 30% de chance: BESOURO (50 a 80)
            _spr_escolhido = spr_besouro; 
            _velocidade_base = 0.3;
            _escala_base = random_range(0.3, 0.4);
        } 
        else if (_chance < 95) {
            // 15% de chance: BARATA (80 a 95)
            _spr_escolhido = spr_barata; 
            _velocidade_base = 1.2;
            _escala_base = random_range(0.2, 0.3);
        } 
        else {
            // 5% de chance: ESCORPIÃO RARO (95 a 100)
            _spr_escolhido = spr_escorpiao; 
            _velocidade_base = 0.8;
            _escala_base = random_range(0.4, 0.5);
        }

        // --- Criação da Instância ---
        var _novo_bicho = instance_create_depth(_pos_x, _pos_y, 0, obj_bicho_ambiente);
        
        _novo_bicho.sprite_index = _spr_escolhido;
        _novo_bicho.seed = _seed;
        _novo_bicho.vel_maxima = _velocidade_base;
        _novo_bicho.image_xscale = _escala_base;
        _novo_bicho.image_yscale = _escala_base;

        // Salva na lista (importante para o save/load)
        ds_list_add(global.posicoes_bichos, [_pos_x, _pos_y, _seed, _spr_escolhido]);

        randomize(); 
        instance_deactivate_object(_novo_bicho);
    }
}