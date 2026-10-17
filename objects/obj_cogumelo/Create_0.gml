// feather disable GM2017
// COGUMELO
// Cenario: floresta
// Cogumelo disfarcado: fica parado ate o jogador chegar perto e entao pula atras dele.
event_inherited();

sprite_normal = spr_cogumelo_andar;
sprite_parado = spr_cogumelo_parado;

vida = 18;
dano = 10;
veloc = 0;
veloc_perse = 1.2;
escala = 1.0;
dist_aggro = 140;
dist_desaggro = 380;
comportamento = "emboscada";
sombra_largura = 34;

inimigo_novo_aplicar_nivel();
