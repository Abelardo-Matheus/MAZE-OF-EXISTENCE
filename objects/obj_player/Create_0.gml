


direction_x = 0;
direction_y = 0;
image_xscale = 1.5;
image_yscale = 1.5;

sprite_index = spr_player_baixo; // Ajuste conforme a direção inicial
image_speed = 1;

// Criar o bloco de colisão logo acima do personagem
global.bloco_colisao = instance_create_layer(x, y+30, "instances", obj_colisao);
state = scr_andando
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



