// feather disable GM2017

/// @desc Inicializa o Banco de Dados de Skills (Padrão Unificado Data-Driven)
function scr_skill_database_init() {
    
    // Enumeração para tipos de habilidades
    enum SKILL_TYPE {
        ACTIVE,
        PASSIVE
    }

    // Inicialização do container global
    global.skill_db = {};

    // ========================================================================
    // 1. HABILIDADES ATIVAS (Ataques Automáticos)
    // ========================================================================

    // --- MAGIC WAND (Varinha Mágica) ---
    global.skill_db.magic_wand = {
        name: "Varinha Mágica",
        description: "Atira um feixe mágico no inimigo mais próximo.",
        type: SKILL_TYPE.ACTIVE,
        icon: spr_bola_icon,
        max_level: 5,
        levels: [
            { damage: 10, cooldown: 60, projectile_count: 1, speed: 8, size: 1 },
            { damage: 12, cooldown: 55, projectile_count: 1, speed: 8, size: 1 },
            { damage: 12, cooldown: 55, projectile_count: 2, speed: 8, size: 1 },
            { damage: 15, cooldown: 50, projectile_count: 2, speed: 9, size: 1.1 },
            { damage: 25, cooldown: 40, projectile_count: 3, speed: 12, size: 1.5 }
        ],
        on_fire: function(_lv) {
            // Mira universal: os mais próximos (instância + horda), já ordenados
            var _enemies = inimigos_alvos(x, y, 500, _lv.projectile_count, "perto");
            if (array_length(_enemies) == 0) return;
            
            var _count = min(_lv.projectile_count, array_length(_enemies));
            var _area_mod = (variable_global_exists("player_area_mod") ? global.player_area_mod : 1);
            
            for (var _i = 0; _i < _count; _i++) {
                var _proj = instance_create_layer(x, y, "Instances", asset_get_index("obj_skill_projectile"));
                _proj.setup({
                    damage: _lv.damage * (global.ataque / 10),
                    speed: _lv.speed,
                    size: _lv.size * _area_mod,
                    direction: point_direction(x, y, _enemies[_i].x, _enemies[_i].y),
                    sprite: spr_bola_icon
                });
            }
        }
    };

    // --- LAMINAS GIRAS (King Bible Style) ---
    global.skill_db.laminas_giras = {
        name: "Lâminas Giras",
        description: "Lâminas espirituais orbitam ao redor do jogador, causando dano a qualquer inimigo que tocarem.",
        type: SKILL_TYPE.ACTIVE,
        icon: spr_shuriken_icon,
        max_level: 5,
        levels: [
            { damage: 8, cooldown: 150, quantity: 1, orbital_speed: 3, radius: 80, duration: 200 },
            { damage: 10, cooldown: 140, quantity: 1, orbital_speed: 4, radius: 85, duration: 220 },
            { damage: 12, cooldown: 130, quantity: 2, orbital_speed: 5, radius: 90, duration: 260 },
            { damage: 15, cooldown: 120, quantity: 2, orbital_speed: 6, radius: 100, duration: 300 },
            { damage: 20, cooldown: 100, quantity: 3, orbital_speed: 8, radius: 110, duration: 400 }
        ],
        on_fire: function(_lv) {
            var _count = _lv.quantity;
            var _area_mod = (variable_global_exists("player_area_mod") ? global.player_area_mod : 1);
            for (var _i = 0; _i < _count; _i++) {
                var _angle = (360 / _count) * _i;
                var _blade = instance_create_layer(x, y, "Instances", asset_get_index("obj_skill_projectile"));
                _blade.setup({
                    damage: _lv.damage, speed: 0, size: 1 * _area_mod, direction: _angle, sprite: spr_shuriken_icon
                });
                _blade.orbital_angle = _angle;
                _blade.orbital_radius = _lv.radius * _area_mod;
                _blade.orbital_speed = _lv.orbital_speed;
                _blade.duration = _lv.duration;
                _blade.parent_player = id;
                _blade.Step_0_Custom = function() {
                    if (!instance_exists(parent_player)) { instance_destroy(); return; }
                    orbital_angle += orbital_speed;
                    x = parent_player.x + lengthdir_x(orbital_radius, orbital_angle);
                    y = parent_player.y + lengthdir_y(orbital_radius, orbital_angle);
                    image_angle += 15;
                    if (duration-- <= 0) instance_destroy();
                };
            }
        }
    };

    // --- RASTRO SOMBRIO (Fire Trail Style) ---
    global.skill_db.rastro_sombrio = {
        name: "Rastro Sombrio",
        description: "Deixa poças de energia escura no chão enquanto se move. Inimigos que pisam nelas sofrem dano por segundo.",
        type: SKILL_TYPE.ACTIVE,
        icon: spr_hitbox_ataque,
        max_level: 5,
        levels: [
            { damage: 3, cooldown: 25, duration: 100, radius: 30 },
            { damage: 5, cooldown: 22, duration: 120, radius: 35 },
            { damage: 8, cooldown: 20, duration: 150, radius: 45 },
            { damage: 10, cooldown: 18, duration: 200, radius: 55 },
            { damage: 15, cooldown: 12, duration: 300, radius: 70 }
        ],
        on_fire: function(_lv) {
            if (variable_instance_exists(id, "andar") && !andar) return;
            var _area_mod = (variable_global_exists("player_area_mod") ? global.player_area_mod : 1);
            var _trail = instance_create_layer(x, y, "Instances", asset_get_index("obj_skill_area_effect"));
            _trail.setup({
                damage: _lv.damage, radius: _lv.radius * _area_mod, duration: _lv.duration, follow_player: false, sprite: spr_hitbox_ataque
            });
            _trail.image_blend = c_black;
            _trail.image_alpha = 0.5;
        }
    };

    // --- ADAGAS VELOZES (Knife Style) ---
    global.skill_db.adagas_velozes = {
        name: "Adagas Velozes",
        description: "Dispara uma rajada de adagas velozes na direção em que o jogador está olhando.",
        type: SKILL_TYPE.ACTIVE,
        icon: spr_flecha,
        max_level: 5,
        levels: [
            { damage: 12, cooldown: 50, quantity: 2, speed: 12, spread: 10 },
            { damage: 15, cooldown: 45, quantity: 3, speed: 13, spread: 12 },
            { damage: 18, cooldown: 40, quantity: 4, speed: 14, spread: 15 },
            { damage: 22, cooldown: 35, quantity: 5, speed: 15, spread: 18 },
            { damage: 30, cooldown: 25, quantity: 6, speed: 18, spread: 20 }
        ],
        on_fire: function(_lv) {
            var _base_dir = 270;
            if (variable_instance_exists(id, "dir")) {
                switch(dir) { case 0: _base_dir = 0; break; case 1: _base_dir = 90; break; case 2: _base_dir = 180; break; case 3: _base_dir = 270; break; }
            }
            var _area_mod = (variable_global_exists("player_area_mod") ? global.player_area_mod : 1);
            for (var _i = 0; _i < _lv.quantity; _i++) {
                var _angle = _base_dir + random_range(-_lv.spread, _lv.spread);
                var _dagger = instance_create_layer(x, y, "Instances", asset_get_index("obj_skill_projectile"));
                _dagger.setup({
                    damage: _lv.damage, speed: _lv.speed, size: 0.8 * _area_mod, direction: _angle, sprite: spr_flecha
                });
                _dagger.image_angle = _angle;
            }
        }
    };

    // --- FIRE AURA (Aura de Fogo) ---
    global.skill_db.fire_aura = {
        name: "Aura de Fogo",
        description: "Dano contínuo em área ao redor do jogador.",
        type: SKILL_TYPE.ACTIVE,
        icon: spr_hitbox_ataque,
        max_level: 5,
        levels: [
            { damage: 4, cooldown: 40, radius: 60, duration: 15 },
            { damage: 6, cooldown: 35, radius: 70, duration: 18 },
            { damage: 8, cooldown: 30, radius: 85, duration: 22 },
            { damage: 12, cooldown: 25, radius: 100, duration: 25 },
            { damage: 20, cooldown: 20, radius: 130, duration: 30 }
        ],
        on_fire: function(_lv) {
            var _area_mod = (variable_global_exists("player_area_mod") ? global.player_area_mod : 1);
            var _aura = instance_create_layer(x, y, "Instances", asset_get_index("obj_skill_area_effect"));
            _aura.setup({
                damage: _lv.damage, radius: _lv.radius * _area_mod, duration: _lv.duration, follow_player: true, sprite: spr_hitbox_ataque
            });
            _aura.image_blend = c_orange;
            _aura.image_alpha = 0.4;
        }
    };

    // ========================================================================
    // 2. HABILIDADES PASSIVAS (Buffs de Status)
    // ========================================================================

    // --- ANEL AMPLIFICADOR (Area) ---
    global.skill_db.anel_amplificador = {
        name: "Anel Amplificador",
        description: "Aumenta a área de efeito e o tamanho de todos os ataques e projéteis do jogador.",
        type: SKILL_TYPE.PASSIVE,
        icon: spr_bola_icon,
        max_level: 5,
        levels: [
            { area: 1.15 }, { area: 1.30 }, { area: 1.45 }, { area: 1.60 }, { area: 1.80 }
        ],
        modifiers: function(_lv, _stats) {
            global.player_area_mod = _lv.area;
        }
    };

    // --- TOMO CELERIDADE (Cooldown) ---
    global.skill_db.tomo_celeridade = {
        name: "Tomo Celeridade",
        description: "Reduz o tempo de recarga (cooldown) de todas as habilidades ativas.",
        type: SKILL_TYPE.PASSIVE,
        icon: spr_relogio,
        max_level: 5,
        levels: [
            { cd: 0.92 }, { cd: 0.84 }, { cd: 0.76 }, { cd: 0.68 }, { cd: 0.60 }
        ],
        modifiers: function(_lv, _stats) {
            global.player_cooldown_mod = _lv.cd;
        }
    };

    // --- IMA DE ALMAS (Magnet) ---
    global.skill_db.ima_de_almas = {
        name: "Imã de Almas",
        description: "Aumenta o raio de coleta do jogador, permitindo puxar itens e XP de mais longe.",
        type: SKILL_TYPE.PASSIVE,
        icon: spr_ima_icon,
        max_level: 5,
        levels: [
            { range: 100 }, { range: 150 }, { range: 220 }, { range: 300 }, { range: 500 }
        ],
        modifiers: function(_lv, _stats) {
            global.coleta = _lv.range;
        }
    };

    // --- BOTAS DE VELOCIDADE ---
    global.skill_db.speed_boots = {
        name: "Botas de Hermes",
        description: "Aumenta a velocidade de movimento do jogador.",
        type: SKILL_TYPE.PASSIVE,
        icon: spr_bola_icon,
        max_level: 5,
        levels: [
            { mult: 1.10 }, { mult: 1.20 }, { mult: 1.30 }, { mult: 1.40 }, { mult: 1.60 }
        ],
        modifiers: function(_lv, _stats) {
            _stats.speed_player *= _lv.mult;
        }
    };

    // --- MUSCULO DE FERRO (Dano) ---
    global.skill_db.iron_muscle = {
        name: "Músculo de Ferro",
        description: "Aumenta permanentemente o dano de todos os ataques.",
        type: SKILL_TYPE.PASSIVE,
        icon: spr_bola_icon,
        max_level: 5,
        levels: [
            { mult: 1.10 }, { mult: 1.20 }, { mult: 1.35 }, { mult: 1.50 }, { mult: 1.80 }
        ],
        modifiers: function(_lv, _stats) {
            _stats.ataque *= _lv.mult;
        }
    };

}
