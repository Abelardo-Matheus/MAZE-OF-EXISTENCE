// feather disable GM2017
/// @desc Parede com porta dupla que fecha a sala de brinquedos no tutorial.
/// Frames do spr_porta_dupla_tuto: 0 trancada (cadeado) | 1 fechada | 2-5 abrindo.
/// A colisão continua sendo a parede invisível do room (global.id_parede_um);
/// ela só é destruída quando a porta termina de abrir (scr_tutorial, passo 8).
image_speed = 0;
image_index = 0;
abrindo = false;
aberta = false;

/// @desc Começa a abrir a porta (a Fada libera a passagem)
abrir = function() {
    if (abrindo || aberta) return;
    abrindo = true;
    image_index = 1;
    image_speed = 1;
}
