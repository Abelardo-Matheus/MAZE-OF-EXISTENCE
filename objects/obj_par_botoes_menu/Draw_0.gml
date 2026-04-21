current_scale = lerp(current_scale, target_scale, lerp_speed);

// Se o mouse estiver em cima, aplica o filtro mágico
if (glow_ativo) {
    shader_set(shd_glow_botao);
    
    // FORÇA DO BRILHO (Se a sua imagem for gigante, aumente este valor para 15.0 ou 20.0)
    var _forca_brilho = 6.0; 
    shader_set_uniform_f(uni_size, _forca_brilho); 
    
    // COR DO BRILHO (R, G, B) de 0.0 a 1.0
    // Amarelo dourado: 1.0, 0.8, 0.2
    // Azul mágico: 0.2, 0.5, 1.0
    shader_set_uniform_f(uni_color, 1.0, 0.8, 0.2); 
    
    // Envia o tamanho dos pixels
    shader_set_uniform_f(uni_w, tex_w);
    shader_set_uniform_f(uni_h, tex_h);
}

// Desenha o botão (agora passando pelo filtro se estiver ligado)
draw_sprite_ext(sprite_index, image_index, x, y, current_scale, current_scale, 0, c_white, 1);

// Desliga o filtro
if (glow_ativo) {
    shader_reset();
}