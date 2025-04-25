

function adicionar_item_invent() {
    ///@arg Item
    ///@arg Quantidade
    ///@arg Sprite
    ///@arg nome
    ///@arg descricao
    ///@arg sala_x
    ///@arg sala_y
    ///@arg pos_x
    ///@arg pos_y
    ///@arg dano
    ///@arg armadura
    ///@arg velocidade
    ///@arg cura
    ///@arg tipo
    ///@arg ind
	///@arg preco
    
	var _grid = global.grid_itens;
    var _item = argument[0];
    var _quantidade = argument[1];
    var _sprite = argument[2];
    var _nome = argument[3];
    var _descricao = argument[4];
    var _dano = argument[9];
    var _armadura = argument[10];
    var _velocidade = argument[11];
    var _cura = argument[12];
    var _tipo = argument[13];
    var _ind = argument[14];
    var _preco = argument_count > 1 ? argument[15] : 0; // Correção aqui
    
    var _check = -1;
    var _empty_slot = -1;
    
    // Verificar se o item já existe no inventário
    for (var i = 0; i < ds_grid_height(_grid); i++) {
        if (_grid[# Infos.item, i] == _item && _grid[# Infos.sprite, i] == _sprite) {
            // Se o item já existir no inventário, somar a quantidade
            _grid[# Infos.quantidade, i] += _quantidade;
            return; // Item já atualizado, não precisa continuar
        }
        // Encontrar o primeiro slot vazio
        if (_grid[# Infos.item, i] == -1 && _empty_slot == -1) {
            _empty_slot = i;
        }
    }
    
    // Se o inventário estiver cheio e não houver slot vazio
    if (_empty_slot == -1) {
        global.inventario_cheio = true; // Ativar mensagem de inventário cheio
        return;
    }
    
    // Adicionar o novo item no slot vazio encontrado
    _grid[# Infos.item, _empty_slot] = _item;
    _grid[# Infos.quantidade, _empty_slot] = _quantidade;
    _grid[# Infos.sprite, _empty_slot] = _sprite;
    _grid[# Infos.nome, _empty_slot] = _nome;
    _grid[# Infos.descricao, _empty_slot] = _descricao;
    _grid[# Infos.dano, _empty_slot] = _dano;
    _grid[# Infos.armadura, _empty_slot] = _armadura;
    _grid[# Infos.velocidade, _empty_slot] = _velocidade;
    _grid[# Infos.cura, _empty_slot] = _cura;
    _grid[# Infos.tipo, _empty_slot] = _tipo;
    _grid[# Infos.image_ind, _empty_slot] = _ind;
	_grid[# Infos.preco, _empty_slot] = _preco;
}
function comprar_item_loja(_slot_index) {
    var _grid = inventario_venda;

    // Verifica se o slot é válido
    if (_slot_index < 0 || _slot_index >= ds_grid_height(_grid)) return;

    // Verifica se há um item no slot
    if (_grid[# Infos.item, _slot_index] == -1) return;

    var preco = _grid[# Infos.preco, _slot_index];

    // Verifica se o jogador tem moedas suficientes
    if (global.moedas < preco) {
        show_debug_message("Moedas insuficientes!");
        return;
    }

    // Subtrai o preço das moedas do jogador
    global.moedas -= preco;

    // Adiciona o item ao inventário do jogador
    adicionar_item_invent(
        _grid[# Infos.item, _slot_index],
        1, // Quantidade
        _grid[# Infos.sprite, _slot_index],
        _grid[# Infos.nome, _slot_index],
        _grid[# Infos.descricao, _slot_index],
        -1, -1, -1, -1, // Sala/posição (opcional, ignorado)
        _grid[# Infos.dano, _slot_index],
        _grid[# Infos.armadura, _slot_index],
        _grid[# Infos.velocidade, _slot_index],
        _grid[# Infos.cura, _slot_index],
        _grid[# Infos.tipo, _slot_index],
        _grid[# Infos.image_ind, _slot_index],
        _grid[# Infos.preco, _slot_index]
    );

    // Apaga o item comprado do inventário do vendedor
    _grid[# Infos.item, _slot_index] = -1;
    _grid[# Infos.quantidade, _slot_index] = 0;
    _grid[# Infos.sprite, _slot_index] = -1;
    _grid[# Infos.nome, _slot_index] = "";
    _grid[# Infos.descricao, _slot_index] = "";
    _grid[# Infos.dano, _slot_index] = 0;
    _grid[# Infos.armadura, _slot_index] = 0;
    _grid[# Infos.velocidade, _slot_index] = 0;
    _grid[# Infos.cura, _slot_index] = 0;
    _grid[# Infos.tipo, _slot_index] = -1;
    _grid[# Infos.image_ind, _slot_index] = 0;
    _grid[# Infos.preco, _slot_index] = 0;

    // Limpa seleção do slot
    global.item_selecionado_venda = -1;

}


function criar_item_aleatorio_ativos(pos_x, pos_y, prof, raridade) {
    randomize();

    // 1. Chance de não dropar nada
    var chance_nao_drop = raridade;
    if (random(101) < chance_nao_drop) {
        return; // Não dropa nada
    }

    // 2. Filtra os itens do tipo "uso" e calcula pesos
    var lista_uso = ds_list_create();
    var total_peso = 0;

    for (var i = 0; i < ds_list_size(global.lista_itens); i++) {
        var item = global.lista_itens[| i];
        if (item[8] == "uso") { // Tipo está na posição 8
            var peso = 100 - (i * 5); // Itens mais raros no final da lista têm menor peso
            ds_list_add(lista_uso, [item, peso]);
            total_peso += peso;
        }
    }

    // 3. Escolhe o item com base no peso
    if (total_peso <= 0) {
        ds_list_destroy(lista_uso);
        return;
    }

    var roll = irandom(total_peso - 1);
    var acumulado = 0;
    var item_selecionado;

    for (var i = 0; i < ds_list_size(lista_uso); i++) {
        var entry = lista_uso[| i];
        acumulado += entry[1];
        if (roll < acumulado) {
            item_selecionado = entry[0];
            break;
        }
    }

    ds_list_destroy(lista_uso);

    // 4. Cria o item na instância
    var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = item_selecionado[0];
    _inst.image_index = item_selecionado[7]; // image_ind está na posição 7
    _inst.nome = item_selecionado[1]; // nome na posição 0
    _inst.descricao = item_selecionado[2]; // descrição na posição 1
    _inst.cura = item_selecionado[3]; // cura na posição 3
    _inst.dano = 0;
    _inst.armadura = 0;
    _inst.velocidade = 0;
    _inst.ind = item_selecionado[7]; // image_ind na posição 7
    _inst.tipo = item_selecionado[8]; // tipo na posição 8
    _inst.preco = item_selecionado[9]; // preco na posição 9

	_inst.quantidade = item_selecionado[10];

    _inst.sala_x = global.current_sala[0];
    _inst.sala_y = global.current_sala[1];
    _inst.pos_x = pos_x;
    _inst.pos_y = pos_y;

    salvar_item(_inst.sala_x, _inst.sala_y, pos_x, pos_y, _inst);
}

function criar_item_aleatorio_passivos_armadura(pos_x, pos_y, prof, raridade) {
    randomize();

    var chance_nao_drop = raridade;
    if (random(101) < chance_nao_drop) return;

    var lista_armaduras = ds_list_create();
    var total_peso = 0;

    for (var i = 0; i < ds_list_size(global.lista_itens); i++) {
        var item = global.lista_itens[| i];
        if (item[8] == "armadura") { // Tipo na posição 8
            var peso = 100 - (i * 5); // Itens mais raros têm menor peso
            ds_list_add(lista_armaduras, [item, peso]);
            total_peso += peso;
        }
    }

    if (total_peso <= 0) {
        ds_list_destroy(lista_armaduras);
        return;
    }

    var roll = irandom(total_peso - 1);
    var acumulado = 0;
    var item_selecionado;

    for (var i = 0; i < ds_list_size(lista_armaduras); i++) {
        var entry = lista_armaduras[| i];
        acumulado += entry[1];
        if (roll < acumulado) {
            item_selecionado = entry[0];
            break;
        }
    }

    ds_list_destroy(lista_armaduras);

    var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = item_selecionado[0];
    _inst.image_index = item_selecionado[7]; // image_ind
    _inst.nome = item_selecionado[1]; // nome
    _inst.descricao = item_selecionado[2]; // descrição
    _inst.armadura = item_selecionado[5]; // armadura na posição 5
    _inst.ind = item_selecionado[7]; // image_ind
    _inst.tipo = item_selecionado[8]; // tipo
    _inst.preco = item_selecionado[9]; // preco

    _inst.depth = prof - 1;
    _inst.profundidade = prof - 1;

    _inst.quantidade = item_selecionado[10];
    _inst.dano = 0;
    _inst.cura = 0;
    _inst.velocidade = 0;
    _inst.sala_x = global.current_sala[0];
    _inst.sala_y = global.current_sala[1];
    _inst.pos_x = pos_x;
    _inst.pos_y = pos_y;

    salvar_item(_inst.sala_x, _inst.sala_y, pos_x, pos_y, _inst);
}

function criar_item_aleatorio_passivos_arma(pos_x, pos_y, prof, raridade) {
    randomize();

    var chance_nao_drop = raridade;
    if (random(101) < chance_nao_drop) return;

    var lista_armas = ds_list_create();
    var total_peso = 0;

    for (var i = 0; i < ds_list_size(global.lista_itens); i++) {
        var item = global.lista_itens[| i];
        if (item[8] == "arma") { // Tipo na posição 8
            var peso = 100 - (i * 5); // Itens mais raros têm menor peso
            ds_list_add(lista_armas, [item, peso]);
            total_peso += peso;
        }
    }

    if (total_peso <= 0) {
        ds_list_destroy(lista_armas);
        return;
    }

    var roll = irandom(total_peso - 1);
    var acumulado = 0;
    var item_selecionado;

    for (var i = 0; i < ds_list_size(lista_armas); i++) {
        var entry = lista_armas[| i];
        acumulado += entry[1];
        if (roll < acumulado) {
            item_selecionado = entry[0];
            break;
        }
    }

    ds_list_destroy(lista_armas);

    var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = item_selecionado[0];
    _inst.image_index = item_selecionado[7]; // image_ind
    _inst.nome = item_selecionado[1]; // nome
    _inst.descricao = item_selecionado[2]; // descrição
    _inst.dano = item_selecionado[4]; // dano na posição 4
    _inst.ind = item_selecionado[7]; // image_ind
    _inst.tipo = item_selecionado[8]; // tipo
    _inst.preco = item_selecionado[9]; // preco

    _inst.depth = prof - 1;
    _inst.profundidade = prof - 1;

    _inst.quantidade = item_selecionado[10];
    _inst.armadura = 0;
    _inst.cura = 0;
    _inst.velocidade = 0;
    _inst.sala_x = global.current_sala[0];
    _inst.sala_y = global.current_sala[1];
    _inst.pos_x = pos_x;
    _inst.pos_y = pos_y;

    salvar_item(_inst.sala_x, _inst.sala_y, pos_x, pos_y, _inst);
}

function criar_item_aleatorio_passivos_pe(pos_x, pos_y, prof, raridade) {
    randomize();

    var chance_nao_drop = raridade;
    if (random(101) < chance_nao_drop) return;

    var lista_botas = ds_list_create();
    var total_peso = 0;

    for (var i = 0; i < ds_list_size(global.lista_itens); i++) {
        var item = global.lista_itens[| i];
        if (item[8] == "bota") { // Tipo na posição 8
            var peso = 100 - (i * 5); // Itens mais raros têm menor peso
            ds_list_add(lista_botas, [item, peso]);
            total_peso += peso;
        }
    }

    if (total_peso <= 0) {
        ds_list_destroy(lista_botas);
        return;
    }

    var roll = irandom(total_peso - 1);
    var acumulado = 0;
    var item_selecionado;

    for (var i = 0; i < ds_list_size(lista_botas); i++) {
        var entry = lista_botas[| i];
        acumulado += entry[1];
        if (roll < acumulado) {
            item_selecionado = entry[0];
            break;
        }
    }

    ds_list_destroy(lista_botas);

    var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = item_selecionado[0];
    _inst.image_index = item_selecionado[7]; // image_ind
    _inst.nome = item_selecionado[1]; // nome
    _inst.descricao = item_selecionado[2]; // descrição
    _inst.velocidade = item_selecionado[6]; // velocidade na posição 6
    _inst.ind = item_selecionado[7]; // image_ind
    _inst.tipo = item_selecionado[8]; // tipo
    _inst.preco = item_selecionado[9]; // preco

    _inst.depth = prof - 1;
    _inst.profundidade = prof - 1;

    _inst.quantidade = item_selecionado[10];
    _inst.dano = 0;
    _inst.cura = 0;
    _inst.armadura = 0;
    _inst.sala_x = global.current_sala[0];
    _inst.sala_y = global.current_sala[1];
    _inst.pos_x = pos_x;
    _inst.pos_y = pos_y;

    salvar_item(_inst.sala_x, _inst.sala_y, pos_x, pos_y, _inst);
}




#region item
function coletar_item(item_x, item_y, current_sala) {
    // Gerar o ID único para a sala atual
    var sala_id = string(current_sala[0]) + "_" + string(current_sala[1]);

    // Verificar se a sala tem itens salvos
    if (ds_map_exists(global.sala_com_item_drop, sala_id)) {
        var lista_itens = ds_map_find_value(global.sala_com_item_drop, sala_id);

        // Procurar o item coletado na lista e removê-lo
        for (var i = 0; i < ds_list_size(lista_itens); i++) {
            var item_info = ds_list_find_value(lista_itens, i);
            if (item_info[0] == item_x && item_info[1] == item_y) {
                ds_list_delete(lista_itens, i); // Remover o item da lista
                break;
            }
        }
        
        // Atualizar o mapa global com a lista modificada
        ds_map_replace(global.sala_com_item_drop, sala_id, lista_itens);
    }


}
function salvar_item(sala_atual_x, sala_atual_y, _item_x, _item_y, item) {
    var sala_id = string(sala_atual_x) + "_" + string(sala_atual_y); 
    var lista_itens;
    
    // Verificar se já existe uma lista de itens para esta sala
    if (ds_map_exists(global.sala_com_item_drop, sala_id)) {
        lista_itens = ds_map_find_value(global.sala_com_item_drop, sala_id);
    } else {
        lista_itens = ds_list_create(); 
    }
    
    // Adicionar o item à lista com todas as informações
    var item_info = [
        _item_x, 
        _item_y, 
        item.sprite_index, 
        item.image_index, 
        item.quantidade, 
        item.nome, 
        item.descricao,
        item.dano, 
        item.armadura, 
        item.velocidade, 
        item.cura, 
        item.tipo, 
        item.ind, 
        item.sala_x, 
        item.sala_y, 
        item.pos_x, 
        item.pos_y,
		item.profundidade,
		item.preco,
    ];
    ds_list_add(lista_itens, item_info);
    
    // Armazenar a lista atualizada no mapa global
    ds_map_replace(global.sala_com_item_drop, sala_id, lista_itens);
}




function recriar_item_dropado(current_sala_x, current_sala_y) {
    var sala_id = string(current_sala_x) + "_" + string(current_sala_y);

    // Verificar se a sala atual tem itens salvos
    if (ds_map_exists(global.sala_com_item_drop, sala_id)) {
        var lista_itens = ds_map_find_value(global.sala_com_item_drop, sala_id);

        // Recriar os itens nas posições salvas
        for (var i = 0; i < ds_list_size(lista_itens); i++) {
            var item_info = ds_list_find_value(lista_itens, i);
            var ponto_x = item_info[0];
            var ponto_y = item_info[1];
            var sprite_index_ = item_info[2];
            var image_index_ = item_info[3];
            var quantidade = item_info[4];
            var nome = item_info[5];
            var descricao = item_info[6];
            var dano = item_info[7];
            var armadura = item_info[8];
            var velocidade = item_info[9];
            var cura = item_info[10];
            var tipo = item_info[11];
            var ind = item_info[12];
            var sala_x = item_info[13];
            var sala_y = item_info[14];
            var pos_x = item_info[15];
            var pos_y = item_info[16];
			var prof = item_info[17];
			var preco = item_info[18];


            // Criar a instância do item na sala
            var _inst = instance_create_layer(ponto_x, ponto_y, "instances", obj_item);
            _inst.sprite_index = sprite_index_;
            _inst.image_index = image_index_;
            _inst.quantidade = quantidade;
            _inst.nome = nome;
            _inst.descricao = descricao;
            _inst.dano = dano;
            _inst.armadura = armadura;
            _inst.velocidade = velocidade;
            _inst.cura = cura;
            _inst.tipo = tipo;
            _inst.ind = ind;
            _inst.sala_x = sala_x;
            _inst.sala_y = sala_y;
            _inst.pos_x = pos_x;
            _inst.pos_y = pos_y;
			_inst.depth = prof -1;
			_inst.prof = prof -1;
			_inst.preco = preco;
        }
    }
}


#endregion



function criar_lista_itens_padronizados() {
    global.lista_itens = ds_list_create();

    // --- ITENS DE USO ---
    var uso = [
        // [sprite, nome, descrição, cura, dano, armadura, velocidade, id, tipo, preco, quantidade]
        [spr_itens_invent_consumiveis, "Maca", "Recupera 10 de vida",         10, -1, -1, -1, 1, "uso",  10, 1],
        [spr_itens_invent_consumiveis, "Uva", "Recupera 10 de vida",          10, -1, -1, -1, 3, "uso",  12, 1],
        [spr_itens_invent_consumiveis, "Banana", "Recupera 13 de vida",       13, -1, -1, -1, 2, "uso",  15, 1],
        [spr_itens_invent_consumiveis, "Batata", "Recupera 20 de vida",       20, -1, -1, -1, 0, "uso",  20, 1],
        [spr_itens_invent_consumiveis, "Leite", "Recupera 30 de vida",        30, -1, -1, -1, 5, "uso",  35, 1],
        [spr_itens_invent_consumiveis, "Vitamina", "Recupera 50 de vida",     50, -1, -1, -1, 4, "uso",  50, 1]
    ];

    // --- ARMADURAS ---
    var armaduras = [
        // [sprite, nome, descrição, cura, dano, armadura, velocidade, id, tipo, preco, quantidade]
        [spr_itens_invent_passivo_armadura, "Cobertor de Super-Herói", "Proteção básica. Armadura +1",        -1, -1, 1, -1, 0, "armadura",  10, 1],
        [spr_itens_invent_passivo_armadura, "Armadura de Papelão", "Proteção média. Armadura +2",             -1, -1, 2, -1, 1, "armadura",  20, 1],
        [spr_itens_invent_passivo_armadura, "Toalha Enrolada", "Proteção melhorada. Armadura +3",             -1, -1, 3, -1, 2, "armadura",  30, 1],
        [spr_itens_invent_passivo_armadura, "Capa de Chuva", "Resistência. Armadura +4",                      -1, -1, 4, -1, 3, "armadura",  40, 1],
        [spr_itens_invent_passivo_armadura, "Casaco Almofadado", "Proteção alta. Armadura +5",                -1, -1, 5, -1, 4, "armadura",  50, 1],
        [spr_itens_invent_passivo_armadura, "Armadura de Travesseiro", "Proteção excelente. Armadura +6",     -1, -1, 6, -1, 5, "armadura",  60, 1],
        [spr_itens_invent_passivo_armadura, "Capa de Super-Herói", "Proteção máxima. Armadura +7",            -1, -1, 7, -1, 6, "armadura",  100, 1]
    ];

    // --- ARMAS ---
    var armas = [
        // [sprite, nome, descrição, cura, dano, armadura, velocidade, id, tipo, preco, quantidade]
        [spr_itens_invent_passivo_armas, "Graveto", "Um pequeno graveto. Dano +2",             -1, 2, -1, -1, 0, "arma",  5, 1],
        [spr_itens_invent_passivo_armas, "Vassoura", "Vassoura velha. Dano +4",                -1, 4, -1, -1, 1, "arma",  10, 1],
        [spr_itens_invent_passivo_armas, "Espada de plástico", "Espada de plástico. Dano +5",  -1, 5, -1, -1, 2, "arma",  15, 1],
        [spr_itens_invent_passivo_armas, "Espada de madeira", "Espada de madeira. Dano +7",    -1, 7, -1, -1, 3, "arma",  25, 1],
        [spr_itens_invent_passivo_armas, "Espada de ouro", "Espada de ouro. Dano +9",          -1, 9, -1, -1, 4, "arma",  50, 1],
        [spr_itens_invent_passivo_armas, "Espada mata Fantasma", "Mata fantasmas. Dano +9",    -1, 9, -1, -1, 5, "arma",  60, 1]
    ];

    // --- BOTAS ---
    var botas = [
        // [sprite, nome, descrição, cura, dano, armadura, velocidade, id, tipo, preco, quantidade]
        [spr_itens_invent_passivo_pe, "Sapato Velho", "Sapatos desgastados. Velocidade +1",        -1, -1, -1, 1, 0, "bota",  5, 1],
        [spr_itens_invent_passivo_pe, "Tenis Velho", "Tênis antigos. Velocidade +2",               -1, -1, -1, 2, 1, "bota",  10, 1],
        [spr_itens_invent_passivo_pe, "Meia Vermelha Nova", "Meias novas. Velocidade +3",          -1, -1, -1, 3, 6, "bota",  15, 1],
        [spr_itens_invent_passivo_pe, "Sapato Novo", "Sapatos elegantes. Velocidade +4",           -1, -1, -1, 4, 5, "bota",  25, 1],
        [spr_itens_invent_passivo_pe, "Tenis Novo", "Tênis brilhantes. Velocidade +5",             -1, -1, -1, 5, 4, "bota",  30, 1],
        [spr_itens_invent_passivo_pe, "Skate", "Aumenta adrenalina. Velocidade +6",                -1, -1, -1, 6, 3, "bota",  40, 1],
        [spr_itens_invent_passivo_pe, "Patins", "Máxima velocidade. Velocidade +7",                -1, -1, -1, 7, 2, "bota",  60, 1]
    ];

    // --- Adiciona todos os itens à lista global ---
    for (var i = 0; i < array_length(uso); i++) ds_list_add(global.lista_itens, uso[i]);
    for (var i = 0; i < array_length(armaduras); i++) ds_list_add(global.lista_itens, armaduras[i]);
    for (var i = 0; i < array_length(armas); i++) ds_list_add(global.lista_itens, armas[i]);
    for (var i = 0; i < array_length(botas); i++) ds_list_add(global.lista_itens, botas[i]);
}