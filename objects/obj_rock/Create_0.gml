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
// Sprite do bioma (spr_rock_<bioma>), mesmos 4 tamanhos do spr_rock.
// Floresta (ou bioma sem sprite) usa o spr_rock original.
var _spr_bioma = asset_get_index("spr_rock_" + terreno_bioma_em(x, y));
if (_spr_bioma != -1) {
    sprite_index = _spr_bioma;
    cor_bioma = c_white;
} else {
    cor_bioma = terreno_cor_objeto(x, y, "pedra");
}
image_blend = cor_bioma;
