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
// DATABASE DE ITENS
// ========================================================

function criar_lista_itens_padronizados() {
    global.lista_itens = ds_list_create();

    // Função auxiliar local para adicionar itens de forma mais limpa
    // Ordem: [spr, nome, desc, cura, dano, arm, vel, img_idx, tipo, preco, qtd]
    var add = function(_arr) {
        ds_list_add(global.lista_itens, _arr);
    };

    // --- CONSUMÍVEIS (USO) ---
    add([spr_itens_invent_consumiveis, "Maçã",     "Recupera 10 de vida.", 10, -1, -1, -1, 1, "uso", 10, 1]);
    add([spr_itens_invent_consumiveis, "Uva",      "Recupera 10 de vida.", 10, -1, -1, -1, 3, "uso", 12, 1]);
    add([spr_itens_invent_consumiveis, "Banana",   "Recupera 13 de vida.", 13, -1, -1, -1, 2, "uso", 15, 1]);
    add([spr_itens_invent_consumiveis, "Batata",   "Recupera 20 de vida.", 20, -1, -1, -1, 0, "uso", 20, 1]);
    add([spr_itens_invent_consumiveis, "Leite",    "Recupera 30 de vida.", 30, -1, -1, -1, 5, "uso", 35, 1]);
    add([spr_itens_invent_consumiveis, "Vitamina", "Recupera 50 de vida.", 50, -1, -1, -1, 4, "uso", 50, 1]);

    // --- ARMADURAS ---
    add([spr_itens_invent_passivo_armadura, "Cobertor",          "Proteção básica. Defesa +1",     -1, -1, 1, -1, 0, "armadura", 10,  1]);
    add([spr_itens_invent_passivo_armadura, "Armadura de Papelão","Proteção média. Defesa +2",      -1, -1, 2, -1, 1, "armadura", 20,  1]);
    add([spr_itens_invent_passivo_armadura, "Toalha Enrolada",   "Proteção confortável. Defesa +3",-1, -1, 3, -1, 2, "armadura", 30,  1]);
    add([spr_itens_invent_passivo_armadura, "Capa de Chuva",     "Resistente à água. Defesa +4",   -1, -1, 4, -1, 3, "armadura", 40,  1]);
    add([spr_itens_invent_passivo_armadura, "Casaco Almofadado", "Muito fofo. Defesa +5",           -1, -1, 5, -1, 4, "armadura", 50,  1]);
    add([spr_itens_invent_passivo_armadura, "Armadura de Travesseiro","Proteção suprema. Defesa +6",-1, -1, 6, -1, 5, "armadura", 60,  1]);
    add([spr_itens_invent_passivo_armadura, "Capa de Super-Herói","Sinta-se poderoso. Defesa +7",   -1, -1, 7, -1, 6, "armadura", 100, 1]);

    // --- ARMAS ---
    add([spr_itens_invent_passivo_armas, "Graveto",            "É só um graveto. Dano +2",       -1, 2, -1, -1, 0, "arma", 5,  1]);
    add([spr_itens_invent_passivo_armas, "Vassoura",           "Limpa o chão e inimigos. Dano +4",-1, 4, -1, -1, 1, "arma", 10, 1]);
    add([spr_itens_invent_passivo_armas, "Espada de Plástico", "Não corta muito. Dano +5",       -1, 5, -1, -1, 2, "arma", 15, 1]);
    add([spr_itens_invent_passivo_armas, "Espada de Madeira",  "Treinamento básico. Dano +7",    -1, 7, -1, -1, 3, "arma", 25, 1]);
    add([spr_itens_invent_passivo_armas, "Espada Dourada",     "Brilha muito. Dano +9",          -1, 9, -1, -1, 4, "arma", 50, 1]);
    add([spr_itens_invent_passivo_armas, "Mata-Fantasma",      "Especializada. Dano +9",         -1, 9, -1, -1, 5, "arma", 60, 1]);

    // --- BOTAS ---
    add([spr_itens_invent_passivo_pe, "Sapato Velho",       "Já viu dias melhores. Vel +1",   -1, -1, -1, 1, 0, "bota", 5,  1]);
    add([spr_itens_invent_passivo_pe, "Tênis Rasgado",      "Ainda serve. Vel +2",            -1, -1, -1, 2, 1, "bota", 10, 1]);
    add([spr_itens_invent_passivo_pe, "Meias Novas",        "Escorregam bem. Vel +3",         -1, -1, -1, 3, 6, "bota", 15, 1]);
    add([spr_itens_invent_passivo_pe, "Sapato Social",      "Elegância. Vel +4",              -1, -1, -1, 4, 5, "bota", 25, 1]);
    add([spr_itens_invent_passivo_pe, "Tênis de Corrida",   "Feito para correr. Vel +5",      -1, -1, -1, 5, 4, "bota", 30, 1]);
    add([spr_itens_invent_passivo_pe, "Skate",              "Radical! Vel +6",                -1, -1, -1, 6, 3, "bota", 40, 1]);
    add([spr_itens_invent_passivo_pe, "Patins",             "Velocidade máxima. Vel +7",      -1, -1, -1, 7, 2, "bota", 60, 1]);
}