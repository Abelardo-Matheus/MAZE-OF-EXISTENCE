// Verifica se o jogador está próximo desta estrutura
var _inst = instance_nearest(x, y, obj_player);

if (distance_to_point(_inst.x, _inst.y) <= 100) {
	show_debug_message(seed)
    // Se o jogador estiver próximo, marca que ele está próximo de uma estrutura
    obj_player.proximo_de_estrutura = true;
	
	
		if(keyboard_check_pressed(ord("F"))){
			global.pos_x_map = x;
			global.pos_y_map = y;
			global.seed_atual = seed;
			global.current_sala = [0,0];
			room_goto(Fase_BEBE);
		}
}


// Verifica se a seleção já foi feita
if (!selecao_feita) {
    // Define a seed para garantir que a seleção seja sempre a mesma
    random_set_seed(seed);

    // Lista de objetos filhos
    var objetos_no_projeto = [obj_casa_1, obj_casa_2, obj_casa_3, obj_casa_4];

    // Gera um índice fixo com base na seed
    var indice_fixo = abs(seed) mod array_length(objetos_no_projeto);

    // Seleciona o filho correspondente ao índice fixo
    var filho_selecionado = objetos_no_projeto[indice_fixo];
    // Altera a instância atual para o filho selecionado
	global.seed_atual = seed;
    instance_change(filho_selecionado, true);

    // Marca que a seleção foi feita
    selecao_feita = true;
}


#region sombra


#endregion