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
// Se image_index for 0, quantis continuará sendo -1
escala = 4;
image_xscale =  escala;
image_yscale =  escala;
depth = -y;