// feather disable GM2017
// MORCEGO VAMPIRO
// Cenario: floresta negra
// Morcego vampiro: zigue-zague e recupera vida ao morder.
event_inherited();      // pai: obj_par_inimigos
inimigo_ia_criar();     // valores padrao da IA (script IA_INIMIGOS)

sprite_normal = spr_morcego_vampiro_andar;
sprite_parado = spr_morcego_vampiro_parado;

vida = 14;
dano = 8;
veloc = 1.0;
veloc_perse = 2.2;
escala = 1.0;
dist_aggro = 300;
dist_desaggro = 600;
comportamento = "erratico";
atravessa = true;
voa = true;
roubo_vida = 1;
sombra_largura = 24;

inimigo_ia_nivel();
