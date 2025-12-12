
show_debug_message(is_open)
if (!is_open) exit;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// Reduz o cooldown do clique
if (cooldown_timer > 0) cooldown_timer--;
var _grid_height = ds_grid_height(global.grid_itens);
// Loop pelos Slots (Inventário + Equipamentos)
for (var i = 0; i < _grid_height; i++) {
    // Calcula posição do slot (reutilizando a lógica de layout)
    var _sx, _sy;
    
    if (i < total_slots) {
        // Grid Principal
        var _col = i % grid_cols;
        var _row = i div grid_cols;
        _sx = inventory_x + grid_start_x + (_col * (slot_width + slot_buffer));
        _sy = inventory_y + grid_start_y + (_row * (slot_height + slot_buffer));
    } else {
        // Slots de Equipamento
        var _eq_idx = i - total_slots;
        _sx = inventory_x + equip_start_x;
        _sy = inventory_y + equip_start_y + (_eq_idx * (slot_height + slot_buffer));
    }

    // Verifica Hover (Mouse sobre o slot)
    var _is_hover = point_in_rectangle(_mx, _my, _sx, _sy, _sx + slot_width, _sy + slot_height);
    
    if (_is_hover) {
        selected_slot = i; // Marca qual slot está sob o mouse

        // --- CLIQUE ESQUERDO: Selecionar / Mover ---
        if (mouse_check_button_pressed(mb_left) && cooldown_timer == 0) {
            cooldown_timer = 10;
            
            // Se não tem item na mão, pega o do slot
            if (selected_item == -1) {
                if (global.grid_itens[# Infos.item, i] != -1) {
                    selected_item = global.grid_itens[# Infos.item, i];
                    selected_index = i;
                }
            } 
            // Se tem item na mão, tenta colocar ou trocar
            else {
                inventory_swap_item(selected_index, i); // Função auxiliar para trocar
                selected_item = -1;
                selected_index = -1;
            }
        }

        // --- CLIQUE DIREITO / TECLA E: Equipar / Desequipar / Usar ---
        if ((mouse_check_button_pressed(mb_right) || keyboard_check_pressed(ord("E"))) && selected_item == -1) {
            inventory_use_item(i); // Função auxiliar para usar/equipar
        }
        
        // --- TECLA F: Dropar Item ---
        if (keyboard_check_pressed(ord("F"))) {
            inventory_drop_item(i);
        }
    }
}







