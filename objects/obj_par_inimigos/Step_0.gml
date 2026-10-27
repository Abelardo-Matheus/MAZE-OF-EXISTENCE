// feather disable GM2017
depth = profundidade_pe(bbox_bottom); // mesma regra do player e dos móveis
// Nível da área, força e XP por tipo — 1x, depois de todos os Creates (scr_progressao)
if (!variable_instance_exists(id, "prog_aplicado")) progressao_inimigo_aplicar();
// Vida acima do máximo (nível, ronda, sala restaurada): o máximo acompanha, senão a barra estoura
if (variable_instance_exists(id, "max_vida") && vida > max_vida) max_vida = vida;
// HITBOX: a máscara fica fixa no sprite de andar. Antes ela trocava junto com a animação
// (andar/parado têm bbox diferentes), e a hitbox "pulava" de tamanho.
if (sprite_exists(sprite_normal) && mask_index != sprite_normal) mask_index = sprite_normal;
if(global.level_up == true){
	alarm[0]++;
	image_speed = 0;
	exit;	
}else{
	image_speed = 1;
}

image_xscale = escala;
image_yscale = escala;
script_execute(state);

if dest_x < x{
	image_xscale = -escala;
}else{
	image_xscale = escala
}
if (vida <= 0) {
	remover_inimigo_por_id(global.current_sala, inimigo_id);
	// XP: vai para o pool de gemas do obj_horde (sem instância, junta com gemas próximas).
	// Sem obj_horde na sala (outras fases), cai como obj_xp_um normal.
	var _xp_valor = variable_instance_exists(id, "xp_valor") ? xp_valor : PROG_XP_PADRAO; // XP por tipo e nível (scr_progressao)
	if (!horde_xp_drop(x, y, _xp_valor)) {
		var _xp = instance_create_layer(x, y, "instances", obj_xp_um);
		_xp.xp_ganho = _xp_valor;
	}
    item_ao_matar(x, y); // XP dos itens equipados + passivas de abate (scr_passivas_itens)
    instance_destroy();
	obj_player.alarm[6] =  3;
	criar_item_aleatorio_passivos_pe(x,y,depth,100);
}

// Noite: teleporta para o lado oposto do quadrado de spawn fixo (Camera.gml).
// Antes usava a borda da câmera, que muda com o zoom.
if (instance_exists(obj_camera) and !global.day_night_cycle.is_day) {
	spawn_quadrado_atualizar();
	if (y < global.spawn_y0) y = global.spawn_y1;
	else if (y > global.spawn_y1) y = global.spawn_y0;
	if (x < global.spawn_x0) x = global.spawn_x1;
	else if (x > global.spawn_x1) x = global.spawn_x0;
}






