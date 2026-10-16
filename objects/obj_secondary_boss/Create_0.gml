// feather disable GM2017
boss_invocado = false;      // Controla se o boss já foi chamado
distancia_interacao = 100;   // Distância em pixels para o botão 'F' funcionar

escala_base = 0.2 * sprite_ajuste(sprite_index); // sprite refeito em 64x64
// Garante que comece no tamanho certo
image_xscale = escala_base;
image_yscale = escala_base;