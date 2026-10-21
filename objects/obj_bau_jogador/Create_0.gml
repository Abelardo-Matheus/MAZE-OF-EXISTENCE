// feather disable GM2017
/// @desc Baú portátil colocado pelo jogador (ver itens_geral.gml: colocar_bau_confirmar / recriar_baus)
dados  = undefined; // struct salvo em global.sala_com_bau (x, y, item_id, slots, spr, escala, grid)
grid   = -1;        // ds_grid com os itens guardados (INFOS.HEIGHT colunas x slots linhas)
slots  = 6;
aberto = false;

solid = true; // garante colisão mesmo se a checkbox "Solid" do objeto não tiver sido marcada
image_speed = 0;
image_index = 0; // 0 = fechado, 1 = aberto (igual aos móveis de casa — scr_casa_moveis)
