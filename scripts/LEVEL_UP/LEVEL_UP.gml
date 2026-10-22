// feather disable GM2017
/// @desc Inicialização de Status e XP
/// [O QUE]: Define os atributos base do player e prepara as listas de upgrade.

// --- Status Básicos ---
global.level_player = 1;
global.xp = 0;
global.max_xp = 100; // XP inicial para o primeiro nível
global.level_up = false;

// --- Tabelas de Crescimento (Stats por Nível) ---
// Inicializa arrays para evitar erro de "index out of bounds"
global.vida_max_calc[1] = 100;
global.max_estamina_calc[1] = 50;
global.dano_base[1] = 6;

// Define valores atuais baseados no nível 1
global.vida_max = global.vida_max_calc[1];
global.vida = global.vida_max;

global.max_estamina = global.max_estamina_calc[1];
global.estamina = global.max_estamina;

global.ataque = global.dano_base[1];
global.critico = 0;

// --- Sistema de Upgrade ---
global.upgrades_vamp_list = ds_list_create(); // Lista que guardará as opções sorteadas
global.upgrade_num = 4; // Quantidade de opções que aparecem na tela (3 ou 4)

// ============================================================================
// 1. FUNÇÕES AUXILIARES DE SLOTS (4 ativos + 4 passivos)
// ============================================================================

/// @desc Linha da grid tem config válida (poder implementado)?
function upgrade_config_valida(_raw) {
    if (_raw == -1) return false;
    var _scr = is_string(_raw) ? asset_get_index(_raw) : _raw;
    return (_scr != -1 && (script_exists(_scr) || is_method(_scr) || is_real(_scr)));
}

