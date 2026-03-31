// Desliga a animação para não ficar piscando
image_speed = 0;



// Cria uma lista vazia para guardar os detalhes
detalhes = [];

// 50% de chance deste bloco de grama ter detalhes por cima
if (random(100) < 50) 
{
    var _qtd_detalhes = irandom_range(1, 4); // Vai ter de 1 a 4 pedrinhas/flores
    
    for (var i = 0; i < _qtd_detalhes; i++) 
    {
        // Escolhe o frame do detalhe (Frames 4 a 10)
        var _frame = choose(4, 5, 6, 7, 8, 9, 10);
        
        // A MÁGICA: Escala bem menor! (Ex: 0.2 a 0.4 do tamanho original)
        var _escala = random_range(0.2, 0.4); 
        
        // Posição aleatória em cima da grama de 272x272
        var _ox = irandom_range(10, 260); 
        var _oy = irandom_range(10, 260);
        
        // Rotação aleatória para não ficar tudo reto
        var _angulo = random(360); 

        // Salva essas informações para desenhar depois
        array_push(detalhes, {
            frame_img: _frame,
            escala_img: _escala,
            offset_x: _ox,
            offset_y: _oy,
            rotacao: _angulo
        });
    }
}