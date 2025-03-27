
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
}

function criar_item_aleatorio_ativos(pos_x, pos_y, prof, raridade) {
    randomize();
    
    // 1. Controle de raridade global (chance de não dropar nada)
    var chance_nao_drop = raridade; // Raridade 1 = 1% chance de não dropar, 100 = 99% chance
    if (random(101) < chance_nao_drop) {
        return; // Não dropa nada
    }
    
    // 2. Sistema de pesos com raridade progressiva
    var itens = [
        // nome, descrição, sprite_ind, cura, ind, tipo, peso_base, quantidade_min, quantidade_max
        ["Maca", "Recupera 10 de vida", 1, 10, 1, "uso", 300, 1, 3],
        ["Uva", "Recupera 10 de vida", 3, 10, 3, "uso", 250, 1, 3],
        ["Banana", "Recupera 13 de vida", 2, 13, 2, "uso", 200, 1, 3],
        ["Batata", "Recupera 20 de vida", 0, 20, 0, "uso", 150, 1, 3],
        ["Leite", "Recupera 30 de vida", 5, 30, 5, "uso", 70, 1, 3],
        ["Vitamina", "Recupera 50 de vida", 4, 50, 4, "uso", 30, 1, 3]
    ];
    
    // Ajusta pesos baseado na raridade (itens de cura maior são mais afetados)
    var total_pesos = 0;
    for (var i = 0; i < array_length(itens); i++) {
        var fator = 1 + (raridade * i / 40); // Progressão mais suave para itens de cura
        itens[i][6] = round(itens[i][6] / fator); // Ajusta o peso
        total_pesos += itens[i][6];
    }
    
    // 3. Seleção do item
    var roll = irandom(total_pesos - 1);
    var acumulado = 0;
    var item_selecionado;
    
    for (var i = 0; i < array_length(itens); i++) {
        acumulado += itens[i][6];
        if (roll < acumulado) {
            item_selecionado = itens[i];
            break;
        }
    }
    
    // 4. Criação da instância (mantendo sua estrutura original)
    var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = spr_itens_invent_consumiveis;
    _inst.image_index = item_selecionado[2];
    _inst.nome = item_selecionado[0];
    _inst.descricao = item_selecionado[1];
    _inst.cura = item_selecionado[3];
    _inst.ind = item_selecionado[4];
    _inst.tipo = item_selecionado[5];
    _inst.quantidade = irandom_range(item_selecionado[7], item_selecionado[8]);
    _inst.depth = prof - 1;
    _inst.profundidade = prof - 1;
    
    // Valores fixos conforme seu original
    _inst.dano = 0;
    _inst.velocidade = 0;
    _inst.armadura = 0;
    _inst.sala_x = global.current_sala[0];
    _inst.sala_y = global.current_sala[1];
    _inst.pos_x = pos_x;
    _inst.pos_y = pos_y;
    
    salvar_item(_inst.sala_x, _inst.sala_y, pos_x, pos_y, _inst);
}


