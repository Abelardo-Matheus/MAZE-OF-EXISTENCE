/// @description Insert description here
// You can write your code in this editor


    // Código que será executado em caso de colisão
    // Por exemplo: parar o movimento ou aplicar um efeito
    
    // Aqui você pode parar o movimento ou fazer outro comportamento
    speed = 2;

    // Alternativamente, você pode aplicar uma força contrária para "empurrar" os inimigos
    var direcao_colisao = point_direction(x, y, other.x, other.y);
    x += lengthdir_x(-3, direcao_colisao);  // Empurra o inimigo para trás
    y += lengthdir_y(-3, direcao_colisao);

// Quando dois inimigos colidem

// Calcular a direção entre os dois inimigos para afastá-los
var direcao = point_direction(x, y, other.x, other.y);

// Empurrar ambos os inimigos na direção oposta à colisão
x += lengthdir_x(-3, direcao);
y += lengthdir_y(-3, direcao);

// Também mover o outro inimigo
other.x += lengthdir_x(3, direcao);
other.y += lengthdir_y(3, direcao);

// Código adicional para colisão (parar movimento, mudar direção, etc.)













