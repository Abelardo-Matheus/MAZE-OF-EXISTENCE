// feather disable GM2017
timer = 5000;
damage = 10;
push = 1;
veloc = 0;
/// @description Inicializar variáveis de animação e movimento

escala_base = 1 * sprite_ajuste(sprite_index); // sprite refeito em 64x64
// Garante que comece no tamanho certo
image_xscale = escala_base;
image_yscale = escala_base;
// --- Configurações de Animação (Fase 1) ---
// Velocidade da animação manual do frame 0 ao 3
velocidade_aparecer = 0.2; 
image_speed = 0; // Começa parado (animação automática desligada)
image_index = 0; // Começa no primeiro frame
ja_encostou = false; // Flag para controlar o estado da animação

// --- Configurações de Movimento ---
velocidade_movimento = 6; // Quão rápido a bola voa (ajuste aqui)
alvo = noone; // Variável para guardar o inimigo alvo

// Encontra o inimigo mais próximo ao nascer
// Certifique-se de que 'obj_par_inimigos' é o objeto pai correto
if (instance_exists(obj_par_inimigos)) {
    alvo = instance_nearest(x, y, obj_par_inimigos);
}