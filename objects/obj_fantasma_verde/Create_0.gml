// feather disable GM2017
// FANTASMA VERDE
// Cenario: floresta negra (pantano)
// Fantasma do pantano coberto de musgo: lento, resistente e bate forte.
event_inherited();      // pai: obj_par_inimigos
inimigo_ia_criar();     // valores padrao da IA (script IA_INIMIGOS)

sprite_normal = spr_fantasma_verde_andar;
sprite_parado = spr_fantasma_verde_parado;

vida = 28;
dano = 18;
veloc = 0.4;
veloc_perse = 0.9;
escala = 1.15;
dist_aggro = 220;
dist_desaggro = 450;
atravessa = true;
voa = true;
transparencia = 0.8;
sombra_largura = 32;

inimigo_ia_nivel();
