
function draw_text_outlined(x,y,cor,cor2,string){
var xx,yy;  
xx = x;  
yy = y;  
  
//Outline  
draw_set_color(cor);  
draw_text(xx+1, yy+1, string);  
draw_text(xx-1, yy-1, string);  
draw_text(xx,   yy+1, string);  
draw_text(xx+1,   yy, string);  
draw_text(xx,   yy-1, string);  
draw_text(xx-1,   yy, string);  
draw_text(xx-1, yy+1, string);  
draw_text(xx+1, yy-1, string);  
  
//Text  
draw_set_color(cor2);  
draw_text(xx, yy, string);  

}
function draw_text_outlined_wrapped_block(x1, y1, x2, y2, cor, cor2, string, line_height) {
    var width_limit = x2 - x1; // Largura do bloco
    var height_limit = y2 - y1; // Altura do bloco
    var current_line = "";
    var words = string_split(string, " ");
    var yy = y1;

    // Se debug estiver ativo, desenha o retângulo delimitador
    if (global.debug) {
        draw_set_color(c_orange); // ou qualquer cor de destaque
        draw_set_alpha(0.8); // transparência para facilitar visualização
        draw_rectangle(x1, y1, x2, y2, false);
        draw_set_alpha(1); // restaura a opacidade
    }

    for (var i = 0; i < array_length_1d(words); i++) {
        var temp_line = current_line + (current_line == "" ? "" : " ") + words[i];

        // Quebra de linha ao exceder o limite de largura
        if (string_width(temp_line) > width_limit) {
            draw_text_outlined(x1, yy, cor, cor2, current_line);
            yy += line_height;

            // Verifica se atingiu o limite de altura do bloco
            if (yy + line_height > y2) {
                break;
            }

            current_line = words[i]; // Inicia uma nova linha
        } else {
            current_line = temp_line; // Continua construindo a linha
        }
    }

    // Desenha a última linha restante
    if (current_line != "") {
        draw_text_outlined(x1, yy, cor, cor2, current_line);
    }
}



/// @function draw_text_colour_outline(x, y, str, thickness, outline_color, quality, sep, w)
/// @desc Desenha texto com contorno usando draw_text_ext.
/// @param {Real} _x Posição X.
/// @param {Real} _y Posição Y.
/// @param {String} _str O texto.
/// @param {Real} _thickness Espessura do contorno.
/// @param {Constant.Color} _outline_color Cor do contorno.
/// @param {Real} _quality Precisão (ex: 4 = cantos, 8 = mais redondo).
/// @param {Real} _sep Separação entre linhas.
/// @param {Real} _w Largura máxima da linha.
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
/// @param {Real} _x Posição X.
/// @param {Real} _y Posição Y.
/// @param {String} _str O texto.
/// @param {Real} _thickness Espessura do contorno.
/// @param {Constant.Color} _outline_color Cor do contorno.
/// @param {Real} _quality Precisão (ex: 8).
/// @param {Real} _sep Separação entre linhas.
/// @param {Real} _w Largura máxima.
/// @param {Real} _xscale Escala X.
/// @param {Real} _yscale Escala Y.
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



