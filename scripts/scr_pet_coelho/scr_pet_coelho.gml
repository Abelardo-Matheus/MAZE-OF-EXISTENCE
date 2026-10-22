// feather disable GM2017
// Iniciado
// ==============================================================================
// PET COELHO — config (dados por nível). Executor: scr_pet_animal (scr_pets_animais),
// objeto obj_pet_animal. Regras gerais de pet (pet_niveis, pet_visual, PET_MAX_COPIAS) ficam em
// scr_pets_animais. Registro: poderes_lista -> inicializar_tudo().
// ==============================================================================

function scr_coelho_config() {
    return {
        pet: true, tipo: "coelho",
        stats_base: {
            damage: 11, move_speed: 6.5, attack_cooldown: 40, range: 320,
            attack_radius: 20, knockback: 3, crit_chance: 0, quantity: 0,
            sprite_icon: spr_coelho_icon
        },
        niveis: pet_niveis("COELHO", "PET COELHO: CORRE MUITO RÁPIDO E DEIXA VOCÊ 8% MAIS VELOZ.", [
            { desc: "PATAS LIGEIRAS: COELHO +20% VELOCIDADE.", upgrade: function(_s) { _s.move_speed *= 1.20; } },
            { desc: "PULO MAIS FORTE: +30% DANO.",             upgrade: function(_s) { _s.damage *= 1.30; } },
            { desc: "PULA MAIS VEZES (-20% RECARGA).",         upgrade: function(_s) { _s.attack_cooldown *= 0.80; } }
        ]),
        // Peculiaridade: o jogador corre mais (8% + 2% por nível, máx 20%)
        pet_bonus: function(_m, _lvl) {
            _m.veloc_player += min(0.20, 0.06 + 0.02 * _lvl);
        }
    };
}
