/// @desc Adiciona um item ao inventário do jogador
function adicionar_item_invent(_item, _quantidade, _sprite, _nome, _descricao, _sala_x, _sala_y, _pos_x, _pos_y, _dano, _armadura, _velocidade, _cura, _tipo, _ind, _preco) {
    var _grid = global.grid_itens;
    
    // Valores padrão caso algum argumento não seja passado (segurança)
    _preco = (_preco == undefined) ? 0 : _preco;

    var _empty_slot = -1;
    
    // 1. Tentar empilhar item existente
    for (var i = 0; i < ds_grid_height(_grid); i++) {
        // Verifica se o item e o sprite são iguais
        if (_grid[# Infos.item, i] == _item && _grid[# Infos.sprite, i] == _sprite) {
            _grid[# Infos.quantidade, i] += _quantidade;
            return; // Item atualizado com sucesso
        }
        
        // Salva o primeiro slot vazio encontrado
        if (_grid[# Infos.item, i] == -1 && _empty_slot == -1) {
            _empty_slot = i;
        }
    }
    
    // 2. Se não empilhou, verificar se há espaço
    if (_empty_slot == -1) {
        global.inventario_cheio = true;
        show_debug_message("Inventário cheio!");
        return;
    }
    
    // 3. Adicionar novo item no slot vazio
    _grid[# Infos.item, _empty_slot]       = _item;
    _grid[# Infos.quantidade, _empty_slot] = _quantidade;
    _grid[# Infos.sprite, _empty_slot]     = _sprite;
    _grid[# Infos.nome, _empty_slot]       = _nome;
    _grid[# Infos.descricao, _empty_slot]  = _descricao;
    _grid[# Infos.dano, _empty_slot]       = _dano;
    _grid[# Infos.armadura, _empty_slot]   = _armadura;
    _grid[# Infos.velocidade, _empty_slot] = _velocidade;
    _grid[# Infos.cura, _empty_slot]       = _cura;
    _grid[# Infos.tipo, _empty_slot]       = _tipo;
    _grid[# Infos.image_ind, _empty_slot]  = _ind;
    _grid[# Infos.preco, _empty_slot]      = _preco;
}

/// @desc Compra um item da loja baseado no slot selecionado
function comprar_item_loja(_slot_index) {
    var _grid = inventario_venda; // Assumindo que esta variável existe no escopo da loja

    if (_slot_index < 0 || _slot_index >= ds_grid_height(_grid)) return;
    if (_grid[# Infos.item, _slot_index] == -1) return;

    var _preco = _grid[# Infos.preco, _slot_index];

    if (global.moedas < _preco) {
        show_debug_message("Moedas insuficientes!");
        return;
    }

    global.moedas -= _preco;

    // Adiciona ao inventário do jogador
    adicionar_item_invent(
        _grid[# Infos.item, _slot_index],
        1,
        _grid[# Infos.sprite, _slot_index],
        _grid[# Infos.nome, _slot_index],
        _grid[# Infos.descricao, _slot_index],
        -1, -1, -1, -1, // Posição ignorada
        _grid[# Infos.dano, _slot_index],
        _grid[# Infos.armadura, _slot_index],
        _grid[# Infos.velocidade, _slot_index],
        _grid[# Infos.cura, _slot_index],
        _grid[# Infos.tipo, _slot_index],
        _grid[# Infos.image_ind, _slot_index],
        _grid[# Infos.preco, _slot_index]
    );

    // Remove do inventário do vendedor (limpa o slot)
    _grid[# Infos.item, _slot_index]       = -1;
    _grid[# Infos.quantidade, _slot_index] = 0;
    _grid[# Infos.sprite, _slot_index]     = -1;
    _grid[# Infos.nome, _slot_index]       = "";
    _grid[# Infos.descricao, _slot_index]  = "";
    _grid[# Infos.dano, _slot_index]       = 0;
    _grid[# Infos.armadura, _slot_index]   = 0;
    _grid[# Infos.velocidade, _slot_index] = 0;
    _grid[# Infos.cura, _slot_index]       = 0;
    _grid[# Infos.tipo, _slot_index]       = -1;
    _grid[# Infos.image_ind, _slot_index]  = 0;
    _grid[# Infos.preco, _slot_index]      = 0;

    global.item_selecionado_venda = -1;
}



/// @desc Função ÚNICA para criar drops aleatórios baseados no tipo
/// @arg pos_x
/// @arg pos_y
/// @arg prof (profundidade/depth)
/// @arg raridade (chance de NÃO dropar nada, 0-100)
/// @arg tipo_filtro (string: "uso", "armadura", "arma", "bota" ou "qualquer")
function criar_drop_aleatorio(_pos_x, _pos_y, _prof, _raridade, _tipo_filtro) {
    randomize();

    // 1. Chance de falha (não dropar nada)
    if (random(100) < _raridade) return;

    // 2. Filtrar itens e calcular pesos
    var _lista_filtrada = ds_list_create();
    var _total_peso = 0;
    var _lista_global = global.lista_itens;

    for (var i = 0; i < ds_list_size(_lista_global); i++) {
        var _item = _lista_global[| i];
        
        // Verifica se o item corresponde ao tipo solicitado
        // Se _tipo_filtro for "qualquer", aceita tudo
        if (_tipo_filtro == "qualquer" || _item[8] == _tipo_filtro) {
            // Lógica de peso: Itens no final da lista são mais raros
            // Ajuste a fórmula conforme necessário
            var _peso = max(10, 100 - (i * 2)); 
            ds_list_add(_lista_filtrada, [_item, _peso]);
            _total_peso += _peso;
        }
    }

    // Se nenhum item foi encontrado para esse filtro
    if (_total_peso <= 0 || ds_list_size(_lista_filtrada) == 0) {
        ds_list_destroy(_lista_filtrada);
        return;
    }

    // 3. Sortear item (Roleta Russa de Pesos)
    var _roll = irandom(_total_peso - 1);
    var _acumulado = 0;
    var _item_data = undefined;

    for (var i = 0; i < ds_list_size(_lista_filtrada); i++) {
        var _entry = _lista_filtrada[| i];
        _acumulado += _entry[1]; // Soma o peso
        if (_roll < _acumulado) {
            _item_data = _entry[0];
            break;
        }
    }

    ds_list_destroy(_lista_filtrada);

    if (is_undefined(_item_data)) return;

    // 4. Instanciar o objeto no jogo
    var _inst = instance_create_layer(_pos_x, _pos_y, "Instances_itens", obj_item);
    
    // Populando dados a partir do array do item
    // Índice de referência: [0:spr, 1:nome, 2:desc, 3:cura, 4:dano, 5:arm, 6:vel, 7:ind, 8:tipo, 9:preco, 10:qtd]
    _inst.sprite_index = _item_data[0];
    _inst.nome         = _item_data[1];
    _inst.descricao    = _item_data[2];
    _inst.cura         = _item_data[3];
    _inst.dano         = _item_data[4];
    _inst.armadura     = _item_data[5];
    _inst.velocidade   = _item_data[6];
    _inst.image_index  = _item_data[7];
    _inst.ind          = _item_data[7]; // Redundante com image_index, mas mantido p/ compatibilidade
    _inst.tipo         = _item_data[8];
    _inst.preco        = _item_data[9];
    _inst.quantidade   = _item_data[10];

    // Configurações de Mundo
    _inst.depth        = _prof - 1;
    _inst.profundidade = _prof - 1;
    _inst.sala_x       = global.current_sala[0];
    _inst.sala_y       = global.current_sala[1];
    _inst.pos_x        = _pos_x;
    _inst.pos_y        = _pos_y;

    // Salvar persistência
    salvar_item(_inst.sala_x, _inst.sala_y, _pos_x, _pos_y, _inst);
}

// --- Wrappers para manter compatibilidade com seu código antigo ---
// Você pode continuar chamando estas funções, mas elas usam a lógica unificada acima.
function criar_item_aleatorio_ativos(_x, _y, _prof, _rar) {
    criar_drop_aleatorio(_x, _y, _prof, _rar, "uso");
}

function criar_item_aleatorio_passivos_armadura(_x, _y, _prof, _rar) {
    criar_drop_aleatorio(_x, _y, _prof, _rar, "armadura");
}

function criar_item_aleatorio_passivos_arma(_x, _y, _prof, _rar) {
    criar_drop_aleatorio(_x, _y, _prof, _rar, "arma");
}

function criar_item_aleatorio_passivos_pe(_x, _y, _prof, _rar) {
    criar_drop_aleatorio(_x, _y, _prof, _rar, "bota");
}

function criar_item_aleatorio_material(_x, _y, _prof, _rar) {
    criar_drop_aleatorio(_x, _y, _prof, _rar, "material");
}

// ========================================================
// SISTEMA DE SALVAMENTO E PERSISTÊNCIA (Recriar Itens)
// ========================================================

function coletar_item(_x, _y, _sala_atual) {
    var _sala_id = string(_sala_atual[0]) + "_" + string(_sala_atual[1]);

    if (ds_map_exists(global.sala_com_item_drop, _sala_id)) {
        var _lista = ds_map_find_value(global.sala_com_item_drop, _sala_id);

        for (var i = 0; i < ds_list_size(_lista); i++) {
            var _info = _lista[| i];
            // Verifica se a posição bate com o item coletado (com margem de erro pequena se necessário)
            if (_info[0] == _x && _info[1] == _y) {
                ds_list_delete(_lista, i);
                break;
            }
        }
        // Não é estritamente necessário replace se for a mesma lista ID, mas garante atualização
        ds_map_replace(global.sala_com_item_drop, _sala_id, _lista);
    }
}

function salvar_item(_sala_x, _sala_y, _pos_x, _pos_y, _inst) {
    var _sala_id = string(_sala_x) + "_" + string(_sala_y);
    var _lista;

    if (ds_map_exists(global.sala_com_item_drop, _sala_id)) {
        _lista = ds_map_find_value(global.sala_com_item_drop, _sala_id);
    } else {
        _lista = ds_list_create();
        ds_map_add(global.sala_com_item_drop, _sala_id, _lista); // Use Add na primeira vez
    }

    // Array com dados para salvar
    var _dados = [
        _pos_x, _pos_y,
        _inst.sprite_index, _inst.image_index,
        _inst.quantidade, _inst.nome, _inst.descricao,
        _inst.dano, _inst.armadura, _inst.velocidade, _inst.cura,
        _inst.tipo, _inst.ind,
        _inst.sala_x, _inst.sala_y,
        _inst.pos_x, _inst.pos_y,
        _inst.profundidade, _inst.preco
    ];
    
    ds_list_add(_lista, _dados);
}
/// @desc Dá um item ao jogador buscando TODOS os status automaticamente pelo Nome
function dar_item_ao_jogador(_nome_item, _quantidade, _enum_id = -1) {
    
    // Puxa toda a matriz do item (Spr, Nome, Desc, Dano, etc)
    var _dados = buscar_dados_por_nome(_nome_item);

    if (_dados != undefined) {
        
        // Se você não passar o Enum, ele usa o próprio nome como ID para conseguir empilhar itens repetidos
        var _id_item = (_enum_id != -1) ? _enum_id : _nome_item;

        adicionar_item_invent(
            _id_item,           // _item (ID para empilhar)
            _quantidade,        // _quantidade
            _dados[0],          // _sprite
            _dados[1],          // _nome
            _dados[2],          // _descricao
            -1, -1, -1, -1,     // Posições no mapa (Ignoradas aqui)
            _dados[4],          // _dano
            _dados[5],          // _armadura
            _dados[6],          // _velocidade
            _dados[3],          // _cura
            _dados[8],          // _tipo ("uso", "arma", etc)
            _dados[7],          // _ind (image_index)
            _dados[9]           // _preco
        );
        
    } else {
        // Se você digitar o nome errado, o jogo avisa no Output!
        show_debug_message("ERRO: O item '" + string(_nome_item) + "' não foi encontrado na Database!");
    }
}
function recriar_item_dropado(_sala_x, _sala_y) {
    var _sala_id = string(_sala_x) + "_" + string(_sala_y);

    if (ds_map_exists(global.sala_com_item_drop, _sala_id)) {
        var _lista = ds_map_find_value(global.sala_com_item_drop, _sala_id);

        for (var i = 0; i < ds_list_size(_lista); i++) {
            var _d = _lista[| i]; // _d de dados
            
            // Criação
            var _inst = instance_create_layer(_d[0], _d[1], "instances", obj_item);
            
            // Atribuição direta
            _inst.sprite_index = _d[2];
            _inst.image_index  = _d[3];
            _inst.quantidade   = _d[4];
            _inst.nome         = _d[5];
            _inst.descricao    = _d[6];
            _inst.dano         = _d[7];
            _inst.armadura     = _d[8];
            _inst.velocidade   = _d[9];
            _inst.cura         = _d[10];
            _inst.tipo         = _d[11];
            _inst.ind          = _d[12];
            _inst.sala_x       = _d[13];
            _inst.sala_y       = _d[14];
            _inst.pos_x        = _d[15];
            _inst.pos_y        = _d[16];
            _inst.profundidade = _d[17];
            _inst.depth        = _d[17];
            _inst.preco        = _d[18];
        }
    }
}


// ========================================================
// DATABASE DE ITENS DO JOGO
// ========================================================

/// @desc Cria a lista global com todos os itens do jogo e seus atributos
function criar_lista_itens_padronizados() {
    
    // Se a lista já existir, destrói para recriar (evita vazamento de memória)
    if (variable_global_exists("lista_itens")) {
        ds_list_destroy(global.lista_itens);
    }
    
    global.lista_itens = ds_list_create();

    // ========================================================
    // FUNÇÃO ADD OTIMIZADA (Com Argumentos Opcionais)
    // ========================================================
    // Os primeiros 6 argumentos são obrigatórios.
    // Os outros (_cura, _dano, etc) já começam com -1. Se você não preencher, o GameMaker preenche com -1 sozinho!
    var add = function(_spr, _nome, _desc, _img_idx, _tipo, _preco, _cura = -1, _dano = -1, _arm = -1, _vel = -1, _qtd = 1) {
        
        // Monta o array na ORDEM EXATA que o seu sistema antigo de drop espera:
        // [0:spr, 1:nome, 2:desc, 3:cura, 4:dano, 5:arm, 6:vel, 7:img_idx, 8:tipo, 9:preco, 10:qtd]
        var _arr = [
            _spr, _nome, _desc, _cura, _dano, _arm, _vel, _img_idx, _tipo, _preco, _qtd
        ];
        
        ds_list_add(global.lista_itens, _arr);
    };

    // ========================================================
    // INSERÇÃO DE ITENS (Muito mais limpo e legível!)
    // ========================================================

    // --- CONSUMÍVEIS (USO) ---
    // Ordem preenchida: Spr, Nome, Desc, Index, Tipo, Preço, Cura
    add(spr_itens_invent_consumiveis, "Maçã",     "Recupera 10 de vida.", 1, "uso", 10, 10);
    add(spr_itens_invent_consumiveis, "Uva",      "Recupera 10 de vida.", 3, "uso", 12, 10);
    add(spr_itens_invent_consumiveis, "Banana",   "Recupera 13 de vida.", 2, "uso", 15, 13);
    add(spr_itens_invent_consumiveis, "Batata",   "Recupera 20 de vida.", 0, "uso", 20, 20);
    add(spr_itens_invent_consumiveis, "Leite",    "Recupera 30 de vida.", 5, "uso", 35, 30);
    add(spr_itens_invent_consumiveis, "Vitamina", "Recupera 50 de vida.", 4, "uso", 50, 50);

    // --- ARMADURAS ---
    // Ordem preenchida: Spr, Nome, Desc, Index, Tipo, Preço, (pula cura), (pula dano), Armadura
    add(spr_itens_invent_passivo_armadura, "Cobertor",                "Proteção básica. Defesa +1.",      0, "armadura", 10,  -1, -1, 1);
    add(spr_itens_invent_passivo_armadura, "Armadura de Papelão",     "Proteção média. Defesa +2.",       1, "armadura", 20,  -1, -1, 2);
    add(spr_itens_invent_passivo_armadura, "Toalha Enrolada",         "Proteção confortável. Defesa +3.", 2, "armadura", 30,  -1, -1, 3);
    add(spr_itens_invent_passivo_armadura, "Capa de Chuva",           "Resistente à água. Defesa +4.",    3, "armadura", 40,  -1, -1, 4);
    add(spr_itens_invent_passivo_armadura, "Casaco Almofadado",       "Muito fofo. Defesa +5.",           4, "armadura", 50,  -1, -1, 5);
    add(spr_itens_invent_passivo_armadura, "Armadura de Travesseiro", "Proteção suprema. Defesa +6.",     5, "armadura", 60,  -1, -1, 6);
    add(spr_itens_invent_passivo_armadura, "Capa de Super-Herói",     "Sinta-se poderoso. Defesa +7.",    6, "armadura", 100, -1, -1, 7);

    // --- ARMAS ---
    // Ordem preenchida: Spr, Nome, Desc, Index, Tipo, Preço, (pula cura), Dano
    add(spr_itens_invent_passivo_armas, "Graveto",            "É só um graveto. Dano +2.",         0, "arma", 5,  -1, 2);
    add(spr_itens_invent_passivo_armas, "Vassoura",           "Limpa o chão e inimigos. Dano +4.", 1, "arma", 10, -1, 4);
    add(spr_itens_invent_passivo_armas, "Espada de Plástico", "Não corta muito. Dano +5.",         2, "arma", 15, -1, 5);
    add(spr_itens_invent_passivo_armas, "Espada de Madeira",  "Treinamento básico. Dano +7.",      3, "arma", 25, -1, 7);
    add(spr_itens_invent_passivo_armas, "Espada Dourada",     "Brilha muito. Dano +9.",            4, "arma", 50, -1, 9);
    add(spr_itens_invent_passivo_armas, "Mata-Fantasma",      "Especializada. Dano +9.",           5, "arma", 60, -1, 9);

    // --- BOTAS ---
    // Ordem preenchida: Spr, Nome, Desc, Index, Tipo, Preço, (pula cura), (pula dano), (pula armadura), Vel
    add(spr_itens_invent_passivo_pe, "Sapato Velho",     "Já viu dias melhores. Vel +1.", 0, "bota", 5,  -1, -1, -1, 1);
    add(spr_itens_invent_passivo_pe, "Tênis Rasgado",    "Ainda serve. Vel +2.",          1, "bota", 10, -1, -1, -1, 2);
    add(spr_itens_invent_passivo_pe, "Meias Novas",      "Escorregam bem. Vel +3.",       6, "bota", 15, -1, -1, -1, 3);
    add(spr_itens_invent_passivo_pe, "Sapato Social",    "Elegância. Vel +4.",            5, "bota", 25, -1, -1, -1, 4);
    add(spr_itens_invent_passivo_pe, "Tênis de Corrida", "Feito para correr. Vel +5.",    4, "bota", 30, -1, -1, -1, 5);
    add(spr_itens_invent_passivo_pe, "Skate",            "Radical! Vel +6.",              3, "bota", 40, -1, -1, -1, 6);
    add(spr_itens_invent_passivo_pe, "Patins",           "Velocidade máxima. Vel +7.",    2, "bota", 60, -1, -1, -1, 7);

    // --- MATERIAIS DE CRAFT (NOVO) ---
    // Ordem preenchida: Spr, Nome, Desc, Index, Tipo, Preço (o resto vira -1 automático)
    add(spr_itens_craft, "Madeira",       "Material essencial para construções.", 0, "material", 2);
    add(spr_itens_craft, "Pedra",         "Material bruto e duro.",               1, "material", 2);
    add(spr_itens_craft, "Erva Vermelha", "Planta com propriedades medicinais.",  2, "material", 4);
    add(spr_itens_craft, "Frasco Vazio",  "Usado para guardar líquidos.",         3, "material", 5);
    add(spr_itens_craft, "Barra de Ferro","Ferro fundido, ótimo para armas.",     4, "material", 15);
    add(spr_itens_craft, "Couro",         "Pele resistente para armaduras.",      5, "material", 10);
	

}
	/// @desc Busca todos os atributos do item na Database baseando-se no sprite e index
function buscar_dados_do_item(_spr, _idx) {
    var _tamanho = ds_list_size(global.lista_itens);
    
    // Varre a database inteira procurando o item que tem esse sprite e esse frame
    for (var i = 0; i < _tamanho; i++) {
        var _item_data = global.lista_itens[| i];
        
        // _item_data[0] é o Sprite e _item_data[7] é o image_index
        if (_item_data[0] == _spr && _item_data[7] == _idx) {
            return _item_data; // Retorna o array completo com dano, armadura, etc!
        }
    }
    
    return undefined; // Retorna vazio se não achar
}
/// @desc Busca todos os atributos do item na Database baseando-se no NOME
function buscar_dados_por_nome(_nome) {
    var _tamanho = ds_list_size(global.lista_itens);
    
    for (var i = 0; i < _tamanho; i++) {
        var _item_data = global.lista_itens[| i];
        
        // _item_data[1] é onde fica salvo o NOME do item na sua lista_itens!
        if (_item_data[1] == _nome) {
            return _item_data; 
        }
    }
    return undefined; 
}