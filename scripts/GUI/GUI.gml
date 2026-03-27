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
            var _data = _list[| i]; 
            
            // Dados da entidade (Básicos)
            var _ent_x = _data[0];
            var _ent_y = _data[1];
            
            // Variáveis seguras (Iniciadas com valores padrão caso seja a lista de inimigos)
            var _sprite = noone;
            var _name = "Inimigos";
            var _custom_scale = 1; // NOVA VARIÁVEL: Escala padrão é 1

            // ========================================================
            // VERIFICA SE É A LISTA DE ESTRUTURAS (QUE TEM MAIS DADOS)
            // ========================================================
            if (array_length(_data) > 3) {
                _sprite = _data[4];
                _name   = _data[5];
                _custom_scale = _data[6]; // Extrai a escala do metadado
            } else {
                // Se for grupo de inimigos (array curta), força a usar a sprite de inimigo
                _sprite = spr_grupoini_mini_map;
            }

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
                
                // ========================================================
                // APLICA A ESCALA CUSTOMIZADA NO RAIO FINAL DO DESENHO
                // ========================================================
                var _radius = 1 * _size_factor * _custom_scale; 

                // Garante que a área clicável do mouse seja de pelo menos 20 pixels
                var _area_hover = max(10, _radius * 10);

                // Verifica Hover
                if (point_distance(_mx, _my, _draw_x, _draw_y) < _area_hover) {
                    _hover_text = _name;
                    
                    // Se o ícone for muito pequeno (ex: Boss com 0.1), ele cresce bem mais no hover
                    if (_custom_scale < 1) {
                        _radius *= 3;   
                    } else {
                        _radius *= 2.5; // Comportamento normal para o resto
                    }
                }

                // Desenha Sprite ou Ponto
                if (_sprite != noone) {
                    draw_sprite_ext(_sprite, 0, _draw_x, _draw_y, _radius, _radius, 0, c_white, 0.8);
                } else {
                    var _blink = 0.5 + 0.5 * sin(current_time / 200);
                    draw_set_color(c_red);
                    draw_set_alpha(_blink);
                    draw_circle(_draw_x, _draw_y, 6 * _custom_scale, false); 
                    draw_set_alpha(1);
                }
            }
        }
    }

    // ========================================================
    // --- RENDERIZAÇÃO DO MARCADOR (spr_locate) ---
    // ========================================================
    if (instance_exists(obj_seta)) {
        var _alvo_x = obj_seta.alvo_x;
        var _alvo_y = obj_seta.alvo_y;
        var _dist_alvo = point_distance(_alvo_x, _alvo_y, obj_player.x, obj_player.y);
        
        if (_dist_alvo <= _max_dist) {
            var _draw_alvo_x = _center_x + (_alvo_x - obj_player.x) * _scale;
            var _draw_alvo_y = _center_y + (_alvo_y - obj_player.y) * _scale;

            _draw_alvo_x = clamp(_draw_alvo_x, _map_x, _map_x + _w);
            _draw_alvo_y = clamp(_draw_alvo_y, _map_y, _map_y + _h);

            var _blink_alvo = 0.7 + 0.3 * sin(current_time / 150);
            
            draw_sprite_ext(spr_locate, 0, _draw_alvo_x, _draw_alvo_y, 0.04, 0.04, 0, c_white, _blink_alvo);

            if (point_distance(_mx, _my, _draw_alvo_x, _draw_alvo_y) < 20) {
                _hover_text = "Destino Marcado";
            }
        }
    }

    // ========================================================
    // --- SISTEMA DE MARCAÇÃO (WAYPOINT) COM DIREITO ---
    // ========================================================
    if (global.minimap_expandido) {
        if (mouse_check_button_pressed(mb_right) && point_in_rectangle(_mx, _my, _map_x, _map_y, _map_x + _w, _map_y + _h)) {
            
            var _clicou_no_marcador = false;

            // 1. Verifica se a seta existe e se o clique foi em cima dela
            if (instance_exists(obj_seta)) {
                var _draw_alvo_x = _center_x + (obj_seta.alvo_x - obj_player.x) * _scale;
                var _draw_alvo_y = _center_y + (obj_seta.alvo_y - obj_player.y) * _scale;
                _draw_alvo_x = clamp(_draw_alvo_x, _map_x, _map_x + _w);
                _draw_alvo_y = clamp(_draw_alvo_y, _map_y, _map_y + _h);

                // Se a distância for menor que 20, destrói!
                if (point_distance(_mx, _my, _draw_alvo_x, _draw_alvo_y) < 20) {
                    instance_destroy(obj_seta);
                    _clicou_no_marcador = true;
                    _hover_text = undefined;
                }
            }

            // 2. Se NÃO clicou no marcador, cria ou move para o novo lugar
            if (!_clicou_no_marcador) {
                var _mundo_x = ((_mx - _center_x) / _scale) + obj_player.x;
                var _mundo_y = ((_my - _center_y) / _scale) + obj_player.y;

                if (instance_exists(obj_seta)) {
                    obj_seta.alvo_x = _mundo_x;
                    obj_seta.alvo_y = _mundo_y;
                } else {
                    var _seta = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_seta);
                    _seta.alvo_x = _mundo_x;
                    _seta.alvo_y = _mundo_y;
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
/// @desc Função de debug interativo para posições X e Y na tela.
/// @param {real} _base_x A posição X base (ex: _card_x)
/// @param {real} _base_y A posição Y base (ex: _desc_y)
/// @returns {struct} Um struct contendo os valores finais {x, y}
function scr_debug_posicao_ui(_base_x, _base_y) 
{
    // Variáveis estáticas
    static _debug_ativo = false;
    static _x_offset = 0;    // Offset do X começa em 0
    static _y_offset = -500; // Offset do Y começa onde você já estava testando
    static _ultimo_tempo = 0; 

    // Garante que o teclado seja lido apenas 1x por frame, mesmo dentro do loop
    if (current_time - _ultimo_tempo > 5) 
    {
        _ultimo_tempo = current_time; 

        // 1. Liga/Desliga com a tecla 'P'
        if (keyboard_check_pressed(ord("P"))) 
        {
            _debug_ativo = !_debug_ativo;
            
            if (_debug_ativo) {
                show_debug_message("=== [DEBUG UI ATIVADO] ===");
                show_debug_message("-> Setas Cima/Baixo para mover o Y");
                show_debug_message("-> Setas Esquerda/Direita para mover o X");
                show_debug_message("-> ENTER para imprimir o código final.");
            } else {
                show_debug_message("=== [DEBUG UI DESATIVADO] ===");
            }
        }

        // 2. Lógica de movimento (X e Y)
        if (_debug_ativo) 
        {
            var _speed = keyboard_check(vk_shift) ? 10 : 2;

            // Movimento Y
            if (keyboard_check(vk_up))   _y_offset -= _speed;
            if (keyboard_check(vk_down)) _y_offset += _speed;
            
            // Movimento X
            if (keyboard_check(vk_left))  _x_offset -= _speed;
            if (keyboard_check(vk_right)) _x_offset += _speed;

            // 3. Confirma e Imprime (ENTER)
            if (keyboard_check_pressed(vk_enter)) 
            {
                _debug_ativo = false;
                
                var _sinal_x = (_x_offset >= 0) ? " + " : " - ";
                var _sinal_y = (_y_offset >= 0) ? " + " : " - ";
                
                show_debug_message("---------------------------------------------------");
                show_debug_message("CÓDIGO FINAL GERADO! Substitua sua linha por:");
                show_debug_message("draw_text_colour_outline_escalado(" + _sinal_x + string(abs(_x_offset)) + "," + _sinal_y + string(abs(_y_offset)) + ", TEXTO, 3, c_white, 7, 30, 300, escala, escala);");
                show_debug_message("---------------------------------------------------");
            }
        }
    }

    // --- Aviso visual na tela ---
    if (_debug_ativo) 
    {
        draw_set_color(c_red);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_text(10, 10, "DEBUG UI ATIVO! Offset X: " + string(_x_offset) + " | Offset Y: " + string(_y_offset));
        draw_set_color(c_white); 
    }

    // Retorna as duas posições finais empacotadas num Struct
    return {
        x: _base_x + _x_offset,
        y: _base_y + _y_offset
    };
}