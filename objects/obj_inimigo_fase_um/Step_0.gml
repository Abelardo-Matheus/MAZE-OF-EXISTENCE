// Verifica se o obj_sperm existe na sala
if (instance_exists(obj_SPERM)) {
    // Obtém a posição do obj_sperm
    var alvo_x = obj_SPERM.x;
    var alvo_y = obj_SPERM.y;
    
    // Direção do inimigo para o obj_sperm
    var direcao = point_direction(x, y, alvo_x, alvo_y);
    
    // Ajustar a rotação do inimigo para a direção calculada
    image_angle = direcao + 90;  // Subtrai 90 graus para alinhar o "frente" do retângulo corretamente
    
    // Velocidade do inimigo
  
    
    // Movimentar o inimigo na direção do obj_sperm
    x += lengthdir_x(velocidade_inimigo, direcao);
    y += lengthdir_y(velocidade_inimigo, direcao);
}

