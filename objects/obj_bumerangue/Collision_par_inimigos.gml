event_inherited();
if (!returning) {
    // Aplica dano ao inimigo atual
    other.vida -= damage; // Reduz a vida do inimigo
    var _dir = point_direction(x, y, other.x, other.y);
    other.empurrar_dir = _dir;
    other.empurrar_veloc = push;
    other.state = scr_inimigo_hit; // Altera o estado do inimigo para "atingido"
    other.alarm[1] = 5; // Tempo de empurrão
    other.hit = true;

    // Adiciona o ID do inimigo atingido à lista local
    if (ds_list_find_index(targets, other.id) == -1) {
        ds_list_add(targets, other.id);
    }

    // Reduz o valor de "pulos" (pierce)
    pierce -= 1;

    // Busca outro inimigo próximo, se ainda houver "pulos"
    if (pierce > 0) {
        var next_target = noone;
        var nearest_distance = -1;

        // Obter os limites da câmera
        var cam_x = camera_get_view_x(view_camera[0]);
        var cam_y = camera_get_view_y(view_camera[0]);
        var cam_w = camera_get_view_width(view_camera[0]);
        var cam_h = camera_get_view_height(view_camera[0]);

        // Verificar inimigos na área da câmera
        with (par_inimigos) {
            if (x >= cam_x && x <= cam_x + cam_w && y >= cam_y && y <= cam_y + cam_h) {
                // Calcula a distância do jogador ao inimigo
                var dist = point_distance(obj_player.x, obj_player.y, x, y);
                if (ds_list_find_index(other.targets, id) == -1 && (next_target == noone || dist < nearest_distance)) {
                    next_target = id; // Define o próximo alvo
                    nearest_distance = dist; // Atualiza a menor distância
                }
            }
        }

        // Verifica se encontrou um alvo válido
        if (instance_exists(next_target)) {
            target = next_target; // Define o novo alvo
            direction = point_direction(x, y, target.x, target.y); // Ajusta a direção para o novo alvo
        } else {
            // Se nenhum alvo válido for encontrado, inicia o retorno ao jogador
            returning = true;
        }
    } else {
        // Se não houver mais "pulos", inicia o retorno ao jogador
        returning = true;
    }
}
