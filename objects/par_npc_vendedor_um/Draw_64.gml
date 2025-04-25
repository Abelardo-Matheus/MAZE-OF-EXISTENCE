if (venda_aberta) {
    var escala = 3;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    // Tamanho da tela
    var tela_w = 1920;
    var tela_h = 1088;

    // Tamanho do fundo original
    var fundo_w = sprite_get_width(spr_loja_fundo_vendedor);
    var fundo_h = sprite_get_height(spr_loja_fundo_vendedor);

    // Posição do fundo
    var fundo_x = (tela_w - fundo_w * escala) / 2;
    var fundo_y = (tela_h - fundo_h * escala) / 2;

    // Fundo escurecido
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, tela_w, tela_h, false);
    draw_set_alpha(1);

    // Fundo da loja
    draw_sprite_ext(spr_loja_fundo_vendedor, 0, fundo_x, fundo_y, escala, escala, 0, c_white, 1);

    // Parâmetros dos slots
    var slot_w = 47 * escala;
    var slot_h = 52 * escala;
    var cols = 6;
    var espacamento = 4 * 2.8;

    var offset_x = 22 * escala;
    var offset_y = 20 * escala;

    var item_hover_index = -1;

    for (var i = 0; i < ds_grid_height(inventario_venda); i++) {
        var col = i mod cols;
        var lin = i div cols;

        var slot_x = fundo_x + offset_x + col * (slot_w + espacamento);
        var slot_y = fundo_y + offset_y + lin * (slot_h + espacamento);

        var mouse_hover = point_in_rectangle(_mx, _my, slot_x, slot_y, slot_x + slot_w, slot_y + slot_h);

        // Hover highlight
        if (mouse_hover) {
            draw_set_alpha(0.4);
            draw_set_color(c_black);
            draw_rectangle(slot_x, slot_y, slot_x + slot_w, slot_y + slot_h, false);
            draw_set_alpha(1);
        }

        // Seleção de item
        if (mouse_hover && mouse_check_button_pressed(mb_left)) {
            if (inventario_venda[# Infos.item, i] != -1) {
                global.item_selecionado_venda = i;
            } else {
                global.item_selecionado_venda = -1;
            }
        }

        // Borda de seleção
        if (global.item_selecionado_venda == i) {
            draw_set_alpha(1);
            draw_set_color(c_lime);
            draw_rectangle(slot_x, slot_y, slot_x + slot_w, slot_y + slot_h, true);
        }

        // Desenhar sprite do item
        if (inventario_venda[# Infos.item, i] != -1) {
            draw_sprite_ext(inventario_venda[# Infos.sprite, i],
                            inventario_venda[# Infos.image_ind, i],
                            slot_x, slot_y, escala, escala, 0, c_white, 1);

            draw_set_font(fnt_numeros);
            draw_set_halign(fa_right);
            draw_set_color(c_yellow);
            draw_text(slot_x + slot_w - 6, slot_y + slot_h + 4, string(inventario_venda[# Infos.preco, i]));
        }

        // Detecta item em hover
        if (mouse_hover && inventario_venda[# Infos.item, i] != -1) {
            item_hover_index = i;
        }
    }

    // Mostrar descrição (hover > selecionado)
    var info_index = item_hover_index != -1 ? item_hover_index : global.item_selecionado_venda;
    if (info_index != -1 && inventario_venda[# Infos.item, info_index] != -1) {
        var nome = inventario_venda[# Infos.nome, info_index];
        var descricao = inventario_venda[# Infos.descricao, info_index];

        draw_set_font(fnt_descricao);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_white);

        draw_text_outlined_wrapped_block(498, 701, 758, 758, c_black, c_white, nome, 20);
        draw_text_outlined_wrapped_block(882, 702, 1421, 974, c_black, c_white, descricao, 1);
    }

    // Mostrar moedas
    draw_set_font(fnt_status);
    draw_set_halign(fa_right);
    draw_set_color(c_white);
    draw_text(tela_w - 40, 30, "Moedas: " + string(global.moedas));

    // Botão de comprar
    var btn_x = fundo_x + 530;
    var btn_y = fundo_y + 480;
    var btn_w = 240;
    var btn_h = 60;
    var btn_text = "Comprar";

    var mouse_em_botao = point_in_rectangle(_mx, _my, btn_x, btn_y, btn_x + btn_w, btn_y + btn_h);

    // Estilo do botão
    if (global.item_selecionado_venda != -1) {
        draw_set_color(mouse_em_botao ? c_yellow : c_green);
    } else {
        draw_set_color(c_gray);
    }
    draw_rectangle(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, false);

    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_status);
    draw_text(btn_x + btn_w / 2, btn_y + btn_h / 2, btn_text);

    // Comprar item
    if (mouse_em_botao and mouse_check_button_pressed(mb_left) and global.item_selecionado_venda != -1) {
        comprar_item_loja(global.item_selecionado_venda);
    }
}
