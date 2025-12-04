// Inicialize estas variáveis no Create Event do seu controlador
global.cmw = camera_get_view_width(view_camera[0]);
global.cmh = camera_get_view_height(view_camera[0]);

function zoom() {
    // --- Configurações (Constantes Locais) ---
    var _zoom_speed_base = 50;       // Velocidade base
    var _zoom_accel = 0.2;           // Aceleração (ajustado para ser mais suave)
    var _max_zoom_mult = 5;          // Multiplicador máximo
    var _aspect_ratio = 1080 / 1920; // Proporção da tela (Altura / Largura)
    
    // Limites de Tamanho
    var _min_w = 740;
    var _max_w = 1280 * 4;

    // --- Variáveis de Estado (Persistentes) ---
    // 'static' mantém o valor da variável entre os frames
    static _current_mult = 1;

    // --- Inputs ---
    var _wheel_up = mouse_wheel_up();
    var _wheel_down = mouse_wheel_down();

    // --- Lógica de Zoom ---
    if (_wheel_up || _wheel_down) {
        // Incrementa aceleração
        _current_mult = min(_current_mult + _zoom_accel, _max_zoom_mult);
        
        // Calcula a alteração
        var _change = _zoom_speed_base * _current_mult;

        if (_wheel_up) {
            global.cmw -= _change; // Zoom In
        } else {
            global.cmw += _change; // Zoom Out
        }
    } else {
        // Reseta aceleração se não houver input
        _current_mult = 1;
    }

    // --- Aplicação de Limites e Proporção ---
    global.cmw = clamp(global.cmw, _min_w, _max_w);
    global.cmh = global.cmw * _aspect_ratio;

    // Atualiza o tamanho da view
    camera_set_view_size(view_camera[0], global.cmw, global.cmh);

    // --- Posicionamento da Câmera ---
    if (instance_exists(obj_player)) {
        // Centraliza a câmera no player (sem suavização conforme solicitado)
        var _cam_x = obj_player.x - (global.cmw / 2);
        var _cam_y = obj_player.y - (global.cmh / 2);
        
        camera_set_view_pos(view_camera[0], _cam_x, _cam_y);
        
        // Atualiza variáveis globais de posição, caso sejam usadas em outros lugares
        global.cmx = _cam_x;
        global.cmy = _cam_y;
    }
}