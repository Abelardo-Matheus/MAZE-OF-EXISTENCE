
gerar_estruturas(obj_estrutura, quantidade_estruturas, distancia_minima);
gerar_estruturas(obj_poste, 5, 100);
gerar_estruturas(obj_grupo_inimigos,10,100);

gerar_estruturas(par_npc_vendedor_um,10,100);
if (mouse_check_button_pressed(mb_left)) {
    var mx = device_mouse_x_to_gui(0); // ou apenas mouse_x se não estiver usando GUI
    var my = device_mouse_y_to_gui(0); // ou apenas mouse_y
    show_debug_message("Mouse clicado na posição: x = " + string(mx) + ", y = " + string(my));
}



if (!variable_global_exists("enemy_id_counter")) {
    global.enemy_id_counter = 0; // Contador para IDs únicos
}

if (global.level_up == true) {
    alarm[0]++;
    exit;
}

var _side = irandom(1);

if (alarm[0] <= 0 and !global.day_night_cycle.is_day) {
    var _enemy_id = global.enemy_id_counter++; // Gera um ID único para o inimigo

    if (_side == 0) {
        var _xx = irandom_range(global.cmx, global.cmx + global.cmw);
        var _yy = choose(global.cmy - 12, global.cmy + global.cmh + 64);

        var _inimigoA = instance_create_layer(_xx, _yy, "instances", obj_amoeba);
        _inimigoA.dist_aggro = 2000;
        _inimigoA.dist_desaggro = 2000;
        _inimigoA.escala = 1.5;
		_inimigoA.vida=1000;
		_inimigoA.max_vida=1000;
        _inimigoA.id_inimigo = _enemy_id; // Associa o ID ao inimigo criado

        // Adiciona o inimigo e seu ID na lista global
        ds_list_add(global.enemy_list, _enemy_id);
    } else if (_side == 1) {
        var _xx = choose(global.cmx - 12, global.cmx + global.cmw + 64);
        var _yy = irandom_range(global.cmy, global.cmy + global.cmh);

        var _inimigoB = instance_create_layer(_xx, _yy, "instances", obj_amoeba);
        _inimigoB.dist_aggro = 2000;
        _inimigoB.dist_desaggro = 2000;
        _inimigoB.escala = 1.5;
		_inimigoB.vida=1000;
		_inimigoB.max_vida=1000;
        _inimigoB.id_inimigo = _enemy_id; // Associa o ID ao inimigo criado

        // Adiciona o inimigo e seu ID na lista global
        ds_list_add(global.enemy_list, _enemy_id);
    }

    alarm[0] = spaw_timer; // Reinicia o timer de spawn
}

// Tecla para simular level up
if (keyboard_check_pressed(vk_enter)) {
    level_up();
}

// Configurações do terreno
var tile_size = 272; // Tamanho de cada tile
var grid_radius = 10; // Número de tiles ao redor do jogador em cada direção (3x3, 5x5, etc.)
var max_distance = (grid_radius + 20) * tile_size; // Distância máxima para manter os tiles (mais 2 de margem)

// Posição do jogador
var player_x = obj_player.x;
var player_y = obj_player.y;

// Converte a posição do jogador para a grade de tiles
var grid_x = floor(player_x / tile_size);
var grid_y = floor(player_y / tile_size);

// Gera os tiles dinamicamente ao redor do jogador
for (var i = -grid_radius; i <= grid_radius; i++) {
    for (var j = -grid_radius; j <= grid_radius; j++) {
        var tile_x = (grid_x + i) * tile_size;
        var tile_y = (grid_y + j) * tile_size;

        // Verifica se o tile já existe
        if (!instance_position(tile_x, tile_y, obj_chao_grama_vamp)) {
            // Cria um novo tile com rotação aleatória
            var new_tile = instance_create_layer(tile_x, tile_y, "chao", obj_chao_grama_vamp);
            
            // Define uma rotação aleatória entre 0, 90, 180 ou 270 graus
            var random_angle = choose(0, 90, 180, 270);
            new_tile.image_angle = random_angle;
            
            // Se precisar manter a rotação física também
            new_tile.rotation = random_angle;
        }
    }
}



with (obj_chao_grama_vamp) {
    if (point_distance(x, y, player_x, player_y) > max_distance) {
        instance_destroy();
    }
}




