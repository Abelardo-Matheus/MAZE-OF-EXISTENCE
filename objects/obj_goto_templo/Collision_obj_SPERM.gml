// Desativar todas as instâncias, exceto obj_controle
instance_deactivate_all(true); // Desativa todas as instâncias

// Reativar o obj_controle manualmente para que ele não seja destruído
instance_activate_object(obj_control_fase_1);

// Mudar para a sala TEMPLO
room_goto(TEMPLO);










