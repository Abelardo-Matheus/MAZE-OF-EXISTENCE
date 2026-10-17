// feather disable GM2017
// RATO GIGANTE
// Cenario: cidade
// Ratazana gigante com cicatriz: prepara e da investidas.
event_inherited();      // pai: obj_par_inimigos
inimigo_ia_criar();     // valores padrao da IA (script IA_INIMIGOS)

sprite_normal = spr_rato_gigante_andar;
sprite_parado = spr_rato_gigante_parado;

vida = 35;
dano = 14;
veloc = 0.6;
veloc_perse = 1.1;
escala = 1.1;
dist_aggro = 240;
dist_desaggro = 500;
comportamento = "investida";
sombra_largura = 46;

inimigo_ia_nivel();