/// @desc Quantos ATIVOS diferentes o jogador já tem (pet conta como ativo)
function slots_ativos_usados() {
    var _n = 0;
    var _g = global.upgrades_vamp_grid;
    for (var _i = 0; _i < ds_grid_height(_g); _i++) if (_g[# UPGRADES_VAMP.LEVEL, _i] > 0) _n++;
    return _n;
}

/// @desc Quantas PASSIVAS diferentes o jogador já tem
function slots_passivos_usados() {
    var _n = 0;
    var _g = global.itens_vamp_grid;
    for (var _i = 0; _i < ds_grid_height(_g); _i++) if (_g[# ITENS_VAMP.LEVEL, _i] > 0) _n++;
    return _n;
}

/// @desc Lista (array de structs) dos poderes que o jogador possui, para o painel da tela de level up
/// @param _tipo 0 = ativos, 1 = passivos
function poderes_possuidos(_tipo) {
    var _res = [];
    var _g = (_tipo == 0) ? global.upgrades_vamp_grid : global.itens_vamp_grid;
    var _col_lvl  = (_tipo == 0) ? UPGRADES_VAMP.LEVEL : ITENS_VAMP.LEVEL;
    var _col_cfg  = (_tipo == 0) ? UPGRADES_VAMP.CONFIG_SCRIPT : ITENS_VAMP.CONFIG_SCRIPT;
    var _col_nome = (_tipo == 0) ? UPGRADES_VAMP.NAME : ITENS_VAMP.NAME;
    for (var _i = 0; _i < ds_grid_height(_g); _i++) {
        var _lvl = _g[# _col_lvl, _i];
        if (_lvl <= 0) continue;
        var _spr = -1;
        var _max = 0;
        var _pet = false;
        var _raw = _g[# _col_cfg, _i];
        if (upgrade_config_valida(_raw)) {
            var _cfg = script_execute(is_string(_raw) ? asset_get_index(_raw) : _raw);
            if (variable_struct_exists(_cfg.stats_base, "sprite_icon")) _spr = _cfg.stats_base.sprite_icon;
            _max = array_length(_cfg.niveis);
            _pet = variable_struct_exists(_cfg, "pet") && _cfg.pet;
        }
        array_push(_res, { nome: _g[# _col_nome, _i], nivel: _lvl, sprite: _spr, max_nivel: -1, pet: (_tipo == 0) ? _pet : false });
    }
    return _res;
}

// ============================================================================
// 2. FUNÇÃO DE ABRIR O MENU DE CARTAS (sorteio)
// ============================================================================
/// @param _som toca o som de level up (false no "sortear de novo")
function level_upp(_som = true) 
{
    global.level_up = true; // Ativa flag para pausar a lógica do jogo e abrir o menu
    if (_som) audio_play_sound(snd_up, 1 , false);

    ds_list_clear(global.upgrades_vamp_list);
    var _pool = ds_list_create();

    // --- Regras de slot ---
    var _ativos_cheios   = slots_ativos_usados()   >= MAX_SLOTS_ATIVOS;
    var _passivos_cheios = slots_passivos_usados() >= MAX_SLOTS_PASSIVOS;
    var _pet_escolhido   = pet_linha_escolhida(); // -1 = nenhum pet ainda

    // ========================================================
    // --- A: ARMAS / PETS (Upgrades Ativos) ---
    // ========================================================
    var _grid_weapons = global.upgrades_vamp_grid;
    for (var _i = 0; _i < ds_grid_height(_grid_weapons); _i++) 
    {
        var _config_raw = _grid_weapons[# UPGRADES_VAMP.CONFIG_SCRIPT, _i];
        if (!upgrade_config_valida(_config_raw)) continue;

        var _curr_lvl_weapon = _grid_weapons[# UPGRADES_VAMP.LEVEL, _i];

        // Já tem 4 ativos: só aparecem os que você já possui
        if (_ativos_cheios && _curr_lvl_weapon <= 0) continue;

        var _skill_data = script_execute(is_string(_config_raw) ? asset_get_index(_config_raw) : _config_raw);
        var _is_pet = variable_struct_exists(_skill_data, "pet") && _skill_data.pet;

        // Só UM pet por partida: depois de escolher, os outros pets não aparecem mais
        if (_is_pet && _pet_escolhido != -1 && _pet_escolhido != _i) continue;

        var _max_lvl = array_length(_skill_data.niveis);
        var _next_level = _curr_lvl_weapon + 1;
        var _desc_final = _skill_data.niveis[_curr_lvl_weapon % _max_lvl].desc;
        var _sprite_final = variable_struct_exists(_skill_data.stats_base, "sprite_icon") ? _skill_data.stats_base.sprite_icon : -1;

        if (variable_struct_exists(_skill_data, "evolucao")) 
        {
            if (_next_level == _skill_data.evolucao.nivel) _desc_final = _skill_data.evolucao.desc;
            if (_curr_lvl_weapon >= _skill_data.evolucao.nivel - 1) _sprite_final = _skill_data.evolucao.sprite_icon;
        }

        var _ciclos = floor(_curr_lvl_weapon / _max_lvl);
        if (_ciclos > 0 && _next_level != 15) _desc_final += "\n[Ciclo " + string(_ciclos + 1) + "]";
        if (_is_pet && _curr_lvl_weapon <= 0) _desc_final += "\n(PET: SÓ PODE ESCOLHER UM)";

        ds_list_add(_pool, {
            nome: _grid_weapons[# UPGRADES_VAMP.NAME, _i],
            sprite: _sprite_final,
            description: _desc_final,
            next_level: _next_level,
            type: 0,
            id_grid: _i,
            novo: (_curr_lvl_weapon <= 0)
        });
    }

    // ========================================================
    // --- B: PASSIVAS ---
    // ========================================================
    var _grid_items = global.itens_vamp_grid;
    for (var _k = 0; _k < ds_grid_height(_grid_items); _k++) 
    {
        var _config_raw_item = _grid_items[# ITENS_VAMP.CONFIG_SCRIPT, _k];
        if (!upgrade_config_valida(_config_raw_item)) continue;

        var _curr_lvl_item = _grid_items[# ITENS_VAMP.LEVEL, _k];
        if (_passivos_cheios && _curr_lvl_item <= 0) continue;

        var _item_data = script_execute(is_string(_config_raw_item) ? asset_get_index(_config_raw_item) : _config_raw_item);
        var _max_lvl_item = array_length(_item_data.niveis);

        // Passivas não têm limite: depois do último nível o ciclo recomeça (igual às armas)
        var _desc_item = _item_data.niveis[_curr_lvl_item % _max_lvl_item].desc;
        var _ciclos_item = floor(_curr_lvl_item / _max_lvl_item);
        if (_ciclos_item > 0) _desc_item += "\n[Ciclo " + string(_ciclos_item + 1) + "]";

        ds_list_add(_pool, {
            nome: _grid_items[# ITENS_VAMP.NAME, _k],
            sprite: variable_struct_exists(_item_data.stats_base, "sprite_icon") ? _item_data.stats_base.sprite_icon : -1,
            description: _desc_item,
            next_level: _curr_lvl_item + 1,
            type: 1,
            id_grid: _k,
            novo: (_curr_lvl_item <= 0)
        });
    }

    // ========================================================
    // --- C: Embaralha e Seleciona ---
    // ========================================================
    ds_list_shuffle(_pool);
    var _picks = min(global.upgrade_num, ds_list_size(_pool));
    for (var _j = 0; _j < _picks; _j++) ds_list_add(global.upgrades_vamp_list, _pool[| _j]);

    // Nada para sortear (tudo no máximo): carta de cura
    if (_picks == 0) {
        ds_list_add(global.upgrades_vamp_list, {
            nome: "LANCHINHO",
            sprite: spr_lancheira_icon,
            description: "TUDO NO MÁXIMO!\nRECUPERA 30% DA VIDA.",
            next_level: 0,
            type: 3,
            id_grid: -1,
            novo: false
        });
    }

    ds_list_destroy(_pool);
}

/// @desc Sorteia as cartas de novo (botão da tela de level up, 3 usos por partida)
function level_up_resortear() {
    if (!variable_global_exists("rerolls_restantes")) global.rerolls_restantes = REROLLS_POR_PARTIDA;
    if (global.rerolls_restantes <= 0) return false;
    global.rerolls_restantes -= 1;
    level_upp(false);
    return true;
}

/// @desc Aplica a carta escolhida e cuida da fila de níveis acumulados
function level_up_aplicar_carta(_card) {
    switch (_card.type) {
        case 0: global.upgrades_vamp_grid[# UPGRADES_VAMP.LEVEL, _card.id_grid] += 1; break;
        case 1: global.itens_vamp_grid[# ITENS_VAMP.LEVEL, _card.id_grid] += 1;       break;
        case 3: global.vida = min(global.vida_max, global.vida + global.vida_max * 0.3); break;
    }

    // Passivas e bônus de pet valem para tudo na hora
    mods_recalcular();

    // Fila de level ups pendentes
    if (variable_global_exists("levels_pendentes")) {
        global.levels_pendentes -= 1;
        if (global.levels_pendentes > 0) {
            level_upp(); // sorteia as próximas cartas
        } else {
            global.level_up = false;
            global.levels_pendentes = 0;
        }
    } else {
        global.level_up = false;
    }
}


// ============================================================================
// 3. FUNÇÃO AUXILIAR DE MATEMÁTICA (Separada para organização)
// ============================================================================
function aplicar_status_level() {
    var _prev_lvl = global.level_player - 1;
    var _curr_lvl = global.level_player;

    // Garante que os arrays de cálculo cresçam
    if (_curr_lvl >= array_length(global.vida_max_calc)) {
        global.vida_max_calc[_curr_lvl]     = global.vida_max_calc[_prev_lvl] + (_curr_lvl * 0.8);
        global.max_estamina_calc[_curr_lvl] = global.max_estamina_calc[_prev_lvl] + 5;
        global.dano_base[_curr_lvl]         = global.dano_base[_prev_lvl] * 1.1;
    }

    global.max_estamina = global.max_estamina_calc[_curr_lvl];
    
    // Deixa o Skill Manager recalcular ataque, velocidade e vida máxima considerando passivas
    if (instance_exists(obj_skill_manager)) {
        obj_skill_manager.recalculate_player_stats();
    } else {
        global.vida_max = global.vida_max_calc[_curr_lvl] + (variable_global_exists("equip_aplicado") ? global.equip_aplicado.vida : 0);
    }
    // Ataque = base do nível + equipamentos/adesivos (scripts/inventario)
    player_stats_recalcular();
}


// ============================================================================
// 4. FUNÇÃO DE GANHAR XP (Com sistema de Fila de Level Up)
// ============================================================================
function ganhar_xp(_xp_amount) 
{
    global.xp += _xp_amount * mods_get().xp; // Estrelinha Dourada
    
    // Calcula o max_xp baseado no level atual
    global.max_xp = global.level_player * 100;
    
    // 1. Verifica quantos níveis foram subidos e acumula na fila
    while (global.xp >= global.max_xp) 
    {
        global.xp -= global.max_xp;
        global.level_player += 1;
        
        // Recalcula o max_xp pro PRÓXIMO nível dentro do loop
        global.max_xp = global.level_player * 100; 
        
        // Acumula na fila de upgrades pendentes
        global.levels_pendentes += 1;
        
        // Aplica os bônus matemáticos imediatamente (Vida, Estamina, Dano)
        aplicar_status_level(); 
    }
    
    // 2. Se subiu de nível e o jogo ainda não está pausado pelo Level Up, abre o menu
    if (global.levels_pendentes > 0 && global.level_up == false) 
    {
        level_upp();
    }
}

function calcular_critico() 
{
    // Ataque sem crítico já inclui equipamentos e adesivos (player_stats_recalcular)
    var _base = variable_global_exists("ataque_sem_crit") ? global.ataque_sem_crit : global.dano_base[global.level_player];
    var _e = variable_global_exists("equip_stats") ? global.equip_stats : undefined;

    // Chance baseada no nível (Nível 10 = 10%) + passivas/buffs de crítico
    var _chance = global.level_player * 1 + (is_undefined(_e) ? 0 : _e.crit) + mods_get().crit; // + Lupa
    var _mult   = 1.5 + (is_undefined(_e) ? 0 : _e.crit_dano / 100);

    if (irandom_range(1, 100) <= _chance) 
    {
        global.critico = 1; // Flag visual
        global.ataque = _base * _mult; // Dano Crítico
    } 
    else 
    {
        global.critico = 0;
        global.ataque = _base; // Dano Normal
    }

    // Vampirismo (Dentinho de Vampiro): cura uma parte do golpe
    if (!is_undefined(_e) && _e.vampirismo > 0) {
        global.vida = min(global.vida_max, global.vida + global.ataque * _e.vampirismo / 100);
    }
}

// ============================================================================
// 5. DESENHO DA TELA DE LEVEL UP (usado pelo obj_GUI/Draw_64)
// ============================================================================

/// @desc Desenha um ícone centralizado dentro de uma caixa, escalando pela bbox (pixel perfect)
function gui_icone_caber(_spr, _cx, _cy, _box_w, _box_h, _alpha = 1, _pad = 0.78) {
    if (!sprite_exists(_spr)) return;
    var _bl = sprite_get_bbox_left(_spr);
    var _bt = sprite_get_bbox_top(_spr);
    var _bw = max(1, sprite_get_bbox_right(_spr)  - _bl + 1);
    var _bh = max(1, sprite_get_bbox_bottom(_spr) - _bt + 1);
    if (_bw > sprite_get_width(_spr) || _bh > sprite_get_height(_spr)) {
        _bl = 0; _bt = 0;
        _bw = sprite_get_width(_spr);
        _bh = sprite_get_height(_spr);
    }
    var _fit = min((_box_w * _pad) / _bw, (_box_h * _pad) / _bh);
    if (_fit >= 3) _fit = floor(_fit);
    var _bcx = _bl + _bw / 2 - sprite_get_xoffset(_spr);
    var _bcy = _bt + _bh / 2 - sprite_get_yoffset(_spr);
    draw_sprite_ext(_spr, 0, _cx - _bcx * _fit, _cy - _bcy * _fit, _fit, _fit, 0, c_white, _alpha);
}

/// @desc Desenha um grupo de 4 slots (ativos ou passivos) com ícone e nível
/// @param _x1     x da borda esquerda do grupo
/// @param _cy     y do centro dos slots
/// @param _titulo texto acima do grupo
/// @param _lista  array de poderes_possuidos()
/// @param _max    quantidade de slots (4)
function gui_desenhar_slots(_x1, _cy, _titulo, _lista, _max, _slot, _gap) {
    var _w = _max * _slot + (_max - 1) * _gap;

    draw_set_font(fnt_descricao);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_white);
    draw_text_colour_outline_escalado(_x1 + _w / 2, _cy - _slot / 2 - 8,
        _titulo + " (" + string(array_length(_lista)) + "/" + string(_max) + ")", 3, c_black, 7, 30, 600, 1.2, 1.2);

    for (var _i = 0; _i < _max; _i++) {
        var _sx = _x1 + _i * (_slot + _gap);
        var _sy = _cy - _slot / 2;
        // Fundo do slot
        draw_set_alpha(0.75);
        draw_rectangle_color(_sx, _sy, _sx + _slot, _sy + _slot, c_black, c_black, c_black, c_black, false);
        draw_set_alpha(1);
        var _cor_borda = (_i < array_length(_lista)) ? make_color_rgb(255, 210, 63) : make_color_rgb(90, 90, 100);
        draw_rectangle_color(_sx, _sy, _sx + _slot, _sy + _slot, _cor_borda, _cor_borda, _cor_borda, _cor_borda, true);
        draw_rectangle_color(_sx + 1, _sy + 1, _sx + _slot - 1, _sy + _slot - 1, _cor_borda, _cor_borda, _cor_borda, _cor_borda, true);

        if (_i < array_length(_lista)) {
            var _p = _lista[_i];
            gui_icone_caber(_p.sprite, _sx + _slot / 2, _sy + _slot / 2 - 4, _slot, _slot, 1, 0.72);
            // Nível
            var _txt = (_p.max_nivel > 0 && _p.nivel >= _p.max_nivel) ? "MAX" : "Nv" + string(_p.nivel);
            draw_set_halign(fa_right);
            draw_set_valign(fa_bottom);
            draw_set_color(_p.pet ? make_color_rgb(140, 255, 160) : c_white);
            draw_text_colour_outline_escalado(_sx + _slot - 3, _sy + _slot - 1, _txt, 2, c_black, 7, 30, 200, 0.9, 0.9);
            draw_set_color(c_white);
            draw_set_halign(fa_center);
        }
    }
}


/// @desc Tela de level up completa (cartas, painel de poderes e botão de sortear de novo).
///       Chamada no Draw GUI do obj_GUI e do obj_tutorial_controller enquanto global.level_up == true.
function gui_desenhar_level_up() {
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    var _mouse_gui_x = device_mouse_x_to_gui(0);
    var _mouse_gui_y = device_mouse_y_to_gui(0);
    var _clicou = mouse_check_button_pressed(mb_left);

    // ========================================================
    // --- 1. Dimmer (Fundo Escuro) ---
    // ========================================================
    draw_set_alpha(0.7);
    draw_rectangle_color(0, 0, _gui_w, _gui_h, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    
    // --- Aviso de níveis acumulados ---
    if (variable_global_exists("levels_pendentes") && global.levels_pendentes > 1) {
        draw_set_font(fnt_nomes_up); 
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(c_black);
        draw_text_colour_outline(_gui_w / 2, 20, "Niveis Acumulados: " + string(global.levels_pendentes), 4, c_yellow, 8, 100, 100);
    }

    // ========================================================
    // --- 2. PAINEL INFERIOR: poderes que você tem + botão de sortear de novo ---
    // (contêiner próprio, posicionado pela borda de baixo da tela)
    // ========================================================
    var _painel_h = 150;
    var _slot = 64;
    var _gap = 10;
    var _grupo_w = MAX_SLOTS_ATIVOS * _slot + (MAX_SLOTS_ATIVOS - 1) * _gap;
    var _slots_cy = _gui_h - 62;
    var _btn_w = 250;
    var _btn_h = 64;

    draw_set_alpha(0.55);
    draw_rectangle_color(0, _gui_h - _painel_h, _gui_w, _gui_h, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);

    gui_desenhar_slots(_gui_w / 2 - _btn_w / 2 - 40 - _grupo_w, _slots_cy, "ATIVOS",   poderes_possuidos(0), MAX_SLOTS_ATIVOS,   _slot, _gap);
    gui_desenhar_slots(_gui_w / 2 + _btn_w / 2 + 40,            _slots_cy, "PASSIVOS", poderes_possuidos(1), MAX_SLOTS_PASSIVOS, _slot, _gap);

    // --- Botão SORTEAR DE NOVO (3 usos por partida) ---
    if (!variable_global_exists("rerolls_restantes")) global.rerolls_restantes = REROLLS_POR_PARTIDA;
    var _bx1 = _gui_w / 2 - _btn_w / 2, _by1 = _slots_cy - _btn_h / 2;
    var _bx2 = _bx1 + _btn_w,          _by2 = _by1 + _btn_h;
    var _pode_rerrolar = global.rerolls_restantes > 0;
    var _hover_btn = point_in_rectangle(_mouse_gui_x, _mouse_gui_y, _bx1, _by1, _bx2, _by2);
    var _cor_btn = !_pode_rerrolar ? make_color_rgb(70, 70, 78) : (_hover_btn ? make_color_rgb(255, 196, 64) : make_color_rgb(226, 150, 40));
    draw_roundrect_color_ext(_bx1, _by1, _bx2, _by2, 18, 18, _cor_btn, _cor_btn, false);
    draw_roundrect_color_ext(_bx1, _by1, _bx2, _by2, 18, 18, c_black, c_black, true);
    draw_set_font(fnt_descricao);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_colour_outline_escalado(_gui_w / 2, _slots_cy - 10, "SORTEAR DE NOVO", 3, c_black, 7, 30, 400, 1.3, 1.3);
    draw_text_colour_outline_escalado(_gui_w / 2, _slots_cy + 16, string(global.rerolls_restantes) + "/" + string(REROLLS_POR_PARTIDA) + " usos", 2, c_black, 7, 30, 400, 1, 1);

    if (_pode_rerrolar && _hover_btn && _clicou) {
        level_up_resortear();
        exit; // as cartas novas aparecem no próximo frame
    }
    
    // ========================================================
    // --- 3. CARTAS (contêiner central, escala para caber entre o topo e o painel) ---
    // ========================================================
    var _options_count = ds_list_size(global.upgrades_vamp_list);
    if (_options_count <= 0) exit; 

    var _sprite_h = sprite_get_height(spr_level_up_hud);
    var _sprite_w = sprite_get_width(spr_level_up_hud);
    var _padding_x = 40;
    var _topo = 70 + 40;                         // espaço do aviso + nome acima da carta
    var _area_h = _gui_h - _painel_h - 20 - _topo;
    var _largura_total_1x = (_sprite_w * _options_count) + (_padding_x * (_options_count - 1));
    var _base = min(1, _area_h / _sprite_h, (_gui_w - 60) / _largura_total_1x);

    var _cw = _sprite_w * _base;
    var _ch = _sprite_h * _base;
    var _pad = _padding_x * _base;
    var _total_width_cards = (_cw * _options_count) + (_pad * (_options_count - 1));
    var _start_x = (_gui_w / 2) - (_total_width_cards / 2) + (_cw / 2);
    var _center_y = _topo + _ch / 2;
    
    for (var _i = 0; _i < _options_count; _i++) 
    {
        var _card_data = global.upgrades_vamp_list[| _i];
        if (!is_struct(_card_data)) continue;

        var _name        = _card_data.nome;
        var _desc        = _card_data.description; 
        var _next_lvl    = _card_data.next_level;       
        var _sprite_icon = _card_data.sprite;        

        var _card_x = _start_x + (_cw + _pad) * _i;
        var _current_scale = 1;
        var _current_alpha = 0.8;

        // --- Interação (hover + clique) ---
        if (point_in_rectangle(_mouse_gui_x, _mouse_gui_y, _card_x - _cw / 2, _center_y - _ch / 2, _card_x + _cw / 2, _center_y + _ch / 2)) 
        {
            _current_alpha = 1;
            _current_scale = 1.05;
            if (_clicou) {
                level_up_aplicar_carta(_card_data); // sobe o nível, recalcula passivas e cuida da fila
                break;
            }
        }

        // --- Fundo da carta ---
        var _sc = _base * _current_scale;
        draw_sprite_ext(spr_level_up_hud, 0, _card_x, _center_y, _sc, _sc, 0, c_white, _current_alpha);

        // Medidas internas do spr_level_up_hud (pixels do sprite, relativas à origem central 201,344):
        //  - Quadro do ícone: centro (0, -147), 318 x 295
        //  - Área de texto:   topo +7, 342 de largura
        var _box_cy = _center_y - 147 * _sc;
        var _text_top = _center_y + 7 * _sc;
        var _text_w = 300;

        gui_icone_caber(_sprite_icon, _card_x, _box_cy, 318 * _sc, 295 * _sc, _current_alpha);

        // --- Textos ---
        draw_set_color(c_black);
        draw_set_halign(fa_center);

        // Nome (acima da carta)
        draw_set_font(fnt_nomes_up);
        draw_set_valign(fa_bottom);
        draw_text_colour_outline(_card_x, _center_y - 344 * _sc - 6, _name, 4, c_white, 8, 100, 100);

        // Selo NOVO! para poderes que você ainda não tem
        if (variable_struct_exists(_card_data, "novo") && _card_data.novo) {
            draw_set_font(fnt_descricao);
            draw_set_color(c_yellow);
            draw_text_colour_outline_escalado(_card_x + _cw * 0.33, _center_y - 300 * _sc, "NOVO!", 3, c_black, 7, 30, 200, 1.4 * _sc, 1.4 * _sc);
            draw_set_color(c_black);
        }

        // Nível e descrição
        draw_set_font(fnt_descricao);
        draw_set_valign(fa_top);
        var _txt_nivel = (_card_data.type == 3) ? "CURA" : "Nv. " + string(_next_lvl);
        draw_text_colour_outline_escalado(_card_x, _text_top + 24 * _sc, _txt_nivel, 3, c_white, 7, 30, _text_w, 1.6 * _sc, 1.6 * _sc);
        draw_text_colour_outline_escalado(_card_x, _text_top + 95 * _sc, _desc, 3, c_white, 7, 30, _text_w, _sc, _sc);

        draw_set_valign(fa_middle);
        draw_set_halign(fa_center);
    }
}
