// feather disable GM2017
event_inherited();
randomize();
image_index = irandom_range(0, 3);
quantis = -1;

if (image_index == 1) {
    quantis = irandom_range(1, 2);
} 
else if (image_index == 2) {
    quantis = irandom_range(2, 4);
} 
else if (image_index == 3) {
    quantis = irandom_range(4, 6);
}
escale = irandom_range(4, 7);
image_xscale = escale;
image_yscale = escale;
depth = -y;

// Tom da pedra conforme o bioma
cor_bioma = terreno_cor_objeto(x, y, "pedra");
image_blend = cor_bioma;
