// feather disable GM2017
/// @desc Anima a abertura e libera a passagem no fim
if (!abrindo) exit;
if (image_index >= image_number - 1) {
    image_index = image_number - 1;
    image_speed = 0;
    abrindo = false;
    aberta = true;
    if (variable_global_exists("id_parede_um") && instance_exists(global.id_parede_um)) {
        instance_destroy(global.id_parede_um);
    }
}
