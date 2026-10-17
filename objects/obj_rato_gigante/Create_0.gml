// feather disable GM2017
// RATO GIGANTE
// Cenario: cidade
// Ratazana gigante com cicatriz: prepara e da investidas.
event_inherited();

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

inimigo_novo_aplicar_nivel();
