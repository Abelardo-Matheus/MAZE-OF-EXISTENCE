
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

function criar_item_aleatorio_ativos(pos_x, pos_y, prof) {
    randomize();

    var item_nome,drop, ind, item_descricao, item_sprite, item_quantidade, sprite_ind, dano, armadura, velocidade, cura, tipo;
    cura = 0;
    velocidade = 0;
    dano = 0;
    armadura = 0;
    tipo = 0;
	drop = true;

    // Gera um número aleatório entre 0 e 1000
    var item_index = irandom(1000);

    // Definir item com base na cura e probabilidade
    if (item_index <= 300) { // 30% de chance - cura baixa
        item_nome = "Maçã";
        item_descricao = "Uma maçã suculenta, deliciosa e crocante. Ideal para um lanche rápido e saudável.";
        item_sprite = spr_itens_invent_consumiveis;
        item_quantidade = irandom_range(1, 3);
        sprite_ind = 1;
        cura = 10;
        ind = 1;
        tipo = "uso";
    } else if (item_index > 300 && item_index <= 550) { // 25% de chance - cura baixa
        item_nome = "Uva";
        item_descricao = "Um cacho de uvas doces, pequenas e cheias de sabor. Uma explosão de doçura a cada mordida.";
        item_sprite = spr_itens_invent_consumiveis;
        item_quantidade = irandom_range(1, 3);
        sprite_ind = 3;
        cura = 10;
        ind = 3;
        tipo = "uso";
    } else if (item_index > 550 && item_index <= 750) { // 20% de chance - cura média
        item_nome = "Banana";
        item_descricao = "Uma banana fresca, carregada de potássio. Perfeita para recarregar suas energias!";
        item_sprite = spr_itens_invent_consumiveis;
        item_quantidade = irandom_range(1, 3);
        sprite_ind = 2;
        cura = 10;
        ind = 2;
        tipo = "uso";
    } else if (item_index > 750 && item_index <= 900) { // 15% de chance - cura média
        item_nome = "Batata";
        item_descricao = "Uma batata robusta, pronta para ser cozida ou assada. A fonte perfeita de energia natural.";
        item_sprite = spr_itens_invent_consumiveis;
        item_quantidade = irandom_range(1, 3);
        sprite_ind = 0;
        cura = 20;
        ind = 0;
        tipo = "uso";
    } else if (item_index > 900 && item_index <= 970) { // 7% de chance - cura alta
        item_nome = "Leite";
        item_descricao = "Um copo de leite fresco e nutritivo, perfeito para fortalecer seus ossos e garantir um dia saudável.";
        item_sprite = spr_itens_invent_consumiveis;
        item_quantidade = irandom_range(1, 3);
        sprite_ind = 5;
        cura = 30;
        ind = 5;
        tipo = "uso";
    } else if (item_index > 970 && item_index <= 1000) { // 3% de chance - cura muito alta
        item_nome = "Vitamina";
        item_descricao = "Uma dose poderosa de vitaminas, embalada em uma pequena pílula. Essencial para manter sua vitalidade.";
        item_sprite = spr_itens_invent_consumiveis;
        item_quantidade = irandom_range(1, 3);
        sprite_ind = 4;
        cura = 50;
        ind = 4;
        tipo = "uso";
    }else if (item_index > 1100 && item_index <= 2000) { // 1% de chance
		drop = false;
	}

  if (drop == true) {
      var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = item_sprite;
    _inst.quantidade = item_quantidade;
    _inst.nome = item_nome;
    _inst.descricao = item_descricao;
    _inst.sala_x = global.current_sala[0];
    _inst.sala_y = global.current_sala[1];
    _inst.pos_x = pos_x;
    _inst.pos_y = pos_y;
    _inst.image_index = sprite_ind;
    _inst.dano = dano;
    _inst.cura = cura;
    _inst.velocidade = velocidade;
    _inst.armadura = armadura;
    _inst.ind = ind;
    _inst.tipo = tipo;
    _inst.depth = prof - 1;
    _inst.profundidade = prof - 1;
    salvar_item(_inst.sala_x, _inst.sala_y, pos_x, pos_y, _inst);// code here
  }
}


