// feather disable GM2017
/// @description Libera a imagem da pausa
// A cópia duplicada se destrói na 1ª linha do Create, antes de "snapshot" existir
if (variable_instance_exists(id, "snapshot") && sprite_exists(snapshot)) sprite_delete(snapshot);
