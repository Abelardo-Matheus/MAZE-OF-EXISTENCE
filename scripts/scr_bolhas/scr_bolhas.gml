// feather disable GM2017
// Iniciado
// ==============================================================================
// BOLHAS DE SABÃO — bolhas lentas que flutuam e estouram em área
// ==============================================================================
// Auxiliares (skill_stats_ativo, skill_timer_pronto, skill_criar_projetil,
// skill_efeito_estouro) ficam em scr_ativos_infancia. Registro: poderes_lista -> inicializar_tudo().

function scr_bolhas_config() {
    return {
        stats_base: {
            damage: 12, cooldown: 2400 * global.cooldown_tomo, quantity: 0, speed: 1.6,
            radius: 46, duration: 3500, size: 1,
            sprite_icon: spr_bolhas_icon
        },
        niveis: [
            { desc: "SOPRA BOLHAS DE SABÃO QUE FLUTUAM E ESTOURAM NOS INIMIGOS.", upgrade: function(_s) { _s.quantity = max(_s.quantity, 2); _s.damage *= 1.10; } },
            { desc: "+1 BOLHA.", upgrade: function(_s) { _s.quantity += 1; } },
            { desc: "BOLHAS MAIORES (+25% ÁREA DO ESTOURO).", upgrade: function(_s) { _s.radius *= 1.25; _s.size *= 1.15; } },
            { desc: "ESTOURO MAIS FORTE (+40% DANO).", upgrade: function(_s) { _s.damage *= 1.40; } },
            { desc: "MEGA UPGRADE: +2 BOLHAS E RECARGA -20%.", upgrade: function(_s) { _s.quantity += 2; _s.cooldown *= 0.80; } }
        ]
    };
}

function scr_bolhas(_row) {
    var _st = skill_stats_ativo(_row, scr_bolhas_config());
    if (is_undefined(_st)) exit;
    if (!skill_timer_pronto("bolhas", _row, _st.cooldown)) exit;

    for (var _i = 0; _i < _st.quantity; _i++) {
        var _dir = (360 / _st.quantity) * _i + irandom_range(-20, 20);
        var _b = skill_criar_projetil(obj_player.x, obj_player.y - 10, spr_bolha_sabao, 26, _st.size, _st.damage, _st.speed, _dir, 0);
        _b.image_angle = 0;
        _b.vida_ms = _st.duration;
        _b.raio_estouro = _st.radius;
        _b.fase = random(360);

        _b.ao_acertar = method(_b, function() {
            skill_dano_area(x, y, raio_estouro, damage, 3);
            skill_efeito_estouro(x, y, spr_bolha_sabao, raio_estouro);
        });
        _b.Step_0_Custom = method(_b, function() {
            // flutua balançando de leve
            fase += 6;
            direction += dsin(fase) * 2;
            image_angle = 0;
            vida_ms -= delta_time / 1000;
            if (vida_ms <= 0) {
                ao_acertar();
                instance_destroy();
            }
        });
    }
}
