// 1. Configurações
var _escala_chao = 3; 
var _tamanho_sprite = 32; // Tamanho real do seu sprite
var _tile_size = _tamanho_sprite * _escala_chao; // Vai dar 96 pixels na tela

// 2. Pega exatamente as coordenadas da Câmera
var _cam = view_camera[0];
var _cam_x = camera_get_view_x(_cam);
var _cam_y = camera_get_view_y(_cam);
var _cam_w = camera_get_view_width(_cam);
var _cam_h = camera_get_view_height(_cam);

// 3. Calcula onde o chão deve começar e terminar a pintura na tela
var _margem = _tile_size * 2; 

var _start_x = (floor(_cam_x / _tile_size) * _tile_size) - _margem;
var _start_y = (floor(_cam_y / _tile_size) * _tile_size) - _margem;
var _end_x = _start_x + _cam_w + (_margem * 2);
var _end_y = _start_y + _cam_h + (_margem * 2);

// 4. Loop de Pintura Rápida
for (var _xx = _start_x; _xx <= _end_x; _xx += _tile_size)
{
    for (var _yy = _start_y; _yy <= _end_y; _yy += _tile_size)
    {
		// ==========================================
        // A MÁGICA DA GERAÇÃO PROCEDURAL (SEM PADRÕES)
        // ==========================================
        // 1. Transformamos a posição de pixels (ex: 320, 640) em números de grade (ex: 1, 2)
        var _grid_x = _xx / _tile_size;
        var _grid_y = _yy / _tile_size;

        // 2. Multiplicamos por números primos aleatórios e embaralhamos os bits com XOR (^)
        var _seed = (_grid_x * 73856093) ^ (_grid_y * 19349663);
        
        // Se o número ficar negativo, transformamos em positivo
        random_set_seed(abs(_seed));

        // ==========================================
        // 2º: FAZ O SORTEIO AQUI DENTRO!
        // ==========================================
		
        var _ind = 0;
        var _chance = random(100);

        if (_chance < 99) 
        {
            // 70% de chance: Sorteia um número de 0 a 30
            _ind = irandom_range(0, 30);
        } 
        else 
        {
            // 30% de chance: Sorteia de 31 a 64
            _ind = irandom_range(31, 64);
        }

        // Agora sorteamos a rotação
        var _virar_x = choose(1, -1);
        var _virar_y = choose(1, -1);

        // Pinta a imagem na tela usando o _ind que acabou de ser sorteado
        draw_sprite_ext(
            spr_grama_vamp_tini, 
            _ind, 
            _xx, 
            _yy, 
            _escala_chao * _virar_x, 
            _escala_chao, 
            0, 
            c_white, 
            1
        );
    }
}

// 5. Devolve a aleatoriedade normal para o resto do jogo (MUITO IMPORTANTE!)
randomize();