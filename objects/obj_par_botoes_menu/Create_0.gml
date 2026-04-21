escala_base = image_xscale;
current_scale = escala_base;
target_scale = escala_base;
lerp_speed = 0.2;

// --- CONFIGURAÇÃO DO SHADER ---
glow_ativo = false;

// Pega os endereços das variáveis lá dentro do Shader
uni_size  = shader_get_uniform(shd_glow_botao, "u_glow_size");
uni_color = shader_get_uniform(shd_glow_botao, "u_glow_color");
uni_w     = shader_get_uniform(shd_glow_botao, "u_pixel_w");
uni_h     = shader_get_uniform(shd_glow_botao, "u_pixel_h");

// Descobre o tamanho real dos pixels da sua Sprite na memória
var _tex = sprite_get_texture(sprite_index, 0);
tex_w = texture_get_texel_width(_tex);
tex_h = texture_get_texel_height(_tex);