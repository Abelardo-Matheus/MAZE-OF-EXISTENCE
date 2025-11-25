/// @desc Inicialização e Lógica de Geração Procedural por Chunks
/// [O QUE]: Inicializa as estruturas de dados globais (Mapas e Listas) e define as funções de geração de mundo baseada na posição do player.
/// [COMO] : 
/// 1. Cria listas e mapas globais se não existirem (Singleton pattern).
/// 2. 'gerar_estruturas': Calcula o chunk atual e itera sobre os vizinhos (3x3).
/// 3. 'gerar_estruturas_para_bloco': Verifica se o bloco já foi populado. Se não, tenta posicionar estruturas aleatoriamente respeitando a distância mínima.
/// 4. 'recriar_estruturas': Lê a lista de estruturas salvas e instancia os objetos novamente (útil ao voltar de interiores ou carregar save).

// --- Configurações Globais ---
if (!variable_global_exists("posicoes_estruturas")) {
    global.posicoes_estruturas = ds_list_create(); // Lista [x, y, seed, obj, spr, nome]
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
global.ultimo_bloco = [999999, 999999]; // Valor absurdo para forçar geração no primeiro frame

// --- Função Principal de Geração ---
function gerar_estruturas(obj_struct, quantidade_estruturas, distancia_minima) 
{
    // Otimização: Usamos floor para garantir números inteiros nos índices do grid
    var _bloco_atual_x = floor(obj_player.x / global.tamanho_bloco);
    var _bloco_atual_y = floor(obj_player.y / global.tamanho_bloco);

    // Loop 3x3 ao redor do jogador (Chunk atual + Vizinhos)
    for (var bx = _bloco_atual_x - 1; bx <= _bloco_atual_x + 1; bx++) 
    {
        for (var by = _bloco_atual_y - 1; by <= _bloco_atual_y + 1; by++) 
        {
            gerar_estruturas_para_bloco(bx, by, obj_struct, quantidade_estruturas, distancia_minima);
        }
    }
}

// --- Função Interna de População do Bloco ---
function gerar_estruturas_para_bloco(bx, by, obj_struct, quantidade_estruturas, distancia_minima) 
{
    var _bloco_id = string(bx) + "," + string(by);

    // 1. Verifica/Cria a entrada no mapa para este bloco
    if (!ds_map_exists(global.blocos_gerados, _bloco_id)) 
    {
        ds_map_add_list(global.blocos_gerados, _bloco_id, ds_list_create());
    }

    var _lista_estruturas_bloco = global.blocos_gerados[? _bloco_id];

    // 2. Se este tipo de estrutura JÁ foi gerado neste bloco, aborta.
    if (ds_list_find_index(_lista_estruturas_bloco, obj_struct) != -1) 
    {
        return;
    }

    // 3. Define área de spawn no centro do bloco
    var _centro_x = (bx + 0.5) * global.tamanho_bloco;
    var _centro_y = (by + 0.5) * global.tamanho_bloco;

    var _estruturas_geradas = 0;
    var _tentativas = 0;
    var _max_tentativas = quantidade_estruturas * 3; // Evita loop infinito

    // 4. Tentativa de Posicionamento
    while (_estruturas_geradas < quantidade_estruturas && _tentativas < _max_tentativas) 
    {
        var _pos_x = _centro_x + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);
        var _pos_y = _centro_y + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);

        // Validação de Distância
        var _posicao_valida = true;
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

        // 5. Criação da Estrutura
        if (_posicao_valida) 
        {
            // Nota: randomize() aqui altera a seed global. Se quiser seeds fixas por mundo, cuidado.
            randomize(); 
            var _seed = random_get_seed();
            
            var _nova_estrutura = instance_create_depth(_pos_x, _pos_y, 0, obj_struct);
            _nova_estrutura.seed = _seed;

            // Definição de Metadados (Nome e Sprite)
            var _spr = noone;
            var _nome = "Outro";

            // Switch é mais limpo que if/else if
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
            }

            // Salva na lista global para persistência
            ds_list_add(global.posicoes_estruturas, [_pos_x, _pos_y, _seed, obj_struct, _spr, _nome]);
            _estruturas_geradas++;
        }
        _tentativas++;
    }

    // Marca que este tipo de estrutura foi processado neste bloco
    ds_list_add(_lista_estruturas_bloco, obj_struct);
}

// --- Função de Reconstrução (Load/Retorno) ---
function recriar_estruturas() 
{
    // Recria Estruturas Padrão
    var _total = ds_list_size(global.posicoes_estruturas);
    for (var i = 0; i < _total; i++) 
    {
        var _info = global.posicoes_estruturas[| i];
        
        // Extração legível dos dados
        var _px = _info[0];
        var _py = _info[1];
        var _seed = _info[2];
        var _obj = _info[3];
        // _spr e _nome estão guardados no índice 4 e 5 se precisar usar

        var _inst = instance_create_depth(_px, _py, 0, _obj);
        _inst.seed = _seed;
        
        // Reaplicação de propriedades visuais
        if (_obj == obj_estrutura) {
            _inst.sprite_index = spr_casa_mini_map;
            _inst.nome = "Casa";
        } else if (_obj == obj_poste) {
            _inst.sprite_index = spr_poste_mini_map;
            _inst.nome = "Poste";
        } else if (_obj == obj_grupo_inimigos) {
            _inst.sprite_index = spr_grupoini_mini_map;
            _inst.nome = "Grupo Inimigos";
        }
    }

    // Recria Grupos de Inimigos (Separado conforme original)
    var _total_grupos = ds_list_size(global.posicoes_grupos_inimigos);
    for (var i = 0; i < _total_grupos; i++) 
    {
        var _g_info = global.posicoes_grupos_inimigos[| i];
        var _g_inst = instance_create_depth(_g_info[0], _g_info[1], 0, obj_grupo_inimigos);
        _g_inst.seed = _g_info[2];
    }
}