
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

function draw_text_colour_outline(){

var dto_dcol = draw_get_color();

	draw_set_color(argument4);
	
	for(var dto_i=45; dto_i<405; dto_i+=360/argument5)
	{
	
	draw_text_ext(argument0+round(lengthdir_x(argument3,dto_i)),argument1+round(lengthdir_y(argument3,dto_i)),argument2,argument6,argument7);
	
	}
	
	draw_set_color(dto_dcol);
	
	draw_text_ext(argument0,argument1,argument2,argument6,argument7);

}


