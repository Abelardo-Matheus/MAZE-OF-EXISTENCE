// Inicializa listas globais se ainda não existirem
if (!variable_global_exists("posicoes_estruturas")) {
    global.posicoes_estruturas = ds_list_create(); // Lista de estruturas (posição, sprite, nome)
}
if (!variable_global_exists("blocos_gerados")) {
    global.blocos_gerados = ds_map_create(); // Mapa que armazena listas de tipos já gerados por bloco
}

if (!variable_global_exists("posicoes_grupos_inimigos")) {
    global.posicoes_grupos_inimigos = ds_list_create(); // Lista de grupos de inimigos (posição, seed)
}
if (!variable_global_exists("blocos_gerados_grupo")) {
    global.blocos_gerados_grupo = ds_map_create(); // Mapa que armazena blocos que já receberam grupos
}

global.tamanho_bloco = 30000; // Tamanho do bloco
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

    if (!ds_map_exists(global.blocos_gerados, bloco_id)) {
        global.blocos_gerados[? bloco_id] = ds_list_create();
    }

    var lista_estruturas = global.blocos_gerados[? bloco_id];

    if (ds_list_find_index(lista_estruturas, obj_struct) != -1) {
        return;
    }

    var centro_x = (bx + 0.5) * global.tamanho_bloco;
    var centro_y = (by + 0.5) * global.tamanho_bloco;

    var estruturas_geradas = 0;
    var tentativas = 0;
    var max_tentativas = quantidade_estruturas * 3;

    while (estruturas_geradas < quantidade_estruturas && tentativas < max_tentativas) {
        var pos_x = centro_x + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);
        var pos_y = centro_y + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);

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

            var spr = noone;
            var nome = "Outro";
            if (obj_struct == obj_estrutura) {
                spr = spr_casa_mini_map;
                nome = "Casa";
            } else if (obj_struct == obj_poste) {
                spr = spr_poste_mini_map;
                nome = "Poste";
            } else if (obj_struct == obj_grupo_inimigos) {
                spr = spr_grupoini_mini_map;
                nome = "Grupo Inimigos";
            }else if (obj_struct == par_npc_vendedor_um) {
                spr = spr_vendedor;
                nome = "Vendedor";
            }

            ds_list_add(global.posicoes_estruturas, [pos_x, pos_y, seed, obj_struct, spr, nome]);
            estruturas_geradas++;
        }
        tentativas++;
    }

    ds_list_add(lista_estruturas, obj_struct);
}

function recriar_estruturas() {
    // Percorre todas as estruturas registradas em posicoes_estruturas
    for (var i = 0; i < ds_list_size(global.posicoes_estruturas); i++) {
        var estrutura_info = global.posicoes_estruturas[| i];
        
        // Extrai os dados da estrutura
        var pos_x = estrutura_info[0];
        var pos_y = estrutura_info[1];
        var seed = estrutura_info[2];
        var obj_tipo = estrutura_info[3];
        var spr = estrutura_info[4]; // Sprite para minimapa
        var nome = estrutura_info[5]; // Nome da estrutura

        // Recria a instância do objeto
        var nova_estrutura = instance_create_depth(pos_x, pos_y, 0, obj_tipo);
        
        // Restaura as propriedades salvas
        nova_estrutura.seed = seed;
        
        // Se for um tipo específico, define sprite e nome (opcional)
        if (obj_tipo == obj_estrutura) {
            nova_estrutura.sprite_index = spr_casa_mini_map;
            nova_estrutura.nome = "Casa";
        } 
        else if (obj_tipo == obj_poste) {
            nova_estrutura.sprite_index = spr_poste_mini_map;
            nova_estrutura.nome = "Poste";
        } 
        else if (obj_tipo == obj_grupo_inimigos) {
            nova_estrutura.sprite_index = spr_grupoini_mini_map;
            nova_estrutura.nome = "Grupo Inimigos";
        }
    }

    // Opcional: Recria grupos de inimigos separadamente (se necessário)
    for (var i = 0; i < ds_list_size(global.posicoes_grupos_inimigos); i++) {
        var grupo_info = global.posicoes_grupos_inimigos[| i];
        var pos_x = grupo_info[0];
        var pos_y = grupo_info[1];
        var seed = grupo_info[2];
        
        var novo_grupo = instance_create_depth(pos_x, pos_y, 0, obj_grupo_inimigos);
        novo_grupo.seed = seed;
    }
}

