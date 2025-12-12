if (!is_open) exit;

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// Fundo Escuro
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(0, 0, _gui_w, _gui_h, false);
draw_set_alpha(1);
draw_set_color(c_white);

// Centralizar Inventário
inventory_x = _gui_w / 2 - inventory_w / 2;
inventory_y = _gui_h / 2 - inventory_h / 2;

draw_sprite_ext(spr_iinventario, 0, inventory_x, inventory_y, scale, scale, 0, c_white, 1);
var _grid_height = ds_grid_height(global.grid_itens);
// Loop de Desenho dos Slots
for (var i = 0; i < _grid_height; i++) {
    var _sx, _sy;
    
    // Cálculo de Posição (Igual ao Step)
    if (i < total_slots) {
        var _col = i % grid_cols;
        var _row = i div grid_cols;
        _sx = inventory_x + grid_start_x + (_col * (slot_width + slot_buffer));
        _sy = inventory_y + grid_start_y + (_row * (slot_height + slot_buffer));
    } else {
        var _eq_idx = i - total_slots;
        _sx = inventory_x + equip_start_x;
        _sy = inventory_y + equip_start_y + (_eq_idx * (slot_height + slot_buffer));
    }

    // Desenha Seleção
    if (selected_slot == i) {
        draw_sprite_ext(spr_selecionado, 0, _sx, _sy, scale, scale, 0, c_white, 1);
    }

    // Desenha Item
    var _spr = global.grid_itens[# Infos.sprite, i];
    var _idx = global.grid_itens[# Infos.image_ind, i];
    var _qtd = global.grid_itens[# Infos.quantidade, i];

    if (_spr != -1) {
        draw_sprite_ext(_spr, _idx, _sx, _sy, scale, scale, 0, c_white, 1);
        
        // Quantidade
        if (_qtd > 1) {
            draw_set_font(fnt_numeros);
            draw_set_halign(fa_right);
            draw_text_outlined(_sx + slot_width - 5, _sy + slot_height - 5, c_black, c_white, string(_qtd));
        }
    }
}

// Desenha Item Arrastado (Mouse)
if (selected_item != -1) {
    var _drag_spr = global.grid_itens[# Infos.sprite, selected_index];
    var _drag_idx = global.grid_itens[# Infos.image_ind, selected_index];
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    
    draw_sprite_ext(_drag_spr, _drag_idx, _mx, _my, scale, scale, 0, c_white, 0.8);
}

// Desenha Detalhes (Texto e Stats) se houver slot selecionado
if (selected_slot != -1 && global.grid_itens[# Infos.item, selected_slot] != -1) {
    var _desc = global.grid_itens[# Infos.descricao, selected_slot];
    var _name = global.grid_itens[# Infos.nome, selected_slot];
    var _price = global.grid_itens[# Infos.preco, selected_slot];
    
    draw_set_font(fnt_nomes_itens);
    draw_set_halign(fa_left);
    draw_text_outlined(inventory_x + text_name_x, inventory_y + text_name_y, c_black, c_white, _name);
    
    draw_set_font(fnt_descricao);
    draw_text_ext(inventory_x + text_desc_x, inventory_y + text_desc_y, _desc + "\nPreço: " + string(_price), 20, 300);
}

// Desenha Status do Player (Lateral)
draw_player_stats_panel(inventory_x, inventory_y);