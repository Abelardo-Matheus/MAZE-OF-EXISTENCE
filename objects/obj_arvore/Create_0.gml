// feather disable GM2017
randomize();
// Sprite do bioma (spr_arvore_<bioma>): 3 variantes x VENTO_POSES poses de vento.
// frame = variante * VENTO_POSES + pose   (pose 0 = inclinada p/ esquerda, 3 = reta, 6 = direita)
var _spr_bioma = asset_get_index("spr_arvore_" + terreno_bioma_em(x, y));
sprite_index = (_spr_bioma != -1) ? _spr_bioma : spr_arvore_floresta;
vento_garantir();                     // cria o obj_vento da sala se ainda nao existir
variante = irandom(2);
vento_fase = random(2 * pi);          // cada arvore balanca num tempo diferente
vento_incl = 0;                       // inclinacao atual (suavizada)
image_speed = 0;
image_index = variante * VENTO_POSES + vento_pose(0);
escale = irandom_range(2, 6);
image_xscale = escale;
image_yscale = escale;
depth = -y;

vida = 100;

// ==========================================
// VARIÁVEIS DE EFEITO DE DANO
// ==========================================
tempo_piscar = 0;
tempo_balancar = 0;
angulo_original = image_angle; // Salva o ângulo inicial para ele voltar ao normal depois

// Tom da arvore conforme o bioma (neve = congelada, deserto = seca...)
// (o sprite do bioma ja tem as cores certas, entao nao tinge mais)
cor_bioma = c_white;
image_blend = cor_bioma;
