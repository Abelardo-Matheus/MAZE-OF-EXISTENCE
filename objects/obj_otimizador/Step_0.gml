// 1. Manda o alarme rodar de novo em 15 frames (1/4 de segundo num jogo a 60fps)
// Isso deixa o jogo super leve, pois não calcula a desativação todo frame!
alarm[0] = 15;

// 2. Pega as posições exatas da sua câmera
var _cam = view_camera[0];
var _cam_x = camera_get_view_x(_cam);
var _cam_y = camera_get_view_y(_cam);
var _cam_w = camera_get_view_width(_cam);
var _cam_h = camera_get_view_height(_cam);

// 3. Define uma margem (em pixels) para os objetos não "pipocarem" do nada na beirada da tela
var _margem = 300; 

// ==========================================
// A MÁGICA DA OTIMIZAÇÃO
// ==========================================

// PASSO A: Desativa TODOS os objetos da família cenário no mapa inteiro de uma vez!
instance_deactivate_object(obj_par_cenario);

// PASSO B: Reativa APENAS os objetos que estão dentro do retângulo da câmera + margem!
// (O último 'true' significa que ele vai checar o "lado de dentro" da região)
instance_activate_region(
    _cam_x - _margem, 
    _cam_y - _margem, 
    _cam_w + (_margem * 2), 
    _cam_h + (_margem * 2), 
    true
);