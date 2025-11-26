/// @desc Lógica de Movimento (Máquina de Estados)
/// [O QUE]: Controla o comportamento de "ir" e "voltar", rastro visual e pausa.
/// [COMO] :
/// 1. Pausa se houver Level Up.
/// 2. Controla rotação e rastro visual.
/// 3. Switch(state):
///    - "going": Move na direção inicial até o timer acabar.
///    - "returning": Persegue o player. Se tocar nele, destrói.

// --- 1. Pausa e Visual ---
if (global.level_up) exit;

image_angle += 20; // Rotação constante

// Efeito de Rastro (Otimizado: a cada 3 frames)
if (global.timer % 3 == 0) 
{
    var _trail = instance_create_layer(x, y, "Instances", obj_bulmerangue_efeito);
    _trail.sprite_index = sprite_index;
    _trail.image_angle = image_angle;
    _trail.image_xscale = image_xscale;
    _trail.image_yscale = image_yscale;
    _trail.image_alpha = 0.5;
}

// --- 2. Máquina de Estados ---
var _current_speed = 0;

switch (state) 
{
    // === ESTADO: INDO ===
    case "going":
        _current_speed = move_speed;
        
        // Diminui o tempo de voo
        timer_going--;

        // Opcional: Desaceleração suave no final da ida (efeito elástico)
        if (timer_going < 10) _current_speed *= 0.8;

        // Se o tempo acabou, muda para volta
        if (timer_going <= 0) 
        {
            state = "returning";
            // Limpa a lista de hits para poder bater nos mesmos inimigos na volta?
            // Se quiser que bata de novo na volta, descomente a linha abaixo:
            // ds_list_clear(hit_list); 
        }
        break;

    // === ESTADO: VOLTANDO ===
    case "returning":
        // Aumenta velocidade para o player não fugir do bumerangue
        _current_speed = move_speed * return_speed_mult;

        if (instance_exists(obj_player)) 
        {
            // Ajusta a direção para o player (Homing)
            direction = point_direction(x, y, obj_player.x, obj_player.y);

            // Checagem de captura (Player pegou de volta)
            var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);
            if (_dist_to_player <= 20) // Raio de captura
            {
                instance_destroy();
                exit; // Sai para não mover mais neste frame
            }
        } 
        else 
        {
            // Se o player morreu, o bumerangue some
            instance_destroy();
            exit;
        }
        break;
}

// --- 3. Aplicação do Movimento ---
// Movimento manual para evitar conflitos com variáveis nativas
x += lengthdir_x(_current_speed, direction);
y += lengthdir_y(_current_speed, direction);