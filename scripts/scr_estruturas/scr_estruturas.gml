// Inicializa listas globais se ainda não existirem
if (!variable_global_exists("posicoes_estruturas")) {
    global.posicoes_estruturas = ds_list_create(); // Lista de estruturas (posição, seed, objeto)
}
if (!variable_global_exists("blocos_gerados")) {
    global.blocos_gerados = ds_map_create(); // Mapa que armazena listas de tipos já gerados por bloco
}

global.tamanho_bloco = 20000; // Tamanho do bloco
global.ultimo_bloco = [0, 0]; // Última posição do jogador em blocos

function gerar_estruturas(obj_struct, quantidade_estruturas, distancia_minima) {
    var bloco_atual_x = floor(obj_player.x / global.tamanho_bloco);
    var bloco_atual_y = floor(obj_player.y / global.tamanho_bloco);

    for (var bx = bloco_atual_x - 1; bx <= bloco_atual_x + 1; bx++) {
        for (var by = bloco_atual_y - 1; by <= bloco_atual_y + 1; by++) {
            gerar_estruturas_para_bloco(bx, by, obj_struct, quantidade_estruturas, distancia_minima);
        }
    }
}

function gerar_estruturas_para_bloco(bx, by, obj_struct, quantidade_estruturas, distancia_minima) {
    var bloco_id = string(bx) + "," + string(by);

    // Verifica se esse bloco já existe no mapa
    if (!ds_map_exists(global.blocos_gerados, bloco_id)) {
        global.blocos_gerados[? bloco_id] = ds_list_create(); // Criamos uma nova lista para esse bloco
    }

    var lista_estruturas = global.blocos_gerados[? bloco_id];

    // Se esse tipo de estrutura já foi gerado nesse bloco, não gera novamente
    if (ds_list_find_index(lista_estruturas, obj_struct) != -1) {
        return;
    }

    var centro_x = (bx + 0.5) * global.tamanho_bloco;
    var centro_y = (by + 0.5) * global.tamanho_bloco;
    
    var estruturas_geradas = 0;
    var tentativas = 0;
    var max_tentativas = quantidade_estruturas * 3;

    while (estruturas_geradas < quantidade_estruturas && tentativas < max_tentativas) {
        var pos_x = centro_x + random_range(-global.tamanho_bloco/2 + 100, global.tamanho_bloco/2 - 100);
        var pos_y = centro_y + random_range(-global.tamanho_bloco/2 + 100, global.tamanho_bloco/2 - 100);
        
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
            var nova_estrutura = instance_create_depth(pos_x, pos_y, 0, obj_struct);
            nova_estrutura.seed = seed;

            ds_list_add(global.posicoes_estruturas, [pos_x, pos_y, seed, obj_struct]);
            estruturas_geradas++;
        }
        tentativas++;
    }

    // Adicionamos o tipo de estrutura à lista do bloco
    ds_list_add(lista_estruturas, obj_struct);
}

function recriar_estruturas() {
    if (ds_exists(global.posicoes_estruturas, ds_type_list)) {
        for (var i = 0; i < ds_list_size(global.posicoes_estruturas); i++) {
            var estrutura_info = global.posicoes_estruturas[| i];
            var pos_x = estrutura_info[0];
            var pos_y = estrutura_info[1];
            var seed = estrutura_info[2];
            var obj_tipo = estrutura_info[3];

            var nova_estrutura = instance_create_depth(pos_x, pos_y, 0, obj_tipo);
            nova_estrutura.seed = seed;
        }
    }
}
