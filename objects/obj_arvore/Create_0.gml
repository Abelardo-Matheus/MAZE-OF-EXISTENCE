randomize();
image_index = irandom_range(1, 3);
escale = irandom_range(2, 6);
image_xscale = escale;
image_yscale = escale;
depth = -y;

vida = 100;

// ==========================================
// VARIÁVEIS DE EFEITO DE DANO
// ==========================================
tempo_piscar = 0;
tempo_balancar = 0;
angulo_original = image_angle; // Salva o ângulo inicial para ele voltar ao normal depois