function criar_armadura_aleatoria(pos_x, pos_y, prof) {
    randomize();

    var item_nome,drop, item_descricao, item_sprite, item_quantidade, sprite_ind, dano, armadura, velocidade, cura, ind, tipo;
    cura = 0;
    velocidade = 0;
    dano = 0;
    armadura = 0;
    tipo = "";
	drop = true;

    // Gera um número aleatório entre 0 e 1000
    var item_index = irandom(1000);

    // Definir item com base no índice e probabilidades
    if (item_index <= 300) { // 30% de chance - menor armadura
        item_nome = "Cobertor de Super-Herói";
        item_descricao = "Um cobertor velho com estampa de super-herói. Não protege muito, mas traz conforto.";
        item_sprite = spr_itens_invent_passivo_armadura;
        item_quantidade = 0;
        sprite_ind = 0;
        armadura = 1;
        tipo = "armadura";
        ind = 0;
    } else if (item_index > 300 && item_index <= 550) { // 25% de chance - armadura média
        item_nome = "Armadura de Papelão";
        item_descricao = "Caixas de papelão cortadas e pintadas. Oferece um pouco mais de proteção do que parece.";
        item_sprite = spr_itens_invent_passivo_armadura;
        item_quantidade = 0;
        sprite_ind = 1;
        armadura = 2;
        tipo = "armadura";
        ind = 1;
    } else if (item_index > 550 && item_index <= 750) { // 20% de chance - armadura maior
        item_nome = "Toalha Enrolada";
        item_descricao = "Uma toalha enrolada como um manto. Ideal para proteger-se contra monstros imaginários.";
        item_sprite = spr_itens_invent_passivo_armadura;
        item_quantidade = 0;
        sprite_ind = 2;
        armadura = 3;
        tipo = "armadura";
        ind = 2;
    } else if (item_index > 750 && item_index <= 900) { // 15% de chance - mais resistência
        item_nome = "Capa de Chuva";
        item_descricao = "Uma capa de chuva velha. Não oferece muita defesa física, mas é resistente à lama.";
        item_sprite = spr_itens_invent_passivo_armadura;
        item_quantidade = 0;
        sprite_ind = 3;
        armadura = 4;
        tipo = "armadura";
        ind = 3;
    } else if (item_index > 900 && item_index <= 970) { // 7% de chance - proteção alta
        item_nome = "Casaco Almofadado";
        item_descricao = "Um casaco acolchoado, perfeito para afastar o frio e proteger contra golpes leves.";
        item_sprite = spr_itens_invent_passivo_armadura;
        item_quantidade = 0;
        sprite_ind = 4;
        armadura = 5;
        tipo = "armadura";
        ind = 4;
    } else if (item_index > 970 && item_index <= 990) { // 2% de chance - armadura bem resistente
        item_nome = "Armadura de Travesseiro";
        item_descricao = "Feita com travesseiros amarrados, essa armadura improvisada é mais útil do que parece.";
        item_sprite = spr_itens_invent_passivo_armadura;
        item_quantidade = 0;
        sprite_ind = 5;
        armadura = 6;
        tipo = "armadura";
        ind = 5;
    } else if (item_index > 990) { // 1% de chance - armadura lendária
        item_nome = "Capa de Super-Herói";
        item_descricao = "Uma capa que te faz sentir invencível. Proteção máxima contra todos os inimigos imaginários.";
        item_sprite = spr_itens_invent_passivo_armadura;
        item_quantidade = 0;
        sprite_ind = 6;
        armadura = 7;
        tipo = "armadura";
        ind = 6;
    }else if (item_index > 1100 && item_index <= 2000) { // 1% de chance
		drop = false;
	}

  if (drop == true) {
      var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = item_sprite;
    _inst.quantidade = item_quantidade;
    _inst.nome = item_nome;
    _inst.descricao = item_descricao;
    _inst.sala_x = global.current_sala[0];
    _inst.sala_y = global.current_sala[1];
    _inst.pos_x = pos_x;
    _inst.pos_y = pos_y;
    _inst.image_index = sprite_ind;
    _inst.dano = dano;
    _inst.cura = cura;
    _inst.velocidade = velocidade;
    _inst.armadura = armadura;
    _inst.ind = ind;
    _inst.tipo = tipo;
    _inst.depth = prof - 1;
    _inst.profundidade = prof - 1;
    salvar_item(_inst.sala_x, _inst.sala_y, pos_x, pos_y, _inst);// code here
  }
}



