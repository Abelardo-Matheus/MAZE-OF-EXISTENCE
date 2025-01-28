
direction_x = 0;
direction_y = 0;
image_xscale = 1;
image_yscale = 1;

sprite_index = spr_player_baixo; // Ajuste conforme a direção inicial
image_speed = 1;

// Criar o bloco de colisão logo acima do personagem
global.bloco_colisao = instance_create_layer(x, y+30, "instances", obj_colisao);
state = scr_andando_vamp
hveloc = -1;
vveloc = -1;
direita = -1;
esquerda = -1;
cima = -1;
baixo = -1;
veloc_dir = -1;
dano = global.ataque;
atacando = false;
andar = false;
hit = false;
tomar_dano = true;
empurrar_dir = 0;
pegar = false;
dano_alfa = -1;
dir_alfa = 0;  // Começa com alfa cheio (1.0)
desenha_arma = false;  // Variável de controle para desenhar o sprite
desenha_botao = false;

// Inicialize as variáveis (essas variáveis devem ser inicializadas uma vez, como no evento Create)
piscando_alpha = 1;  // Opacidade inicial do botão
piscando_timer = 30;  // Intervalo de piscada (30 frames, ajustável)

dash_dir = -1;
dash_veloc = 20;