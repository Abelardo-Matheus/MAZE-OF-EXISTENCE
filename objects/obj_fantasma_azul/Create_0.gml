// feather disable GM2017
// FANTASMA AZUL
// Cenario: floresta negra
// Fantasma classico: atravessa paredes e fica semi-transparente.
event_inherited();

sprite_normal = spr_fantasma_azul_andar;
sprite_parado = spr_fantasma_azul_parado;

vida = 16;
dano = 10;
veloc = 0.5;
veloc_perse = 1.3;
escala = 1.0;
dist_aggro = 250;
dist_desaggro = 500;
atravessa = true;
voa = true;
transparencia = 0.75;
sombra_largura = 30;

inimigo_novo_aplicar_nivel();
