// feather disable GM2017
/// @desc Pet genérico (Cachorro, Gato, Coelho, Tartaruga) — dados vêm de scr_pets_animais
event_inherited();

tipo = "cachorro";

// --- Status (sobrescritos todo frame por scr_pet_animal) ---
damage = 10;
move_speed = 3;
attack_cooldown = 60;
range = 250;
attack_radius = 20;
knockback = 3;
crit_chance = 0;
angulo_roda = 0;

// --- Estado ---
state = "idle";          // idle, chase, attack, cooldown
target_enemy = undefined;
cooldown_atual = 0;
attack_timer = 0;
has_hit = false;
wander_x = x;
wander_y = y;
wander_timer = 0;
lado = 1;                // 1 = olhando para a direita, -1 = esquerda

// --- Visual ---
spr_idle = spr_cachorro_idle;
spr_walk = spr_cachorro_walk;
spr_attack = spr_cachorro_attack;
escala_base = 0.7;
image_speed = 1;

/// @desc Define o tipo do bicho (sprites e tamanho na tela)
pet_configurar = function(_tipo) {
    tipo = _tipo;
    var _v = pet_visual(_tipo);
    spr_idle = _v.idle;
    spr_walk = _v.walk;
    spr_attack = _v.attack;
    sprite_index = spr_idle;
    escala_base = skill_escala_px(spr_idle, _v.px);
    image_xscale = escala_base;
    image_yscale = escala_base;
}
