/// @desc Controle Unificado de Dia/Noite (Lógica + Renderização)
/// [O QUE]: Gerencia o timer do ciclo, calcula a cor da luz ambiente e desenha a superfície de iluminação (shadow casting).
/// [COMO] : 
/// 1. Atualiza o timer global e verifica input de aceleração.
/// 2. Calcula a variável 'current_light' baseada no progresso do dia/noite.
/// 3. Gerencia a surface 'overlay', limpando-a com escuridão e recortando as luzes com 'bm_subtract'.

function day_night_cycle_manager()
{
    var _cycle = global.day_night_cycle;

    // ============================================================
    // PARTE 1: LÓGICA (Colocar no Step Event futuramente)
    // ============================================================

    // --- Atualização de Tempo e Debug ---
    if (keyboard_check_pressed(ord("L"))) 
    {
        global.time_accelerated = !global.time_accelerated;
        global.time_multiplier = global.time_accelerated ? 50 : 1;
    }

    if (global.timer_running) 
    {
        global.timer += (1 / room_speed) * global.time_multiplier;
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
        // É DIA?
        if (_current_time_in_cycle < _cycle.day_duration) 
        {
            _cycle.is_day = true;
            _cycle.current_cycle = _current_time_in_cycle / _cycle.day_duration;
            
            if (_cycle.current_cycle < 0.15) 
            {
                _cycle.current_light = lerp(_cycle.dawn_light, _cycle.base_light, _cycle.current_cycle / 0.15);
            } 
            else if (_cycle.current_cycle < 0.85) 
            {
                _cycle.current_light = _cycle.base_light;
            } 
            else 
            {
                _cycle.current_light = lerp(_cycle.base_light, _cycle.dawn_light, (_cycle.current_cycle - 0.85) / 0.15);
            }
        } 
        // É NOITE?
        else 
        {
            _cycle.is_day = false;
            _cycle.current_cycle = (_current_time_in_cycle - _cycle.day_duration) / _cycle.night_duration;
            
            if (_cycle.current_cycle < 0.15) 
            {
                _cycle.current_light = lerp(_cycle.dawn_light, _cycle.min_light, _cycle.current_cycle / 0.15);
            } 
            else if (_cycle.current_cycle < 0.85) 
            {
                _cycle.current_light = _cycle.min_light;
            } 
            else 
            {
                _cycle.current_light = lerp(_cycle.min_light, _cycle.dawn_light, (_cycle.current_cycle - 0.85) / 0.15);
            }
        }
    }

    // ============================================================
    // PARTE 2: RENDERIZAÇÃO (Colocar no Draw/Draw GUI futuramente)
    // ============================================================

    // --- Gestão da Surface ---
    if (!surface_exists(_cycle.overlay)) 
    {
        _cycle.overlay = surface_create(global.room_width, global.room_height);
    }

    surface_set_target(_cycle.overlay);
    draw_clear_alpha(c_black, 1 - _cycle.current_light); // Base de escuridão

    // --- Desenho das Luzes (Recorte) ---
    gpu_set_blendmode(bm_subtract); // Modo Subtrativo (Luz remove escuridão)

    var _scale_x = display_get_width() / global.cmw;
    var _scale_y = display_get_height() / global.cmh;

    // Loop pelas luzes
    var _list_size = ds_list_size(global.lista_luzes); // Cache do tamanho da lista

    for (var i = 0; i < _list_size; i++) 
    {
        var _light_inst = global.lista_luzes[| i];
        
        if (instance_exists(_light_inst)) 
        {
            // Cálculos de Posição e Intensidade
            var _pos_x = (_light_inst.x + _light_inst.light_offset_x - global.cmx) * _scale_x;
            var _pos_y = (_light_inst.y + _light_inst.light_offset_y - global.cmy) * _scale_y;
            var _intensity = _light_inst.light_intensity * (1 - _cycle.current_light);

            // Raios de Luz (Mantendo nomes de propriedades originais do objeto luz)
            var _radius_1 = _light_inst.luz_1 * _scale_x;
            var _radius_2 = _light_inst.luz_2 * _scale_x;
            var _radius_3 = _light_inst.luz_3 * _scale_x;
            var _radius_4 = _light_inst.luz_4 * _scale_x;
            var _radius_5 = _light_inst.luz_5 * _scale_x;

            // Desenha baseado no estilo da luz
            switch (_light_inst.light_style) 
            {
                case "soft":
                    draw_set_alpha(_intensity * 0.3); draw_circle(_pos_x, _pos_y, _radius_1, false);
                    draw_set_alpha(_intensity * 0.6); draw_circle(_pos_x, _pos_y, _radius_2, false);
                    draw_set_alpha(_intensity);       draw_circle(_pos_x, _pos_y, _radius_3, false);
                    break;

                case "flicker":
                    var _jitter = random_range(-2, 2);
                    draw_set_alpha(_intensity);       draw_circle(_pos_x + _jitter, _pos_y + _jitter, _radius_1 + random_range(-2, 2), false);
                    draw_set_alpha(_intensity * 0.9); draw_circle(_pos_x + _jitter, _pos_y + _jitter, _radius_2 + random_range(-2, 2), false);
                    draw_set_alpha(_intensity * 0.8); draw_circle(_pos_x + _jitter, _pos_y + _jitter, _radius_3 + random_range(-2, 2), false);
                    draw_set_alpha(_intensity * 0.7); draw_circle(_pos_x + _jitter, _pos_y + _jitter, _radius_4 + random_range(-2, 2), false);
                    draw_set_alpha(_intensity * 0.6); draw_circle(_pos_x + _jitter, _pos_y + _jitter, _radius_5 + random_range(-2, 2), false);
                    break;

                case "pulse":
                    // Usa current_time do sistema para oscilação
                    var _pulse = 1 + sin(current_time * 0.005 + i * 10) * 0.1;
                    draw_set_alpha(_intensity * 0.3); draw_circle(_pos_x, _pos_y, _radius_1 * _pulse, false);
                    draw_set_alpha(_intensity * 0.7); draw_circle(_pos_x, _pos_y, _radius_2 * _pulse, false);
                    draw_set_alpha(_intensity);       draw_circle(_pos_x, _pos_y, _radius_3 * _pulse, false);
                    break;

                default: // Padrão
                    draw_set_alpha(_intensity);       draw_circle(_pos_x, _pos_y, _radius_1, false);
                    draw_set_alpha(_intensity * 0.7); draw_circle(_pos_x, _pos_y, _radius_2, false);
                    draw_set_alpha(_intensity * 0.5); draw_circle(_pos_x, _pos_y, _radius_3, false);
                    break;
            }
        }
    }

    // Finalização
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
}