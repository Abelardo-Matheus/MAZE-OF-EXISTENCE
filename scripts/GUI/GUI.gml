function relogio() {
    // --- Configuração ---
    var _x = global.room_width / 2;
    var _y = 120;
    var _pointer_len = 32;
    var _color_pointer = c_red;
    
    // --- Desenho Base ---
    draw_sprite_ext(spr_relogio, 0, _x, _y, 1, 1, 0, c_white, 1);
    
    // --- Cálculo do Ângulo ---
    // Timer total do ciclo
    var _total_cycle = global.day_night_cycle.day_duration + global.day_night_cycle.night_duration;
    
    // Mapeia o timer atual (0 a total) para um ângulo (180 a -180 para sentido horário começando da esquerda)
    // Ajuste o '180' e o '-' conforme a direção desejada da sua arte
    var _angle = 180 - ((global.timer / _total_cycle) * 360);
    
    // --- Desenho do Ponteiro ---
    draw_set_color(_color_pointer);
    draw_circle(_x, _y, 4, false); // Eixo central
    
    // Desenha a haste e a seta
    draw_clock_hand(_x, _y, _angle, _pointer_len, _color_pointer);
    
    // Reset de cor
    draw_set_color(c_white);
}

function draw_clock_hand(_x, _y, _angle, _len, _color) {
    // Calcula a ponta e a base da seta
    var _tip_x = _x + lengthdir_x(_len, _angle);
    var _tip_y = _y + lengthdir_y(_len, _angle);
    
    // A linha vai apenas até 90% do caminho para dar espaço à cabeça da seta
    var _line_end_x = _x + lengthdir_x(_len * 0.9, _angle);
    var _line_end_y = _y + lengthdir_y(_len * 0.9, _angle);
    
    // Desenha Linha
    draw_line_width_color(_x, _y, _line_end_x, _line_end_y, 3, _color, _color);
    
    // Desenha Cabeça da Seta (Triângulo)
    var _arrow_size = 8;
    var _angle_diff = 150; // Abertura da seta
    
    var _p1_x = _tip_x + lengthdir_x(_arrow_size, _angle + _angle_diff);
    var _p1_y = _tip_y + lengthdir_y(_arrow_size, _angle + _angle_diff);
    var _p2_x = _tip_x + lengthdir_x(_arrow_size, _angle - _angle_diff);
    var _p2_y = _tip_y + lengthdir_y(_arrow_size, _angle - _angle_diff);
    
    draw_primitive_begin(pr_trianglelist);
    draw_vertex_color(_tip_x, _tip_y, c_black, 1); // Ponta
    draw_vertex_color(_p1_x, _p1_y, c_black, 1);   // Lado A
    draw_vertex_color(_p2_x, _p2_y, c_black, 1);   // Lado B
    draw_primitive_end();
}
function mini_mapa_vamp() {
    // --- Input (Idealmente mover para o Step Event, mas mantido aqui para portabilidade) ---
    if (keyboard_check_pressed(ord("M"))) {
        global.minimap_expandido = !global.minimap_expandido;
    }

    // --- Configuração Dinâmica ---
    var _w, _h, _map_x, _map_y, _scale, _max_dist;
    var _gw = display_get_width();
    var _gh = display_get_height();

    if (global.minimap_expandido) {
        _w = 1000; _h = 800;
        _map_x = (_gw - _w) / 2;
        _map_y = (_gh - _h) / 2;
        _scale = 0.02;
        _max_dist = 30000;
    } else {
        _w = 220; _h = 200;
        _map_x = _gw - _w - 40;
        _map_y = _gh - _h - 40;
        _scale = 0.008;
        _max_dist = 14000;
    }

    // --- Renderização do Fundo ---
    var _c_border = c_black;
    var _c_bg = make_color_rgb(174, 91, 28); // Marrom
    
    draw_set_color(_c_border);
    draw_rectangle(_map_x - 4, _map_y - 4, _map_x + _w + 4, _map_y + _h + 4, false);
    
    draw_set_color(_c_bg);
    draw_rectangle(_map_x, _map_y, _map_x + _w, _map_y + _h, false);

    // --- Renderização do Player (Centro) ---
    var _center_x = _map_x + _w / 2;
    var _center_y = _map_y + _h / 2;
    
    draw_set_color(c_blue);
    draw_circle(_center_x, _center_y, 3, false);

    // --- Loop de Entidades ---
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _hover_text = undefined;
    
    // Array de listas para iterar
    var _lists_to_check = [global.posicoes_estruturas, global.posicoes_grupos_inimigos];

    for (var l = 0; l < array_length(_lists_to_check); l++) {
        var _list = _lists_to_check[l];
        var _size = ds_list_size(_list);

        for (var i = 0; i < _size; i++) {
            var _data = _list[| i]; // [x, y, ?, ?, sprite, nome]
            
            // Dados da entidade
            var _ent_x = _data[0];
            var _ent_y = _data[1];
            var _sprite = _data[4];
            var _name   = _data[5];

            // Verifica distância
            var _dist = point_distance(_ent_x, _ent_y, obj_player.x, obj_player.y);
            
            if (_dist <= _max_dist) {
                // Projeção no minimapa
                var _draw_x = _center_x + (_ent_x - obj_player.x) * _scale;
                var _draw_y = _center_y + (_ent_y - obj_player.y) * _scale;

                // Clamp para não desenhar fora do quadrado
                _draw_x = clamp(_draw_x, _map_x, _map_x + _w);
                _draw_y = clamp(_draw_y, _map_y, _map_y + _h);

                // Escala visual baseada na distância
                var _size_factor = clamp(1 - (_dist / _max_dist), 0.6, 1);
                var _radius = 1 * _size_factor; // Tamanho base 1

                // Verifica Hover
                // Multiplicamos o raio por um valor maior para facilitar o mouse over
                if (point_distance(_mx, _my, _draw_x, _draw_y) < (_radius * 20)) {
                    _hover_text = _name;
                    _radius *= 2.5; // Aumenta ao passar o mouse
                }

                // Desenha Sprite ou Ponto
                if (_sprite != noone) {
                    draw_sprite_ext(_sprite, 0, _draw_x, _draw_y, _radius, _radius, 0, c_white, 0.8);
                } else {
                    var _blink = 0.5 + 0.5 * sin(current_time / 200);
                    draw_set_color(c_red);
                    draw_set_alpha(_blink);
                    draw_circle(_draw_x, _draw_y, 6, false);
                    draw_set_alpha(1);
                }
            }
        }
    }

    // --- Tooltip ---
    if (_hover_text != undefined) {
        draw_set_color(c_white);
        draw_text(_mx + 10, _my, _hover_text);
    }
    
    // Reset final de segurança
    draw_set_color(c_white);
}
function mini_mapa_bebe() {
    // --- Configuração ---
    var _map_w = 220;
    var _map_h = 200;
    var _cell_size = 25;
    var _sprite_base_size = 64; 
    var _scale_factor = _cell_size / _sprite_base_size;
    
    // Posição na tela (Canto Inferior Direito)
    var _start_x = display_get_width() - _map_w - 40;
    var _start_y = display_get_height() - _map_h - 40;
    
    // Centro do Minimapa
    var _center_x = _start_x + _map_w / 2;
    var _center_y = _start_y + _map_h / 2;

    // Limites de Visibilidade (em células)
    var _limit_x = (_map_w div _cell_size) / 2;
    var _limit_y = (_map_h div _cell_size) / 2;

    // --- Fundo ---
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(_start_x, _start_y, _start_x + _map_w, _start_y + _map_h, false);
    draw_set_alpha(1);

    // --- Loop de Salas ---
    var _total_rooms = array_length(global.salas_geradas);
    
    for (var i = 0; i < _total_rooms; i++) {
        var _room_data = global.salas_geradas[i];
        
        if (!is_array(_room_data)) continue;

        var _rx = _room_data[0]; // Room X Grid Coordinate
        var _ry = _room_data[1]; // Room Y Grid Coordinate

        // Distância relativa à sala atual do player
        var _dx = _rx - global.current_sala[0];
        var _dy = _ry - global.current_sala[1];

        // Só desenha se estiver dentro da área visível do minimapa
        if (abs(_dx) <= _limit_x && abs(_dy) <= _limit_y) {
            
            // Posição visual final
            var _draw_x = _center_x + (_dx * _cell_size);
            var _draw_y = _center_y - (_dy * _cell_size); // Y invertido para grid cartesiano visual

            // --- Lógica do Tipo de Sala (Ícone) ---
            var _subimg = 0; // 0 = Padrão

            // Verifica Templos
            if (variable_global_exists("templos_salas_pos") && global.templos_salas_pos != undefined) {
                var _len_t = array_length(global.templos_salas_pos);
                for (var j = 0; j < _len_t; j++) {
                    var _t_pos = global.templos_salas_pos[j];
                    if (_t_pos[0] == _rx && _t_pos[1] == _ry) {
                        _subimg = 1;
                        break;
                    }
                }
            }

            // Verifica Boss (Jardim)
            // Assumindo que global.sala_jardim pode ser uma coordenada [x,y] ou array de coordenadas
            if (variable_global_exists("sala_jardim") && global.sala_jardim != undefined) {
                 // Verifica se é array de coordenadas ou apenas uma coordenada
                 if (array_length(global.sala_jardim) > 0) {
                     // Checagem simplificada: Se sala_jardim for apenas [x, y]
                     if (!is_array(global.sala_jardim[0])) {
                         if (global.sala_jardim[0] == _rx && global.sala_jardim[1] == _ry) {
                             _subimg = 2;
                         }
                     } else {
                         // Se for array de arrays [[x,y], [x,y]]
                         var _len_b = array_length(global.sala_jardim);
                         for (var k = 0; k < _len_b; k++) {
                             var _b_pos = global.sala_jardim[k];
                             if (_b_pos[0] == _rx && _b_pos[1] == _ry) {
                                 _subimg = 2;
                                 break;
                             }
                         }
                     }
                 }
            }

            // --- Desenho da Sala ---
            // Desenha Sprite da Sala
            draw_sprite_ext(spr_salas, _subimg, _draw_x + _cell_size/2, _draw_y + _cell_size/2, _scale_factor, _scale_factor, 0, c_white, 1);

            // Destaque para Sala Atual
            if (_dx == 0 && _dy == 0) {
                draw_set_color(c_red);
                draw_set_alpha(0.6);
                // Borda interna leve
                draw_rectangle(_draw_x + 4, _draw_y + 4, _draw_x + _cell_size - 5, _draw_y + _cell_size - 5, false);
                draw_set_alpha(1);
            }
        }
    }

    // Reset final
    draw_set_color(c_white);
    draw_set_font(fnt_menu_op); // Restaura fonte se necessário
}