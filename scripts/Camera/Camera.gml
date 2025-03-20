global.cmw = camera_get_view_width(view_camera[0]);
global.cmh = camera_get_view_height(view_camera[0]);



function zoom() {
	// Variáveis para controle de aceleração do zoom
	var zoom_speed_base = 50; // Velocidade base do zoom
	var zoom_speed_multiplier = 1; // Multiplicador de velocidade (aumenta com o tempo)
	var zoom_acceleration = 0.8; // Taxa de aceleração do zoom
	var max_zoom_multiplier = 5; // Limite máximo do multiplicador de velocidade
    // Limites de zoom
    var min_width = 740; // Largura mínima da viewport
    var min_height = min_width * (1080 / 1920); // Altura mínima mantendo a proporção
    var max_width = 1280*2; // Largura máxima da viewport
    var max_height = max_width * (1080 / 1920); // Altura máxima mantendo a proporção

    // Verifica se a roda do mouse foi rolada para cima
    if (mouse_wheel_up()) {
        // Aumenta o zoom (diminui o tamanho da viewport)
        global.cmw -= zoom_speed_base * zoom_speed_multiplier;
        global.cmh = global.cmw * (1080 / 1920); // Mantém a proporção
        // Aumenta o multiplicador de velocidade (aceleração)
        zoom_speed_multiplier = min(zoom_speed_multiplier + zoom_acceleration, max_zoom_multiplier);
    }

    // Verifica se a roda do mouse foi rolada para baixo
    if (mouse_wheel_down()) {
        // Diminui o zoom (aumenta o tamanho da viewport)
        global.cmw += zoom_speed_base * zoom_speed_multiplier;
        global.cmh = global.cmw * (1080 / 1920); // Mantém a proporção
        // Aumenta o multiplicador de velocidade (aceleração)
        zoom_speed_multiplier = min(zoom_speed_multiplier + zoom_acceleration, max_zoom_multiplier);
    }

    // Reseta o multiplicador de velocidade se não houver input de zoom
    if (!mouse_wheel_up() && !mouse_wheel_down()) {
        zoom_speed_multiplier = 1;
    }

    // Limita o tamanho da viewport
    global.cmw = clamp(global.cmw, min_width, max_width);
    global.cmh = clamp(global.cmh, min_height, max_height);

    // Atualiza o tamanho da viewport da câmera
    camera_set_view_size(view_camera[0], global.cmw, global.cmh);

    // Define a posição da câmera diretamente (sem suavização)
    global.cmx = obj_player.x - global.cmw / 2;
    global.cmy = obj_player.y - global.cmh / 2;
    camera_set_view_pos(view_camera[0], global.cmx, global.cmy);
}