function criar_armadura_aleatoria(pos_x, pos_y, prof, raridade) {
    randomize();
    
    // 1. Controle de raridade global (chance de não dropar nada)
    var chance_nao_drop = raridade; // Raridade 1 = 1% chance de não dropar, 100 = 99% chance
    if (random(101) < chance_nao_drop) {
        return; // Não dropa nada
    }
    
    // 2. Sistema de pesos com raridade progressiva
    var itens = [
        // nome, descrição, sprite_ind, armadura, ind, tipo, peso_base
        ["Cobertor de Super-Herói", "Proteção básica. Armadura +1", 0, 1, 0, "armadura", 300],
        ["Armadura de Papelão", "Proteção média. Armadura +2", 1, 2, 1, "armadura", 250],
        ["Toalha Enrolada", "Proteção melhorada. Armadura +3", 2, 3, 2, "armadura", 200],
        ["Capa de Chuva", "Resistência. Armadura +4", 3, 4, 3, "armadura", 150],
        ["Casaco Almofadado", "Proteção alta. Armadura +5", 4, 5, 4, "armadura", 70],
        ["Armadura de Travesseiro", "Proteção excelente. Armadura +6", 5, 6, 5, "armadura", 20],
        ["Capa de Super-Herói", "Proteção máxima. Armadura +7", 6, 7, 6, "armadura", 10]
    ];
    
    // Ajusta pesos baseado na raridade (itens mais raros são mais afetados)
    var total_pesos = 0;
    for (var i = 0; i < array_length(itens); i++) {
        var fator = 1 + (raridade * i / 60); // Progressão balanceada para armaduras
        itens[i][6] = round(itens[i][6] / fator); // Ajusta o peso
        total_pesos += itens[i][6];
    }
    
    // 3. Seleção do item
    var roll = irandom(total_pesos - 1);
    var acumulado = 0;
    var item_selecionado;
    
    for (var i = 0; i < array_length(itens); i++) {
        acumulado += itens[i][6];
        if (roll < acumulado) {
            item_selecionado = itens[i];
            break;
        }
    }
    
    // 4. Criação da instância (mantendo sua estrutura original)
    var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = spr_itens_invent_passivo_armadura;
    _inst.image_index = item_selecionado[2];
    _inst.nome = item_selecionado[0];
    _inst.descricao = item_selecionado[1];
    _inst.armadura = item_selecionado[3];
    _inst.ind = item_selecionado[4];
    _inst.tipo = item_selecionado[5];
    _inst.depth = prof - 1;
    _inst.profundidade = prof - 1;
    
    // Valores fixos conforme seu original
    _inst.quantidade = 0;
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
    
    // 1. Controle de raridade global (chance de não dropar nada)
    var chance_nao_drop = raridade; // Raridade 1 = 1% chance de não dropar, 100 = 99% chance
    if (random(101) < chance_nao_drop) {
        return; // Não dropa nada
    }
    
    // 2. Sistema de pesos com raridade progressiva
    var itens = [
        // nome, descrição, sprite_ind, dano, ind, tipo, peso_base
        ["Graveto", "Um pequeno graveto. Dano +2", 0, 2, 0, "arma", 500],
        ["Vassoura", "Vassoura velha. Dano +4", 1, 4, 1, "arma", 300],
        ["Espada de plastico", "Espada de plástico. Dano +5", 2, 5, 2, "arma", 150],
        ["Espada de madeira", "Espada de madeira. Dano +7", 3, 7, 3, "arma", 40],
        ["Espada de ouro", "Espada de ouro. Dano +9", 4, 9, 4, "arma", 10],
        ["Espada mata Fantasma", "Mata fantasmas. Dano +9", 5, 9, 5, "arma", 10]
    ];
    
    // Ajusta pesos baseado na raridade (itens mais raros são mais afetados)
    var total_pesos = 0;
    for (var i = 0; i < array_length(itens); i++) {
        var fator = 1 + (raridade * i / 50); // Progressão mais acentuada para armas
        itens[i][6] = round(itens[i][6] / fator); // Ajusta o peso
        total_pesos += itens[i][6];
    }
    
    // 3. Seleção do item
    var roll = irandom(total_pesos - 1);
    var acumulado = 0;
    var item_selecionado;
    
    for (var i = 0; i < array_length(itens); i++) {
        acumulado += itens[i][6];
        if (roll < acumulado) {
            item_selecionado = itens[i];
            break;
        }
    }
    
    // 4. Criação da instância (mantendo sua estrutura original)
    var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = spr_itens_invent_passivo_armas;
    _inst.image_index = item_selecionado[2];
    _inst.nome = item_selecionado[0];
    _inst.descricao = item_selecionado[1];
    _inst.dano = item_selecionado[3];
    _inst.ind = item_selecionado[4];
    _inst.tipo = item_selecionado[5];
    _inst.depth = prof - 1;
    _inst.profundidade = prof - 1;
    
    // Valores fixos conforme seu original
    _inst.quantidade = 0;
    _inst.cura = 0;
    _inst.velocidade = 0;
    _inst.armadura = 0;
    _inst.sala_x = global.current_sala[0];
    _inst.sala_y = global.current_sala[1];
    _inst.pos_x = pos_x;
    _inst.pos_y = pos_y;
    
    salvar_item(_inst.sala_x, _inst.sala_y, pos_x, pos_y, _inst);
}

function criar_item_aleatorio_passivos_pe(pos_x, pos_y, prof, raridade) {
    randomize();
	var tanto_itens = 6;
    
    // 1. Controle de raridade global (chance de não dropar nada)
    var chance_nao_drop = raridade; // Raridade 1 = 1% chance de não dropar, 100 = 99% chance
    if (random(101) < chance_nao_drop) {
        return; // Não dropa nada
    }
    
    // 2. Sistema de pesos com raridade progressiva
    var itens = [
        // nome, descrição, sprite_ind, velocidade, ind, tipo, peso_base
        ["Sapato Velho", "Sapatos desgastados, mas úteis. Velocidade +1", 0, 1, 0, "bota", 300],
        ["Tenis Velho", "Tênis antigos mas confortáveis. Velocidade +2", 1, 2, 1, "bota", 250],
        ["Meia Vermelha Nova", "Meias novas com proteção. Velocidade +3", 6, 3, 6, "bota", 200],
        ["Sapato Novo", "Sapatos elegantes. Velocidade +4", 5, 4, 5, "bota", 150],
        ["Tenis Novo", "Tênis brilhantes. Velocidade +5", 4, 5, 4, "bota", 70],
        ["Skate", "Aumenta adrenalina. Velocidade +6", 3, 6, 3, "bota", 20],
        ["Patins", "Máxima velocidade. Velocidade +7", 2, 7, 2, "bota", 10]
    ];
    
    // Ajusta pesos baseado na raridade (itens mais raros são mais afetados)
    var total_pesos = 0;
    for (var i = 0; i < array_length(itens); i++) {
        var fator = 1 + (raridade * i / 100); // Progressão por índice
        itens[i][tanto_itens] = round(itens[i][tanto_itens] / fator); // Ajusta o peso
        total_pesos += itens[i][tanto_itens];
    }
    
    // 3. Seleção do item
    var roll = irandom(total_pesos - 1);
    var acumulado = 0;
    var item_selecionado;
    
    for (var i = 0; i < array_length(itens); i++) {
        acumulado += itens[i][tanto_itens];
        if (roll < acumulado) {
            item_selecionado = itens[i];
            break;
        }
    }
    
    // 4. Criação da instância (mantendo sua estrutura original)
    var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = spr_itens_invent_passivo_pe;
    _inst.image_index = item_selecionado[2];
    _inst.nome = item_selecionado[0];
    _inst.descricao = item_selecionado[1];
    _inst.velocidade = item_selecionado[3];
    _inst.ind = item_selecionado[4];
    _inst.tipo = item_selecionado[5];
    _inst.depth = prof - 1;
    _inst.profundidade = prof - 1;
    
    // Valores fixos conforme seu original
    _inst.quantidade = 0;
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
		item.profundidade
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
        }
    }
}


#endregion

