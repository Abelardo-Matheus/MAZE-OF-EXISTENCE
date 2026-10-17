// feather disable GM2017
// ESQUELETO ARQUEIRO
// Cenario: floresta negra
// Mantem distancia e atira flechas de osso.
event_inherited();      // pai: obj_par_inimigos
inimigo_ia_criar();     // valores padrao da IA (script IA_INIMIGOS)

sprite_normal = spr_esqueleto_arqueiro_andar;
sprite_parado = spr_esqueleto_arqueiro_parado;

vida = 14;
dano = 6;
veloc = 0.6;
veloc_perse = 1.0;
escala = 1.1;
dist_aggro = 320;
dist_desaggro = 520;
sombra_largura = 24;
comportamento = "distancia";
sprite_tiro = spr_flecha_osso;
dist_tiro = 210;
cadencia_tiro = 90;
dano_tiro = 10;
vel_tiro = 4.5;
altura_tiro = 34;

inimigo_ia_nivel();
