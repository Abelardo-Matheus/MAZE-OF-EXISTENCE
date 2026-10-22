// feather disable GM2017
// ============================================================================
//  INVENTÁRIO — operações da mochila, equipamentos, adesivos, upgrade,
//  status do player (equipamento + passivas + buffs), craft e tooltip.
//  Dados dos itens: scripts/itens_geral (item_db, passivas_db, receitas_craft)
// ============================================================================

#region ---------- CONSULTAS BÁSICAS ----------

/// @desc Conta a quantidade total de um item (por ID) na mochila
function inventory_count_item(_item_id) {
    var _total = 0;
    var _bag = inventory_bag_slots();
    for (var _i = 0; _i < _bag; _i++) {
        if (global.grid_itens[# INFOS.ITEM, _i] == _item_id) _total += global.grid_itens[# INFOS.QUANTIDADE, _i];
    }
    return _total;
}

function inventory_find_empty_slot() {
    var _grid = global.grid_itens;
    var _bag = inventory_bag_slots();
    for (var _i = 0; _i < _bag; _i++) {
        if (_grid[# INFOS.ITEM, _i] == -1) return _i;
    }
    return -1;
}

/// Tipo exigido por um slot (-1 = mochila, aceita tudo)
function inventory_slot_tipo(_slot) {
    var _bag = inventory_bag_slots();
    if (_slot == _bag)     return "cabeca";      // chapéu (antes: arma — armas agora só na hotbar)
    if (_slot == _bag + 1) return "armadura";
    if (_slot == _bag + 2) return "bota";
    if (hotbar_e_slot(_slot)) return "ferramenta";   // hotbar: arma, arco ou luz
    return -1;
}

function inventory_slot_e_equip(_slot) { return _slot >= inventory_bag_slots(); }

/// O item que está em _src pode ir para _dest?
function inventory_slot_aceita(_dest, _src) {
    var _req = inventory_slot_tipo(_dest);
    if (_req == -1) return true;
    if (global.grid_itens[# INFOS.ITEM, _src] == -1) return true; // slot vazio pode "ir" pra qualquer lugar
    if (_req == "ferramenta") return item_tipo_hotbar(global.grid_itens[# INFOS.TIPO, _src]);
    return global.grid_itens[# INFOS.TIPO, _src] == _req;
}

#endregion

#region ---------- MENSAGENS NA TELA ----------

function inventory_msg(_txt, _cor = c_white) {
    if (!instance_exists(obj_inventario)) { show_debug_message(_txt); return; }
    with (obj_inventario) { msg_texto = _txt; msg_cor = _cor; msg_timer = 150; }
}

#endregion

#region ---------- MOVER / LIMPAR / REMOVER ----------

/// @desc Copia todos os dados de um slot para outro
function inventory_copy_slot(_dest, _src) {
    var _grid = global.grid_itens;
    for (var _c = 0; _c < INFOS.HEIGHT; _c++) _grid[# _c, _dest] = _grid[# _c, _src];
}

/// @desc Limpa um slot (tudo -1)
function inventory_clear_slot(_slot) {
    var _grid = global.grid_itens;
    for (var _c = 0; _c < INFOS.HEIGHT; _c++) _grid[# _c, _slot] = -1;
}

/// @desc Troca dois slots (sem validação)
function inventory_swap_item(_a, _b) {
    var _grid = global.grid_itens;
    for (var _c = 0; _c < INFOS.HEIGHT; _c++) {
        var _tmp = _grid[# _c, _a];
        _grid[# _c, _a] = _grid[# _c, _b];
        _grid[# _c, _b] = _tmp;
    }
    if (inventory_slot_e_equip(_a) || inventory_slot_e_equip(_b)) player_stats_recalcular();
}

/// @desc Solta o item _src em cima do slot _dest (arrastar e soltar)
function inventory_mover(_src, _dest) {
    if (_src == _dest || _src < 0 || _dest < 0) return;
    var _grid = global.grid_itens;
    var _id_src = _grid[# INFOS.ITEM, _src];
    var _id_dst = _grid[# INFOS.ITEM, _dest];
    if (_id_src == -1) return;

    // 1. Adesivo em cima de equipamento = colar passiva
    if (_grid[# INFOS.TIPO, _src] == "adesivo" && _id_dst != -1 && item_tipo_e_equipamento(_grid[# INFOS.TIPO, _dest])) {
        inventory_aplicar_adesivo(_src, _dest);
        return;
    }

    // 2. Mesmo item empilhável = junta a pilha
    var _d = item_db(_id_src);
    if (_id_src == _id_dst && !is_undefined(_d) && _d.stack) {
        _grid[# INFOS.QUANTIDADE, _dest] += _grid[# INFOS.QUANTIDADE, _src];
        inventory_clear_slot(_src);
        inventory_pos_mudanca();
        return;
    }

    // 3. Troca, respeitando o tipo dos slots de equipamento
    if (!inventory_slot_aceita(_dest, _src)) {
        inventory_msg("Esse espaço é só para " + string_lower(item_tipo_nome(inventory_slot_tipo(_dest))) + "!", c_orange);
        return;
    }
    if (!inventory_slot_aceita(_src, _dest)) {
        inventory_msg("Esse item não cabe ali!", c_orange);
        return;
    }
    inventory_swap_item(_src, _dest);
    inventory_pos_mudanca();
}

/// @desc Remove uma quantidade de um item (por ID) da mochila
function inventory_remove_item(_item_id, _qtd_remover) {
    if (_qtd_remover <= 0) return false;
    var _grid = global.grid_itens;
    var _falta = _qtd_remover;
    var _bag = inventory_bag_slots();
    for (var _i = 0; _i < _bag && _falta > 0; _i++) {
        if (_grid[# INFOS.ITEM, _i] != _item_id) continue;
        var _q = _grid[# INFOS.QUANTIDADE, _i];
        if (_q > _falta) { _grid[# INFOS.QUANTIDADE, _i] -= _falta; _falta = 0; }
        else { _falta -= _q; inventory_clear_slot(_i); }
    }
    inventory_pos_mudanca();
    return _falta == 0;
}

/// @desc Joga o item do slot no chão (pilha inteira)
function inventory_drop_item(_slot) {
    var _grid = global.grid_itens;
    var _id = _grid[# INFOS.ITEM, _slot];
    if (_id == -1) return;
    var _p = instance_exists(obj_player) ? obj_player : noone;
    if (_p == noone) return;

    if (!is_undefined(item_db(_id))) {
        item_criar_no_mundo(_p.x, _p.y, _id, _grid[# INFOS.QUANTIDADE, _slot], _grid[# INFOS.NIVEL, _slot], _grid[# INFOS.PASSIVAS, _slot], undefined, item_xp_slot(_grid, _slot));
    } else {
        // item legado (fora da database)
        var _inst = instance_create_depth(_p.x, _p.y, -_p.y, obj_item);
        with (_inst) {
            sprite_index = _grid[# INFOS.SPRITE, _slot]; image_index = _grid[# INFOS.IMAGE_IND, _slot]; image_speed = 0;
            quantidade = _grid[# INFOS.QUANTIDADE, _slot]; nome = _grid[# INFOS.NOME, _slot];
            descricao = _grid[# INFOS.DESCRICAO, _slot]; dano = _grid[# INFOS.DANO, _slot];
            armadura = _grid[# INFOS.ARMADURA, _slot]; velocidade = _grid[# INFOS.VELOCIDADE, _slot];
            cura = _grid[# INFOS.CURA, _slot]; tipo = _grid[# INFOS.TIPO, _slot]; preco = _grid[# INFOS.PRECO, _slot];
            ind = image_index; sala_x = global.current_sala[0]; sala_y = global.current_sala[1];
            pos_x = x; pos_y = y; profundidade = -y;
        }
        salvar_item(_inst.sala_x, _inst.sala_y, _inst.x, _inst.y, _inst);
    }
    var _era_equip = inventory_slot_e_equip(_slot);
    inventory_clear_slot(_slot);
    if (_era_equip) player_stats_recalcular();
    inventory_pos_mudanca();
}

#endregion

#region ---------- USAR / EQUIPAR ----------

/// @desc Usa (consumível), equipa ou desequipa o item do slot
function inventory_use_item(_slot) {
    var _grid = global.grid_itens;
    var _id = _grid[# INFOS.ITEM, _slot];
    if (_id == -1) return;
    var _tipo = _grid[# INFOS.TIPO, _slot];
    var _bag = inventory_bag_slots();

    if (_tipo == "uso") {
        var _cura = max(0, _grid[# INFOS.CURA, _slot]);
        if (_cura > 0) global.vida = min(global.vida + _cura, global.vida_max);
        var _d = item_db(_id);
        if (!is_undefined(_d)) {
            for (var _b = 0; _b < array_length(_d.buffs); _b++) {
                var _bf = _d.buffs[_b];
                buff_adicionar(_bf.stat, _bf.valor, _bf.seg, _d.nome);
            }
        }
        inventory_msg("Usou " + _grid[# INFOS.NOME, _slot] + (_cura > 0 ? "  (+" + string(round(_cura)) + " vida)" : ""), make_color_rgb(140, 255, 140));
        _grid[# INFOS.QUANTIDADE, _slot]--;
        if (_grid[# INFOS.QUANTIDADE, _slot] <= 0) inventory_clear_slot(_slot);
        inventory_pos_mudanca();
        return;
    }

    if (_tipo == "adesivo") { inventory_msg("Arraste o adesivo até um equipamento para colar!", c_yellow); return; }
    if (_tipo == "material") { inventory_msg("Materiais são usados no craft.", c_ltgray); return; }
    if (_tipo == "colocavel") { colocar_bau_iniciar(_slot); return; }

    // Arma, arco e luz: botão direito manda para a hotbar (e de volta para a mochila)
    if ((item_tipo_ferramenta(_tipo) || _tipo == "coleta") && !hotbar_e_slot(_slot) && _slot < _bag) {
        var _hb = -1;
        for (var _h = 0; _h < HOTBAR_SLOTS; _h++) if (_grid[# INFOS.ITEM, hotbar_slot(_h)] == -1) { _hb = hotbar_slot(_h); break; }
        if (_hb == -1) _hb = hotbar_slot(hotbar_ativo()); // hotbar cheia: troca com o item na mão
        inventory_swap_item(_slot, _hb);
        inventory_pos_mudanca();
        return;
    }

    if (_slot < _bag) {
        var _alvo = -1;
        if (_tipo == "cabeca")   _alvo = _bag;
        if (_tipo == "armadura") _alvo = _bag + 1;
        if (_tipo == "bota")     _alvo = _bag + 2;
        if (_alvo != -1) { inventory_swap_item(_slot, _alvo); inventory_pos_mudanca(); }
    } else {
        var _vazio = inventory_find_empty_slot();
        if (_vazio != -1) { inventory_swap_item(_slot, _vazio); inventory_pos_mudanca(); }
        else inventory_msg("Mochila cheia!", c_red);
    }
}

#endregion

#region ---------- ADESIVOS E UPGRADE ----------

/// @desc Cola o adesivo de _src no equipamento de _dest
function inventory_aplicar_adesivo(_src, _dest) {
    var _grid = global.grid_itens;
    var _ad = item_db(_grid[# INFOS.ITEM, _src]);
    if (is_undefined(_ad) || _ad.passiva_adesivo == "") return false;
    var _pid = _ad.passiva_adesivo;

    var _nv  = _grid[# INFOS.NIVEL, _dest];
    var _pas = _grid[# INFOS.PASSIVAS, _dest];
    if (!is_array(_pas)) { _pas = []; _grid[# INFOS.PASSIVAS, _dest] = _pas; }
    var _eq = item_db(_grid[# INFOS.ITEM, _dest]);

    if (!is_undefined(_eq) && _eq.inata == _pid) { inventory_msg("Esse item já nasce com essa passiva!", c_orange); return false; }
    if (!is_undefined(_eq) && !passiva_serve(_pid, _eq.tipo)) { inventory_msg("Esse adesivo não serve nesse tipo de item!", c_orange); return false; }
    for (var _i = 0; _i < array_length(_pas); _i++) {
        if (_pas[_i] == _pid) { inventory_msg("Esse item já tem essa passiva!", c_orange); return false; }
    }
    // Cheio (3): o adesivo substitui a passiva mais antiga
    if (array_length(_pas) >= item_slots_passiva(_nv)) {
        var _saiu = global.passivas_db[$ _pas[0]];
        array_delete(_pas, 0, 1);
        if (!is_undefined(_saiu)) inventory_msg(_saiu.nome + " saiu para dar lugar ao adesivo.", c_orange);
    }

    array_push(_pas, _pid);
    _grid[# INFOS.QUANTIDADE, _src]--;
    if (_grid[# INFOS.QUANTIDADE, _src] <= 0) inventory_clear_slot(_src);
    if (inventory_slot_e_equip(_dest)) player_stats_recalcular();
    inventory_pos_mudanca();
    inventory_msg(global.passivas_db[$ _pid].nome + " colado em " + _grid[# INFOS.NOME, _dest] + "!", global.passivas_db[$ _pid].cor);
    return true;
}

// (Upgrade com moedas/Pó de Estrela saiu: o nível agora sobe matando monstros — scr_passivas_itens)

#endregion

#region ---------- STATUS DO PLAYER (EQUIPAMENTO + PASSIVAS + BUFFS) ----------

function equip_stats_zero() {
    return { dano: 0, dano_pct: 0, defesa: 0, vel: 0, vida: 0, crit: 0, crit_dano: 0,
             regen: 0, vampirismo: 0, esquiva: 0, mata_fantasma: false,
             // passivas novas (scr_passivas_itens)
             alcance: 0, flechas: 0, recarga: 0, cura_abate: 0, moeda_abate: 0,
             xp_item: 0, espinhos: 0, sanidade_regen: 0 };
}

function _equip_somar(_e, _stat, _v) {
    if (_stat == "mata_fantasma") { _e.mata_fantasma = true; return; }
    if (variable_struct_exists(_e, _stat)) _e[$ _stat] += _v;
}

/// @desc Soma tudo que vem dos 3 equipamentos e dos buffs ativos -> global.equip_stats
function equip_calcular_bonus() {
    var _e = equip_stats_zero();
    var _tem_grid = variable_global_exists("grid_itens") && ds_exists(global.grid_itens, ds_type_grid);
    var _grid = _tem_grid ? global.grid_itens : -1;
    var _bag = _tem_grid ? inventory_bag_slots() : 0;
    var _stats = ["dano", "defesa", "vel", "vida", "crit"];
    // Slots que dão atributos: os 3 equipamentos + SÓ o item ativo da hotbar
    var _slots_bonus = _tem_grid ? [_bag, _bag + 1, _bag + 2, hotbar_slot(hotbar_ativo())] : [];

    for (var _q = 0; _q < array_length(_slots_bonus); _q++) {
        var _s = _slots_bonus[_q];
        var _id = _grid[# INFOS.ITEM, _s];
        if (_id == -1) continue;
        var _d = item_db(_id);
        if (is_undefined(_d)) {
            // item legado: usa as colunas antigas
            _e.dano   += max(0, _grid[# INFOS.DANO, _s]);
            _e.defesa += max(0, _grid[# INFOS.ARMADURA, _s]);
            _e.vel    += max(0, _grid[# INFOS.VELOCIDADE, _s]);
            continue;
        }
        var _nv = _grid[# INFOS.NIVEL, _s];
        for (var _k = 0; _k < array_length(_stats); _k++) _e[$ _stats[_k]] += item_stat(_id, _stats[_k], _nv);

        if (_d.inata != "") _equip_somar(_e, global.passivas_db[$ _d.inata].stat, passiva_valor(_d.inata, _nv));
        var _pas = _grid[# INFOS.PASSIVAS, _s];
        if (is_array(_pas)) {
            for (var _p = 0; _p < array_length(_pas); _p++) {
                var _pd = global.passivas_db[$ _pas[_p]];
                if (!is_undefined(_pd)) _equip_somar(_e, _pd.stat, passiva_valor(_pas[_p], _nv));
            }
        }
    }

    if (variable_global_exists("buffs_ativos")) {
        for (var _b = 0; _b < array_length(global.buffs_ativos); _b++) {
            _equip_somar(_e, global.buffs_ativos[_b].stat, global.buffs_ativos[_b].valor);
        }
    }
    global.equip_stats = _e;
    return _e;
}

/// @desc Recalcula ataque/defesa/velocidade/vida do player. Chame sempre que equipar algo.
function player_stats_recalcular() {
    hotbar_atualizar_armamento(); // o item ativo da hotbar define espada / arco / nada
    var _e = equip_calcular_bonus();
    if (!variable_global_exists("equip_aplicado")) global.equip_aplicado = { vel: 0, vida: 0 };

    if (instance_exists(obj_skill_manager)) {
        // O skill manager recalcula do zero e chama equip_aplicar_pos_skill() no fim
        obj_skill_manager.recalculate_player_stats();
    } else {
        // Sem skill manager: aplica só a diferença (não quebra slow, dash, etc.)
        global.speed_player += _e.vel  - global.equip_aplicado.vel;
        global.vida_max     += _e.vida - global.equip_aplicado.vida;
        global.equip_aplicado = { vel: _e.vel, vida: _e.vida };
        var _lvl = global.level_player;
        var _base = (variable_global_exists("dano_base") && _lvl < array_length(global.dano_base)) ? global.dano_base[_lvl] : 6;
        global.ataque_sem_crit = (_base + _e.dano) * (1 + _e.dano_pct / 100);
        global.ataque          = global.ataque_sem_crit;
    }
    global.armadura_bebe = _e.defesa;
    global.mata_fantasma = _e.mata_fantasma;
    global.vida = min(global.vida, global.vida_max);
}

/// @desc Chamado no fim de obj_skill_manager.recalculate_player_stats()
function equip_aplicar_pos_skill() {
    if (!variable_global_exists("equip_stats")) return;
    var _e = global.equip_stats;
    global.speed_player += _e.vel;
    global.vida_max     += _e.vida;
    global.equip_aplicado = { vel: _e.vel, vida: _e.vida };
    global.ataque_sem_crit = (global.ataque + _e.dano) * (1 + _e.dano_pct / 100);
    global.ataque          = global.ataque_sem_crit;
    global.armadura_bebe   = _e.defesa;
    global.mata_fantasma   = _e.mata_fantasma;
}

/// @desc Dano que o player realmente recebe (defesa + esquiva). 0 = esquivou.
function player_dano_recebido(_dano) {
    var _e = variable_global_exists("equip_stats") ? global.equip_stats : equip_stats_zero();
    if (_e.esquiva > 0 && random(100) < min(_e.esquiva, 60)) {
        var _p = (variable_global_exists("current_player") && instance_exists(global.current_player)) ? global.current_player : obj_player;
        with (_p) { tomar_dano = false; alarm[ALARM_INVENCIBILIDADE] = 40; player_sinal_dano(c_aqua, 40); }
        return 0;
    }
    var _reducao = min(0.6, max(0, global.armadura_bebe) * 0.025); // 1 de defesa = 2.5%, máx 60%
    _reducao = min(0.75, _reducao + mods_get().reducao_dano);         // + Curativo / pet Tartaruga
    return max(1, round(_dano * (1 - _reducao)));
}

/// @desc Adiciona um buff temporário (consumíveis)
function buff_adicionar(_stat, _valor, _seg, _origem = "") {
    if (!variable_global_exists("buffs_ativos")) global.buffs_ativos = [];
    // Mesmo buff da mesma origem: renova o tempo
    for (var _i = 0; _i < array_length(global.buffs_ativos); _i++) {
        var _b = global.buffs_ativos[_i];
        if (_b.stat == _stat && _b.origem == _origem) { _b.timer = _seg * game_get_speed(gamespeed_fps); player_stats_recalcular(); return; }
    }
    array_push(global.buffs_ativos, { stat: _stat, valor: _valor, timer: _seg * game_get_speed(gamespeed_fps), max: _seg * game_get_speed(gamespeed_fps), origem: _origem });
    player_stats_recalcular();
}

/// @desc Roda todo frame (obj_inventario Step): regeneração e tempo dos buffs
function itens_passivas_tick() {
    if (!variable_global_exists("equip_stats")) return;
    if (variable_global_exists("level_up") && global.level_up) return;

    // Regeneração (vida por segundo)
    var _regen = global.equip_stats.regen;
    if (_regen > 0 && global.vida > 0 && global.vida < global.vida_max) {
        global.vida = min(global.vida_max, global.vida + _regen / game_get_speed(gamespeed_fps));
    }

    // Sanidade, espinhos, recarga do X e efeitos (scr_passivas_itens)
    itens_passivas_especiais_tick();

    // Buffs
    if (!variable_global_exists("buffs_ativos")) return;
    var _mudou = false;
    for (var _i = array_length(global.buffs_ativos) - 1; _i >= 0; _i--) {
        var _bf = global.buffs_ativos[_i];
        _bf.timer -= 1;
        if (_bf.timer <= 0) { array_delete(global.buffs_ativos, _i, 1); _mudou = true; }
    }
    if (_mudou) player_stats_recalcular();
}

#endregion

#region ---------- CRAFT ----------

/// @desc Retorna [sprite, frame] de um item pelo ID
function crafting_get_item_dados(_item_id) {
    var _d = item_db(_item_id);
    if (is_undefined(_d)) return [noone, 0];
    return [_d.spr, _d.img];
}

function player_has_all_ingredients(_receita) {
    for (var _j = 0; _j < array_length(_receita.ingredientes); _j++) {
        var _req = _receita.ingredientes[_j];
        if (inventory_count_item(_req.item) < _req.qtd) return false;
    }
    return true;
}

/// @desc Atualiza a lista de receitas disponíveis e a ordem de exibição (disponíveis primeiro)
function atualizar_crafts_disponiveis() {
    if (!instance_exists(obj_inventario)) return;
    with (obj_inventario) {
        ds_list_clear(crafts_disponiveis);
        craft_ordem = [];
        if (!variable_global_exists("receitas_craft") || !is_array(global.receitas_craft)) return;
        var _n = array_length(global.receitas_craft);
        var _resto = [];
        for (var _i = 0; _i < _n; _i++) {
            if (player_has_all_ingredients(global.receitas_craft[_i])) { ds_list_add(crafts_disponiveis, _i); array_push(craft_ordem, _i); }
            else array_push(_resto, _i);
        }
        for (var _i = 0; _i < array_length(_resto); _i++) array_push(craft_ordem, _resto[_i]);
    }
}

/// @desc Faz o craft da receita de índice _i
function craft_fazer(_i) {
    var _rec = global.receitas_craft[_i];
    if (!player_has_all_ingredients(_rec)) { inventory_msg("Faltam materiais!", c_red); return false; }

    // Garante espaço antes de consumir
    var _d = item_db(_rec.resultado);
    if (inventory_find_empty_slot() == -1 && !(_d.stack && inventory_count_item(_rec.resultado) > 0)) {
        inventory_msg("Mochila cheia!", c_red);
        return false;
    }
    for (var _j = 0; _j < array_length(_rec.ingredientes); _j++) {
        inventory_remove_item(_rec.ingredientes[_j].item, _rec.ingredientes[_j].qtd);
    }
    inventory_add(_rec.resultado, _rec.qtd_resultado);
    inventory_msg("Criou " + _d.nome + (_rec.qtd_resultado > 1 ? " x" + string(_rec.qtd_resultado) : "") + "!", item_raridade(_d.raridade).cor);
    return true;
}

#endregion

#region ---------- DROPS ESPECÍFICOS ----------

/// @desc Cria um item específico no chão (monstros, árvores, pedras)
/// @arg _nome_item  nome ou ID do item
/// @arg _raridade   chance (0-100) de NÃO dropar. 0 = sempre dropa.
function criar_drop_especifico(_pos_x, _pos_y, _nome_item, _quantidade, _raridade = 0) {
    if (_quantidade <= 0) return;
    if (random(100) < clamp(_raridade, 0, 100)) return;
    var _id = item_id_por_nome(_nome_item);
    if (is_undefined(_id)) { show_debug_message("ERRO AO DROPAR: o item '" + string(_nome_item) + "' não existe na database!"); return; }
    var _ex = item_sortear_extras(_id);
    item_criar_no_mundo(_pos_x, _pos_y, _id, _quantidade, _ex.nivel, _ex.passivas);
}

#endregion

#region ---------- TOOLTIP (texto ao passar o mouse) ----------

/// @desc Monta as linhas do tooltip de um item.
/// Cada linha: { t: texto, c: cor, s: escala relativa, estrelas: nível (opcional) }
function item_tooltip_linhas(_id, _nivel, _passivas, _qtd = 1, _contexto = "mochila", _xp = -1) {
    var _L = [];
    var _d = item_db(_id);
    if (is_undefined(_d)) {
        array_push(_L, { t: string(_id), c: c_white, s: 1.2 });
        return _L;
    }
    var _rar = item_raridade(_d.raridade);
    var _equip = item_tipo_e_equipamento(_d.tipo);

    array_push(_L, { t: _d.nome, c: _rar.cor, s: 1.25 });
    array_push(_L, { t: item_tipo_nome(_d.tipo) + "  -  " + _rar.nome, c: make_color_rgb(190, 180, 170), s: 0.85 });
    if (_equip) {
        var _txt_nv = "Nv " + string(floor(_nivel));
        if (_xp >= 0) _txt_nv += "   XP " + string(floor(_xp)) + "/" + string(item_xp_prox(_nivel));
        array_push(_L, { t: _txt_nv, c: make_color_rgb(255, 220, 90), s: 0.9 });
    }

    // Atributos
    var _ordem = ["dano", "defesa", "vel", "vida", "crit"];
    for (var _k = 0; _k < array_length(_ordem); _k++) {
        var _v = item_stat(_id, _ordem[_k], _nivel);
        if (_v == 0) continue;
        var _inf = item_stat_info(_ordem[_k]);
        var _prox = "";
        if (_equip && _v > 0) _prox = "   (Nv" + string(_nivel + 1) + ": " + item_num_str(item_stat(_id, _ordem[_k], _nivel + 1)) + ")";
        array_push(_L, { t: (_v > 0 ? "+" : "") + item_num_str(_v) + _inf.sufixo + " " + _inf.nome + _prox, c: (_v > 0 ? _inf.cor : c_red), s: 1 });
    }

    // Hotbar: o que a arma/arco/luz faz
    if (_d.tipo == "arco" && is_struct(_d.arco)) {
        var _txt_arco = (_d.arco.flechas > 1 ? string(_d.arco.flechas) + " flechas por tiro, " : "") + "flecha " + (_d.arco.vel >= 15 ? "muito rápida" : (_d.arco.vel >= 12 ? "rápida" : "lenta"));
        array_push(_L, { t: _txt_arco, c: make_color_rgb(200, 230, 255), s: 0.9 });
    }
    if (_d.tipo == "arma" && is_struct(_d.espada) && _d.espada.alcance != 1) {
        array_push(_L, { t: "Golpe " + (_d.espada.alcance > 1 ? "grande" : "curtinho") + " (" + string(round(_d.espada.alcance * 100)) + "%)", c: make_color_rgb(200, 230, 255), s: 0.9 });
    }
    if (_d.tipo == "luz" && is_struct(_d.luz)) {
        array_push(_L, { t: "Ilumina " + string(_d.luz.raio) + " px em volta e acalma (sanidade)", c: make_color_rgb(255, 235, 150), s: 0.9 });
    }
    if (_d.tipo == "arma") array_push(_L, { t: "X: Giro (acerta tudo em volta)", c: make_color_rgb(255, 200, 120), s: 0.9 });
    if (_d.tipo == "arco") array_push(_L, { t: "X: Chuva de flechas em leque", c: make_color_rgb(255, 200, 120), s: 0.9 });
    if (_d.tipo == "coleta" && is_struct(_d.coleta)) {
        var _alvo_txt = (_d.coleta.tipo == "machado") ? "árvores" : ((_d.coleta.tipo == "picareta") ? "pedras" : "montinhos de terra");
        array_push(_L, { t: "Quebra " + _alvo_txt + " (força " + string(_d.coleta.forca) + ")", c: make_color_rgb(200, 230, 255), s: 0.9 });
    }
    if (item_tipo_ferramenta(_d.tipo) || _d.tipo == "coleta") array_push(_L, { t: "Coloque na hotbar (1-4) para usar", c: make_color_rgb(170, 160, 150), s: 0.8 });
    else if (_d.tipo == "uso" || _d.tipo == "colocavel") array_push(_L, { t: "Pode ir na hotbar: clique esquerdo usa", c: make_color_rgb(170, 160, 150), s: 0.8 });

    // Consumível: cura e buffs
    if (_d.tipo == "uso") {
        var _cura = item_stat(_id, "cura", 1);
        if (_cura > 0) array_push(_L, { t: "+" + string(_cura) + " Vida", c: make_color_rgb(120, 240, 140), s: 1 });
        for (var _b = 0; _b < array_length(_d.buffs); _b++) {
            var _bf = _d.buffs[_b];
            var _inf = item_stat_info(_bf.stat);
            array_push(_L, { t: "+" + item_num_str(_bf.valor) + _inf.sufixo + " " + _inf.nome + " por " + string(_bf.seg) + "s", c: _inf.cor, s: 1 });
        }
    }

    // Adesivo: mostra a passiva que ele dá
    if (_d.tipo == "adesivo" && _d.passiva_adesivo != "") {
        var _pd = global.passivas_db[$ _d.passiva_adesivo];
        array_push(_L, { t: _pd.nome + ": " + passiva_texto(_d.passiva_adesivo, 1), c: _pd.cor, s: 1 });
        array_push(_L, { t: "(fica mais forte conforme o nível do item)", c: make_color_rgb(170, 160, 150), s: 0.8 });
    }

    // Passivas do equipamento
    if (_equip) {
        if (_d.inata != "") {
            var _pi = global.passivas_db[$ _d.inata];
            array_push(_L, { t: "* " + _pi.nome + " (própria): " + passiva_texto(_d.inata, _nivel), c: make_color_rgb(255, 210, 80), s: 0.95 });
        }
        var _slots = item_slots_passiva(_nivel);
        var _np = is_array(_passivas) ? array_length(_passivas) : 0;
        for (var _p = 0; _p < _slots; _p++) {
            if (_p < _np) {
                var _pd2 = global.passivas_db[$ _passivas[_p]];
                if (!is_undefined(_pd2)) array_push(_L, { t: "> " + _pd2.nome + ": " + passiva_texto(_passivas[_p], _nivel), c: _pd2.cor, s: 0.95 });
            } else {
                array_push(_L, { t: "[ espaço de passiva vazio: cole um adesivo ]", c: make_color_rgb(140, 130, 120), s: 0.85 });
            }
        }
        array_push(_L, { t: "Equipado, sobe de nível matando monstros", c: make_color_rgb(140, 200, 120), s: 0.8 });
    }

    array_push(_L, { t: _d.desc, c: make_color_rgb(230, 220, 205), s: 0.9, wrap: true });

    var _preco_txt = "Valor: " + string(_d.preco) + " moedas";
    if (_qtd > 1) _preco_txt += "   |   Quantidade: " + string(_qtd);
    array_push(_L, { t: _preco_txt, c: make_color_rgb(255, 215, 100), s: 0.85 });

    // Dicas de controle
    var _dica = "";
    switch (_contexto) {
        case "mochila":
            if (_d.tipo == "uso")      _dica = "Botão dir./E: usar  |  F: soltar";
            else if (_equip)           _dica = "Botão dir./E: equipar  |  Clique: oficina  |  F: soltar";
            else if (_d.tipo == "adesivo") _dica = "Arraste até um equipamento  |  F: soltar";
            else                       _dica = "Arraste para organizar  |  F: soltar";
            break;
        case "equipado": _dica = "Botão dir./E: desequipar  |  Clique: oficina"; break;
        case "craft":    _dica = "Clique em CRIAR para fazer"; break;
    }
    if (_dica != "") array_push(_L, { t: _dica, c: make_color_rgb(150, 140, 130), s: 0.75 });
    return _L;
}

/// @desc Desenha estrelinha (nível) — usada no tooltip e na oficina
function draw_estrela(_x, _y, _r, _cor, _alpha = 1) {
    draw_set_alpha(_alpha);
    draw_set_color(c_black);
    draw_primitive_begin(pr_trianglefan);
    draw_vertex(_x, _y);
    for (var _i = 0; _i <= 10; _i++) {
        var _rr = ((_i mod 2) == 0 ? _r + 1.5 : _r * 0.45 + 1.5);
        var _a = -90 + _i * 36;
        draw_vertex(_x + lengthdir_x(_rr, _a), _y + lengthdir_y(_rr, _a));
    }
    draw_primitive_end();
    draw_set_color(_cor);
    draw_primitive_begin(pr_trianglefan);
    draw_vertex(_x, _y);
    for (var _i = 0; _i <= 10; _i++) {
        var _rr = ((_i mod 2) == 0 ? _r : _r * 0.45);
        var _a = -90 + _i * 36;
        draw_vertex(_x + lengthdir_x(_rr, _a), _y + lengthdir_y(_rr, _a));
    }
    draw_primitive_end();
    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// @desc Texto com contorno e escala (para a UI do inventário)
function ui_text(_x, _y, _txt, _cor, _escala, _contorno = c_black) {
    draw_set_color(_contorno);
    var _o = max(1, round(_escala * 1.5));
    draw_text_transformed(_x - _o, _y, _txt, _escala, _escala, 0);
    draw_text_transformed(_x + _o, _y, _txt, _escala, _escala, 0);
    draw_text_transformed(_x, _y - _o, _txt, _escala, _escala, 0);
    draw_text_transformed(_x, _y + _o, _txt, _escala, _escala, 0);
    draw_set_color(_cor);
    draw_text_transformed(_x, _y, _txt, _escala, _escala, 0);
    draw_set_color(c_white);
}

/// @desc Texto que diminui sozinho para caber na largura _w
function ui_text_fit(_x, _y, _txt, _cor, _escala, _w) {
    var _sw = string_width(_txt) * _escala;
    if (_sw > _w && _sw > 0) _escala *= _w / _sw;
    ui_text(_x, _y, _txt, _cor, _escala);
}

#endregion

#region ---------- UI: PEÇAS DE DESENHO DO INVENTÁRIO (cards, barras, pílulas, botões) ----------
// Todas recebem coordenadas/tamanhos já em pixels da GUI.

/// Paleta da UI (tons de pergaminho/madeira que combinam com o spr_iinventario)
function ui_cor(_nome) {
    switch (_nome) {
        case "papel":      return make_color_rgb(240, 228, 206);
        case "papel2":     return make_color_rgb(226, 209, 182);
        case "chip":       return make_color_rgb(250, 241, 224);
        case "borda":      return make_color_rgb(122, 74, 46);
        case "borda2":     return make_color_rgb(168, 122, 86);
        case "texto":      return make_color_rgb(72, 46, 34);
        case "texto2":     return make_color_rgb(132, 100, 78);
        case "ouro":       return make_color_rgb(255, 200, 58);
        case "verde":      return make_color_rgb(82, 176, 72);
        case "vermelho":   return make_color_rgb(214, 66, 58);
        case "azul":       return make_color_rgb(70, 140, 222);
        case "escuro":     return make_color_rgb(52, 32, 26);
    }
    return c_white;
}

function ui_rrect(_x1, _y1, _x2, _y2, _r, _col, _a = 1) {
    draw_set_alpha(_a);
    draw_set_color(_col);
    if (_r <= 0.5) draw_rectangle(_x1, _y1, _x2, _y2, false);
    else draw_roundrect_ext(_x1, _y1, _x2, _y2, _r, _r, false);
    draw_set_alpha(1);
}

/// Card com sombra, borda, preenchimento e brilho no topo
function ui_card(_x1, _y1, _x2, _y2, _r, _fill, _border, _bw = 2, _sombra = true) {
    if (_sombra) ui_rrect(_x1 + _bw, _y1 + _bw * 1.5, _x2 + _bw, _y2 + _bw * 1.5, _r, c_black, 0.22);
    ui_rrect(_x1, _y1, _x2, _y2, _r, _border);
    ui_rrect(_x1 + _bw, _y1 + _bw, _x2 - _bw, _y2 - _bw, max(0, _r - _bw), _fill);
    var _hy = _y1 + (_y2 - _y1) * 0.45;
    if (_hy - _y1 > _bw * 4) ui_rrect(_x1 + _bw * 2, _y1 + _bw * 2, _x2 - _bw * 2, _hy, max(0, _r - _bw * 2), c_white, 0.09);
}

/// Barra arredondada (vida, XP)
function ui_bar(_x1, _y1, _x2, _y2, _pct, _col, _bg = make_color_rgb(70, 44, 36)) {
    var _h = _y2 - _y1;
    var _r = _h / 2;
    var _b = max(1, round(_h * 0.14));
    ui_rrect(_x1, _y1, _x2, _y2, _r, ui_cor("escuro"));
    ui_rrect(_x1 + _b, _y1 + _b, _x2 - _b, _y2 - _b, max(0, _r - _b), _bg);
    var _w = (_x2 - _x1 - _b * 2) * clamp(_pct, 0, 1);
    if (_w > 1) {
        var _rr = min(max(0, _r - _b), _w / 2);
        ui_rrect(_x1 + _b, _y1 + _b, _x1 + _b + _w, _y2 - _b, _rr, _col);
        ui_rrect(_x1 + _b * 2, _y1 + _b * 1.6, _x1 + _b + _w - _b, _y1 + _h * 0.45, min(_rr, _h * 0.2), c_white, 0.32);
    }
}

/// Pílula com texto. Retorna a largura. (valign do texto: meio)
function ui_pill(_x, _y, _h, _txt, _bg, _fg, _ts, _contorno = undefined) {
    var _w = string_width(_txt) * _ts + _h * 0.9;
    ui_rrect(_x, _y, _x + _w, _y + _h, _h / 2, _bg);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    if (is_undefined(_contorno)) { draw_set_color(_fg); draw_text_transformed(_x + _w / 2, _y + _h / 2, _txt, _ts, _ts, 0); }
    else ui_text(_x + _w / 2, _y + _h / 2, _txt, _fg, _ts, _contorno);
    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
    return _w;
}

/// Desenha um sprite de item centralizado num quadrado de lado _size
function ui_icon(_spr, _img, _cx, _cy, _size, _a = 1) {
    if (!sprite_exists(_spr)) return;
    var _sw = sprite_get_width(_spr), _sh = sprite_get_height(_spr);
    var _k = _size / max(_sw, _sh);
    draw_sprite_ext(_spr, _img, _cx - (_sw / 2 - sprite_get_xoffset(_spr)) * _k, _cy - (_sh / 2 - sprite_get_yoffset(_spr)) * _k, _k, _k, 0, c_white, _a);
}

/// Ícone de um item da database pelo ID
function ui_icon_item(_id, _cx, _cy, _size, _a = 1) {
    var _d = item_db(_id);
    if (!is_undefined(_d)) ui_icon(_d.spr, _d.img, _cx, _cy, _size, _a);
}

/// Item que representa cada atributo (usado como ícone)
function ui_icone_stat(_stat) {
    switch (_stat) {
        case "dano":       return "espada_madeira";
        case "defesa":     return "cavaleiro";
        case "vel":        return "tenis_corrida";
        case "vida":       return "ad_coracao";
        case "crit":       return "ad_estrela";
        case "dano_pct":   return "ad_forca";
        case "crit_dano":  return "ad_bum";
        case "regen":      return "chocolate";
        case "vampirismo": return "ad_vampiro";
        case "esquiva":    return "ad_nuvem";
    }
    return "";
}

/// Moedinha desenhada
function ui_moeda(_cx, _cy, _r) {
    draw_set_color(ui_cor("escuro"));                 draw_circle(_cx, _cy, _r + max(1, _r * 0.18), false);
    draw_set_color(make_color_rgb(214, 140, 20));     draw_circle(_cx, _cy, _r, false);
    draw_set_color(make_color_rgb(255, 204, 52));     draw_circle(_cx - _r * 0.08, _cy - _r * 0.08, _r * 0.8, false);
    draw_set_color(make_color_rgb(255, 240, 160));    draw_circle(_cx - _r * 0.32, _cy - _r * 0.32, _r * 0.25, false);
    draw_set_color(c_white);
}

/// Botão com sombra, brilho e efeito de apertar. Retorna true se o mouse está em cima.
function ui_button(_x1, _y1, _x2, _y2, _txt, _ativo, _col, _ts, _mx, _my) {
    var _hover = point_in_rectangle(_mx, _my, _x1, _y1, _x2, _y2);
    var _press = _hover && _ativo && mouse_check_button(mb_left);
    var _h = _y2 - _y1;
    var _r = _h * 0.32;
    var _dep = max(2, round(_h * 0.12));
    var _c = _ativo ? _col : make_color_rgb(150, 136, 122);
    if (_ativo && _hover && !_press) _c = merge_color(_c, c_white, 0.18);
    var _oy = _press ? _dep : 0;
    ui_rrect(_x1, _y1 + _dep, _x2, _y2 + _dep, _r, ui_cor("escuro"));                  // base/sombra
    ui_rrect(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, ui_cor("escuro"));
    var _b = max(1, round(_h * 0.08));
    ui_rrect(_x1 + _b, _y1 + _b + _oy, _x2 - _b, _y2 - _b + _oy, max(0, _r - _b), _c);
    ui_rrect(_x1 + _b * 2, _y1 + _b * 2 + _oy, _x2 - _b * 2, _y1 + _h * 0.36 + _oy, max(0, _r - _b * 2), c_white, _ativo ? 0.2 : 0.08);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    ui_text((_x1 + _x2) / 2, (_y1 + _y2) / 2 + _oy, _txt, _ativo ? c_white : make_color_rgb(225, 215, 205), _ts, merge_color(_c, c_black, 0.6));
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    return _hover;
}

/// Fita/aba de título que fica em cima da moldura de um painel
function ui_tab(_x, _y, _h, _txt, _col, _ts) {
    var _w = string_width(_txt) * _ts + _h * 1.4;
    ui_rrect(_x + 2, _y + 3, _x + _w + 2, _y + _h + 3, _h * 0.3, c_black, 0.3);
    ui_rrect(_x, _y, _x + _w, _y + _h, _h * 0.3, ui_cor("escuro"));
    var _b = max(1, round(_h * 0.1));
    ui_rrect(_x + _b, _y + _b, _x + _w - _b, _y + _h - _b, _h * 0.25, _col);
    ui_rrect(_x + _b * 2, _y + _b * 2, _x + _w - _b * 2, _y + _h * 0.45, _h * 0.2, c_white, 0.25);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    ui_text(_x + _w / 2, _y + _h / 2, _txt, c_white, _ts, merge_color(_col, c_black, 0.65));
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    return _w;
}

/// Encaixe redondo de adesivo
function ui_socket(_cx, _cy, _r, _aberto, _cor_glow = c_white) {
    draw_set_color(ui_cor("escuro")); draw_circle(_cx, _cy, _r + max(1, _r * 0.15), false);
    draw_set_color(_aberto ? make_color_rgb(198, 176, 148) : make_color_rgb(118, 100, 86)); draw_circle(_cx, _cy, _r, false);
    draw_set_color(_aberto ? make_color_rgb(170, 146, 118) : make_color_rgb(98, 82, 70));   draw_circle(_cx + _r * 0.12, _cy + _r * 0.12, _r * 0.78, false);
    draw_set_color(c_white);
}

#endregion

#region ---------- HOTBAR (4 espaços na esquerda: armas, arcos e luzes) ----------
// Os 4 espaços ficam no FIM da global.grid_itens, depois dos 3 equipamentos:
//   [0 .. mochila-1] mochila | [mochila .. +2] chapéu/armadura/calçado | [mochila+3 .. +6] hotbar
// Aceita armas, arcos, luzes, consumíveis e colocáveis (item_tipo_hotbar).
// Só o item ATIVO da hotbar dá atributos (equip_calcular_bonus) e define o ataque (global.armamento).
// Trocar: teclas 1 2 3 4 (configuráveis: espada, arco, hot3, hot4) ou roda do mouse.
// O zoom da câmera passou para Ctrl + roda (Camera.gml).
#macro HOTBAR_SLOTS 4

function hotbar_primeiro_slot() { return inventory_bag_slots() + 3; }
function hotbar_slot(_i)        { return hotbar_primeiro_slot() + _i; }
function hotbar_e_slot(_slot)   { var _h = hotbar_primeiro_slot(); return _slot >= _h && _slot < _h + HOTBAR_SLOTS; }

function hotbar_ativo() {
    if (!variable_global_exists("hotbar_ativo")) global.hotbar_ativo = 0;
    return global.hotbar_ativo;
}

/// ID do item no espaço _i da hotbar (-1 = vazio)
function hotbar_item_id(_i) {
    if (!variable_global_exists("grid_itens") || !ds_exists(global.grid_itens, ds_type_grid)) return -1;
    var _s = hotbar_slot(_i);
    if (_s < 0 || _s >= ds_grid_height(global.grid_itens)) return -1;
    return global.grid_itens[# INFOS.ITEM, _s];
}

/// Dados (item_db) do item na mão, ou undefined
function hotbar_ativo_db() {
    var _id = hotbar_item_id(hotbar_ativo());
    if (_id == -1) return undefined;
    return item_db(_id);
}

/// Espada / arco / nada (luz e espaço vazio não atacam)
function hotbar_atualizar_armamento() {
    var _d = hotbar_ativo_db();
    var _t = is_undefined(_d) ? "" : _d.tipo;
    if (_t == "arma" || _t == "coleta") global.armamento = ARMAMENTOS.ESPADA; // ferramenta de coleta golpeia igual à espada
    else if (_t == "arco") global.armamento = ARMAMENTOS.ARCO;
    else                   global.armamento = ARMAMENTOS.ALTURA; // nenhum ataque
}

/// Seleciona o espaço _i (dá a volta: 4 -> 0, -1 -> 3)
function hotbar_selecionar(_i) {
    global.hotbar_ativo = ((_i mod HOTBAR_SLOTS) + HOTBAR_SLOTS) mod HOTBAR_SLOTS;
    global.hotbar_aviso = 90;   // mostra o nome do item por um tempinho
    player_stats_recalcular();  // também atualiza global.armamento
    with (obj_player) { dir_alfa = 1; desenha_arma = true; }
}

/// Clique esquerdo com consumível/colocável na mão: usa (cura/buff gasta 1; baú entra no modo posicionar)
function hotbar_usar_ativo() {
    if (instance_exists(obj_inventario) && obj_inventario.is_open) exit;
    if (variable_global_exists("colocando_bau") && is_struct(global.colocando_bau) && variable_struct_exists(global.colocando_bau, "ativo") && global.colocando_bau.ativo) exit;
    var _d = hotbar_ativo_db();
    if (is_undefined(_d)) exit;
    var _s = hotbar_slot(hotbar_ativo());
    if (_d.tipo == "uso") {
        inventory_use_item(_s);
        player_stats_recalcular();    // acabou a pilha: a mão fica vazia
    } else if (_d.tipo == "colocavel") {
        colocar_bau_iniciar(_s);
    }
}

/// Teclas 1-4 e roda do mouse (chamado no Step do obj_player)
function hotbar_input() {
    if (variable_global_exists("level_up") && global.level_up) exit;
    if (instance_exists(obj_inventario) && obj_inventario.is_open) exit;
    if (variable_global_exists("bau_aberto") && instance_exists(global.bau_aberto)) exit;
    var _acoes = ["espada", "arco", "hot3", "hot4"];
    for (var _i = 0; _i < HOTBAR_SLOTS; _i++) {
        var _k = tecla(_acoes[_i]);
        if (_k <= 0) _k = ord(string(_i + 1));
        if (keyboard_check_pressed(_k)) { hotbar_selecionar(_i); exit; }
    }
    if (!keyboard_check(vk_control)) {
        if (mouse_wheel_down()) hotbar_selecionar(hotbar_ativo() + 1);
        else if (mouse_wheel_up()) hotbar_selecionar(hotbar_ativo() - 1);
    }
    if (variable_global_exists("hotbar_aviso") && global.hotbar_aviso > 0) global.hotbar_aviso--;
}

/// Luz na mão: o player vira uma fonte de luz (global.lista_luzes) — clareia a noite e recupera
/// sanidade (o loop de sanidade do obj_player já usa a lista). Chamar no escopo do obj_player.
function hotbar_luz_atualizar() {
    if (!variable_global_exists("lista_luzes") || !ds_exists(global.lista_luzes, ds_type_list)) exit;
    var _d = hotbar_ativo_db();
    var _luz = (!is_undefined(_d) && is_struct(_d.luz)) ? _d.luz : undefined;
    var _pos = ds_list_find_index(global.lista_luzes, id);
    if (!is_undefined(_luz)) {
        var _r = _luz.raio;
        luz_1 = _r; luz_2 = _r * 0.75; luz_3 = _r * 0.45; luz_4 = _r * 0.3; luz_5 = _r * 0.2;
        light_intensity = _luz.intensidade;
        light_color     = _luz.cor;
        light_style     = _luz.estilo;
        light_offset_x  = 0;
        light_offset_y  = -20;
        global.luz_item_raio = _r;
        if (_pos == -1) ds_list_add(global.lista_luzes, id);
    } else {
        global.luz_item_raio = 0;
        if (_pos != -1) ds_list_delete(global.lista_luzes, _pos);
    }
}

/// Retângulo (GUI) do espaço _i da hotbar: coluna pequena no meio da borda esquerda
function hotbar_rect(_i) {
    var _gh = display_get_gui_height();
    var _k  = max(1, _gh / 360);
    var _tam = 22 * _k, _gap = 4 * _k;
    var _y0 = _gh / 2 - (HOTBAR_SLOTS * _tam + (HOTBAR_SLOTS - 1) * _gap) / 2;
    var _x0 = 8 * _k;
    var _y = _y0 + _i * (_tam + _gap);
    return [_x0, _y, _x0 + _tam, _y + _tam];
}

/// Desenha a hotbar (Draw GUI do obj_inventario). Com o inventário aberto, os ícones
/// são desenhados pelo loop de slots do inventário (para arrastar e soltar); aqui só o fundo.
function hotbar_desenhar(_inventario_aberto) {
    if (variable_global_exists("level_up") && global.level_up) exit;
    var _ativo = hotbar_ativo();
    var _k = max(1, display_get_gui_height() / 360);
    draw_set_font(fnt_descricao);
    var _fh = max(1, string_height("Ag"));
    for (var _i = 0; _i < HOTBAR_SLOTS; _i++) {
        var _r = hotbar_rect(_i);
        var _sel = (_i == _ativo);
        // fundo
        draw_set_alpha(_inventario_aberto ? 0.95 : 0.75);
        draw_set_color(make_color_rgb(52, 32, 26));
        draw_roundrect_ext(_r[0] - _k, _r[1] - _k, _r[2] + _k, _r[3] + _k, 6 * _k, 6 * _k, false);
        draw_set_color(_sel ? make_color_rgb(255, 236, 190) : make_color_rgb(222, 202, 176));
        draw_roundrect_ext(_r[0], _r[1], _r[2], _r[3], 5 * _k, 5 * _k, false);
        draw_set_alpha(1);
        if (_sel) {
            draw_set_color(make_color_rgb(255, 200, 60));
            for (var _b = 0; _b < 2 * _k; _b++) draw_roundrect_ext(_r[0] - _b, _r[1] - _b, _r[2] + _b, _r[3] + _b, 6 * _k, 6 * _k, true);
        }
        // ícone (inventário fechado)
        var _id = hotbar_item_id(_i);
        if (!_inventario_aberto && _id != -1) {
            var _d = item_db(_id);
            if (!is_undefined(_d) && sprite_exists(_d.spr)) {
                var _cx = (_r[0] + _r[2]) / 2, _cy = (_r[1] + _r[3]) / 2;
                var _is = (_r[2] - _r[0]) * 0.9 / max(sprite_get_width(_d.spr), sprite_get_height(_d.spr));
                draw_sprite_ext(_d.spr, _d.img, _cx - sprite_get_width(_d.spr) * _is / 2 + sprite_get_xoffset(_d.spr) * _is,
                                _cy - sprite_get_height(_d.spr) * _is / 2 + sprite_get_yoffset(_d.spr) * _is, _is, _is, 0, c_white, 1);
            }
        }
        // quantidade (consumíveis empilhados)
        if (!_inventario_aberto && _id != -1) {
            var _q = global.grid_itens[# INFOS.QUANTIDADE, hotbar_slot(_i)];
            if (_q > 1) {
                draw_set_halign(fa_right); draw_set_valign(fa_bottom);
                ui_text(_r[2] - 2 * _k, _r[3] - 1 * _k, string(_q), c_white, (7 * _k) / _fh);
            }
        }
        // recarga da habilidade X (só no item da mão)
        if (_sel && variable_global_exists("item_ativo_cd") && global.item_ativo_cd > 0) {
            var _pc = global.item_ativo_cd / max(1, global.item_ativo_cd_max);
            draw_set_alpha(0.55);
            draw_set_color(c_black);
            draw_rectangle(_r[0], _r[1], _r[2], _r[1] + (_r[3] - _r[1]) * _pc, false);
            draw_set_alpha(1);
            draw_set_halign(fa_center); draw_set_valign(fa_middle);
            ui_text((_r[0] + _r[2]) / 2, (_r[1] + _r[3]) / 2, string(ceil(global.item_ativo_cd / 60)), c_white, (8 * _k) / _fh);
        }
        // número do atalho
        draw_set_halign(fa_left); draw_set_valign(fa_top);
        ui_text(_r[0] + 2 * _k, _r[1] + 1 * _k, string(_i + 1), _sel ? make_color_rgb(255, 220, 90) : c_white, (7 * _k) / _fh);
    }
    // nome do item ativo logo depois de trocar
    if (!_inventario_aberto && variable_global_exists("hotbar_aviso") && global.hotbar_aviso > 0) {
        var _r = hotbar_rect(_ativo);
        var _d2 = hotbar_ativo_db();
        var _nome = is_undefined(_d2) ? "Mãos vazias" : _d2.nome;
        draw_set_alpha(min(1, global.hotbar_aviso / 20));
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        ui_text(_r[2] + 6 * _k, (_r[1] + _r[3]) / 2, _nome, is_undefined(_d2) ? c_ltgray : item_raridade(_d2.raridade).cor, (8 * _k) / _fh);
        draw_set_alpha(1);
    }
    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
}

#endregion
