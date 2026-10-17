// feather disable GM2017
// OLHO VAZIO
// Cenario: vazio
// Olho flutuante com tentaculos: mantem distancia e dispara orbes.
event_inherited();      // pai: obj_par_inimigos
inimigo_ia_criar();     // valores padrao da IA (script IA_INIMIGOS)

sprite_normal = spr_olho_vazio_andar;
sprite_parado = spr_olho_vazio_parado;

vida = 24;
dano = 8;
veloc = 0.4;
veloc_perse = 0.9;
escala = 1.0;
dist_aggro = 340;
dist_desaggro = 600;
comportamento = "distancia";
atravessa = true;
voa = true;
sprite_tiro = spr_orbe_vazio;
dist_tiro = 240;
cadencia_tiro = 110;
dano_tiro = 12;
vel_tiro = 3;
altura_tiro = 32;
sombra_largura = 30;

inimigo_ia_nivel();
