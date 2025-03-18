// Verifica se o jogador está próximo desta estrutura
var _inst = instance_nearest(x, y, obj_player);

if (distance_to_point(_inst.x, _inst.y) <= 100) {
    // Se o jogador estiver próximo, marca que ele está próximo de uma estrutura
    obj_player.proximo_de_estrutura = true;
	
	
		if(keyboard_check_pressed(ord("F"))){
			room_goto(Fase_BEBE)
		}
}