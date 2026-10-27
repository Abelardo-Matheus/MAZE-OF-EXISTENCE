// feather disable GM2017
/// @desc E abre/fecha o baú mais próximo do player. Recolher fica no botão do painel.
/// A UI do baú é bau_ui_step / bau_ui_desenhar (itens_geral.gml), chamadas pelo obj_inventario.
image_index = aberto ? 1 : 0;
depth = profundidade_pe(y);
perto = false;

if (!instance_exists(obj_player) || global.colocando_bau.ativo) exit;
if (instance_exists(obj_inventario) && obj_inventario.is_open) exit;

perto = (distance_to_object(obj_player) <= BAU_DIST_ABRIR)
     && (instance_nearest(obj_player.x, obj_player.y, obj_bau_jogador) == id);

// Abrir: tecla Interagir escolhida pelo scr_interacao. Fechar: Interagir (ou E, como antes).
if (aberto) {
    if (tecla_apertou("interagir") || keyboard_check_pressed(ord("E"))) bau_fechar();
} else if (interacao_pedida() && !instance_exists(global.bau_aberto)) {
    bau_abrir(id);
}
