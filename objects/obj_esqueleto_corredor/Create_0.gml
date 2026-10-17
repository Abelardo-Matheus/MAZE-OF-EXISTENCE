// feather disable GM2017
// ESQUELETO CORREDOR
// Cenario: floresta negra / noite
// Esqueleto sombrio de olhos vermelhos: fragil e muito rapido.
event_inherited();

sprite_normal = spr_esqueleto_corredor_andar;
sprite_parado = spr_esqueleto_corredor_parado;

vida = 10;
dano = 8;
veloc = 0.9;
veloc_perse = 2.3;
escala = 1.05;
dist_aggro = 260;
dist_desaggro = 500;
sombra_largura = 24;

inimigo_novo_aplicar_nivel();