function criar_item_aleatorio_passivos_arma(pos_x, pos_y, prof) {
    randomize();

    var item_nome, item_descricao, item_sprite, item_quantidade, sprite_ind, dano, armadura, velocidade,drop, cura, ind, tipo;
    cura = 0;
    velocidade = 0;
    dano = 0;
    armadura = 0;
    tipo = "";
	drop = true;

    // Gera um número aleatório entre 0 e 1000
    var item_index = irandom_range(0, 2000);

    // Definir item com base no índice e probabilidades
    if (item_index <= 500) { // 50% de chance
        item_nome = "Graveto";
        item_descricao = "Um pequeno graveto.";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 0;
        sprite_ind = 0;
        dano = 2;
        tipo = "arma";
        ind = 0;
    } else if (item_index > 500 && item_index <= 800) { // 30% de chance
        item_nome = "Vassoura";
        item_descricao = "Uma vassoura velha.";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 0;
        sprite_ind = 1;
        dano = 4;
        tipo = "arma";
        ind = 1;
    } else if (item_index > 800 && item_index <= 950) { // 15% de chance
        item_nome = "Espada de plástico";
        item_descricao = "Uma espada de plástico.";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 0;
        sprite_ind = 2;
        dano = 5;
        tipo = "arma";
        ind = 2;
    } else if (item_index > 950 && item_index <= 990) { // 4% de chance
        item_nome = "Espada de madeira";
        item_descricao = "Uma espada de madeira.";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 0;
        sprite_ind = 3;
        dano = 7;
        tipo = "arma";
        ind = 3;
    } else if (item_index > 990 && item_index <= 1000) { // 1% de chance
        item_nome = "Espada de ouro";
        item_descricao = "Uma espada de ouro brilhante.";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 0;
        sprite_ind = 4;
        dano = 9;
        tipo = "arma";
        ind = 4;
    }
	 else if (item_index > 1000 && item_index <= 1100) { 
        item_nome = "Espada mata Fantasma";
        item_descricao = "Uma espada que lhe da o poder de matar fantasmas.";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 0;
        sprite_ind = 4;
        dano = 9;
        tipo = "arma";
        ind = 4;
    } else if (item_index > 1100 && item_index <= 1200) { 
        item_nome = "Arco de brinquedo";
        item_descricao = "Um arco simples para atirar de longe.";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 0;
        sprite_ind = 4;
        dano = 9;
        tipo = "arco";
        ind = 4;
    } else if (item_index > 1200 && item_index <= 2000) { 
		drop = false;
	}

  if (drop == true) {
      var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = item_sprite;
    _inst.quantidade = item_quantidade;
    _inst.nome = item_nome;
    _inst.descricao = item_descricao;
    _inst.sala_x = global.current_sala[0];
    _inst.sala_y = global.current_sala[1];
    _inst.pos_x = pos_x;
    _inst.pos_y = pos_y;
    _inst.image_index = sprite_ind;
    _inst.dano = dano;
    _inst.cura = cura;
    _inst.velocidade = velocidade;
    _inst.armadura = armadura;
    _inst.ind = ind;
    _inst.tipo = tipo;
    _inst.depth = prof - 1;
    _inst.profundidade = prof - 1;
    salvar_item(_inst.sala_x, _inst.sala_y, pos_x, pos_y, _inst);// code here
  }
   
}

