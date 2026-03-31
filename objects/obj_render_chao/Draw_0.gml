// 1. Configurações
var _escala_chao = 4; 
var _tamanho_sprite = 80; // Tamanho real do seu sprite
var _tile_size = _tamanho_sprite * _escala_chao; // Vai dar 50 pixels na tela

// 2. Pega exatamente as coordenadas da Câmera (Para não desenhar o que está fora da tela)
var _cam = view_camera[0];
var _cam_x = camera_get_view_x(_cam);
var _cam_y = camera_get_view_y(_cam);
var _cam_w = camera_get_view_width(_cam);
var _cam_h = camera_get_view_height(_cam);

// 3. Calcula onde o chão deve começar e terminar a pintura na tela
// O "floor" garante que o desenho ande em "pulos" perfeitos de 50 em 50 pixels
var _start_x = floor(_cam_x / _tile_size) * _tile_size;
var _start_y = floor(_cam_y / _tile_size) * _tile_size;
var _end_x = _start_x + _cam_w + _tile_size;
var _end_y = _start_y + _cam_h + _tile_size;

// 4. Loop de Pintura Rápida (SÓ pinta o que está visível na tela!)
for (var _xx = _start_x; _xx <= _end_x; _xx += _tile_size)
{
    for (var _yy = _start_y; _yy <= _end_y; _yy += _tile_size)
    {
        // ==========================================
        // A MÁGICA DA GERAÇÃO PROCEDURAL
        // Setamos a "semente" da aleatoriedade baseada na posição X e Y.
        // Assim, a grama na posição (100, 150) vai ser SEMPRE virada pro mesmo lado!
        // ==========================================
        var _seed = abs(_xx * 100000) + abs(_yy);
        random_set_seed(_seed);

        // Agora sorteamos a rotação de forma segura
        var _virar_x = choose(1, -1);
        var _virar_y = choose(1, -1);

        // Pinta a imagem na tela (SUPER LEVE, custa 0 de Memória RAM)
        draw_sprite_ext(
            spr_grama_vamp182, 
            0, 
            _xx, 
            _yy, 
            _escala_chao * _virar_x, 
            _escala_chao , 
            0, 
            c_white, 
            1
        );
    }
}

// 5. Devolve a aleatoriedade normal para o resto do jogo (MUITO IMPORTANTE!)
randomize();