/// @desc Sistema Completo de Cutscenes (Core + Builder)

// ============================================================
// PARTE 1: FUNÇÕES DE CONTROLE (CORE)
// ============================================================

/// @desc Avança para a próxima ação.
function cutscene_next_action()
{
    with (obj_cutscene) 
    {
        action_index++;
        
        if (action_index >= array_length(cutscene_data)) 
        {
            instance_destroy();
        }
    } 
}

/// @desc Inicia a cutscene (Usada pelo Builder).
function cutscene_start(_scene_data_array) 
{
    if (!instance_exists(obj_cutscene)) {
        instance_create_layer(0, 0, "Instances", obj_cutscene);
    }

    // Reinicia o objeto para a nova cena
    obj_cutscene.cutscene_data = _scene_data_array;  
    obj_cutscene.cutscene_active = true;
    obj_cutscene.action_index = 0;
    obj_cutscene.timer = 0;
    obj_cutscene.x_dest = -1;
    obj_cutscene.y_dest = -1;
}

// ============================================================
// PARTE 2: AÇÕES DA CUTSCENE (Lógica)
// ============================================================

/// @desc Espera X segundos.
function action_wait(_seconds)
{
    with(obj_cutscene) {
        timer++;
        if (timer >= (game_get_speed(gamespeed_fps) * _seconds)) 
        {
            timer = 0;
            cutscene_next_action();
        }
    }
}

/// @desc Move objeto para posição.
function action_move_object(_target_id, _target_x, _target_y, _is_relative, _speed)
{
    // Inicialização do destino
    if (obj_cutscene.x_dest == -1) 
    {
        if (!_is_relative) {
            obj_cutscene.x_dest = _target_x;
            obj_cutscene.y_dest = _target_y;
        } else {
            obj_cutscene.x_dest = _target_id.x + _target_x;
            obj_cutscene.y_dest = _target_id.y + _target_y;
        }
    }
    
    var _dest_x = obj_cutscene.x_dest;
    var _dest_y = obj_cutscene.y_dest;
    
    with (_target_id) 
    {
        if (point_distance(x, y, _dest_x, _dest_y) >= _speed) 
        {
            var _dir = point_direction(x, y, _dest_x, _dest_y);
            x += lengthdir_x(_speed, _dir);
            y += lengthdir_y(_speed, _dir);
        } 
        else 
        {
            x = _dest_x;
            y = _dest_y;
            obj_cutscene.x_dest = -1;
            obj_cutscene.y_dest = -1;
            cutscene_next_action();
        }
    }
}

/// @desc Cria instância.
function action_create_instance(_x, _y, _layer_name, _object_index)
{
    instance_create_layer(_x, _y, _layer_name, _object_index);
    cutscene_next_action();
}

/// @desc Destrói instância.
function action_destroy_instance(_target_id)
{
    if (instance_exists(_target_id)) {
        instance_destroy(_target_id);
    }
    cutscene_next_action();
}

/// @desc Altera escala X.
function action_set_xscale(_target_id, _scale_value)
{
    if (_scale_value != undefined) {
        _target_id.image_xscale = _scale_value;
    } else {
        _target_id.image_xscale *= -1; // Flip
    }
    cutscene_next_action();
}

/// @desc Troca Sprite.
function action_change_sprite(_target_id, _new_sprite)
{
    _target_id.sprite_index = _new_sprite;
    _target_id.image_index = 0;
    cutscene_next_action();
}

/// @desc Altera variável arbitrária.
function action_set_variable(_target_id, _var_name, _value)
{
    variable_instance_set(_target_id, _var_name, _value);
    cutscene_next_action();
}

/// @desc Toca som.
function action_play_sound(_sound_id, _loops)
{
    audio_play_sound(_sound_id, 1, _loops);
    cutscene_next_action();
}

/// @desc Encerra cutscene liberando um objeto (ex: player).
function action_finish_cutscene(_object_to_unlock)
{
    if (instance_exists(_object_to_unlock)) {
        _object_to_unlock.cutscene_active = false;    
    }
    cutscene_next_action();
}

// ============================================================
// PARTE 3: O CONSTRUTOR (BUILDER)
// ============================================================

/// @desc Ferramenta para criar cutscenes de forma fácil.
function CutsceneBuilder() constructor 
{
    scene_data = [];

    /// @func move(id, x, y, relative, speed)
    static move = function(_id, _x, _y, _is_relative, _spd) 
    {
        array_push(scene_data, [action_move_object, _id, _x, _y, _is_relative, _spd]);
        return self;
    }

    /// @func wait(seconds)
    static wait = function(_seconds) 
    {
        array_push(scene_data, [action_wait, _seconds]);
        return self;
    }

    /// @func sound(sound_id, loop)
    static sound = function(_snd, _loop) 
    {
        array_push(scene_data, [action_play_sound, _snd, _loop]);
        return self;
    }

    /// @func scale(id, xscale)
    static scale = function(_id, _scale = undefined) 
    {
        array_push(scene_data, [action_set_xscale, _id, _scale]);
        return self;
    }
    
    /// @func change_sprite(id, sprite)
    static change_sprite = function(_id, _spr)
    {
        array_push(scene_data, [action_change_sprite, _id, _spr]);
        return self;
    }

    /// @func create(x, y, layer, object)
    static create = function(_x, _y, _layer, _obj) 
    {
        array_push(scene_data, [action_create_instance, _x, _y, _layer, _obj]);
        return self;
    }
    
    /// @func destroy(id)
    static destroy = function(_id)
    {
        array_push(scene_data, [action_destroy_instance, _id]);
        return self;
    }

    /// @func set_var(id, var_name, value)
    static set_var = function(_id, _var_name, _value) 
    {
        array_push(scene_data, [action_set_variable, _id, _var_name, _value]);
        return self;
    }

    /// @func finish(object_to_unlock)
    static finish = function(_obj_to_unlock = noone) 
    {
        if (_obj_to_unlock != noone) {
            array_push(scene_data, [action_finish_cutscene, _obj_to_unlock]);
        }
        return self;
    }

    /// @func run()
    static run = function() 
    {
        cutscene_start(scene_data);
    }
}