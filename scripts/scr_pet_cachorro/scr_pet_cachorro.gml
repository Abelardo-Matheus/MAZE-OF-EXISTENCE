// feather disable GM2017
// Iniciado
// ==============================================================================
// PET CACHORRO — config (dados por nível). Executor: scr_pet_animal (scr_pets_animais),
// objeto obj_pet_animal. Regras gerais de pet (pet_niveis, pet_visual, PET_MAX_COPIAS) ficam em
// scr_pets_animais. Registro: poderes_lista -> inicializar_tudo().
// ==============================================================================

function scr_cachorro_config() {
    return {
        pet: true, tipo: "cachorro",
        stats_base: {
            damage: 22, move_speed: 3.2, attack_cooldown: 70, range: 260,
            attack_radius: 18, knockback: 7, crit_chance: 0, quantity: 0,
            sprite_icon: spr_cachorro_icon
        },
        niveis: pet_niveis("CACHORRO", "PET CACHORRO: MORDIDA FORTE QUE EMPURRA OS INIMIGOS.", [
            { desc: "MORDIDA +20% DANO.",               upgrade: function(_s) { _s.damage *= 1.20; } },
            { desc: "LATIDO: MORDE MAIS RÁPIDO (-15%).", upgrade: function(_s) { _s.attack_cooldown *= 0.85; } },
            { desc: "FAREJA MAIS LONGE E EMPURRA MAIS.", upgrade: function(_s) { _s.range *= 1.25; _s.knockback += 3; } }
        ])
    };
}
