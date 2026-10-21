// feather disable GM2017
/// @description Controle do vento (1 por sala) + efeito visual
// Criado sozinho pelas arvores (vento_garantir). Atualiza global.vento e
// desenha riscos de vento e folhas voando por cima do cenario.
vento_init();
depth = -100000;
particulas = [];   // structs { tipo, x, y, vx, vy, vida, dur, esc, cor, fase }
max_part = 45;
