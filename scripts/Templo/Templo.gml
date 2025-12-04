// Defina isso em um script de inicialização ou no topo do arquivo (Macros)
#macro DIR_BAIXO 1
#macro DIR_ESQUERDA 2
#macro DIR_CIMA 3
#macro DIR_DIREITA 4
#macro CELL_VAZIO 0
#macro CELL_CHAO 1

// --- FUNÇÃO PRINCIPAL ---
function carregar_templo(_direcao) {
    // 1. Resetar e criar estrutura base
    criar_chao_room_inteira(global._maze_width, global._maze_height, global._maze);
    criar_templo_poder(global._maze_width, global._maze_height, global._maze, global.distancia_parede_templo, global.distancia_parede_templo);

    // 2. Abrir a entrada baseada na direção (Lógica extraída)
    temple_open_entrance(_direcao);

    // 3. Criar as instâncias físicas das paredes
    criar_paredes_intances(global._maze_width, global._maze_height, global._maze, global._cell_size);    

    // 4. Spawnar o poder (Lógica extraída)
    temple_spawn_powerup();
}

// --- HELPER: ABRIR ENTRADA ---
function temple_open_entrance(_dir) {
    var _grid = global._maze;
    var _tunnel_length = 5; // O quanto o tunel avança para fora (loop do 'i')

    switch (_dir) {
        case DIR_ESQUERDA:
            var _x = global.x_meio_esquerda;
            var _y = global.y_meio_esquerda;
            
            // Abre o chão (altura de 3 blocos: y-1 a y+1)
            ds_grid_set_region(_grid, _x, _y - 1, _x, _y + 1, CELL_CHAO);
            
            // Cria paredes do túnel
            for (var i = 1; i < _tunnel_length; i++) {
                ds_grid_set(_grid, _x - i, _y - 2, CELL_VAZIO);
                ds_grid_set(_grid, _x - i, _y + 2, CELL_VAZIO);
            }
            break;

        case DIR_DIREITA:
            var _x = global.x_meio_direita;
            var _y = global.y_meio_direita;

            // Abre o chão
            ds_grid_set_region(_grid, _x, _y - 1, _x, _y + 1, CELL_CHAO);

            // Cria paredes do túnel
            for (var i = 1; i < _tunnel_length; i++) {
                ds_grid_set(_grid, _x + i, _y - 2, CELL_VAZIO);
                ds_grid_set(_grid, _x + i, _y + 2, CELL_VAZIO);
            }
            break;

        case DIR_CIMA:
            var _x = global.x_meio_superior;
            var _y = global.y_meio_superior;

            // Abre o chão (Largura de 4 blocos: x-2 a x+1, mantendo sua lógica original)
            ds_grid_set_region(_grid, _x - 2, _y, _x + 1, _y, CELL_CHAO);

            // Cria paredes do túnel
            for (var i = 1; i < _tunnel_length; i++) {
                ds_grid_set(_grid, _x - 2, _y - i, CELL_VAZIO);
                ds_grid_set(_grid, _x + 2, _y - i, CELL_VAZIO);
            }
            break;

        case DIR_BAIXO:
            var _x = global.x_meio_inferior;
            var _y = global.y_meio_inferior;

            // Abre o chão
            ds_grid_set_region(_grid, _x - 2, _y, _x + 1, _y, CELL_CHAO);

            // Cria paredes do túnel
            for (var i = 1; i < _tunnel_length; i++) {
                ds_grid_set(_grid, _x - 2, _y + i, CELL_VAZIO);
                ds_grid_set(_grid, _x + 2, _y + i, CELL_VAZIO);
            }
            break;
    }
}

// --- HELPER: SPAWNAR PODER ---
function temple_spawn_powerup() {
    global.poder_escolhido = irandom(ds_list_size(global.lista_poderes_basicos) - 1);
    global.objeto_escolhido = procurar_poder(global.poder_escolhido);
    
    if (!global.objeto_escolhido.coletado) {
        instance_create_layer(global.room_width / 2, global.room_height / 2, "instances", global.objeto_escolhido.objeto);
    }
}