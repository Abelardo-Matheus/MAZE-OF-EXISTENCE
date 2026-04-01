/// @desc Inicialização e Lógica de Geração Procedural por Chunks
/// [O QUE]: Inicializa as estruturas de dados globais (Mapas e Listas) e define as funções de geração de mundo baseada na posição do player.

// --- Configurações Globais ---
if (!variable_global_exists("posicoes_estruturas")) {
    global.posicoes_estruturas = ds_list_create(); // Lista [x, y, seed, obj, spr, nome, escala]
}
// NOVO: Lista exclusiva para árvores (Otimiza o minimapa!)
if (!variable_global_exists("posicoes_arvores")) {
    global.posicoes_arvores = ds_list_create(); // Lista [x, y, seed, escala]
}
// NOVO: Lista exclusiva para árvores (Otimiza o minimapa!)
if (!variable_global_exists("pedras")) {
    global.posicoes_pedras = ds_list_create(); // Lista [x, y, seed, escala]
}

if (!variable_global_exists("blocos_gerados")) {
    global.blocos_gerados = ds_map_create(); // Chaves "x,y" para evitar re-geração
}

// Inicializa listas de grupos de inimigos
if (!variable_global_exists("posicoes_grupos_inimigos")) {
    global.posicoes_grupos_inimigos = ds_list_create(); 
}
if (!variable_global_exists("blocos_gerados_grupo")) {
    global.blocos_gerados_grupo = ds_map_create(); 
}

global.tamanho_bloco = 30000;
global.ultimo_bloco = [9999999, 9999999]; // Valor absurdo para forçar geração no primeiro frame

// ============================================================================
// FUNÇÃO PRINCIPAL: CHAMA A GERAÇÃO PARA O BLOCO ATUAL E OS 8 VIZINHOS (3x3)
// ============================================================================
function gerar_estruturas(obj_struct, quantidade_estruturas, distancia_minima) 
{
    // Pega a posição atual do player no grid de blocos
    var _bloco_atual_x = floor(obj_player.x / global.tamanho_bloco);
    var _bloco_atual_y = floor(obj_player.y / global.tamanho_bloco);

    // Percorre o bloco atual e os 8 blocos vizinhos (Grid 3x3)
    for (var bx = _bloco_atual_x - 1; bx <= _bloco_atual_x + 1; bx++) 
    {
        for (var by = _bloco_atual_y - 1; by <= _bloco_atual_y + 1; by++) 
        {
            gerar_estruturas_para_bloco(bx, by, obj_struct, quantidade_estruturas, distancia_minima);
        }
    }
}

