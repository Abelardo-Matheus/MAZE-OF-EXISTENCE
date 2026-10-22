// feather disable GM2017
/// @desc Montinho de terra: só sai com PÁ (scr_coleta). Frame pelo bioma: 0 terra, 1 areia, 2 neve.
event_inherited(); // vida 100 + efeitos de dano (par_objetos)
var _b = terreno_bioma_em(x, y);
image_index = (_b == "deserto") ? 1 : ((_b == "neve") ? 2 : 0);
image_speed = 0;
escala = random_range(2.2, 3);
image_xscale = escala * choose(-1, 1);
image_yscale = escala;
depth = -y;
solid = false;
