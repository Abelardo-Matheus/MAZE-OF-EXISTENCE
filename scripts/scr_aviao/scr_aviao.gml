// feather disable GM2017
// Iniciado
// ==============================================================================
// AVIÃO DE PAPEL — teleguiado, persegue o inimigo mais próximo
// ==============================================================================
// Auxiliares (skill_stats_ativo, skill_timer_pronto, skill_criar_projetil,
// skill_efeito_estouro) ficam em scr_ativos_infancia. Registro: poderes_lista -> inicializar_tudo().

function scr_aviao_config() {
    return {
        stats_base: {
            damage: 14, cooldown: 1700, quantity: 0, speed: 5,
            duration: 4000, size: 1, knockback: 2,
            sprite_icon: spr_aviao_icon
        },
        niveis: [
            { desc: "DOBRA UM AVIÃO DE PAPEL QUE PERSEGUE OS INIMIGOS.", upgrade: function(_s) { _s.quantity = max(_s.quantity, 1); _s.damage *= 1.10; } },
            { desc: "+1 AVIÃO.", upgrade: function(_s) { _s.quantity += 1; } },
            { desc: "PAPEL MAIS DURO (+35% DANO).", upgrade: function(_s) { _s.damage *= 1.35; } },
            { desc: "VOO MAIS RÁPIDO E RECARGA -15%.", upgrade: function(_s) { _s.speed *= 1.25; _s.cooldown *= 0.85; } },
            { desc: "MEGA UPGRADE: +2 AVIÕES.", upgrade: function(_s) { _s.quantity += 2; } }
        ]
    };
}

function scr_aviao(_row) {
    var _st = skill_stats_ativo(_row, scr_aviao_config());
    if (is_undefined(_st)) exit;
    if (!skill_timer_pronto("aviao", _row, _st.cooldown)) exit;

    var _alvos = inimigos_alvos(obj_player.x, obj_player.y, 700, _st.quantity, "perto");
    for (var _i = 0; _i < _st.quantity; _i++) {
        var _alvo = (array_length(_alvos) > 0) ? _alvos[_i mod array_length(_alvos)] : undefined;
        var _dir = is_undefined(_alvo) ? random(360) : point_direction(obj_player.x, obj_player.y, _alvo.x, _alvo.y);
        _dir += (_i - (_st.quantity - 1) / 2) * 25; // sai em leque
        var _a = skill_criar_projetil(obj_player.x, obj_player.y, spr_aviao_papel, 24, _st.size, _st.damage, _st.speed, _dir, _st.knockback);
        _a.alvo = _alvo;
        _a.vida_ms = _st.duration;
        _a.curva = 5;

        _a.Step_0_Custom = method(_a, function() {
            if (inimigo_posicao(alvo) == undefined) alvo = inimigo_mais_proximo(x, y, 600);
            if (!is_undefined(alvo)) {
                var _quer = point_direction(x, y, alvo.x, alvo.y);
                direction += clamp(angle_difference(_quer, direction), -curva, curva);
            }
            image_angle = direction;
            vida_ms -= delta_time / 1000;
            if (vida_ms <= 0) instance_destroy();
        });
    }
}
