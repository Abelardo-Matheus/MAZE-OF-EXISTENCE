// feather disable GM2017
/// @desc Máquina de estados do pet genérico
/// idle: vagueia perto do jogador (posição na "roda") e procura inimigos
/// chase: corre até o alvo   attack: golpe (depende do tipo)   cooldown: espera
if (global.level_up) { speed = 0; image_speed = 0; exit; }
if (!instance_exists(obj_player)) exit;

var _px = obj_player.x, _py = obj_player.y;

// --- Muito longe do jogador: "pula" para perto (sem animação especial) ---
if (point_distance(x, y, _px, _py) > 700) {
    x = _px + lengthdir_x(40, angulo_roda);
    y = _py + lengthdir_y(40, angulo_roda);
    state = "idle";
    speed = 0;
    var _fx = instance_create_layer(x, y, "Instances", obj_par_efeito_rastro);
    _fx.sprite_index = sprite_index;
    _fx.image_xscale = image_xscale;
    _fx.image_yscale = image_yscale;
}

switch (state) {
    // ------------------------------------------------------------
    case "idle":
        wander_timer--;
        if (wander_timer <= 0) {
            wander_timer = irandom_range(50, 120);
            var _dist = 45 + random(40);
            var _ang = angulo_roda + irandom_range(-35, 35);
            wander_x = _px + lengthdir_x(_dist, _ang);
            wander_y = _py + lengthdir_y(_dist, _ang);
        }
        var _vel = move_speed;
        if (point_distance(x, y, _px, _py) > 160) { wander_x = _px; wander_y = _py; _vel = move_speed * 1.6; }
        if (point_distance(x, y, wander_x, wander_y) > 6) {
            move_towards_point(wander_x, wander_y, _vel);
            sprite_index = spr_walk;
        } else {
            speed = 0;
            sprite_index = spr_idle;
        }
        var _alvo = inimigo_mais_proximo(x, y, range);
        if (!is_undefined(_alvo)) { target_enemy = _alvo; state = "chase"; }
        break;

    // ------------------------------------------------------------
    case "chase":
        if (inimigo_posicao(target_enemy) == undefined
         || point_distance(_px, _py, target_enemy.x, target_enemy.y) > range * 1.8) {
            state = "idle"; target_enemy = undefined; break;
        }
        move_towards_point(target_enemy.x, target_enemy.y, move_speed * 1.4);
        sprite_index = spr_walk;
        if (point_distance(x, y, target_enemy.x, target_enemy.y) < attack_radius + 14) {
            state = "attack";
            attack_timer = 16;
            has_hit = false;
            image_index = 0;
            sprite_index = spr_attack;
            direction = point_direction(x, y, target_enemy.x, target_enemy.y);
            // Coelho e cachorro dão um "bote" curto para frente
            speed = (tipo == "coelho") ? move_speed * 1.2 : ((tipo == "cachorro") ? 4 : 0);
        }
        break;

    // ------------------------------------------------------------
    case "attack":
        attack_timer--;
        speed = max(0, speed - 0.4);
        if (!has_hit && attack_timer <= 10) {
            has_hit = true;
            var _crit = (crit_chance > 0 && irandom(99) < crit_chance);
            var _dmg = _crit ? damage * 2 : damage;
            switch (tipo) {
                case "cachorro": // mordida forte em 1 alvo
                    if (!skill_dano_alvo(target_enemy, _dmg, knockback, x, y, _crit)) {
                        skill_dano_area(x + lengthdir_x(10, direction), y + lengthdir_y(10, direction), attack_radius, _dmg, knockback, _crit);
                    }
                    break;
                case "gato": // arranhão em área pequena na frente
                    skill_dano_area(x + lengthdir_x(12, direction), y + lengthdir_y(12, direction), attack_radius, _dmg, knockback, _crit);
                    break;
                case "coelho": // pulo que acerta o alvo e quem estiver em volta
                    skill_dano_area(x, y, attack_radius, _dmg, knockback, _crit);
                    break;
                case "tartaruga": // giro do casco em volta de si
                    skill_dano_area(x, y, attack_radius, _dmg, knockback, _crit);
                    skill_efeito_estouro(x, y, spr_idle, attack_radius);
                    break;
            }
        }
        if (attack_timer <= 0) {
            speed = 0;
            state = "cooldown";
            cooldown_atual = attack_cooldown;
        }
        break;

    // ------------------------------------------------------------
    case "cooldown":
        cooldown_atual--;
        // continua acompanhando o jogador enquanto recarrega
        if (point_distance(x, y, _px, _py) > 120) { move_towards_point(_px, _py, move_speed); sprite_index = spr_walk; }
        else { speed = 0; sprite_index = spr_idle; }
        if (cooldown_atual <= 0) state = "idle";
        break;
}

// --- Visual: lado que olha e velocidade da animação ---
if (hspeed > 0.1) lado = 1;
else if (hspeed < -0.1) lado = -1;
image_xscale = lado * escala_base;
image_yscale = escala_base;
image_speed = (state == "attack") ? 1.2 : ((speed > 0) ? clamp(speed / 2.5, 0.6, 2) : 0.6);
depth = -y;
