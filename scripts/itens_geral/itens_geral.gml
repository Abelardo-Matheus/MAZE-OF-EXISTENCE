
function adicionar_item_invent(){
	///@arg Item
	///@arg Quantidade
	///@arg Sprite
	///@arg nome
	///@arg descricao
	///@arg sala_x
	///@arg sala_y
	///@arg pos_x
	///@arg pox_y
	///@arg dano
	///@arg armadura
	///@arg velocidade
	///@arg cura
	///@arg tipo
	///@arg ind
	var _grid = global.grid_itens;
	var _empty_slots = 0;
	
	for (var i = 0; i < ds_grid_height(_grid); i++) {
    if (_grid[# Infos.item, i] == -1) {
        _empty_slots++;
    }
}
	
	if (_empty_slots > 0) {
	var _grid = global.grid_itens;
	var _check = 0;
	while _grid[# Infos.item, _check] != -1{
	_check++;	
	}
	}else {
	 global.inventario_cheio = true; // esse variavel aqui ativa uma mensagem que indica q o inventario está cheio.
	 return;
}
	_grid[# 0, _check] = argument[0];
	_grid[# 1, _check] = argument[1];
	_grid[# 2, _check] = argument[2];
	_grid[# 3, _check] = argument[3];
	_grid[# 4, _check] = argument[4];
	_grid[# 5, _check] = argument[5];
	_grid[# 6, _check] = argument[6];
	_grid[# 7, _check] = argument[7];
	_grid[# 8, _check] = argument[8];
	_grid[# 9, _check] = argument[9];
	_grid[# 10, _check] = argument[10];
	_grid[# 11, _check] = argument[11];
	_grid[# 12, _check] = argument[12];
	_grid[# 13, _check] = argument[13];
	_grid[# 14, _check] = argument[14];
}

function criar_item_aleatorio_ativos(pos_x,pos_y,prof) {
    // Escolher entre itens passivos e ativos
	randomize();
    var tipo_item = irandom(1); // 0 para passivo, 1 para ativo

    var item_nome,ind, item_descricao, item_sprite, item_quantidade,sprite_ind,dano,armadura,velocidade,cura,tipo;
	cura = 0;
	velocidade = 0;
	dano = 0;
	armadura = 0;
	tipo = 0;
        // Escolher item ativo aleatório
        var item_index = irandom(itens_ativos.Altura - 1);
		show_debug_message(item_index)
        switch (item_index) {
            case 2:
                item_nome = "Banana";
                item_descricao = "Uma banana fresca, carregada de potássio. Perfeita para recarregar suas energias!";
                item_sprite = spr_itens_invent_consumiveis;
                item_quantidade = irandom_range(1, 3);
				sprite_ind = 2;
				ind = 2;
				cura = 10;
				tipo = "uso";
			
                break;
            case 1:
                item_nome = "Maçã";
                item_descricao = "Uma maçã suculenta, deliciosa e crocante. Ideal para um lanche rápido e saudável.";
                item_sprite = spr_itens_invent_consumiveis;
                item_quantidade = irandom_range(1, 3);
				sprite_ind = 1;
				cura = 10;
				ind = 1;
				tipo = "uso";
                break;
			case 0:
                item_nome = "Batata";
                item_descricao = "Uma batata robusta, pronta para ser cozida ou assada. A fonte perfeita de energia natural.";
                item_sprite = spr_itens_invent_consumiveis;
                item_quantidade = irandom_range(1, 3);
				sprite_ind = 0;
				cura = 20;
				ind = 0;
				tipo = "uso";
                break;
			case 3:
                item_nome = "Uva";
                item_descricao = "Um cacho de uvas doces, pequenas e cheias de sabor. Uma explosão de doçura a cada mordida.";
                item_sprite = spr_itens_invent_consumiveis;
                item_quantidade = irandom_range(1, 3 );
				sprite_ind = 3;
				cura = 10;
				ind = 3;
				tipo = "uso";
                break;
			case 4:
                item_nome = "Vitamina";
                item_descricao = "Uma dose poderosa de vitaminas, embalada em uma pequena pílula. Essencial para manter sua vitalidade.";
                item_sprite = spr_itens_invent_consumiveis;
                item_quantidade = irandom_range(1, 3);
				sprite_ind = 4;
				cura = 50;
				ind = 4;
				tipo = "uso";
                break;
			case 5:
                item_nome = "Leite";
                item_descricao = "Um copo de leite fresco e nutritivo, perfeito para fortalecer seus ossos e garantir um dia saudável."
                item_sprite = spr_itens_invent_consumiveis;
				sprite_ind = 5;
                item_quantidade = irandom_range(1, 3);
				cura = 30;
				ind = 5;
				tipo = "uso";
                break;
		}

    var _inst = instance_create_layer(pos_x, pos_y, "instances", obj_item);
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
	_inst.ind = ind;
	_inst.cura = cura;
	_inst.velocidade = velocidade;
	_inst.armadura = armadura;
	_inst.tipo = tipo;
	_inst.depth = prof -1;
	salvar_item(_inst.sala_x,_inst.sala_y,pos_x,pos_y,_inst);

} 
function criar_item_aleatorio_passivos(pos_x,pos_y,prof) {
	randomize();
    // Escolher entre itens passivos e ativos
    var tipo_item = irandom(1); // 0 para passivo, 1 para ativo

    var item_nome, item_descricao, item_sprite, item_quantidade,sprite_ind,dano,armadura,velocidade,cura,ind,tipo;
	cura = 0;
	velocidade = 0;
	dano = 0;
	armadura = 0;
	tipo = 0;
        // Escolher item ativo aleatório
        var item_index = irandom(itens_passivos.Altura - 1);
        switch (item_index) {
            case 1:
                item_nome = "Cobertor";
                item_descricao = "Um cobertor quentinho que espanta qualquer mal!";
                item_sprite = spr_itens_invent_passivo;
                item_quantidade = 1;
				sprite_ind = 1;
				armadura = 10;
				tipo = "armadura";
				ind = 1;
                break;
			case 0:
                item_nome = "graveto";
                item_descricao = "Um graveto bom para atacar monstros";
                item_sprite = spr_itens_invent_passivo;
                item_quantidade = 1;
				sprite_ind = 0;
				dano = 10;
				tipo = "arma";
				ind = 0;
                break;
			case 2:
                item_nome = "Bota";
                item_descricao = "Uma Bota um pouco velha mas de bom uso";
                item_sprite = spr_itens_invent_passivo;
                item_quantidade = 1;
				sprite_ind = 2;
				velocidade = 10;
				tipo = "bota";
				ind = 2;
                break;
			
		}

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
	_inst.depth = prof -1;
	
	salvar_item(_inst.sala_x,_inst.sala_y,pos_x,pos_y,_inst);

} 

function criar_item_aleatorio_passivos_arma(pos_x,pos_y,prof) {
	randomize();
    // Escolher entre itens passivos e ativos
    var tipo_item = irandom(1); // 0 para passivo, 1 para ativo

    var item_nome, item_descricao, item_sprite, item_quantidade,sprite_ind,dano,armadura,velocidade,cura,ind,tipo;
	cura = 0;
	velocidade = 0;
	dano = 0;
	armadura = 0;
	tipo = 0;
	var item_index = irandom(itens_armas.Altura - 1);
        switch (item_index) {
    case 0:
        item_nome = "Graveto";
        item_descricao = "Esses tênis já viram melhores dias, mas ainda protegem bem os pés. Oferece uma boa defesa com um toque de nostalgia.";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 1;
        sprite_ind = 0;
        dano = 2;
        tipo = "arma";
        ind = 0;
        break;
    case 1:
        item_nome = "Vassoura";
        item_descricao = "Este sapato desgastado pode não ser bonito, mas faz um ótimo trabalho como arma improvisada. Bom para atacar monstros desprevenidos.";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 1;
        sprite_ind = 1;
		dano = 4;
        tipo = "arma";
        ind = 1;
        break;
    case 2:
        item_nome = "Espada de plastico";
        item_descricao = "Velhos, mas funcionais! Esses patins ainda podem fazer você deslizar com agilidade. Ganhe um impulso extra de velocidade!";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 1;
        sprite_ind = 2;
        dano = 5;
        tipo = "arma";
        ind = 2;
        break;
    case 3:
        item_nome = "Espada de madeira";
        item_descricao = "Sinta a adrenalina enquanto você desliza pelas ruas com este skate, ganhando velocidade e deixando seus inimigos comendo poeira.";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 1;
        sprite_ind = 3;
        dano = 7;
        tipo = "arma";
        ind = 3;
        break;
    case 4:
        item_nome = "Espada de ouro";
        item_descricao = "Brilhante e pronto para a ação! Esses tênis novos garantem a você um conforto extra e um ótimo impulso de velocidade.";
        item_sprite = spr_itens_invent_passivo_armas;
        item_quantidade = 1;
        sprite_ind = 4;
        dano = 9;
        tipo = "arma";
        ind = 4;
       break;
  
}


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
	_inst.depth = prof -1;
	
	
	salvar_item(_inst.sala_x,_inst.sala_y,pos_x,pos_y,_inst);

} 


function criar_item_aleatorio_passivos_pe(pos_x,pos_y,prof) {
	randomize();
    // Escolher entre itens passivos e ativos
    var tipo_item = irandom(1); // 0 para passivo, 1 para ativo

    var item_nome, item_descricao, item_sprite, item_quantidade,sprite_ind,dano,armadura,velocidade,cura,ind,tipo;
	cura = 0;
	velocidade = 0;
	dano = 0;
	armadura = 0;
	tipo = 0;
	var item_index = irandom(itens_pe.Altura - 1);
        switch (item_index) {
    case 1:
        item_nome = "Tênis Velho";
        item_descricao = "Esses tênis já viram melhores dias, mas ainda protegem bem os pés. Oferece uma boa defesa com um toque de nostalgia.";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 1;
        sprite_ind = 1;
        velocidade = 2;
        tipo = "bota";
        ind = 1;
        break;
    case 0:
        item_nome = "Sapato Velho";
        item_descricao = "Este sapato desgastado pode não ser bonito, mas faz um ótimo trabalho como arma improvisada. Bom para atacar monstros desprevenidos.";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 1;
        sprite_ind = 0;
        velocidade = 1;
        tipo = "bota";
        ind = 0;
        break;
    case 2:
        item_nome = "Patins";
        item_descricao = "Velhos, mas funcionais! Esses patins ainda podem fazer você deslizar com agilidade. Ganhe um impulso extra de velocidade!";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 1;
        sprite_ind = 2;
        velocidade = 5;
        tipo = "bota";
        ind = 2;
        break;
    case 3:
        item_nome = "Skate";
        item_descricao = "Sinta a adrenalina enquanto você desliza pelas ruas com este skate, ganhando velocidade e deixando seus inimigos comendo poeira.";
        item_sprite = spr_itens_invent_passivo;
        item_quantidade = 1;
        sprite_ind = 3;
        velocidade = 5;
        tipo = "bota";
        ind = 3;
        break;
    case 4:
        item_nome = "Tênis Novo";
        item_descricao = "Brilhante e pronto para a ação! Esses tênis novos garantem a você um conforto extra e um ótimo impulso de velocidade.";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 1;
        sprite_ind = 4;
        velocidade = 4;
        tipo = "bota";
        ind = 4;
        break;
    case 5:
        item_nome = "Sapato Novo";
        item_descricao = "Elegante e resistente, este sapato novo não apenas parece bom, mas também te ajuda a correr mais rápido!";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 1;
        sprite_ind = 5;
        velocidade = 3;
        tipo = "bota";
        ind = 5;
        break;
	case 6:
        item_nome = "Meia vermelha nova";
        item_descricao = "Elegante e boa para não atrair inimgos!";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 1;
        sprite_ind = 56
        velocidade = 2;
        tipo = "bota";
        ind = 6;
        break;
	case 7:
        item_nome = "Meia Amarela velha";
        item_descricao = "Fedorrenta e velha espanta os inimigos!E tambem amigos!";
        item_sprite = spr_itens_invent_passivo_pe;
        item_quantidade = 1;
        sprite_ind = 7;
        velocidade = 2;
        tipo = "bota";
        ind = 7;
        break;
}


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
	_inst.depth = prof -1;
	
	salvar_item(_inst.sala_x,_inst.sala_y,pos_x,pos_y,_inst);

} 



