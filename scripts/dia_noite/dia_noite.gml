/// @desc Controle Unificado de Dia/Noite (Lógica + Renderização)

/// @desc Processa a lógica de passagem de tempo e luz ambiente.
function day_night_logic()
{
    var _cycle = global.day_night_cycle;

    // --- Atualização de Tempo e Debug ---
    if (keyboard_check_pressed(ord("L"))) 
    {
        global.time_accelerated = !global.time_accelerated;
        global.time_multiplier = global.time_accelerated ? 50 : 1;
    }

    if (global.timer_running) 
    {
        global.timer += (1 / game_get_speed(gamespeed_fps)) * global.time_multiplier;
    }

    // --- Cálculo do Ciclo ---
    var _full_cycle_time = _cycle.day_duration + _cycle.night_duration;
    var _current_time_in_cycle = global.timer mod _full_cycle_time;

    // Caso especial: Primeira Manhã
    if (!global.first_dawn_passed) 
    {
        _cycle.is_day = true;
        var _progress = _current_time_in_cycle / _cycle.day_duration;
        
        if (_progress < 0.15) 
        {
            _cycle.current_light = _cycle.base_light;
        } 
        else 
        {
            global.first_dawn_passed = true;
        }
    }

    // Ciclo Recorrente
    if (global.first_dawn_passed) 
    {
        if (_current_time_in_cycle < _cycle.day_duration) 
        {
            _cycle.is_day = true;
            _cycle.current_cycle = _current_time_in_cycle / _cycle.day_duration;
            
            if (_cycle.current_cycle < 0.15) 
                _cycle.current_light = lerp(_cycle.dawn_light, _cycle.base_light, _cycle.current_cycle / 0.15);
            else if (_cycle.current_cycle < 0.85) 
                _cycle.current_light = _cycle.base_light;
            else 
                _cycle.current_light = lerp(_cycle.base_light, _cycle.dawn_light, (_cycle.current_cycle - 0.85) / 0.15);
        } 
        else 
        {
            _cycle.is_day = false;
            _cycle.current_cycle = (_current_time_in_cycle - _cycle.day_duration) / _cycle.night_duration;
            
            if (_cycle.current_cycle < 0.15) 
                _cycle.current_light = lerp(_cycle.dawn_light, _cycle.min_light, _cycle.current_cycle / 0.15);
            else if (_cycle.current_cycle < 0.85) 
                _cycle.current_light = _cycle.min_light;
            else 
                _cycle.current_light = lerp(_cycle.min_light, _cycle.dawn_light, (_cycle.current_cycle - 0.85) / 0.15);
        }
    }
}

/// @desc Renderiza a surface de iluminação. Chamado preferencialmente no Draw GUI ou Post Draw.
function day_night_render()
{
    var _cycle = global.day_night_cycle;
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    // --- Gestão da Surface (Tamanho da GUI para performance) ---
    if (!surface_exists(_cycle.overlay)) 
    {
        _cycle.overlay = surface_create(_gw, _gh);
    }

    surface_set_target(_cycle.overlay);
    draw_clear_alpha(c_black, 1 - _cycle.current_light);

    // --- Desenho das Luzes ---
    gpu_set_blendmode(bm_subtract);

    // Fatores de Escala (Mapeia coordenadas da sala para coordenadas da surface/GUI)
    var _scale_x = _gw / global.cmw;
    var _scale_y = _gh / global.cmh;

    var _list_size = ds_list_size(global.lista_luzes);

    for (var i = 0; i < _list_size; i++) 
    {
        var _light_inst = global.lista_luzes[| i];
        
        if (instance_exists(_light_inst)) 
        {
            var _pos_x = (_light_inst.x + _light_inst.light_offset_x - global.cmx) * _scale_x;
            var _pos_y = (_light_inst.y + _light_inst.light_offset_y - global.cmy) * _scale_y;
            var _intensity = _light_inst.light_intensity * (1 - _cycle.current_light);

            var _r1 = _light_inst.luz_1 * _scale_x;
            var _r2 = _light_inst.luz_2 * _scale_x;
            var _r3 = _light_inst.luz_3 * _scale_x;
            var _r4 = _light_inst.luz_4 * _scale_x;
            var _r5 = _light_inst.luz_5 * _scale_x;

            switch (_light_inst.light_style) 
            {
                case "soft":
                    draw_set_alpha(_intensity * 0.3); draw_circle(_pos_x, _pos_y, _r1, false);
                    draw_set_alpha(_intensity * 0.6); draw_circle(_pos_x, _pos_y, _r2, false);
                    draw_set_alpha(_intensity);       draw_circle(_pos_x, _pos_y, _r3, false);
                    break;

                case "flicker":
                    var _j = random_range(-1, 1);
                    draw_set_alpha(_intensity);       draw_circle(_pos_x + _j, _pos_y + _j, _r1 + _j, false);
                    draw_set_alpha(_intensity * 0.7); draw_circle(_pos_x + _j, _pos_y + _j, _r2 + _j, false);
                    draw_set_alpha(_intensity * 0.5); draw_circle(_pos_x + _j, _pos_y + _j, _r3 + _j, false);
                    break;

                case "pulse":
                    var _p = 1 + sin(current_time * 0.005 + i) * 0.05;
                    draw_set_alpha(_intensity * 0.4); draw_circle(_pos_x, _pos_y, _r1 * _p, false);
                    draw_set_alpha(_intensity);       draw_circle(_pos_x, _pos_y, _r2 * _p, false);
                    break;

                default:
                    draw_set_alpha(_intensity);       draw_circle(_pos_x, _pos_y, _r1, false);
                    draw_set_alpha(_intensity * 0.5); draw_circle(_pos_x, _pos_y, _r2, false);
                    break;
            }
        }
    }

    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
}

/// @desc Legado para compatibilidade se necessário
function day_night_cycle_manager() {
    day_night_logic();
}
