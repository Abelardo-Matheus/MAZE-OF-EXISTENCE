// feather disable GM2017
// Iniciado
// ==============================================================================
// PET GATO — config (dados por nível). Executor: scr_pet_animal (scr_pets_animais),
// objeto obj_pet_animal. Regras gerais de pet (pet_niveis, pet_visual, PET_MAX_COPIAS) ficam em
// scr_pets_animais. Registro: poderes_lista -> inicializar_tudo().
// ==============================================================================

function scr_gato_config() {
    return {
        pet: true, tipo: "gato",
        stats_base: {
            damage: 8, move_speed: 3.6, attack_cooldown: 28, range: 230,
            attack_radius: 26, knockback: 1, crit_chance: 25, quantity: 0,
            sprite_icon: spr_gato_icon
        },
        niveis: pet_niveis("GATO", "PET GATO: ARRANHÕES RÁPIDOS EM ÁREA COM CHANCE DE CRÍTICO.", [
            { desc: "UNHAS AFIADAS: +10% CRÍTICO.",       upgrade: function(_s) { _s.crit_chance += 10; } },
            { desc: "ARRANHA MAIS RÁPIDO (-20%).",       upgrade: function(_s) { _s.attack_cooldown *= 0.80; } },
            { desc: "ARRANHÃO MAIOR E +25% DANO.",        upgrade: function(_s) { _s.attack_radius *= 1.30; _s.damage *= 1.25; } }
        ])
    };
}
