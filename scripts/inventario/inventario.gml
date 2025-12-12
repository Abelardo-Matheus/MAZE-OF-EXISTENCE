/// @func inventory_find_empty_slot()
/// @desc Retorna o índice do primeiro slot vazio na mochila ou -1 se estiver cheia
function inventory_find_empty_slot() {
    var _grid = global.grid_itens;
    var _total_slots = ds_grid_height(_grid);
    var _equip_slots = 3; // Arma, Armadura, Bota (ficam no final)

    // Percorre apenas a parte da mochila (exclui equipamentos)
    for (var i = 0; i < _total_slots - _equip_slots; i++) {
        // Se o item for -1, está vazio
        if (_grid[# Infos.item, i] == -1) {
            return i;
        }
    }

    return -1; // Mochila cheia
}

/// @func inventory_copy_slot(dest_slot, src_slot)
/// @desc Copia todos os dados de um slot para outro DENTRO da mesma grid global
function inventory_copy_slot(_dest, _src) {
    var _grid = global.grid_itens;
    
    // Copia coluna por coluna (Item, Quantidade, Sprite, etc.)
    _grid[# Infos.item,       _dest] = _grid[# Infos.item,       _src];
    _grid[# Infos.quantidade, _dest] = _grid[# Infos.quantidade, _src];
    _grid[# Infos.sprite,     _dest] = _grid[# Infos.sprite,     _src];
    _grid[# Infos.nome,       _dest] = _grid[# Infos.nome,       _src];
    _grid[# Infos.descricao,  _dest] = _grid[# Infos.descricao,  _src];
    _grid[# Infos.sala_x,     _dest] = _grid[# Infos.sala_x,     _src];
    _grid[# Infos.sala_y,     _dest] = _grid[# Infos.sala_y,     _src];
    _grid[# Infos.pos_x,      _dest] = _grid[# Infos.pos_x,      _src];
    _grid[# Infos.pos_y,      _dest] = _grid[# Infos.pos_y,      _src];
    _grid[# Infos.dano,       _dest] = _grid[# Infos.dano,       _src];
    _grid[# Infos.armadura,   _dest] = _grid[# Infos.armadura,   _src];
    _grid[# Infos.velocidade, _dest] = _grid[# Infos.velocidade, _src];
    _grid[# Infos.cura,       _dest] = _grid[# Infos.cura,       _src];
    _grid[# Infos.tipo,       _dest] = _grid[# Infos.tipo,       _src];
    _grid[# Infos.image_ind,  _dest] = _grid[# Infos.image_ind,  _src];
    _grid[# Infos.preco,      _dest] = _grid[# Infos.preco,      _src];
}

/// @func inventory_drop_item(slot)
/// @desc Joga o item do slot no chão, salva no mapa da sala e limpa o slot
function inventory_drop_item(_slot) {
    var _grid = global.grid_itens;

    // 1. Segurança: Se o slot já estiver vazio, não faz nada
    if (_grid[# Infos.item, _slot] == -1) return;

    // 2. Garante que o player existe para usar a posição dele como origem do drop
    if (instance_exists(obj_player)) {
        var _p_x = obj_player.x;
        var _p_y = obj_player.y;

        // 3. Cria o objeto físico no mundo
        var _inst = instance_create_layer(_p_x, _p_y, "instances", obj_item);

        // 4. Transfere os dados da Grid para o Objeto criado
        _inst.sprite_index = _grid[# Infos.sprite, _slot];
        _inst.image_index  = _grid[# Infos.image_ind, _slot]; 
        _inst.quantidade   = _grid[# Infos.quantidade, _slot];
        _inst.nome         = _grid[# Infos.nome, _slot];
        _inst.descricao    = _grid[# Infos.descricao, _slot];
        _inst.dano         = _grid[# Infos.dano, _slot];
        _inst.armadura     = _grid[# Infos.armadura, _slot];
        _inst.velocidade   = _grid[# Infos.velocidade, _slot];
        _inst.cura         = _grid[# Infos.cura, _slot];
        _inst.tipo         = _grid[# Infos.tipo, _slot];
        _inst.ind          = _grid[# Infos.image_ind, _slot];
        _inst.preco        = _grid[# Infos.preco, _slot];

        // 5. Configura dados de Persistência (Sala e Posição)
        _inst.sala_x = global.current_sala[0];
        _inst.sala_y = global.current_sala[1];
        _inst.pos_x  = _p_x;
        _inst.pos_y  = _p_y;
        
        // Define profundidade (opcional, baseado no seu código anterior)
        _inst.prof = _inst.depth;

        // 6. Salva o item no sistema de persistência (ds_map da sala)
        salvar_item(_inst.sala_x, _inst.sala_y, _p_x, _p_y, _inst);
    }

    // 7. Limpa o slot no inventário (remove o item da UI)
    inventory_clear_slot(_slot);

    // 8. Recalcula status (caso você tenha dropado um item que estava equipado)
    recalculate_player_stats();
}

/// @func inventory_clear_slot(slot)
/// @desc Limpa um slot específico definindo tudo como -1
function inventory_clear_slot(_slot) {
    var _grid = global.grid_itens;
    
    _grid[# Infos.item,       _slot] = -1;
    _grid[# Infos.quantidade, _slot] = -1;
    _grid[# Infos.sprite,     _slot] = -1;
    _grid[# Infos.nome,       _slot] = -1;
    _grid[# Infos.descricao,  _slot] = -1;
    _grid[# Infos.sala_x,     _slot] = -1;
    _grid[# Infos.sala_y,     _slot] = -1;
    _grid[# Infos.pos_x,      _slot] = -1;
    _grid[# Infos.pos_y,      _slot] = -1;
    _grid[# Infos.dano,       _slot] = -1;
    _grid[# Infos.armadura,   _slot] = -1;
    _grid[# Infos.velocidade, _slot] = -1;
    _grid[# Infos.cura,       _slot] = -1;
    _grid[# Infos.tipo,       _slot] = -1;
    _grid[# Infos.image_ind,  _slot] = -1;
    _grid[# Infos.preco,      _slot] = -1;
}

/// @func recalculate_player_stats()
/// @desc Atualiza os atributos do player baseados nos itens equipados
function recalculate_player_stats() {
    // 1. Reseta para os valores base (defina seus globais padrão aqui)
    global.ataque = 10; // Valor base exemplo
    global.armadura_bebe = 0;
    global.speed_player = 4; // Valor base exemplo

    // 2. Soma atributos da ARMA (Slot fixo definido no Create: slot_index_weapon)
    // Nota: Como você está usando variáveis de instância no obj_inventario, 
    // precisamos acessar via global.grid_itens usando índices calculados.
    // Assumindo: Total Slots (mochila) + 0 = Arma, + 1 = Armadura, + 2 = Bota
    
    var _total_slots = 18; // 6x3, ajuste se seu inventário for maior
    var _slot_arma = _total_slots;
    var _slot_armadura = _total_slots + 1;
    var _slot_bota = _total_slots + 2;

    // Arma
    if (global.grid_itens[# Infos.item, _slot_arma] != -1) {
        global.ataque += global.grid_itens[# Infos.dano, _slot_arma];
        
        // Lógica da Espada Fantasma
        if (global.grid_itens[# Infos.nome, _slot_arma] == "Mata-Fantasma") {
            global.mata_fantasma = true;
        } else {
            global.mata_fantasma = false;
        }
    } else {
        global.mata_fantasma = false;
    }

    // Armadura
    if (global.grid_itens[# Infos.item, _slot_armadura] != -1) {
        global.armadura_bebe += global.grid_itens[# Infos.armadura, _slot_armadura];
    }

    // Bota
    if (global.grid_itens[# Infos.item, _slot_bota] != -1) {
        global.speed_player += global.grid_itens[# Infos.velocidade, _slot_bota];
    }
}

/// @desc Troca itens entre dois slots (origem e destino)
function inventory_swap_item(_src_slot, _dest_slot) {
    // Cria uma grid temporária de 1 linha para segurar os dados
    var _temp_grid = ds_grid_create(Infos.Height, 1);
    var _main_grid = global.grid_itens;

    // 1. Copia ORIGEM -> TEMP
    for (var i = 0; i < Infos.Height; i++) {
        _temp_grid[# i, 0] = _main_grid[# i, _src_slot];
    }

    // 2. Copia DESTINO -> ORIGEM (Move o item do destino para onde estava o da mão)
    inventory_copy_slot(_src_slot, _dest_slot);

    // 3. Copia TEMP -> DESTINO (Coloca o item da mão no destino)
    for (var i = 0; i < Infos.Height; i++) {
        _main_grid[# i, _dest_slot] = _temp_grid[# i, 0];
    }

    // Limpa a memória
    ds_grid_destroy(_temp_grid);
    
    // Atualiza status do player
    recalculate_player_stats();
}

/// @desc Usa ou Equipa o item no slot
function inventory_use_item(_slot) {
    var _grid = global.grid_itens;
    var _item_type = _grid[# Infos.tipo, _slot];
    
    if (_grid[# Infos.item, _slot] == -1) return;

    // Caso 1: Consumível (Uso)
    if (_item_type == "uso") {
        var _cura = _grid[# Infos.cura, _slot];
        global.vida = min(global.vida + _cura, global.vida_max);
        
        // Reduz quantidade
        _grid[# Infos.quantidade, _slot]--;
        if (_grid[# Infos.quantidade, _slot] <= 0) {
            inventory_clear_slot(_slot);
        }
    }
    // Caso 2: Equipamento (Mover para slot dedicado)
    else if (_slot < total_slots) { // Se está na mochila, equipa
        var _target_slot = -1;
        if (_item_type == "arma") _target_slot = total_slots; // Slot Arma
        if (_item_type == "armadura") _target_slot = total_slots + 1;
        if (_item_type == "bota") _target_slot = total_slots + 2;
        
        if (_target_slot != -1) {
            inventory_swap_item(_slot, _target_slot);
        }
    }
    // Caso 3: Desequipar (Mover para mochila)
    else {
        var _empty = inventory_find_empty_slot();
        if (_empty != -1) {
            inventory_swap_item(_slot, _empty);
        }
    }
}

/// @desc Desenha os status e o sprite do player no menu de inventário
function draw_player_stats_panel(_x, _y) {
    // Pega a escala da instância atual (obj_inventario)
    var _s = scale; 

    // --- Configuração de Texto ---
    draw_set_font(fnt_status);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);

    // --- Definição das Strings ---
    // Usando round() para não mostrar números quebrados (ex: 10.5 de vida)
    var _str_lvl  = "LVL: " + string(global.level_player);
    var _str_atk  = "ATK: " + string(round(global.ataque));
    var _str_spd  = "SPD: " + string(global.speed_player);
    var _str_life = "LIFE: " + string(round(global.vida)) + "/" + string(round(global.vida_max));
    var _str_def  = "DEF: " + string(global.armadura_bebe);

    // --- Coordenadas (Baseadas no seu código original) ---
    var _text_x = _x + (370 * _s);
    var _base_y = _y + (183 * _s); // Ponto central vertical dos textos
    var _gap    = 35; // Espaçamento entre linhas

    // --- Desenho dos Textos ---
    draw_text(_text_x, _base_y - _gap,       _str_lvl);
    draw_text(_text_x, _base_y,              _str_atk);
    draw_text(_text_x, _base_y + _gap,       _str_spd);
    draw_text(_text_x, _base_y + (_gap * 2), _str_life);
    draw_text(_text_x, _base_y + (_gap * 3), _str_def);

    // --- Desenho do Personagem ---
    var _char_x   = _x + (442 * _s);
    var _char_y   = _y + (126 * _s);
    var _shadow_y = _y + (155 * _s); // Sombra um pouco abaixo

    // Sombra
    if (sprite_exists(spr_sombra)) {
        draw_sprite_ext(spr_sombra, 0, _char_x + 1, _shadow_y, 3, 3, 0, c_white, 1);
    }

    // Player
    // Verifica se o objeto player existe para pegar o frame da animação
    var _img_index = 0;
    if (instance_exists(obj_player)) {
        _img_index = obj_player.image_index;
    }

    // Desenha o sprite do player parado
    if (sprite_exists(spr_player_baixo_parado)) {
        draw_sprite_ext(spr_player_baixo_parado, _img_index, _char_x, _char_y, 4, 4, 0, c_white, 1);
    }

    // Resetar cor para não afetar outros desenhos
    draw_set_color(c_white);
}