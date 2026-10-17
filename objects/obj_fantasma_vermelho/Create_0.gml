// feather disable GM2017
// FANTASMA VERMELHO
// Cenario: floresta negra / vazio
// Fantasma raivoso em chamas: treme e da um bote rapido no jogador.
event_inherited();

sprite_normal = spr_fantasma_vermelho_andar;
sprite_parado = spr_fantasma_vermelho_parado;

vida = 20;
dano = 14;
veloc = 0.6;
veloc_perse = 1.4;
escala = 1.0;
dist_aggro = 260;
dist_desaggro = 520;
comportamento = "investida";
atravessa = true;
voa = true;
transparencia = 0.85;
sombra_largura = 30;

inimigo_novo_aplicar_nivel();
