// feather disable GM2017
// Iniciado
// ==============================================================================
// ESTILINGUE — pedrinhas rápidas nos inimigos mais próximos
// ==============================================================================
// Auxiliares (skill_stats_ativo, skill_timer_pronto, skill_criar_projetil,
// skill_efeito_estouro) ficam em scr_ativos_infancia. Registro: poderes_lista -> inicializar_tudo().

function scr_estilingue_config() {
    return {
        stats_base: {
            damage: 9, cooldown: 800, quantity: 0, speed: 11,
            size: 1, knockback: 3, range: 450,
            sprite_icon: spr_estilingue_icon
        },
        niveis: [
            { desc: "ATIRA PEDRINHAS DE ESTILINGUE NO INIMIGO MAIS PERTO.", upgrade: function(_s) { _s.quantity = max(_s.quantity, 1); _s.damage *= 1.10; } },
            { desc: "ELÁSTICO NOVO: RECARGA -20%.", upgrade: function(_s) { _s.cooldown *= 0.80; } },
            { desc: "+1 PEDRINHA (MIRA EM OUTRO INIMIGO).", upgrade: function(_s) { _s.quantity += 1; } },
            { desc: "PEDRAS MAIS PESADAS (+40% DANO E EMPURRÃO).", upgrade: function(_s) { _s.damage *= 1.40; _s.knockback += 2; } },
            { desc: "MEGA UPGRADE: +2 PEDRINHAS E MAIS ALCANCE.", upgrade: function(_s) { _s.quantity += 2; _s.range += 150; } }
        ]
    };
}

function scr_estilingue(_row) {
    var _st = skill_stats_ativo(_row, scr_estilingue_config());
    if (is_undefined(_st)) exit;
    if (!skill_timer_pronto("estilingue", _row, _st.cooldown)) exit;

    var _alvos = inimigos_alvos(obj_player.x, obj_player.y, _st.range, _st.quantity, "perto");
    for (var _i = 0; _i < array_length(_alvos); _i++) {
        var _dir = point_direction(obj_player.x, obj_player.y, _alvos[_i].x, _alvos[_i].y);
        var _p = skill_criar_projetil(obj_player.x, obj_player.y, spr_pedrinha, 10, _st.size, _st.damage, _st.speed, _dir, _st.knockback);
        _p.image_angle = 0;
    }
}