// ============================================================================
// FUNÇÃO INTERNA: TENTA POSICIONAR AS ESTRUTURAS DENTRO DE UM ÚNICO BLOCO
// ============================================================================
function gerar_estruturas_para_bloco(bx, by, obj_struct, quantidade_estruturas, distancia_minima) 
{
    // Cria um ID único para este bloco (Ex: "5,-2")
    var _bloco_id = string(bx) + "," + string(by);

    // 1. Verifica se o bloco já existe no mapa global de geração
    if (!ds_map_exists(global.blocos_gerados, _bloco_id)) 
    {
        ds_map_add_list(global.blocos_gerados, _bloco_id, ds_list_create());
    }

    var _lista_estruturas_bloco = global.blocos_gerados[? _bloco_id];

    // 2. Se ESTE objeto específico já foi gerado neste bloco, cancela para não duplicar
    if (ds_list_find_index(_lista_estruturas_bloco, obj_struct) != -1) 
    {
        return;
    }

    // 3. Define o centro do bloco no mundo real (pixels)
    var _centro_x = (bx + 0.5) * global.tamanho_bloco;
    var _centro_y = (by + 0.5) * global.tamanho_bloco;

    var _estruturas_geradas = 0;
    var _tentativas = 0;
    
    // Limite de segurança: tenta 3x mais que a quantidade necessária. 
    // Se não achar espaço, ele desiste para o jogo não travar (loop infinito).
    var _max_tentativas = quantidade_estruturas * 3; 

    // 4. Loop de Tentativa de Posicionamento
    while (_estruturas_geradas < quantidade_estruturas && _tentativas < _max_tentativas) 
    {
        // Sorteia uma posição aleatória dentro dos limites deste bloco
        var _pos_x = _centro_x + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);
        var _pos_y = _centro_y + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);

        var _posicao_valida = true;

        // --- VALIDAÇÃO DE DISTÂNCIA (Evita sobreposição) ---
        // Checa distância contra outras estruturas já geradas
        var _total_estruturas = ds_list_size(global.posicoes_estruturas);
        for (var j = 0; j < _total_estruturas; j++) 
        {
            var _info = global.posicoes_estruturas[| j];
            if (point_distance(_pos_x, _pos_y, _info[0], _info[1]) < distancia_minima) 
            {
                _posicao_valida = false; 
                break;
            }
        }
        
       

        // 5. Se a posição for válida (longe de tudo), cria a estrutura!
        if (_posicao_valida) 
        {
            randomize(); 
            var _seed = random_get_seed();
            
            var _nova_estrutura = instance_create_depth(_pos_x, _pos_y, 0, obj_struct);
            _nova_estrutura.seed = _seed;

            // Variáveis padrão para o Minimapa e Escala
            var _spr = noone;
            var _nome = "Outro";
            var _escala = 1;

            // Configura os detalhes visuais baseados no objeto
            switch (obj_struct)
            {
                case obj_estrutura: 
                    _spr = spr_casa_mini_map; 
                    _nome = "Casa"; 
                    break;
                case obj_poste: 
                    _spr = spr_poste_mini_map; 
                    _nome = "Poste"; 
                    break;
                case obj_grupo_inimigos: 
                    _spr = spr_grupoini_mini_map; 
                    _nome = "Grupo Inimigos"; 
                    break;
                case par_npc_vendedor_um: 
                    _spr = spr_vendedor; 
                    _nome = "Vendedor"; 
                    break;
                case obj_secondary_boss: 
                    _spr = spr_boss_mini_map; 
                    _nome = "BOSS"; 
                    _escala = 0.03; // Boss nasce menor
                    break;
            }

            // Aplica a escala na hora da criação
            _nova_estrutura.image_xscale = _escala;
            _nova_estrutura.image_yscale = _escala;

            // Salva na lista global para o minimapa e para o sistema de save/load
            ds_list_add(global.posicoes_estruturas, [_pos_x, _pos_y, _seed, obj_struct, _spr, _nome, _escala]);
            
            _estruturas_geradas++;
        }
        
        _tentativas++;
    }

    // 6. Registra que este objeto terminou de ser gerado neste bloco (não tenta de novo ao voltar pra cá)
    ds_list_add(_lista_estruturas_bloco, obj_struct);
}

