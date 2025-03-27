
// Inicializa a lista global de estruturas
if (!variable_global_exists("posicoes_estruturas")) {
    global.posicoes_estruturas = ds_list_create();
}


global.tamanho_bloco = 20000;  // Tamanho de cada bloco (ajustável)
global.blocos_gerados = ds_list_create();
global.ultimo_bloco = [0, 0];

function recriar_estruturas() {
    if (ds_exists(global.posicoes_estruturas, ds_type_list) && ds_list_size(global.posicoes_estruturas) > 0) {
        for (var i = 0; i < ds_list_size(global.posicoes_estruturas); i++) {
            var estrutura_info = global.posicoes_estruturas[| i];
            var pos_x = estrutura_info[0];
            var pos_y = estrutura_info[1];
            var seed = estrutura_info[2];

                var casa = instance_create_depth(pos_x, pos_y, 0, obj_estrutura);
                casa.seed = seed;
            
        }
    }
}

function scr_estruturas() {
    var bloco_atual_x = floor(obj_player.x / global.tamanho_bloco);
    var bloco_atual_y = floor(obj_player.y / global.tamanho_bloco);

    if (!variable_instance_exists(global, "estruturas_iniciais_geradas")) {
        gerar_blocos_3x3(bloco_atual_x, bloco_atual_y);
        global.ultimo_bloco = [bloco_atual_x, bloco_atual_y];
        global.estruturas_iniciais_geradas = true;
        return;
    }

    // Verifica distância e destrói estruturas muito distantes
    for (var i = ds_list_size(global.posicoes_estruturas) - 1; i >= 0; i--) {
        var estrutura_info = global.posicoes_estruturas[| i];
        var pos_x = estrutura_info[0];
        var pos_y = estrutura_info[1];
        var bloco_x = floor(pos_x / global.tamanho_bloco);
        var bloco_y = floor(pos_y / global.tamanho_bloco);
        
        if (abs(bloco_x - bloco_atual_x) > 2 || abs(bloco_y - bloco_atual_y) > 2) {
            var estrutura = instance_position(pos_x, pos_y, obj_estrutura);
            if (estrutura) {
                instance_destroy(estrutura);
            }
           
        }
    }

    // Se o jogador mudou de bloco, gera novos blocos e recria estruturas
    if (global.ultimo_bloco[0] != bloco_atual_x || global.ultimo_bloco[1] != bloco_atual_y) {
        gerar_blocos_3x3(bloco_atual_x, bloco_atual_y); // Gera novos blocos
        recriar_estruturas(); // Recria estruturas existentes
        global.ultimo_bloco = [bloco_atual_x, bloco_atual_y];
    }
}



function gerar_blocos_3x3(bloco_centro_x, bloco_centro_y) {
    // Gera blocos em um grid 3x3 ao redor do bloco central
    for (var bx = bloco_centro_x - 1; bx <= bloco_centro_x + 1; bx++) {
        for (var by = bloco_centro_y - 1; by <= bloco_centro_y + 1; by++) {
            gerar_estruturas_para_bloco(bx, by);
        }
    }
}

function gerar_estruturas_para_bloco(bx, by) {
    // Verifica se o bloco já foi gerado
    var bloco_id = string(bx) + "," + string(by);
    if (ds_list_find_index(global.blocos_gerados, bloco_id) != -1) {
        return; // Bloco já foi gerado
    }
    
    // Marca o bloco como gerado
    ds_list_add(global.blocos_gerados, bloco_id);
    
    // Calcula as coordenadas do centro do bloco
    var centro_x = (bx + 0.5) * global.tamanho_bloco;
    var centro_y = (by + 0.5) * global.tamanho_bloco;
    
    // Gera estruturas aleatoriamente dentro deste bloco
    var estruturas_geradas = 0;
    var tentativas = 0;
    var max_tentativas = quantidade_estruturas * 3;
    
    while (estruturas_geradas < quantidade_estruturas && tentativas < max_tentativas) {
        var pos_x = centro_x + random_range(-global.tamanho_bloco/2 + 100, global.tamanho_bloco/2 - 100);
        var pos_y = centro_y + random_range(-global.tamanho_bloco/2 + 100, global.tamanho_bloco/2 - 100);
        
        // Verifica distância mínima
        var posicao_valida = true;
        for (var j = 0; j < ds_list_size(global.posicoes_estruturas); j++) {
            var estrutura_info = global.posicoes_estruturas[| j];
            var estrutura_x = estrutura_info[0];
            var estrutura_y = estrutura_info[1];
            
            if (point_distance(pos_x, pos_y, estrutura_x, estrutura_y) < distancia_minima) {
                posicao_valida = false;
                break;
            }
        }
        
        if (posicao_valida) {
			randomize();
            var seed = random_get_seed();
            var casa = instance_create_depth(pos_x, pos_y, 0, obj_estrutura);
            casa.seed = seed;
            
            // Salva a posição global (como no seu código original)
            if (estruturas_geradas == 0) {
                global.pos_x_map = pos_x;
                global.pos_y_map = pos_y;
            }
            
            ds_list_add(global.posicoes_estruturas, [pos_x, pos_y, seed]);
            estruturas_geradas++;
        }
        
        tentativas++;
    }
}




function filhos(){
	random_set_seed(seed);
    var objetos_no_projeto = [obj_casa_1, obj_casa_2, obj_casa_3, obj_casa_4];
    var indice_aleatorio = irandom(array_length(objetos_no_projeto) - 1);
    var filho_selecionado = filhos[indice_aleatorio];
    instance_change(filho_selecionado, true);
	
}