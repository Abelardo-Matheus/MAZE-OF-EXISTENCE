

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
// ==========================================
// LÓGICA DE CLIQUE NO CRAFTING (COM SCROLL E CONSUMO)
// ==========================================
if (mouse_check_button_pressed(mb_left) && cooldown_timer == 0) {
    
    if (!variable_instance_exists(id, "craft_scroll")) craft_scroll = 0;
    var _receitas_total = array_length(global.receitas_craft);
    var _max_visiveis = 3;
    var _fim_loop = min(_receitas_total, craft_scroll + _max_visiveis);

    for (var i = craft_scroll; i < _fim_loop; i++) {
        
        var _posicao_na_tela = i - craft_scroll;
        var _cx = inventory_x + craft_box_x;
        var _cy = inventory_y + craft_box_y + (_posicao_na_tela * (craft_pane_height + craft_buffer));
        
        var _bx = _cx + craft_pane_width - craft_btn_w - 15;
        var _by = _cy + (craft_pane_height / 2) - (craft_btn_h / 2);

        // Se clicou em cima do botão...
        if (point_in_rectangle(_mx, _my, _bx, _by, _bx + craft_btn_w, _by + craft_btn_h)) {
            
            var _receita = global.receitas_craft[i];
            
            // Só faz o item se tiver os ingredientes
            if (player_has_all_ingredients(_receita)) {
                cooldown_timer = 10;
                
                // 1. Remove os ingredientes do inventário
                var _total_reqs = array_length(_receita.ingredientes);
                for (var j = 0; j < _total_reqs; j++) {
                    var _req = _receita.ingredientes[j];
                    // Consome o item!
                    inventory_remove_item(_req.item, _req.qtd); 
                }
                
                // 2. Busca os atributos completos na Database usando o sprite e index da receita!
                var _dados_completos = buscar_dados_do_item(_receita.spr_resultado, _receita.idx_resultado);

                if (_dados_completos != undefined) {
                    // 3. Adiciona no inventário puxando a vida, dano e armadura corretos da Database!
                    adicionar_item_invent(
                        _receita.resultado,            // O ID do item (enum)
                        _receita.qtd_resultado,        // Quantidade que o craft gera
                        _dados_completos[0],           // Sprite
                        _dados_completos[1],           // Nome
                        _dados_completos[2],           // Descrição
                        -1, -1, -1, -1,                // Posições no mundo (ignorado, pois vai direto pra mochila)
                        _dados_completos[4],           // Dano
                        _dados_completos[5],           // Armadura
                        _dados_completos[6],           // Velocidade
                        _dados_completos[3],           // Cura
                        _dados_completos[8],           // Tipo ("arma", "uso", etc)
                        _dados_completos[7],           // Index da imagem
                        _dados_completos[9]            // Preço
                    );
                } else {
                    // Segurança: Se por algum motivo o item não existir na database, avisa no console
                    show_debug_message("ERRO DE CRAFT: Item não encontrado na Database! Spr: " + string(_receita.spr_resultado) + " Idx: " + string(_receita.idx_resultado));
                }
                
                // 4. Atualiza a lista (os ingredientes sumiram, a lista precisa atualizar!)
                atualizar_crafts_disponiveis(); 
            }
            break; // Já clicou num botão, para o loop
        }
    }
}