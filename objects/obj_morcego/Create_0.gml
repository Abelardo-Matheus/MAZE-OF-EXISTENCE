// feather disable GM2017
// MORCEGO
// Cenario: cidade (noite)
// Morcego que voa em zigue-zague em volta do jogador.
event_inherited();

sprite_normal = spr_morcego_andar;
sprite_parado = spr_morcego_parado;

vida = 6;
dano = 5;
veloc = 1.2;
veloc_perse = 2.0;
escala = 0.9;
dist_aggro = 280;
dist_desaggro = 550;
comportamento = "erratico";
atravessa = true;
voa = true;
sombra_largura = 22;

inimigo_novo_aplicar_nivel();
