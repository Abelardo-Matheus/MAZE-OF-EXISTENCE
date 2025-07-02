switch (state) {
    case "flying":
        var move_amount = throw_speed;
        var dir = point_direction(x, y, target_x, target_y);
        var dist_remaining = point_distance(x, y, target_x, target_y);

        if (dist_remaining <= move_amount) {
            x = target_x;
            y = target_y;
            state = "exploding";
            // Garante que a bomba chegue ao tamanho final antes da explosão
            image_xscale = radius / base_bomb_size;
            image_yscale = radius / base_bomb_size;
        } else {
            x += lengthdir_x(move_amount, dir);
            y += lengthdir_y(move_amount, dir);

            var current_dist_from_start = point_distance(initial_x, initial_y, x, y);
            var total_dist = point_distance(initial_x, initial_y, target_x, target_y);

            if (total_dist > 0) {
                var travel_ratio = current_dist_from_start / total_dist;
                var current_height_offset = sin(travel_ratio * pi) * throw_height;

                // --- AJUSTE AQUI: Tamanho visual da bomba durante o voo ---
                // A escala baseada no raio
                var scale_factor = radius / base_bomb_size;
                image_xscale = scale_factor + (current_height_offset / 100);
                image_yscale = scale_factor + (current_height_offset / 100);
                // --- FIM DO AJUSTE ---

                y -= current_height_offset; // Move o sprite para cima visualmente
            }
        }
        break;

    case "exploding":
        // Certifica que a bomba está na posição do alvo e com a escala correta antes de mudar para a explosão
        if (sprite_index != spr_explosion) {
            x = target_x;
            y = target_y;
            // Garante que a bomba esteja no tamanho final da explosão quando o sprite mudar
            image_xscale = radius / base_bomb_size; // Redefine para o tamanho determinado pelo radius
            image_yscale = radius / base_bomb_size;
            sprite_index = spr_explosion; // Muda o sprite para a animação da explosão
            image_speed = 1;
            exploded = true; // Marca como explodida
        }

        // Lógica de dano e hit dos inimigos (mantida como na versão anterior)
        if (exploded && explosion_timer == 0) { // Garante que o dano é aplicado apenas uma vez no início da explosão
            var enemies_to_hit = ds_list_create();
            
            with (par_inimigos) {
                var dist = point_distance(x, y, other.x, other.y);
                if (dist <= other.radius) {
                    ds_list_add(enemies_to_hit, id);
                }
            }

            for (var i = 0; i < ds_list_size(enemies_to_hit); i++) {
                var enemy_id = enemies_to_hit[| i];
                
                if (instance_exists(enemy_id)) {
                    var dist_to_center = point_distance(enemy_id.x, enemy_id.y, x, y);
                    var final_damage = damage;
                    
                    if (dist_to_center > 0) {
                        final_damage = damage * (1 - (dist_to_center / radius) * (1 - splash_damage_multiplier));
                        if (final_damage < 0) final_damage = 0;
                    }
                    
                    enemy_id.vida -= final_damage; 

                    if (push > 0) {
                        var _dir = point_direction(obj_player.x, obj_player.y, enemy_id.x, enemy_id.y);
                        enemy_id.empurrar_dir = _dir;
                        enemy_id.empurrar_veloc = push;
                    }

                    enemy_id.state = scr_inimigo_hit;
                    enemy_id.alarm[1] = 5;
                    enemy_id.hit = true;

                    var _inst = instance_create_layer(x, y, "instances", obj_dano);
                    _inst.alvo = enemy_id;
                    _inst.dano = final_damage;
                }
            }
            ds_list_destroy(enemies_to_hit);
        }

        explosion_timer++;
        // Se o sprite de explosão tiver uma animação, você pode querer destruir após ela terminar
        if (sprite_index == spr_explosion && image_index >= image_number - 1) { // Verifica se a animação terminou
            instance_destroy();
        } else if (explosion_timer >= explosion_duration) { // Ou após um tempo fixo, se não houver animação
            instance_destroy();
        }
        break;
}