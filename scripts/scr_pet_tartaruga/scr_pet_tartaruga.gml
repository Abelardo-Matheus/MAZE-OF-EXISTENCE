// feather disable GM2017
// Iniciado
// ==============================================================================
// PET TARTARUGA — config (dados por nível). Executor: scr_pet_animal (scr_pets_animais),
// objeto obj_pet_animal. Regras gerais de pet (pet_niveis, pet_visual, PET_MAX_COPIAS) ficam em
// scr_pets_animais. Registro: poderes_lista -> inicializar_tudo().
// ==============================================================================

function scr_tartaruga_config() {
    return {
        pet: true, tipo: "tartaruga",
        stats_base: {
            damage: 14, move_speed: 1.8, attack_cooldown: 90, range: 200,
            attack_radius: 48, knockback: 5, crit_chance: 0, quantity: 0,
            sprite_icon: spr_tartaruga_icon
        },
        niveis: pet_niveis("TARTARUGA", "PET TARTARUGA: GIRA O CASCO EM ÁREA E VOCÊ RECEBE 8% MENOS DANO.", [
            { desc: "CASCO MAIS DURO: +25% DANO.",       upgrade: function(_s) { _s.damage *= 1.25; } },
            { desc: "GIRO MAIOR (+25% ÁREA).",            upgrade: function(_s) { _s.attack_radius *= 1.25; } },
            { desc: "GIRA MAIS VEZES (-20% RECARGA).",    upgrade: function(_s) { _s.attack_cooldown *= 0.80; } }
        ]),
        // Peculiaridade: escudo para o jogador (8% + 2% por nível, máx 25%)
        pet_bonus: function(_m, _lvl) {
            _m.reducao_dano += min(0.25, 0.06 + 0.02 * _lvl);
        }
    };
}
