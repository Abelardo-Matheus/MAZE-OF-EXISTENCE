// feather disable GM2017
// RATO
// Cenario: cidade
// Rato de esgoto: pouca vida, muito rapido.
event_inherited();      // pai: obj_par_inimigos
inimigo_ia_criar();     // valores padrao da IA (script IA_INIMIGOS)

sprite_normal = spr_rato_andar;
sprite_parado = spr_rato_parado;

vida = 6;
dano = 5;
veloc = 1.1;
veloc_perse = 2.4;
escala = 0.8;
dist_aggro = 240;
dist_desaggro = 480;
sombra_largura = 36;

inimigo_ia_nivel();
