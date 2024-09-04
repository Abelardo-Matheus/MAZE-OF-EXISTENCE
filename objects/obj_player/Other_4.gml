
restaurar_estado_dash();


for (var i = 0; i < array_length_1d(global.salas_escuras); i++) {
    var sala_escura = global.salas_escuras[i];

    // Verificar se a sala atual é igual a sala escura
    if (global.current_sala[0] == sala_escura[0] && global.current_sala[1] == sala_escura[1]) {
        encontrou_sala_escura = true;
        break; // Parar o loop se a sala for encontrada
    }
}













