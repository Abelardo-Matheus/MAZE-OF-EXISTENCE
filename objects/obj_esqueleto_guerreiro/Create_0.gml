// feather disable GM2017
// ESQUELETO GUERREIRO
// Cenario: floresta negra / vazio
// Esqueleto com elmo e escudo: lento, mas aguenta muito dano.
event_inherited();      // pai: obj_par_inimigos
inimigo_ia_criar();     // valores padrao da IA (script IA_INIMIGOS)

sprite_normal = spr_esqueleto_guerreiro_andar;
sprite_parado = spr_esqueleto_guerreiro_parado;

vida = 40;
dano = 15;
veloc = 0.5;
veloc_perse = 0.75;
escala = 1.1;
dist_aggro = 220;
dist_desaggro = 450;
sombra_largura = 26;

inimigo_ia_nivel();
