// feather disable GM2017
function draw_text_outlined(_x, _y, _cor, _cor2, _string){
    var _xx, _yy;  
    _xx = _x;  
    _yy = _y;  
  
    //Outline  
    draw_set_color(_cor);  
    draw_text(_xx + 1, _yy + 1, _string);  
    draw_text(_xx - 1, _yy - 1, _string);  
    draw_text(_xx,   _yy + 1, _string);  
    draw_text(_xx,   _yy - 1, _string);  
    draw_text(_xx + 1, _yy,   _string);  
    draw_text(_xx - 1, _yy,   _string);  
    draw_text(_xx + 1, _yy - 1, _string);  
    draw_text(_xx - 1, _yy + 1, _string);  
  
    //Text  
    draw_set_color(_cor2);  
    draw_text(_xx, _yy, _string);  
}

function draw_text_outlined_ext(_x1, _y1, _x2, _y2, _cor, _cor2, _string, _line_height) {
    var _width_limit = _x2 - _x1;
    var _height_limit = _y2 - _y1;
    var _current_line = "";
    var _words = string_split(_string, " ");
    var _yy = _y1;

    for (var _i = 0; _i < array_length(_words); _i++) {
        var _temp_line = _current_line + _words[_i] + " ";
        
        // Verifica se a linha atual com a nova palavra excede a largura
        if (string_width(_temp_line) > _width_limit) {
            // Desenha a linha atual se não estiver vazia
            draw_text_outlined(_x1, _yy, _cor, _cor2, _current_line);
            _yy += _line_height;
            _current_line = _words[_i] + " ";
            
            // Verifica se a altura excede o limite
            if (_yy + _line_height > _y2) break;
        } else {
            _current_line = _temp_line;
        }
    }

    // Desenha a última linha restante
    if (_current_line != "" && _yy + _line_height <= _y2) {
        draw_text_outlined(_x1, _yy, _cor, _cor2, _current_line);
    }
}

function draw_text_outlined_wrapped_block(_x1, _y1, _x2, _y2, _cor, _cor2, _string, _line_height) {
    var _width_limit = _x2 - _x1;
    var _current_line = "";
    var _words = string_split(_string, " ");
    var _yy = _y1;

    for (var _i = 0; _i < array_length(_words); _i++) {
        var _temp_line = _current_line + (_current_line == "" ? "" : " ") + _words[_i];

        // Quebra de linha ao exceder o limite de largura
        if (string_width(_temp_line) > _width_limit) {
            draw_text_outlined(_x1, _yy, _cor, _cor2, _current_line);
            _yy += _line_height;

            // Verifica se atingiu o limite de altura do bloco
            if (_yy + _line_height > _y2) return;

            _current_line = _words[_i];
        } else {
            _current_line = _temp_line;
        }
    }

    // Desenha a última linha restante
    if (_current_line != "") {
        draw_text_outlined(_x1, _yy, _cor, _cor2, _current_line);
    }
}

function draw_text_outlined_transformed(_x, _y, _str, _sep, _w, _xscale, _yscale, _out_color, _main_color) {
    // Desenha o contorno
    draw_set_color(_out_color);
    for (var _dx = -1; _dx <= 1; _dx++) {
        for (var _dy = -1; _dy <= 1; _dy++) {
            if (_dx == 0 && _dy == 0) continue;
            draw_text_ext_transformed(
                _x + _dx * 2, // Espessura do contorno (ajustável)
                _y + _dy * 2,
                _str,
                _sep,
                _w,
                _xscale,
                _yscale,
                0 // Ângulo (rotação) fixo em 0
            );
        }
    }
    
    // Restaura cor e desenha o texto principal
    draw_set_color(_main_color);
    
    draw_text_ext_transformed(_x, _y, _str, _sep, _w, _xscale, _yscale, 0);
}

/// @function draw_text_colour_outline(x, y, str, thickness, outline_color, quality, sep, w)
/// @desc Desenha texto com contorno usando draw_text_ext.
function draw_text_colour_outline(_x, _y, _str, _thickness, _outline_color, _quality, _sep, _w){

    // Salva a cor atual (que será a cor do texto principal)
    var _main_color = draw_get_color();

    // Define a cor do contorno
    draw_set_color(_outline_color);
    
    // Desenha o contorno girando em volta da posição original
    for(var _i = 45; _i < 405; _i += 360 / _quality)
    {
        draw_text_ext(
            _x + lengthdir_x(_thickness, _i),
            _y + lengthdir_y(_thickness, _i),
            _str,
            _sep,
            _w
        );
    }
    
    // Restaura a cor original
    draw_set_color(_main_color);
    
    // Desenha o texto principal por cima do contorno
    draw_text_ext(_x, _y, _str, _sep, _w);
}

/// @function draw_text_colour_outline_escalado(x, y, str, thickness, outline_color, quality, sep, w, xscale, yscale)
/// @desc Desenha texto escalado com contorno.
function draw_text_colour_outline_escalado(_x, _y, _str, _thickness, _outline_color, _quality, _sep, _w, _xscale, _yscale){

    // Guarda a cor original (texto principal)
    var _main_color = draw_get_color();

    // Configura cor do contorno
    draw_set_color(_outline_color);
    
    // Loop para desenhar o contorno (várias cópias do texto ao redor)
    for(var _i = 45; _i < 405; _i += 360 / _quality)
    {
        draw_text_ext_transformed(
            _x + round(lengthdir_x(_thickness, _i)),
            _y + round(lengthdir_y(_thickness, _i)),
            _str,
            _sep,
            _w,
            _xscale,
            _yscale,
            0 // Ângulo (rotação) fixo em 0
        );
    }
    
    // Restaura cor e desenha o texto principal
    draw_set_color(_main_color);
    
    draw_text_ext_transformed(_x, _y, _str, _sep, _w, _xscale, _yscale, 0);
}
