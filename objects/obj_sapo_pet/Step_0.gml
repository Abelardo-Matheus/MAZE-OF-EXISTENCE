if (instance_exists(obj_player)) {
    var cx = obj_player.x;
    var cy = obj_player.y;

    // Estado: retornando após ataque
    if (is_returning) {
        move_towards_point(return_x, return_y, velocidade);

        if (point_distance(x, y, return_x, return_y) < 4) {
            is_returning = false;
            cooldown = true;
            cooldown_timer = 0;
            wander_timer = wander_max;
        }

    // Estado: atacando
    } else if (is_attacking && instance_exists(attack_target)) {
        var tx = attack_target.x;
        var ty = attack_target.y;

        move_towards_point(tx, ty, velocidade * 1.5);

        if (point_distance(x, y, tx, ty) < 8) {
            // Aplicar dano e empurrão
            attack_target.vida -= damage;

            attack_target.empurrar_dir = point_direction(x, y, tx, ty);
            attack_target.empurrar_veloc = 1.2; // mais forte que inimigos normais
            attack_target.state = scr_inimigo_hit;

            // Criar efeito de dano
            var inst = instance_create_layer(tx, ty, "Instances", obj_dano);
            inst.alvo = attack_target;
            inst.dano = damage;

            // Entrar em cooldown e definir ponto fixo de retorno
            is_attacking = false;
            is_returning = true;

            var angle = irandom(359);
            var dist = random_range(follow_distance * 0.5, follow_distance);
            return_x = cx + lengthdir_x(dist, angle);
            return_y = cy + lengthdir_y(dist, angle);
        }

    // Estado: cooldown após ataque
    } else if (cooldown) {
        cooldown_timer++;
        if (cooldown_timer >= cooldown_max) {
            cooldown = false;
            cooldown_timer = 0;
        }

        // Vagar durante cooldown
        if (point_distance(x, y, wander_target_x, wander_target_y) < 4) {
            wander_direction = irandom(359);
            var wander_radius = random(follow_distance);
            wander_target_x = cx + lengthdir_x(wander_radius, wander_direction);
            wander_target_y = cy + lengthdir_y(wander_radius, wander_direction);
        }

        move_towards_point(wander_target_x, wander_target_y, velocidade);

    // Estado: livre para vagar e procurar inimigos
    } else {
        if (point_distance(x, y, wander_target_x, wander_target_y) < 4) {
            wander_direction = irandom(359);
            var wander_radius = random(follow_distance);
            wander_target_x = cx + lengthdir_x(wander_radius, wander_direction);
            wander_target_y = cy + lengthdir_y(wander_radius, wander_direction);
        }

        move_towards_point(wander_target_x, wander_target_y, velocidade);

        // Procurar inimigo mais próximo dentro do alcance
        var alvo = noone;
        var menor_dist = range;

        with (par_inimigos) {
            var dist = point_distance(x, y, other.x, other.y);
            if (dist < menor_dist && vida > 0) {
                menor_dist = dist;
                alvo = id;
            }
        }

        if (alvo != noone) {
            is_attacking = true;
            attack_target = alvo;
        }
    }

    // Teleporte de segurança (se estiver muito longe do jogador)
    if (!is_attacking && !is_returning) {
        var dist_to_player = point_distance(x, y, cx, cy);
        if (dist_to_player > follow_distance) {
            var angle = irandom(359);
            var radius = random(follow_distance);
            x = cx + lengthdir_x(radius, angle);
            y = cy + lengthdir_y(radius, angle);

            wander_target_x = x;
            wander_target_y = y;

            show_debug_message("Sapo teleportado para: " + string(x) + ", " + string(y));
        }
    }
}
