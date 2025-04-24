draw_self(); // desenha o sprite normalmente

// Alpha oscilando entre 0.3 e 0.8
var alpha_pulsante = 0.55 + 0.25 * sin(current_time * 0.005);

// Cor e alpha
draw_set_color(c_red);
draw_set_alpha(alpha_pulsante);

// Desenha várias bordas para parecer uma linha mais grossa
for (var i = 0; i < 30; i++) {
    draw_circle(x, y, distancia_criar - 1 + i, true); // borda falsa com espessura
	
}

// Restaura alpha padrão
draw_set_alpha(1);
