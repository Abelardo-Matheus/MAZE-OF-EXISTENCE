// 1. Configurações
var _escala_chao = 3; 
var _tamanho_sprite = 32; 
var _tile_size = _tamanho_sprite * _escala_chao; 

var _cam = view_camera[0];
var _cam_x = camera_get_view_x(_cam);
var _cam_y = camera_get_view_y(_cam);
var _cam_w = camera_get_view_width(_cam);
var _cam_h = camera_get_view_height(_cam);

var _margem = _tile_size * 2; 

var _start_x = (floor(_cam_x / _tile_size) * _tile_size) - _margem;
var _start_y = (floor(_cam_y / _tile_size) * _tile_size) - _margem;
var _end_x = _start_x + _cam_w + (_margem * 2);
var _end_y = _start_y + _cam_h + (_margem * 2);

// ========================================================
// CATÁLOGO INTELIGENTE DE FRONTEIRAS
// Retorna: [sprite_index, flip_x]
// ========================================================
var _obter_dados_linha = function(_bioma_esq_ou_cima, _bioma_dir_ou_baixo) {
    // Montamos a string exatamente na ordem em que os blocos estão no mundo
    var _par = _bioma_esq_ou_cima + "_" + _bioma_dir_ou_baixo;
    
    var _ind = 65; // Padrão
    var _flip = 1; // 1 = Normal, -1 = Espelhado

    switch (_par) {
        // --- CIDADE E FLORESTA ---
        // Se a Cidade está na Esquerda/Cima (como o seu desenho original): Normal
        case "cidade_floresta": _ind = irandom_range(66, 70); _flip = 1; break;
        // Se a Floresta está na Esquerda/Cima: Inverte a imagem!
        case "floresta_cidade": _ind = irandom_range(66, 70); _flip = -1; break;

        // --- FLORESTA E VAZIA ---
        case "floresta_vazia": _ind = 46; _flip = 1; break;
        case "vazia_floresta": _ind = 46; _flip = -1; break;

        // --- FLORESTA E FLORESTA NEGRA ---
        case "floresta_floresta_negra": _ind = 46; _flip = 1; break;
        case "floresta_negra_floresta": _ind = 46; _flip = -1; break;

        // --- CIDADE E VAZIA ---
        case "cidade_vazia": _ind = 46; _flip = 1; break;
        case "vazia_cidade": _ind = 46; _flip = -1; break;

        // --- CIDADE E FLORESTA NEGRA ---
        case "cidade_floresta_negra": _ind = 46; _flip = 1; break;
        case "floresta_negra_cidade": _ind = 46; _flip = -1; break;

        // --- VAZIA E FLORESTA NEGRA ---
        case "vazia_floresta_negra": _ind = 46; _flip = 1; break;
        case "floresta_negra_vazia": _ind = 46; _flip = -1; break;
    }
    
    return [_ind, _flip];
};


// 4. Loop de Pintura Rápida
for (var _xx = _start_x; _xx <= _end_x; _xx += _tile_size)
{
    for (var _yy = _start_y; _yy <= _end_y; _yy += _tile_size)
    {
        // ==========================================
        // 1º: A MÁGICA DA GERAÇÃO DA SEED DO TILE
        // ==========================================
        var _grid_x = _xx / _tile_size;
        var _grid_y = _yy / _tile_size;

        var _seed = (_grid_x * 73856093) ^ (_grid_y * 19349663);
        random_set_seed(abs(_seed));

        // ========================================================
        // 2º: DESCOBRE O BIOMA REAL DO TILE ATUAL E VIZINHOS
        // ========================================================
        var _chunk_x = floor(_xx / global.tamanho_bloco);
        var _chunk_y = floor(_yy / global.tamanho_bloco);
        var _id_real = string(_chunk_x) + "," + string(_chunk_y);
        
        var _bioma_real = "floresta";
        if (variable_global_exists("mapa_biomas") && ds_map_exists(global.mapa_biomas, _id_real)) {
            _bioma_real = global.mapa_biomas[? _id_real];
        }

        // --- Vizinho da ESQUERDA ---
        var _chunk_esq_x = floor((_xx - _tile_size) / global.tamanho_bloco);
        var _id_esq = string(_chunk_esq_x) + "," + string(_chunk_y);
        var _bioma_esq = "floresta";
        if (variable_global_exists("mapa_biomas") && ds_map_exists(global.mapa_biomas, _id_esq)) {
            _bioma_esq = global.mapa_biomas[? _id_esq];
        }

        // --- Vizinho de CIMA ---
        var _chunk_cima_y = floor((_yy - _tile_size) / global.tamanho_bloco);
        var _id_cima = string(_chunk_x) + "," + string(_chunk_cima_y);
        var _bioma_cima = "floresta";
        if (variable_global_exists("mapa_biomas") && ds_map_exists(global.mapa_biomas, _id_cima)) {
            _bioma_cima = global.mapa_biomas[? _id_cima];
        }

        // ========================================================
        // 3º: PINTA O CHÃO BASE PRIMEIRO
        // ========================================================
        var _ind_real = 1;
        switch (_bioma_real) {
            case "floresta":       _ind_real = irandom_range(1, 31); break;
            case "vazia":          _ind_real = irandom_range(1, 36); break;
            case "cidade":         _ind_real = irandom_range(32, 37); break;
            case "floresta_negra": _ind_real = irandom_range(64, 65); break;
        }

        var _virar_x = choose(1, -1);
        var _virar_y = choose(1, -1);
        var _centro_x = _xx + (_tile_size / 2);
        var _centro_y = _yy + (_tile_size / 2);

        // Pinta o Chão
        draw_sprite_ext(
            spr_grama_vamp_tini, _ind_real, 
            _centro_x, _centro_y, 
            _escala_chao * _virar_x, _escala_chao * _virar_y,
            0, c_white, 1
        );

        // ========================================================
        // 4º: DESENHA AS FRONTEIRAS ALINHADAS PERFEITAMENTE
        // ========================================================
        
        // --- FRONTEIRA VERTICAL (Entre Esquerda e Atual) ---
        if (_bioma_real != _bioma_esq) {
            var _dados_esq = _obter_dados_linha(_bioma_esq, _bioma_real);
            var _idx_linha = _dados_esq[0];
            var _flip_linha = _dados_esq[1];
            
            draw_sprite_ext(
                spr_grama_vamp_tini, _idx_linha, 
                _xx, _centro_y, 
                _escala_chao * _flip_linha, _escala_chao, 
                0, c_white, 1
            );
        }

        // --- FRONTEIRA HORIZONTAL (Entre Cima e Atual) ---
        if (_bioma_real != _bioma_cima) {
            var _dados_cima = _obter_dados_linha(_bioma_cima, _bioma_real);
            var _idx_linha = _dados_cima[0];
            var _flip_linha = _dados_cima[1];
            
            // O Segredo: O Ângulo de 270 (ou -90) faz o lado "Esquerdo" do seu sprite
            // apontar para CIMA. Assim a Cidade fica em cima e a Floresta em baixo!
            draw_sprite_ext(
                spr_grama_vamp_tini, _idx_linha, 
                _centro_x, _yy, 
                _escala_chao * _flip_linha, _escala_chao, 
                270, c_white, 1
            );
        }
    }
}

// 5. Devolve a aleatoriedade normal
randomize();