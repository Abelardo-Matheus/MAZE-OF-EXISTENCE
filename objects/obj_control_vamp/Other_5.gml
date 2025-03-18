// Salva as posições das estruturas ao sair da sala
if (ds_list_size(global.posicoes_estruturas) > 0) {
    // Limpa a lista antes de salvar
    ds_list_clear(global.posicoes_estruturas);

    // Salva as posições das estruturas existentes
    with (obj_casa) {
        ds_list_add(global.posicoes_estruturas, x, y);
    }
}