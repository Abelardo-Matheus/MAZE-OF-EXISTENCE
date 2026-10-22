// feather disable GM2017
// Iniciado
// ==============================================================================
// PIÃO — gira pelo chão, quica nas bordas da tela e atravessa inimigos
// ==============================================================================
// Auxiliares (skill_stats_ativo, skill_timer_pronto, skill_criar_projetil,
// skill_efeito_estouro) ficam em scr_ativos_infancia. Registro: poderes_lista -> inicializar_tudo().

function scr_piao_config() {
    return {
        stats_base: {
            damage: 7, cooldown: 3800, quantity: 0, speed: 3.5,
            duration: 4000, size: 1, knockback: 1,
            sprite_icon: spr_piao_icon
        },
        niveis: [
            { desc: "SOLTA UM PIÃO QUE GIRA PELO CHÃO E ATRAVESSA OS INIMIGOS.", upgrade: function(_s) { _s.quantity = max(_s.quantity, 1); _s.damage *= 1.10; } },
            { desc: "PIÃO MAIS RÁPIDO (+25% VELOCIDADE).", upgrade: function(_s) { _s.speed *= 1.25; } },
            { desc: "+1 PIÃO.", upgrade: function(_s) { _s.quantity += 1; } },
            { desc: "GIRA POR MAIS TEMPO E +30% DANO.", upgrade: function(_s) { _s.duration += 1500; _s.damage *= 1.30; } },
            { desc: "MEGA UPGRADE: PIÕES GIGANTES (+40% TAMANHO) E +1 PIÃO.", upgrade: function(_s) { _s.size *= 1.40; _s.quantity += 1; } }
        ]
    };
}

function scr_piao(_row) {
    var _st = skill_stats_ativo(_row, scr_piao_config());
    if (is_undefined(_st)) exit;
    if (!skill_timer_pronto("piao", _row, _st.cooldown)) exit;

    for (var _i = 0; _i < _st.quantity; _i++) {
        var _dir = random(360);
        var _p = skill_criar_projetil(obj_player.x, obj_player.y, spr_piao, 24, _st.size, _st.damage, _st.speed, _dir, _st.knockback);
        _p.perfura = true;
        _p.image_angle = 0;
        _p.vida_ms = _st.duration;

        _p.Step_0_Custom = method(_p, function() {
            image_angle = 0;
            // quica nas bordas da câmera para continuar perto do jogador
            var _cam = view_camera[0];
            var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
            var _vw = camera_get_view_width(_cam), _vh = camera_get_view_height(_cam);
            if ((x < _vx + 16 && hspeed < 0) || (x > _vx + _vw - 16 && hspeed > 0)) direction = 180 - direction;
            if ((y < _vy + 16 && vspeed < 0) || (y > _vy + _vh - 16 && vspeed > 0)) direction = -direction;
            vida_ms -= delta_time / 1000;
            if (vida_ms <= 0) {
                image_alpha -= 0.1;
                if (image_alpha <= 0) instance_destroy();
            }
        });
    }
}
