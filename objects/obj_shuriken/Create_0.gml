// feather disable GM2017
// Inicializa as propriedades da shuriken
angle = 0; // Ângulo inicial
speed = 3; // Velocidade base
radius = 50; // Raio base
damage = 10; // Dano base
push = 0;
veloc = 0;
duration = 2000; // Duração base
escala_base = 0.2 * sprite_ajuste(sprite_index); // sprite refeito em 64x64
image_xscale = escala_base;
image_yscale = escala_base;
hit_list = ds_list_create();
reset_hit_timer = 0;