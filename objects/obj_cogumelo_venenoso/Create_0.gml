// feather disable GM2017
// COGUMELO VENENOSO
// Cenario: floresta
// Versao venenosa e roxa do cogumelo: mais vida e mais dano.
event_inherited();

sprite_normal = spr_cogumelo_venenoso_andar;
sprite_parado = spr_cogumelo_venenoso_parado;

vida = 22;
dano = 16;
veloc = 0;
veloc_perse = 1.0;
escala = 1.05;
dist_aggro = 140;
dist_desaggro = 380;
comportamento = "emboscada";
sombra_largura = 34;

inimigo_novo_aplicar_nivel();
