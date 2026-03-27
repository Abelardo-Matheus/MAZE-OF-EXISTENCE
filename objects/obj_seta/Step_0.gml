if (instance_exists(obj_player)) 
{
    // ========================================================
    // 1. DESCOBRE O CENTRO E OS LIMITES DA TELA
    // ========================================================
    var _cam = view_camera[0]; 
    var _cam_x = camera_get_view_x(_cam);
    var _cam_y = camera_get_view_y(_cam);
    var _cam_w = camera_get_view_width(_cam);
    var _cam_h = camera_get_view_height(_cam);

    // Acha o centro da tela
    var _center_x = _cam_x + _cam_w / 2;
    var _center_y = _cam_y + _cam_h / 2;

    // Descobre qual a distância máxima que a seta pode ir a partir do centro
    var _max_dist_x = (_cam_w / 2) - margem;
    var _max_dist_y = (_cam_h / 2) - margem;

    // Descobre a distância real entre o centro e o alvo
    var _dx = alvo_x - _center_x;
    var _dy = alvo_y - _center_y;

    // ========================================================
    // 2. MATEMÁTICA PARA DESLIZAR NA BORDA
    // ========================================================
    var _escala = 1; // 1 significa "está dentro da tela"

    // Se o alvo X está mais longe que a borda X, calcula o quanto precisa encolher
    if (_dx != 0) {
        var _escala_x = _max_dist_x / abs(_dx);
        if (_escala_x < _escala) _escala = _escala_x;
    }
    
    // Se o alvo Y está mais longe que a borda Y, calcula o quanto precisa encolher
    if (_dy != 0) {
        var _escala_y = _max_dist_y / abs(_dy);
        if (_escala_y < _escala) _escala = _escala_y;
    }

    // Aplica a posição! Se ele encolheu (_escala < 1), vai grudar na borda certinho
    x = _center_x + (_dx * _escala);
    y = _center_y + (_dy * _escala);

    // ========================================================
    // 3. APONTA PARA A DIREÇÃO CERTA
    // ========================================================
    // Faz a seta sempre apontar do centro da tela para o alvo
    image_angle = point_direction(_center_x, _center_y, alvo_x, alvo_y);

    // ========================================================
    // 4. EFEITOS ESPECIAIS (Quando o alvo está na tela)
    // ========================================================
    // Se a escala continuou 1, significa que o alvo JÁ ESTÁ na tela!
    if (_escala == 1) 
    {
        // Aponta para baixo como um pino
        image_angle = 270; 
        
        // Quica suavemente
        y = alvo_y + sin(current_time / 150) * 10;
    }

    // ========================================================
    // 5. CHEGADA AO DESTINO
    // ========================================================
    if (point_distance(obj_player.x, obj_player.y, alvo_x, alvo_y) < 50) 
    {
        instance_destroy(); 
    }
}