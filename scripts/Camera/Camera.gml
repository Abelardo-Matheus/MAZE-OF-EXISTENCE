function zoom() {
    // --- Configurações (Constantes Locais) ---
    var _zoom_speed_base = 50;       
    var _zoom_accel = 0.2;           
    var _max_zoom_mult = 5;          
    var _aspect_ratio = 1080 / 1920; 
    
    // Limites de Tamanho
    var _min_w = 740;
    var _max_w = 1280 * 4;
	
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
    var _wheel_up = mouse_wheel_up();
    var _wheel_down = mouse_wheel_down();

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