function criar_item_aleatorio_passivos_pe(pos_x, pos_y, prof) {
    randomize();

    var item_nome,drop, item_descricao, item_sprite, item_quantidade, sprite_ind, dano, armadura, velocidade, cura, ind, tipo;
    cura = 0;
    velocidade = 0;
    dano = 0;
    armadura = 0;
    tipo = 0;
	drop = true;

    var item_index = irandom(1000);

    // Itens baseados na probabilidade de velocidade
    if (item_index <= 300) { // 30% de chance - baixa velocidade
        item_nome = "Sapato Velho";
        item_descricao = "Sapatos desgastados, porém ainda úteis. Oferece uma pequena melhoria de velocidade.";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 0;
        sprite_ind = 0;
        velocidade = 1;
        tipo = "bota";
        ind = 0;
    } else if (item_index > 300 && item_index <= 550) { // 25% de chance
        item_nome = "Tênis Velho";
        item_descricao = "Tênis antigos, mas confortáveis o suficiente para dar um leve impulso.";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 0;
        sprite_ind = 1;
        velocidade = 2;
        tipo = "bota";
        ind = 1;
    } else if (item_index > 550 && item_index <= 750) { // 20% de chance
        item_nome = "Meia Vermelha Nova";
        item_descricao = "Meias novas que oferecem proteção e velocidade moderada.";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 0;
        sprite_ind = 6;
        velocidade = 2;
        tipo = "bota";
        ind = 6;
    } else if (item_index > 750 && item_index <= 900) { // 15% de chance
        item_nome = "Sapato Novo";
        item_descricao = "Sapatos elegantes que oferecem um bom equilíbrio entre estilo e desempenho.";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 0;
        sprite_ind = 5;
        velocidade = 3;
        tipo = "bota";
        ind = 5;
    } else if (item_index > 900 && item_index <= 970) { // 7% de chance
        item_nome = "Tênis Novo";
        item_descricao = "Tênis brilhantes que garantem um aumento considerável na velocidade.";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 0;
        sprite_ind = 4;
        velocidade = 4;
        tipo = "bota";
        ind = 4;
    } else if (item_index > 970 && item_index <= 990) { // 2% de chance
        item_nome = "Skate";
        item_descricao = "Aumenta a adrenalina com seu skate, deslizando rapidamente pelas ruas.";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 0;
        sprite_ind = 3;
        velocidade = 5;
        tipo = "bota";
        ind = 3;
    } else if (item_index > 990) { // 1% de chance
        item_nome = "Patins";
        item_descricao = "Rápidos e ágeis, esses patins oferecem a maior velocidade possível.";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 0;
        sprite_ind = 2;
        velocidade = 5;
        tipo = "bota";
        ind = 2;
    }else if (item_index > 1100 && item_index <= 2000) { // 1% de chance
		drop = false;
	}

  if (drop == true) {
      var _inst = instance_create_layer(pos_x, pos_y, "Instances_itens", obj_item);
    _inst.sprite_index = item_sprite;
    _inst.quantidade = item_quantidade;
    _inst.nome = item_nome;
    _inst.descricao = item_descricao;
    _inst.sala_x = global.current_sala[0];
    _inst.sala_y = global.current_sala[1];
    _inst.pos_x = pos_x;
    _inst.pos_y = pos_y;
    _inst.image_index = sprite_ind;
    _inst.dano = dano;
    _inst.cura = cura;
    _inst.velocidade = velocidade;
    _inst.armadura = armadura;
    _inst.ind = ind;
    _inst.tipo = tipo;
    _inst.depth = prof - 1;
    _inst.profundidade = prof - 1;
    salvar_item(_inst.sala_x, _inst.sala_y, pos_x, pos_y, _inst);// code here
  }
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

