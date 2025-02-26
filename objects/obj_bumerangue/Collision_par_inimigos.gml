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

    // Se ainda houver "pulos", busca outro inimigo
    if (pierce > 0) {
        var next_target = noone;
        var nearest_distance = infinity; // Usa um valor infinito para a distância mínima

        // Obtém a posição real do projétil
        var proj_x = x;
        var proj_y = y;

        // Busca por inimigos na sala
        with (par_inimigos) {
            // Verifica se o inimigo não está na lista de atingidos
            if (ds_list_find_index(other.targets, id) == -1) {
                var dist = point_distance(proj_x, proj_y, x, y);
                if (dist < nearest_distance) {
                    next_target = id;
                    nearest_distance = dist;
                }
            }
        }

        // Se encontrou um alvo válido, ajusta para o novo alvo
        if (instance_exists(next_target)) {
            target = next_target;
            direction = point_direction(proj_x, proj_y, target.x, target.y);
        } else {
            // Se nenhum alvo for encontrado, retorna ao jogador
            returning = true;
        }
    } else {
        // Se não houver mais "pulos", inicia o retorno ao jogador
        returning = true;
    }
}