
restaurar_estado_dash();

current_speed = global.speed_player;

direction_x = 0;
direction_y = 0;
image_xscale = 1.5;
image_yscale = 1.5;

sprite_index = spr_player_baixo; // Ajuste conforme a direção inicial
image_speed = 1;

// Criar o bloco de colisão logo acima do personagem
global.bloco_colisao = instance_create_layer(x, y+30, "instances", obj_colisao);

hveloc = 0;
vveloc = 0;
direita = -1;
esquerda = -1;
cima = -1;
baixo = -1;






