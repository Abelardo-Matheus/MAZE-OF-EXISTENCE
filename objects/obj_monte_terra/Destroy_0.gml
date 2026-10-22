// feather disable GM2017
// Só fica "morto" de vez quando foi QUEBRADO (coleta_quebrar põe quebrada = true).
// Sair de perto (despawn do obj_otimizador) também destrói a instância, e aí ela tem que
// voltar quando o player chegar perto de novo.
if (variable_instance_exists(id, "virtual_id") && variable_instance_exists(id, "quebrada") && quebrada) {
    global.entidades_mortas[? virtual_id] = true;
}
