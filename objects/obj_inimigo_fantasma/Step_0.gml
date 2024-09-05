// Verifica se o obj_player existe na sala
if (instance_exists(obj_player)) {
    // Obtém a posição do obj_player
    var alvo_x = obj_player.x;
    var alvo_y = obj_player.y;
    
    // Direção do inimigo para o obj_player
    var direcao = point_direction(x, y, alvo_x, alvo_y);

    // Definir se o inimigo está indo para a esquerda ou direita
    if (direcao > 90 && direcao < 270) {
        image_xscale = -3; // Vira para a esquerda
    } else {
        image_xscale = 3; // Vira para a direita
    }

    // Verifica se o movimento resultaria em colisão com outro inimigo
    var novo_x = x + lengthdir_x(velocidade_inimigo, direcao);
    var novo_y = y + lengthdir_y(velocidade_inimigo, direcao);
    
    if (!place_meeting(novo_x, novo_y, obj_inimigo_fantasma)) {
        // Se não houver colisão, movimenta o inimigo
        x = novo_x;
        y = novo_y;
    }
}
