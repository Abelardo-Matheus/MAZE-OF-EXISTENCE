if (venda_aberta) {
    var escala = 3;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    // Tamanho da tela
    var tela_w = 1920;
    var tela_h = 1088;

    // Tamanho do fundo original (em pixels)
    var fundo_w = sprite_get_width(spr_loja_fundo_vendedor);
    var fundo_h = sprite_get_height(spr_loja_fundo_vendedor);

    // Posição centralizada do fundo
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


    // Offset dentro do fundo da loja
    var offset_x = 22 * escala;
    var offset_y = 20 * escala;

    for (var i = 0; i < ds_grid_height(inventario_venda); i++) {
        var col = i mod cols;
        var lin = i div cols;

        var slot_x = fundo_x + offset_x + col * (slot_w + espacamento);
        var slot_y = fundo_y + offset_y + lin * (slot_h + espacamento);

        var mouse_hover = point_in_rectangle(_mx, _my, slot_x, slot_y, slot_x + slot_w, slot_y + slot_h);

        // Desenhar retângulo escuro no hover
        if (mouse_hover) {
            draw_set_alpha(0.4);
            draw_set_color(c_black);
            draw_rectangle(slot_x, slot_y, slot_x + slot_w, slot_y + slot_h, false);
            draw_set_alpha(1);
        }

        // Desenhar o item se existir
        if (inventario_venda[# Infos.item, i] != -1) {
            draw_sprite_ext(inventario_venda[# Infos.sprite, i],
                            inventario_venda[# Infos.image_ind, i],
                            slot_x, slot_y, escala, escala, 0, c_white, 1);

            draw_set_font(fnt_numeros);
            draw_set_halign(fa_right);
            draw_set_color(c_yellow);
            draw_text(slot_x + slot_w - 6, slot_y + slot_h + 4, string(inventario_venda[# Infos.preco, i]));
        }

        // Informações do item no hover
        if (mouse_hover && inventario_venda[# Infos.item, i] != -1) {
            var nome = inventario_venda[# Infos.nome, i];
            var descricao = inventario_venda[# Infos.descricao, i];
            var preco = string(inventario_venda[# Infos.preco, i]) + " moedas";

            draw_set_font(fnt_descricao);
            draw_set_halign(fa_left);
            draw_set_color(c_white);

            var desc_x = fundo_x + 160 * escala;
            var desc_y = fundo_y + 50 * escala;

            draw_text(desc_x, desc_y, nome);
            draw_text(desc_x, desc_y + 30, descricao);
            draw_text(desc_x, desc_y + 60, preco);
            draw_text(desc_x + 20, desc_y + 90, "COMPRAR");
        }
    }

    // Mostrar moedas do jogador
    draw_set_font(fnt_status);
    draw_set_halign(fa_right);
    draw_set_color(c_white);
    draw_text(tela_w - 40, 30, "Moedas: " + string(global.moedas));
}
