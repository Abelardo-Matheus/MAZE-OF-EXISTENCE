// feather disable GM2017

// ==========================================
// LIMITES DO ZOOM E QUADRADO DE SPAWN
// ==========================================
// Zoom máximo (largura da câmera). Era 1280 * 4 = 5120: com a tela tão aberta o jogo
// desenhava e simulava área demais e o FPS caía. 2560 = 2x a visão base.
#macro CAMERA_ZOOM_MAX_W        2560
// Quadrado fixo (centrado na câmera) onde os inimigos da noite nascem e "teleportam".
// O lado é SEMPRE maior que o zoom máximo, então o spawn nunca aparece dentro da tela,
// e não muda quando o jogador mexe no zoom.
#macro SPAWN_QUADRADO_MARGEM    192
#macro SPAWN_QUADRADO_LADO      (CAMERA_ZOOM_MAX_W + SPAWN_QUADRADO_MARGEM * 2)

/// @function spawn_quadrado_atualizar()
/// @description Recalcula os limites do quadrado de spawn em volta do centro da câmera.
function spawn_quadrado_atualizar() {
    var _cx = global.cmx + global.cmw * 0.5;
    var _cy = global.cmy + global.cmh * 0.5;
    var _h  = SPAWN_QUADRADO_LADO * 0.5;
    global.spawn_x0 = _cx - _h;
    global.spawn_y0 = _cy - _h;
    global.spawn_x1 = _cx + _h;
    global.spawn_y1 = _cy + _h;
}

/// @function spawn_ponto_quadrado()
/// @description Sorteia um ponto na borda do quadrado de spawn.
/// Resultado em global.spawn_px / global.spawn_py.
function spawn_ponto_quadrado() {
    spawn_quadrado_atualizar();
    var _t = random(1);
    switch (irandom(3)) {
        case 0: global.spawn_px = lerp(global.spawn_x0, global.spawn_x1, _t); global.spawn_py = global.spawn_y0; break; // cima
        case 1: global.spawn_px = lerp(global.spawn_x0, global.spawn_x1, _t); global.spawn_py = global.spawn_y1; break; // baixo
        case 2: global.spawn_px = global.spawn_x0; global.spawn_py = lerp(global.spawn_y0, global.spawn_y1, _t); break; // esquerda
        default: global.spawn_px = global.spawn_x1; global.spawn_py = lerp(global.spawn_y0, global.spawn_y1, _t); break; // direita
    }
}

function zoom() {
    // --- Configurações (Constantes Locais) ---
    var _zoom_speed_base = 50;       
    var _zoom_accel = 0.2;           
    var _max_zoom_mult = 5;          
    var _aspect_ratio = 1080 / 1920; 
    
    // Limites de Tamanho
    var _min_w = 740;
    var _max_w = CAMERA_ZOOM_MAX_W; // antes: 1280 * 4 (FPS caía no zoom máximo)
	
    var _debug_max_w = 1280 * 10; // Limite absurdo só para o modo Debug

    // --- Variáveis de Estado (Persistentes) ---
    static _current_mult = 1;
    static _debug_zoom = false; 
    
    // Variável própria para a largura da câmera de debug (para não sujar o global)
    static _debug_w = 1280 * 4;

    // ==========================================
    // SISTEMA DE DEBUG (Troca de Câmeras com Ctrl + P)
    // ==========================================
    if (keyboard_check(vk_control) && keyboard_check_pressed(ord("P"))) {
        _debug_zoom = !_debug_zoom; 

        if (_debug_zoom) {
            // LIGANDO O DEBUG
            view_visible[0] = false; // Esconde a câmera principal
            view_visible[1] = true;  // Mostra a câmera de debug
            
            // Garante que a câmera 1 existe na memória
            if (view_camera[1] == -1) {
                view_camera[1] = camera_create();
            }
            
            _debug_w = global.cmw * 2; // Começa o debug de longe
        } else {
            // DESLIGANDO O DEBUG
            view_visible[1] = false; // Esconde o debug
            view_visible[0] = true;  // Volta para a visão do jogo
        }
    }

    // --- Inputs ---
    // A roda sozinha troca o item da hotbar; zoom agora é Ctrl + roda
    var _wheel_up = mouse_wheel_up() && keyboard_check(vk_control);
    var _wheel_down = mouse_wheel_down() && keyboard_check(vk_control);

    // --- Lógica de Zoom Matemática ---
    if (_wheel_up || _wheel_down) {
        _current_mult = min(_current_mult + _zoom_accel, _max_zoom_mult);
        var _change = _zoom_speed_base * _current_mult;

        // Se NÃO estiver no debug, mexe no global. Se ESTIVER, mexe só na variável local.
        if (!_debug_zoom) {
            if (_wheel_up) global.cmw -= _change; 
            else global.cmw += _change; 
        } else {
            if (_wheel_up) _debug_w -= _change; 
            else _debug_w += _change; 
        }
    } else {
        _current_mult = 1;
    }

    // ==========================================
    // APLICAR AS CÂMERAS
    // ==========================================
    if (!_debug_zoom) 
    {
        // === MODO NORMAL (CÂMERA 0) ===
        global.cmw = clamp(global.cmw, _min_w, _max_w);
        global.cmh = global.cmw * _aspect_ratio;

        camera_set_view_size(view_camera[0], global.cmw, global.cmh);

        if (instance_exists(obj_player)) {
            var _cam_x = obj_player.x - (global.cmw / 2);
            var _cam_y = obj_player.y - (global.cmh / 2);
            
            camera_set_view_pos(view_camera[0], _cam_x, _cam_y);
            
            // ATUALIZA OS GLOBAIS PARA O JOGO USAR
            global.cmx = _cam_x;
            global.cmy = _cam_y;
        }
    } 
    else 
    {
        // === MODO DEBUG (CÂMERA 1) ===
        _debug_w = clamp(_debug_w, _min_w, _debug_max_w);
        var _debug_h = _debug_w * _aspect_ratio;

        camera_set_view_size(view_camera[1], _debug_w, _debug_h);

        if (instance_exists(obj_player)) {
            var _cam_debug_x = obj_player.x - (_debug_w / 2);
            var _cam_debug_y = obj_player.y - (_debug_h / 2);
            
            camera_set_view_pos(view_camera[1], _cam_debug_x, _cam_debug_y);
            
            // NOTE QUE NÓS NÃO MEXEMOS NO global.cmx e global.cmy AQUI DENTRO!
            // Para o jogo, a câmera continua onde estava quando você apertou Ctrl+P.
        }
    }
}