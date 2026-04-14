if (!is_open) exit;

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// ============================================================================
// 1. FUNDO E INVENTÁRIO BASE
// ============================================================================
draw_set_alpha(0.7); draw_set_color(c_black);
draw_rectangle(0, 0, _gui_w, _gui_h, false);
draw_set_alpha(1); draw_set_color(c_white);

inventory_x = _gui_w / 2 - inventory_w / 2;
inventory_y = _gui_h / 2 - inventory_h / 2;

draw_sprite_ext(spr_iinventario, 0, inventory_x, inventory_y, scale, scale, 0, c_white, 1);

// ============================================================================
// 2. DESENHO DOS SLOTS (Mochila e Equipamentos)
// ============================================================================
var _grid_height = ds_grid_height(global.grid_itens);
for (var i = 0; i < _grid_height; i++) {
    var _sx, _sy;
    if (i < total_slots) {
        var _col = i % grid_cols; var _row = i div grid_cols;
        _sx = inventory_x + grid_start_x + (_col * (slot_width + slot_buffer));
        _sy = inventory_y + grid_start_y + (_row * (slot_height + slot_buffer));
    } else {
        var _eq_idx = i - total_slots;
        _sx = inventory_x + equip_start_x;
        _sy = inventory_y + equip_start_y + (_eq_idx * (slot_height + slot_buffer));
    }

    if (selected_slot == i) { draw_sprite_ext(spr_selecionado, 0, _sx, _sy, scale, scale, 0, c_white, 1); }

    var _spr = global.grid_itens[# Infos.sprite, i];
    var _idx = global.grid_itens[# Infos.image_ind, i];
    var _qtd = global.grid_itens[# Infos.quantidade, i];

    if (_spr != -1) {
        draw_sprite_ext(_spr, _idx, _sx, _sy, scale, scale, 0, c_white, 1);
        if (_qtd > 1) {
            draw_set_font(fnt_numeros); draw_set_halign(fa_right);
            draw_text_outlined(_sx + slot_width - 5, _sy + slot_height - 5, c_black, c_white, string(_qtd));
        }
    }
}

// Item Arrastado
if (selected_item != -1) {
    var _drag_spr = global.grid_itens[# Infos.sprite, selected_index];
    var _drag_idx = global.grid_itens[# Infos.image_ind, selected_index];
    draw_sprite_ext(_drag_spr, _drag_idx, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), scale, scale, 0, c_white, 0.8);
}

// Detalhes do Item e Stats
if (selected_slot != -1 && global.grid_itens[# Infos.item, selected_slot] != -1) {
    draw_set_font(fnt_nomes_itens); draw_set_halign(fa_left);
    draw_text_outlined(inventory_x + text_name_x, inventory_y + text_name_y, c_black, c_white, global.grid_itens[# Infos.nome, selected_slot]);
    draw_set_font(fnt_descricao);
    draw_text_ext(inventory_x + text_desc_x, inventory_y + text_desc_y, global.grid_itens[# Infos.descricao, selected_slot] + "\nPreço: " + string(global.grid_itens[# Infos.preco, selected_slot]), 20, 300);
}
draw_player_stats_panel(inventory_x, inventory_y);


// ============================================================================
// 3. SISTEMA DE DEBUG VISUAL (ALINHAMENTO DO CRAFT)
// ============================================================================
if (!variable_global_exists("modo_debug_ui")) global.modo_debug_ui = false;

// Liga/Desliga o Debug ao apertar "B"
if (keyboard_check_pressed(ord("B"))) {
    global.modo_debug_ui = !global.modo_debug_ui;
}

// Controles Interativos do Debugger
if (global.modo_debug_ui) {
    var _vel = keyboard_check(vk_shift) ? 5 : 1; // Segure Shift para mover rápido
    
    // Mover a caixa inteira
    if (keyboard_check(vk_right)) craft_box_x += _vel;
    if (keyboard_check(vk_left))  craft_box_x -= _vel;
    if (keyboard_check(vk_down))  craft_box_y += _vel;
    if (keyboard_check(vk_up))    craft_box_y -= _vel;
    
    // Alterar Largura e Altura do Painel
    if (keyboard_check(ord("D"))) craft_pane_width += _vel;
    if (keyboard_check(ord("A"))) craft_pane_width -= _vel;
    if (keyboard_check(ord("S"))) craft_pane_height += _vel;
    if (keyboard_check(ord("W"))) craft_pane_height -= _vel;
    
    // Alterar Espaçamento entre os painéis
    if (keyboard_check(ord("E"))) craft_buffer += _vel;
    if (keyboard_check(ord("Q"))) craft_buffer -= _vel;
}


// ============================================================================
// 4. SISTEMA DE CRAFTING COM SCROLL (LISTA)
// ============================================================================
var _receitas_total = array_length(global.receitas_craft);
var _mx = device_mouse_x_to_gui(0); 
var _my = device_mouse_y_to_gui(0);

// Cria a variável de rolagem se ela não existir
if (!variable_instance_exists(id, "craft_scroll")) craft_scroll = 0;

var _max_visiveis = 3; // Quantos painéis aparecem de uma vez!

// Área onde o mouse precisa estar para o scroll funcionar
var _area_scroll_x1 = inventory_x + craft_box_x;
var _area_scroll_y1 = inventory_y + craft_box_y;
var _area_scroll_x2 = _area_scroll_x1 + craft_pane_width;
var _area_scroll_y2 = _area_scroll_y1 + (_max_visiveis * (craft_pane_height + craft_buffer));

// LÓGICA DA BOLINHA DO MOUSE
if (point_in_rectangle(_mx, _my, _area_scroll_x1, _area_scroll_y1, _area_scroll_x2, _area_scroll_y2)) {
    if (mouse_wheel_down()) craft_scroll++;
    if (mouse_wheel_up()) craft_scroll--;
}

// Trava o scroll para não subir demais nem descer pro vazio
var _limite_scroll = max(0, _receitas_total - _max_visiveis);
craft_scroll = clamp(craft_scroll, 0, _limite_scroll);

// --- CAIXA DE DEBUG (LARANJA) ---
if (global.modo_debug_ui) {
    draw_set_color(c_orange); draw_set_alpha(0.5);
    var _debug_h = (min(_receitas_total, _max_visiveis) * (craft_pane_height + craft_buffer));
    draw_rectangle(_area_scroll_x1, _area_scroll_y1, _area_scroll_x2, _area_scroll_y1 + _debug_h, false);
    draw_set_alpha(1); draw_set_color(c_white);
}
// ---------------------------------

// LOOP DO CRAFT: Começa do 'craft_scroll' e vai só até o limite de visíveis!
var _fim_loop = min(_receitas_total, craft_scroll + _max_visiveis);

for (var i = craft_scroll; i < _fim_loop; i++) {
    
    // O pulo do gato: A posição na tela não é 'i', é 'i - craft_scroll'
    var _posicao_na_tela = i - craft_scroll;
    
    var _cx = inventory_x + craft_box_x;
    var _cy = inventory_y + craft_box_y + (_posicao_na_tela * (craft_pane_height + craft_buffer));

    // Desenha o fundo do painel inteiro
    draw_set_color(c_dkgray); draw_set_alpha(0.8);
    draw_rectangle(_cx, _cy, _cx + craft_pane_width, _cy + craft_pane_height, false);
    
    // Borda do painel
    draw_set_color(c_orange); draw_set_alpha(1);
    draw_rectangle(_cx, _cy, _cx + craft_pane_width, _cy + craft_pane_height, true);
    draw_set_color(c_white);

    var _receita = global.receitas_craft[i];
    var _disponivel = player_has_all_ingredients(_receita);

    // 1. Ícone do Item Resultado
    var _escala_item = craft_item_icon_size / sprite_get_width(_receita.spr_resultado);
    var _alpha = _disponivel ? 1 : 0.5; 
    var _item_y_center = _cy + (craft_pane_height / 2) - (craft_item_icon_size / 2);
    draw_sprite_ext(_receita.spr_resultado, _receita.idx_resultado, _cx + 15, _item_y_center, _escala_item, _escala_item, 0, c_white, _alpha);
    
    // 2. Ingredientes Necessários
    var _total_reqs = array_length(_receita.ingredientes);
    var _ing_start_x = _cx + 80; 
    
    for (var j = 0; j < _total_reqs; j++) {
        var _req = _receita.ingredientes[j];
        
        // --- O CÓDIGO NOVO ENTRA AQUI ---
        var _dados_ing = crafting_get_item_dados(_req.item); 
        var _spr_ing = _dados_ing[0]; 
        var _idx_ing = _dados_ing[1]; 
        
        var _qtd_player = inventory_count_item(_req.item); 
        
        var _icx = _ing_start_x + (j * 70);
        var _icy = _cy + (craft_pane_height / 2) - (craft_ing_icon_size / 2);
        
        if (_spr_ing != noone) {
            var _escala_ing = craft_ing_icon_size / sprite_get_width(_spr_ing);
            
            // AGORA ELE DESENHA O FRAME CORRETO DA MADEIRA/PEDRA/ERVA!
            draw_sprite_ext(_spr_ing, _idx_ing, _icx, _icy, _escala_ing, _escala_ing, 0, c_white, 1);
            
            draw_set_font(fnt_numeros_craft); draw_set_halign(fa_left); draw_set_valign(fa_middle);
            var _cor_qtd = (_qtd_player >= _req.qtd) ? c_lime : c_red;
            draw_text_outlined(_icx + craft_ing_icon_size + 5, _icy + (craft_ing_icon_size/2), c_black, _cor_qtd, string(_qtd_player) + "/" + string(_req.qtd));
            draw_set_valign(fa_top); 
        }
    }

    // 3. Botão CRAFT
    var _bx = _cx + craft_pane_width - craft_btn_w - 15;
    var _by = _cy + (craft_pane_height / 2) - (craft_btn_h / 2); 
    
    var _btn_hover = point_in_rectangle(_mx, _my, _bx, _by, _bx + craft_btn_w, _by + craft_btn_h);
    var _btn_alpha = _disponivel ? (_btn_hover ? 1 : 0.8) : 0.3;
    
    draw_set_color(_disponivel ? (_btn_hover ? c_green : c_lime) : c_gray); draw_set_alpha(_btn_alpha);
    draw_rectangle(_bx, _by, _bx + craft_btn_w, _by + craft_btn_h, false);
    draw_set_color(c_white); draw_set_alpha(1);
    
    draw_set_halign(fa_center); draw_set_valign(fa_middle); draw_set_font(fnt_nomes_itens);
    draw_text_outlined(_bx + (craft_btn_w/2), _by + (craft_btn_h/2), c_black, c_white, "CRAFT");
    draw_set_valign(fa_top);
}


// ============================================================================
// 5. TEXTO DO DEBUGGER NA TELA
// ============================================================================
if (global.modo_debug_ui) {
    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_font(fnt_descricao);
    
    var _texto = "--- MODO DE EDICAO DE CRAFT ---\n";
    _texto += "Setas: Mover X/Y\n";
    _texto += "A/D: Largura | W/S: Altura\n";
    _texto += "Q/E: Espacamento | Shift: Rapido\n\n";
    _texto += "Copie para o Evento Create:\n";
    _texto += "craft_box_x = " + string(craft_box_x) + ";\n";
    _texto += "craft_box_y = " + string(craft_box_y) + ";\n";
    _texto += "craft_pane_width = " + string(craft_pane_width) + ";\n";
    _texto += "craft_pane_height = " + string(craft_pane_height) + ";\n";
    _texto += "craft_buffer = " + string(craft_buffer) + ";";
    
    // Fundo da caixa de texto
    draw_set_alpha(0.8); draw_set_color(c_black);
    draw_rectangle(10, 10, 320, 220, false);
    draw_set_alpha(1);
    
    // Texto amarelo
    draw_set_color(c_yellow);
    draw_text(20, 20, _texto);
    draw_set_color(c_white);
}