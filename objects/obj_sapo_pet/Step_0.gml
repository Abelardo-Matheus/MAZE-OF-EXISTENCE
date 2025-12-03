// --- Pausa e Checagem de Player ---
if (global.level_up) exit;
if (!instance_exists(obj_player)) { image_speed = 0; exit; }

// --- Checagem de Distância para Teleporte (Início) ---
// Só ativa se não estiver em nenhum estado de teleporte
if (state != "teleport_out" && state != "teleport_in" && point_distance(x, y, obj_player.x, obj_player.y) > 800) 
{
    state = "teleport_out";
    sprite_index = spr_sapo_teleporte; // Animação de sumir
    image_index = 0;
    image_speed = 1;
    speed = 0; // Para de andar
}

// ============================================================
// MÁQUINA DE ESTADOS DO SAPO
// ============================================================

switch (state) 
{
    // ------------------------------------------------------------
    // ESTADO: TELEPORTE SAÍDA (Sumindo)
    // ------------------------------------------------------------
    case "teleport_out":
        if (image_index >= image_number - 1) 
        {
            // Teleporta instantaneamente
            var _angle = irandom(360);
            var _dist = 100;
            
            x = obj_player.x + lengthdir_x(_dist, _angle);
            y = obj_player.y + lengthdir_y(_dist, _angle);
            
            // Inicia animação de chegada
            state = "teleport_in";
            sprite_index = spr_sapo_teleporte_inverso; // Animação de aparecer
            image_index = 0;
            
            // Atualiza variáveis de vagar para o novo local
            wander_x = x;
            wander_y = y;
        }
        break;

    // ------------------------------------------------------------
    // ESTADO: TELEPORTE ENTRADA (Aparecendo)
    // ------------------------------------------------------------
    case "teleport_in":
        if (image_index >= image_number - 1) 
        {
            // Terminou de aparecer -> Volta a agir
            state = "idle";
            sprite_index = spr_sapo_idle;
        }
        break;

    // ------------------------------------------------------------
    // ESTADO 1: VAGANDO (IDLE)
    // ------------------------------------------------------------
    case "idle":
        // 1. Escolhe novo ponto
        wander_timer--;
        if (wander_timer <= 0) {
            wander_timer = irandom_range(60, 180);
            var _angle = irandom(360);
            var _dist = random(orbit_radius);
            wander_x = obj_player.x + lengthdir_x(_dist, _angle);
            wander_y = obj_player.y + lengthdir_y(_dist, _angle);
        }
        
        // 2. Se afastou muito (mas não o suficiente pra teleportar), corre
        if (point_distance(x, y, obj_player.x, obj_player.y) > orbit_radius * 2) {
            wander_x = obj_player.x;
            wander_y = obj_player.y;
            velocidade = 5; 
        } else {
            velocidade = 2;
        }

        // 3. Move
        if (point_distance(x, y, wander_x, wander_y) > 5) {
            move_towards_point(wander_x, wander_y, velocidade);
            sprite_index = spr_sapo_walk;
        } else {
            speed = 0;
            sprite_index = spr_sapo_idle;
        }

        // 4. Procura Inimigo
        var _nearest = instance_nearest(x, y, par_inimigos);
        if (_nearest != noone) {
            if (point_distance(x, y, _nearest.x, _nearest.y) < range) {
                target_enemy = _nearest;
                state = "chase";
            }
        }
        break;

    // ------------------------------------------------------------
    // ESTADO 2: PERSEGUINDO (CHASE)
    // ------------------------------------------------------------
    case "chase":
        if (instance_exists(target_enemy)) {
            move_towards_point(target_enemy.x, target_enemy.y, velocidade * 1.5);
            sprite_index = spr_sapo_walk;

            if (point_distance(x, y, target_enemy.x, target_enemy.y) < 60) {
                state = "dash";
                dash_timer = dash_duration;
                has_hit = false;
                direction = point_direction(x, y, target_enemy.x, target_enemy.y);
                speed = dash_speed;
                sprite_index = spr_sapo_attack; 
            }
            
            if (point_distance(x, y, target_enemy.x, target_enemy.y) > range * 1.5) {
                state = "idle";
                target_enemy = noone;
            }
        } else {
            state = "idle";
        }
        break;

    // ------------------------------------------------------------
    // ESTADO 3: DASH/ATAQUE
    // ------------------------------------------------------------
    case "dash":
        dash_timer--;
        if (dash_timer % 2 == 0) {
            var _trail = instance_create_layer(x, y, layer, obj_par_efeito_rastro);
            _trail.sprite_index = sprite_index;
            _trail.image_alpha = 1;
        }

        if (dash_timer <= 0) {
            speed = 0;
            state = "cooldown";
            attack_cooldown_current = attack_cooldown_max;
        }
        break;

    // ------------------------------------------------------------
    // ESTADO 4: COOLDOWN
    // ------------------------------------------------------------
    case "cooldown":
        attack_cooldown_current--;
        sprite_index = spr_sapo_walk;
        if (attack_cooldown_current <= 0) {
            state = "idle";
        }
        break;
}

// --- Controle Visual (Espelhamento e Escala) ---

// Define o lado que ele está olhando (1 = Direita, -1 = Esquerda)
var _lado_olhar = sign(image_xscale); // Mantém o lado atual por padrão

if (hspeed != 0) {
    _lado_olhar = (hspeed > 0) ? 1 : -1;
}

// Aplica a escala base RESPEITANDO o lado e o estado de teleporte
if (state != "teleport_out" && state != "teleport_in") 
{
    image_xscale = _lado_olhar * escala_base; // Multiplica 1 ou -1 pelo tamanho (ex: 2 ou -2)
    image_yscale = escala_base; // Y geralmente fica sempre positivo
}

// 2. Velocidade da Animação Dinâmica
if (state == "idle" || state == "chase") 
{
    if (speed != 0) {
        // Normaliza: Se speed for 2, image_speed é 1. Se for 5, é 2.5.
        // Ajuste o divisor '2' conforme o gosto.
        image_speed = speed / 2; 
    } else {
        image_speed = 1; // Velocidade normal para animação de idle (respirando)
    }
} 
else if (state == "dash") 
{
    image_speed = 0.2; // Rápido no ataque
}
else 
{
    image_speed = 1; // Padrão para teleporte e cooldown
}