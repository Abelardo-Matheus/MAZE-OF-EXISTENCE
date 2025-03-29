function dia_noite() {
    var cycle = global.day_night_cycle;

    // === Atualiza Timer ===
    if (keyboard_check_pressed(ord("L"))) {
        global.time_accelerated = !global.time_accelerated;
        global.time_multiplier = global.time_accelerated ? 50 : 1;
    }
    if (global.timer_running) {
        global.timer += (1 / room_speed) * global.time_multiplier;
    }

    // === Controle de Ciclo Dia/Noite ===
    var full_cycle_time = cycle.day_duration + cycle.night_duration;
    var current_time_in_cycle = global.timer mod full_cycle_time;

    if (!global.first_dawn_passed) {
        cycle.is_day = true;
        var p = current_time_in_cycle / cycle.day_duration;
        if (p < 0.15) {
            cycle.current_light = cycle.base_light;
        } else {
            global.first_dawn_passed = true;
        }
    }

    if (global.first_dawn_passed) {
        if (current_time_in_cycle < cycle.day_duration) {
            cycle.is_day = true;
            cycle.current_cycle = current_time_in_cycle / cycle.day_duration;
            if (cycle.current_cycle < 0.15) {
                cycle.current_light = lerp(cycle.dawn_light, cycle.base_light, cycle.current_cycle / 0.15);
            } else if (cycle.current_cycle < 0.85) {
                cycle.current_light = cycle.base_light;
            } else {
                cycle.current_light = lerp(cycle.base_light, cycle.dawn_light, (cycle.current_cycle - 0.85) / 0.15);
            }
        } else {
            cycle.is_day = false;
            cycle.current_cycle = (current_time_in_cycle - cycle.day_duration) / cycle.night_duration;
            if (cycle.current_cycle < 0.15) {
                cycle.current_light = lerp(cycle.dawn_light, cycle.min_light, cycle.current_cycle / 0.15);
            } else if (cycle.current_cycle < 0.85) {
                cycle.current_light = cycle.min_light;
            } else {
                cycle.current_light = lerp(cycle.min_light, cycle.dawn_light, (cycle.current_cycle - 0.85) / 0.15);
            }
        }
    }

    // === Atualiza a Surface ===
    if (!surface_exists(cycle.overlay)) {
        cycle.overlay = surface_create(global.room_width, global.room_height);
    }

    surface_set_target(cycle.overlay);
    draw_clear_alpha(c_black, 1 - cycle.current_light); // Escuridão base

    // === Desenha Luzes ===
    gpu_set_blendmode(bm_subtract); // Clarear

    var scale_x = display_get_width() / global.cmw;
    var scale_y = display_get_height() / global.cmh;

for (var i = 0; i < ds_list_size(global.lista_luzes); i++) {
    var luz = global.lista_luzes[| i];
    if (instance_exists(luz)) {
        var pos_x = (luz.x + luz.light_offset_x - global.cmx) * scale_x;
        var pos_y = (luz.y + luz.light_offset_y - global.cmy) * scale_y;
        var intensity = luz.light_intensity * (1 - cycle.current_light);

        var tamanho_luz_1 = luz.luz_1 * scale_x;
        var tamanho_luz_2 = luz.luz_2 * scale_x;
        var tamanho_luz_3 = luz.luz_3 * scale_x;
        var tamanho_luz_4 = luz.luz_4 * scale_x;
        var tamanho_luz_5 = luz.luz_5 * scale_x;
        var tamanho_luz_6 = 0; // Caso precise adicionar algo depois

        draw_set_color(luz.light_color);

        switch (luz.light_style) {
            case "soft":
                // Luz suave
                draw_set_alpha(intensity * 0.3);
                draw_circle(pos_x, pos_y, tamanho_luz_1, false);

                draw_set_alpha(intensity * 0.6);
                draw_circle(pos_x, pos_y, tamanho_luz_2, false);

                draw_set_alpha(intensity);
                draw_circle(pos_x, pos_y, tamanho_luz_3, false);
            break;

            case "flicker":
                // Luz tremida
                var jitter = random_range(-2, 2);

                draw_set_alpha(intensity);
                draw_circle(pos_x + jitter, pos_y + jitter, tamanho_luz_1 + random_range(-2, 2), false);

                draw_set_alpha(intensity * 0.9);
                draw_circle(pos_x + jitter, pos_y + jitter, tamanho_luz_2 + random_range(-2, 2), false);

                draw_set_alpha(intensity * 0.8);
                draw_circle(pos_x + jitter, pos_y + jitter, tamanho_luz_3 + random_range(-2, 2), false);

                draw_set_alpha(intensity * 0.7);
                draw_circle(pos_x + jitter, pos_y + jitter, tamanho_luz_4 + random_range(-2, 2), false);

                draw_set_alpha(intensity * 0.6);
                draw_circle(pos_x + jitter, pos_y + jitter, tamanho_luz_5 + random_range(-2, 2), false);
            break;

            case "pulse":
                // Luz pulsante
                var pulse = 1 + sin(current_time * 0.005 + i * 10) * 0.1;

                draw_set_alpha(intensity * 0.3);
                draw_circle(pos_x, pos_y, tamanho_luz_1 * pulse, false);

                draw_set_alpha(intensity * 0.7);
                draw_circle(pos_x, pos_y, tamanho_luz_2 * pulse, false);

                draw_set_alpha(intensity);
                draw_circle(pos_x, pos_y, tamanho_luz_3 * pulse, false);
            break;

            default:
                // Luz padrão
                draw_set_alpha(intensity);
                draw_circle(pos_x, pos_y, tamanho_luz_1, false);

                draw_set_alpha(intensity * 0.7);
                draw_circle(pos_x, pos_y, tamanho_luz_2, false);

                draw_set_alpha(intensity * 0.5);
                draw_circle(pos_x, pos_y, tamanho_luz_3, false);
            break;
        }
    }
}



    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
}
