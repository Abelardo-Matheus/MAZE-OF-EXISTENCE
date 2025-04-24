function inicializar_itens_venda(npc_level) {
    randomize();
    ds_grid_clear(inventario_venda, -1);
    
    // Define quantos itens o NPC terá para vender (baseado no nível)
    var quantidade_itens = clamp(3 + floor(npc_level / 2), 3, 8); // Mínimo 3, máximo 8 itens
    
    // Filtra itens baseado no nível do NPC
    var itens_disponiveis = filtrar_itens_por_nivel(npc_level);
    
    // Adiciona itens aleatórios ao inventário de venda
    for (var i = 0; i < quantidade_itens; i++) {
        // Escolhe um item aleatório da lista filtrada
        var item_index = irandom(ds_list_size(itens_disponiveis) - 1);
        var item = itens_disponiveis[| item_index];
        
        // Define quantidade aleatória baseada no tipo de item e nível do NPC
        var quantidade = 1;
        if (item[8] == "uso") { // Itens de uso têm quantidades maiores
            quantidade = irandom_range(1, 3 + npc_level);
        }
        
        // Adiciona o item ao inventário de venda
        adicionar_item_venda(
            item[0],       // sprite
            item[7],       // image_index
            item[10],    // quantidade
            item[1],       // nome
            item[2],       // descricao
            item[4],       // dano
            item[5],       // armadura
            item[6],       // velocidade
            item[3],       // cura
            item[8],       // tipo
            item[7],       // ind (usando image_index)
            calcular_preco_com_base_no_nivel(item[9], npc_level) // preco ajustado
        );
        
        // Remove o item da lista temporária para evitar duplicatas
        ds_list_delete(itens_disponiveis, item_index);
        
        // Se não houver mais itens disponíveis, sai do loop
        if (ds_list_size(itens_disponiveis) == 0) break;
    }
    
    // Limpa a lista temporária
    ds_list_destroy(itens_disponiveis);
}

function filtrar_itens_por_nivel(npc_level) {
    var itens_filtrados = ds_list_create();
    
    for (var i = 0; i < ds_list_size(global.lista_itens); i++) {
        var item = global.lista_itens[| i];
        var item_tier = determinar_tier_do_item(item);
        
        // Itens de tier mais alto só aparecem para NPCs de nível mais alto
        if (item_tier <= npc_level) {
            ds_list_add(itens_filtrados, item);
        }
    }
    
    return itens_filtrados;
}

function determinar_tier_do_item(item) {
    // Define o tier do item baseado em suas propriedades
    var poder = 0;
    
    switch (item[8]) { // tipo
        case "uso":
            poder = item[3] / 10; // baseado na cura
            break;
        case "arma":
            poder = item[5] / 2;  // baseado no dano
            break;
        case "armadura":
            poder = item[6];      // baseado na armadura
            break;
        case "bota":
            poder = item[7];      // baseado na velocidade
            break;
    }
    
    return clamp(floor(poder / 2), 1, 5); // Tiers de 1 a 5
}

function calcular_preco_com_base_no_nivel(preco_base, npc_level) {
    // Aumenta o preço baseado no nível do NPC (10% por nível)
    var multiplicador = 1 + (npc_level * 0.1);
    
    // Adiciona uma variação aleatória de ±20%
    var variacao = random_range(0.8, 1.2);
    
    return round(preco_base * multiplicador * variacao);
}

function adicionar_item_venda(_sprite, _img_index, _quantidade, _nome, _descricao, _dano, _armadura, _velocidade, _cura, _tipo, _ind, _preco) {
    // Encontra o primeiro slot vazio
    for (var i = 0; i < ds_grid_height(inventario_venda); i++) {
        if (inventario_venda[# Infos.item, i] == -1) {
            // Preenche os dados do item
            inventario_venda[# Infos.item, i] = i; // ID único
            inventario_venda[# Infos.quantidade, i] = _quantidade;
            inventario_venda[# Infos.sprite, i] = _sprite;
            inventario_venda[# Infos.nome, i] = _nome;
            inventario_venda[# Infos.descricao, i] = _descricao;
            inventario_venda[# Infos.dano, i] = _dano;
            inventario_venda[# Infos.armadura, i] = _armadura;
            inventario_venda[# Infos.velocidade, i] = _velocidade;
            inventario_venda[# Infos.cura, i] = _cura;
            inventario_venda[# Infos.tipo, i] = _tipo;
            inventario_venda[# Infos.image_ind, i] = _ind;
            inventario_venda[# Infos.preco, i] = _preco;
            break;
        }
    }
}