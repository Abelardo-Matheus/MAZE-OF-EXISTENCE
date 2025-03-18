// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_estruturas(){
// Verifica se o jogador está se movendo e se as estruturas já foram criadas
if (!estruturas_criadas) {
    // Obtém a posição do jogador
    var jogador_x = obj_player.x;
    var jogador_y = obj_player.y;

    // Gera estruturas aleatoriamente ao redor do jogador
    for (var i = 0; i < quantidade_estruturas; i++) {
        var pos_x, pos_y;
        var tentativas = 0;
        var posicao_valida = false;

        // Tenta encontrar uma posição válida para a estrutura
        while (!posicao_valida && tentativas < 100) {
            pos_x = jogador_x + random_range(-raio_geracao, raio_geracao);
            pos_y = jogador_y + random_range(-raio_geracao, raio_geracao);

            // Verifica se a posição está longe o suficiente de outras estruturas
            posicao_valida = true;
            for (var j = 0; j < ds_list_size(global.posicoes_estruturas); j += 2) {
                var estrutura_x = global.posicoes_estruturas[| j];
                var estrutura_y = global.posicoes_estruturas[| j + 1];
                if (point_distance(pos_x, pos_y, estrutura_x, estrutura_y) < distancia_minima) {
                    posicao_valida = false;
                    break;
                }
            }

            tentativas++;
        }

        // Se encontrou uma posição válida, cria a estrutura e salva a posição
        if (posicao_valida) {
            instance_create_depth(pos_x, pos_y, 0, obj_casa);
            ds_list_add(global.posicoes_estruturas, pos_x, pos_y);
        }
    }

    estruturas_criadas = true;
}

// Verifica se o jogador está se movendo para gerar mais estruturas
if (point_distance(obj_player.x, obj_player.y, x, y) > raio_geracao / 2) {
    estruturas_criadas = false; // Permite a geração de mais estruturas
    x = obj_player.x; // Atualiza a posição do controle para o centro do jogador
    y = obj_player.y;
}
}