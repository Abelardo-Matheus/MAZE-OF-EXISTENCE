// 1. Manda o alarme rodar de novo (Otimizado para rodar a cada 20 frames)
alarm[0] = 20;

var _target = instance_exists(global.current_player) ? global.current_player : obj_player;
if (!instance_exists(_target)) exit;

// 2. Câmera e Margens
var _cam = view_camera[0];
var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam);
var _ch = camera_get_view_height(_cam);
var _margem = 1200; // Margem de spawn/despawn

var _spawn_rect = [_cx - _margem, _cy - _margem, _cx + _cw + _margem, _cy + _ch + _margem];
var _despawn_dist = 2500; // Distância absoluta para destruir instâncias

// 3. Descobre quais chunks estão na área da câmera
var _start_bx = floor(_spawn_rect[0] / global.tamanho_bloco);
var _end_bx = floor(_spawn_rect[2] / global.tamanho_bloco);
var _start_by = floor(_spawn_rect[1] / global.tamanho_bloco);
var _end_by = floor(_spawn_rect[3] / global.tamanho_bloco);

// 4. SPAWN: Itera pelos blocos visíveis e cria o que for necessário
for (var bx = _start_bx; bx <= _end_bx; bx++) {
    for (var by = _start_by; by <= _end_by; by++) {
        var _key = string(bx) + "," + string(by);
        var _entidades = global.grid_entidades_mundo[? _key];
        
        if (!is_undefined(_entidades)) {
            var _size = ds_list_size(_entidades);
            for (var i = 0; i < _size; i++) {
                var _ent = _entidades[| i];
                var _tipo = _ent[0];
                var _dados = _ent[1];
                var _px = _dados[0];
                var _py = _dados[1];
                var _seed = _dados[2];
                
                // Chave única para esta instância virtual
                var _inst_key = string(_px) + "_" + string(_py) + "_" + string(_seed);
                
                // Se está na tela, ainda não tem instância real E não foi morto permanentemente
                if (point_in_rectangle(_px, _py, _spawn_rect[0], _spawn_rect[1], _spawn_rect[2], _spawn_rect[3])) {
                    if (!ds_map_exists(global.instancias_ativas, _inst_key) && !ds_map_exists(global.entidades_mortas, _inst_key)) {
                        
                        var _inst = noone;
                        switch (_tipo) {
                            case "estrutura":
                                _inst = instance_create_depth(_px, _py, 0, _dados[3], { seed: _seed });
                                _inst.nome = _dados[5];
                                _inst.escala_mini = _dados[6];
                                break;
                            case "arvore":
                                _inst = instance_create_depth(_px, _py, 0, obj_arvore, { seed: _seed });
                                break;
                            case "pedra":
                                _inst = instance_create_depth(_px, _py, 0, obj_rock, { seed: _seed });
                                break;
                            case "fauna":
                                _inst = instance_create_depth(_px, _py, 0, obj_bicho_ambiente, { seed: _seed });
                                _inst.sprite_index = _dados[3];
                                _inst.vel_maxima = _dados[4];
                                break;
                            case "monstro":
                                _inst = instance_create_depth(_px, _py, 0, _dados[3], { 
                                    seed: _seed, escala: _dados[4], hp: _dados[5], dano: _dados[6], lvl: _dados[7] 
                                });
                                break;
                        }
                        
                        if (_inst != noone) {
                            global.instancias_ativas[? _inst_key] = _inst;
                            _inst.virtual_id = _inst_key; // Identificador crucial para o despawn e morte
                        }
                    }
                }
            }
        }
    }
}

// 5. DESPAWN: Destrói o que estiver longe demais
var _to_remove = [];
var _key_inst = ds_map_find_first(global.instancias_ativas);

while (!is_undefined(_key_inst)) {
    var _inst = global.instancias_ativas[? _key_inst];
    
    if (instance_exists(_inst)) {
        if (point_distance(_inst.x, _inst.y, _target.x, _target.y) > _despawn_dist) {
            instance_destroy(_inst);
            array_push(_to_remove, _key_inst);
        }
    } else {
        // Instância foi destruída por outros meios (morta, quebrada)
        array_push(_to_remove, _key_inst);
    }
    _key_inst = ds_map_find_next(global.instancias_ativas, _key_inst);
}

// Limpa o mapa de ativas
for (var i = 0; i < array_length(_to_remove); i++) {
    ds_map_delete(global.instancias_ativas, _to_remove[i]);
}