// ============================================================================
// FUNÇÃO OTIMIZADA PARA GERAR FLORESTAS (ZERO LAG)
// ============================================================================
/// @desc Gera uma cobertura de objetos (árvores, pedras, etc) em grade com jittering
/// @arg bx O índice X do bloco
/// @arg by O índice Y do bloco
/// @arg obj O objeto a ser criado (ex: obj_arvore, obj_pedra)
/// @arg quantidade Quantidade aproximada por bloco
/// @arg lista_global A ds_list onde salvar as posições (ex: global.posicoes_arvores ou global.posicoes_pedras)
function gerar_cobertura_cenario(bx, by, obj, quantidade, lista_global) 
{
    // 1. Cria um ID único baseado no BLOCO e no OBJETO para não repetir
    var _obj_name = object_get_name(obj);
    var _bloco_id = _obj_name + "_" + string(bx) + "," + string(by);

    if (ds_map_exists(global.blocos_gerados, _bloco_id)) return;
    ds_map_add(global.blocos_gerados, _bloco_id, true);

    // 2. Localização
    var _inicio_x = bx * global.tamanho_bloco;
    var _inicio_y = by * global.tamanho_bloco;

    // 3. Grid Jittering
    var _celulas_por_lado = ceil(sqrt(quantidade));
    var _tamanho_celula = global.tamanho_bloco / _celulas_por_lado;
    var _distancia_das_estruturas = 300; 

    for (var i = 0; i < _celulas_por_lado; i++) 
    {
        for (var j = 0; j < _celulas_por_lado; j++) 
        {
            // Chance de 80% de existir o objeto nessa célula da grade
            if (random(100) < 80) 
            {
                var _pos_x = _inicio_x + (i * _tamanho_celula) + random_range(50, _tamanho_celula - 50);
                var _pos_y = _inicio_y + (j * _tamanho_celula) + random_range(50, _tamanho_celula - 50);

                var _pode_criar = true;

                // 4. Checa contra estruturas VIPS (Casas, Boss, etc)
                var _total_estruturas = ds_list_size(global.posicoes_estruturas);
                for (var k = 0; k < _total_estruturas; k++) 
                {
                    var _info = global.posicoes_estruturas[| k];
                    if (point_distance(_pos_x, _pos_y, _info[0], _info[1]) < _distancia_das_estruturas) 
                    {
                        _pode_criar = false;
                        break; 
                    }
                }

                // 5. Criação e Virtualização
                if (_pode_criar) 
                {
                    var _seed = abs((_pos_x * 73856093) ^ (_pos_y * 19349663));
                    
                    var _inst = instance_create_depth(_pos_x, _pos_y, 0, obj);
                    
                    // Se o seu objeto tiver a variável 'seed', ele a recebe
                    if (variable_instance_exists(_inst, "seed")) {
                        _inst.seed = _seed;
                    }

                    // Salva na lista passada por argumento
                    ds_list_add(lista_global, [_pos_x, _pos_y, _seed, 1]);

                    // Congela instantaneamente para performance
                    instance_deactivate_object(_inst);
                }
            }
        }
    }
}
// --- Função de Reconstrução (Load/Retorno) ---
function recriar_estruturas() 
{
    // Recria Estruturas Padrão
    var _total = ds_list_size(global.posicoes_estruturas);
    for (var i = 0; i < _total; i++) 
    {
        var _info = global.posicoes_estruturas[| i];
        
        var _px     = _info[0];
        var _py     = _info[1];
        var _seed   = _info[2];
        var _obj    = _info[3];
        var _spr    = _info[4]; 
        var _nome   = _info[5]; 
        var _escala = _info[6]; 

        var _inst = instance_create_depth(_px, _py, 0, _obj);
        _inst.seed = _seed;
        
        if (_spr != noone) { _inst.sprite_index = _spr; }
        _inst.nome = _nome;
        _inst.image_xscale = _escala;
        _inst.image_yscale = _escala;
    }

    // ==========================================
    // NOVO: Recria as Árvores
    // ==========================================
    var _total_arvores = ds_list_size(global.posicoes_arvores);
    for (var i = 0; i < _total_arvores; i++) 
    {
        var _a_info = global.posicoes_arvores[| i];
        var _a_inst = instance_create_depth(_a_info[0], _a_info[1], 0, obj_arvore);
        _a_inst.seed = _a_info[2];
        _a_inst.image_xscale = _a_info[3];
        _a_inst.image_yscale = _a_info[3];
    }

    // Recria Grupos de Inimigos
    var _total_grupos = ds_list_size(global.posicoes_grupos_inimigos);
    for (var i = 0; i < _total_grupos; i++) 
    {
        var _g_info = global.posicoes_grupos_inimigos[| i];
        var _g_inst = instance_create_depth(_g_info[0], _g_info[1], 0, obj_grupo_inimigos);
        _g_inst.seed = _g_info[2];
    }
}