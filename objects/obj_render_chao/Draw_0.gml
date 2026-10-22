// feather disable GM2017
// ============================================================================
// CHAO DO MUNDO (otimizado)
// O chao e desenhado em regioes de 16x16 tiles dentro de surfaces (script TERRENO).
// Cada regiao e montada uma vez so; a cada frame desenhamos apenas as surfaces.
// ============================================================================
var _cam = view_camera[0];
var _cam_x = camera_get_view_x(_cam);
var _cam_y = camera_get_view_y(_cam);
var _cam_w = camera_get_view_width(_cam);
var _cam_h = camera_get_view_height(_cam);

var _tam = TERRENO_TILE_MUNDO * TERRENO_REGIAO; // tamanho da regiao no mundo (1536 px)

// regioes visiveis
var _rx0 = floor(_cam_x / _tam);
var _ry0 = floor(_cam_y / _tam);
var _rx1 = floor((_cam_x + _cam_w) / _tam);
var _ry1 = floor((_cam_y + _cam_h) / _tam);

var _extras = 0;

// percorre as visiveis + 1 de margem (a margem e pre-desenhada aos poucos)
for (var _rx = _rx0 - 1; _rx <= _rx1 + 1; _rx++) {
    for (var _ry = _ry0 - 1; _ry <= _ry1 + 1; _ry++) {
        var _visivel = (_rx >= _rx0 && _rx <= _rx1 && _ry >= _ry0 && _ry <= _ry1);
        var _k = string(_rx) + "," + string(_ry);
        var _s = regioes[? _k];

        if (is_undefined(_s) || !surface_exists(_s)) {
            // visivel: desenha agora | margem: no maximo 1 por frame
            if (!_visivel) {
                if (_extras >= max_construcoes_extras) continue;
                _extras++;
            }
            _s = terreno_construir_regiao(_rx, _ry);
            regioes[? _k] = _s;
        }

        if (_visivel) {
            draw_surface_ext(_s, _rx * _tam, _ry * _tam, TERRENO_ESCALA, TERRENO_ESCALA, 0, c_white, 1);
        }
    }
}

// Rastro de veneno do player (scr_rastro_sombrio): no chão, por baixo de tudo
rastro_desenhar();

// libera da memoria as regioes que ficaram longe (a cada ~2 s)
timer_limpeza++;
if (timer_limpeza >= 120) {
    timer_limpeza = 0;
    var _chaves = ds_map_keys_to_array(regioes);
    for (var _i = 0; _i < array_length(_chaves); _i++) {
        var _partes = string_split(_chaves[_i], ",");
        var _qx = real(_partes[0]);
        var _qy = real(_partes[1]);
        if (_qx < _rx0 - 3 || _qx > _rx1 + 3 || _qy < _ry0 - 3 || _qy > _ry1 + 3) {
            var _sf = regioes[? _chaves[_i]];
            if (surface_exists(_sf)) surface_free(_sf);
            ds_map_delete(regioes, _chaves[_i]);
        }
    }
}
