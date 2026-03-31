// 1. Desenha o bloco de grama grande normal no fundo
draw_self();

// 2. Desenha os detalhes minúsculos por cima
var _total = array_length(detalhes);

//for (var i = 0; i < _total; i++) 
//{
//    var _d = detalhes[i];
    
//    // Pinta o detalhe usando as informações que sorteamos no Create
//    draw_sprite_ext(
//        sprite_index,   // O mesmo sprite (spr_chao_tudo)
//        _d.frame_img,   // O frame da pedrinha/flor
//        x + _d.offset_x, // Posição X em cima da grama
//        y + _d.offset_y, // Posição Y em cima da grama
//        _d.escala_img,  // Escala X (Bem menor)
//        _d.escala_img,  // Escala Y (Bem menor)
//        _d.rotacao,     // Girado aleatoriamente
//        c_white, 
//        1
//    );
//}