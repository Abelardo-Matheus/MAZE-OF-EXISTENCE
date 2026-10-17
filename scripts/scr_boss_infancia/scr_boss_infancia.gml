// feather disable GM2017
/// @desc scr_boss_infancia — Bosses "inimigos de uma criança" (fase bebê)
/// [O QUE]: Couve, Bicho-Papão e Livro de Dever de Casa. Mesma base do obj_boss_brocolis
///          (filhos de par_boss: barra de vida, flash de dano e dano de contato já vêm do pai).
/// [COMO] :
///  - Cada boss tem uma lista de ataques (funções). A máquina de estados escolhe um ataque
///    diferente do último, roda ele quadro a quadro até devolver true e descansa.
///  - Tiros usam o obj_projetil_boss de sempre, só trocando sprite/rotação (boss_tiro).
///  - Cada boss ganha um "covil" por fase: a primeira sala do tipo certo que o jogador visitar.
///    couve -> cozinha | bicho-papão -> quarto | livro -> quarto/fundos/banheiro (outra sala).

#macro BOSS_INF_DESCANSO   50    // frames parado entre um ataque e outro
#macro BOSS_INF_TIRO_VIDA  240   // frames até um tiro sumir sozinho

global.boss_infancia = {
    couve: { vivo: true, obj: obj_boss_couve, tipos: ["cozinha"],                     sala: undefined, nivel: -1 },
    papao: { vivo: true, obj: obj_boss_papao, tipos: ["quarto"],                      sala: undefined, nivel: -1 },
    livro: { vivo: true, obj: obj_boss_livro, tipos: ["quarto", "fundos", "banheiro"], sala: undefined, nivel: -1 },
};

#region ---------- SPAWN (chamado por recriar_bosses) ----------

function _boss_inf_mesma_sala(_a, _b) {
    return !is_undefined(_a) && !is_undefined(_b) && _a[0] == _b[0] && _a[1] == _b[1];
}

/// Cria o boss desta sala (se ela for o covil de algum) — chamado ao carregar cada sala.
function boss_infancia_spawnar() {
    if (!variable_global_exists("boss_infancia") || !is_struct(global.sala)) return;
    var _sala_atual = global.current_sala;
    var _tipo = global.sala.tipo;
    var _nivel = variable_global_exists("level_fase") ? global.level_fase : 1;
    var _keys = variable_struct_get_names(global.boss_infancia);

    for (var _i = 0; _i < array_length(_keys); _i++) {
        var _b = global.boss_infancia[$ _keys[_i]];
        if (!_b.vivo) continue;
        if (_b.nivel != _nivel) { _b.nivel = _nivel; _b.sala = undefined; } // fase nova = mapa novo

        if (is_undefined(_b.sala) && array_contains(_b.tipos, _tipo)) {
            // não divide sala com outro boss
            var _livre = true;
            for (var _j = 0; _j < array_length(_keys); _j++) {
                if (_j != _i && _boss_inf_mesma_sala(global.boss_infancia[$ _keys[_j]].sala, _sala_atual)) _livre = false;
            }
            if (_livre) _b.sala = [_sala_atual[0], _sala_atual[1]];
        }
        if (_boss_inf_mesma_sala(_b.sala, _sala_atual) && !instance_exists(_b.obj)) {
            instance_create_layer(global.room_width / 2 + 32, global.room_height / 2, "Layer_Player", _b.obj);
        }
    }
}

#endregion

#region ---------- BASE ----------

/// Chamar no Create de cada boss (depois do event_inherited()).
function boss_infancia_init(_chave, _vida, _dano, _xp, _ataques) {
    chave       = _chave;
    vida_max    = _vida;
    vida        = vida_max;
    dano        = _dano;
    xp_morte    = _xp;
    ataques     = _ataques;
    ataque      = -1;       // função do ataque atual
    ataque_ult  = -1;
    atk_t       = 0;        // frames desde o início do ataque
    atk_n       = 0;        // contador livre para o ataque
    descanso    = 90;       // espera inicial antes do 1º ataque
    image_xscale = 5;
    image_yscale = 5;
    image_speed  = 1;
    escala_hud   = 10;
    sombra_sprite = spr_sombra;
    hit = false;
}

/// Chamar no Step de cada boss.
function boss_infancia_step() {
    if (vida <= 0) {
        global.boss_infancia[$ chave].vivo = false;
        ganhar_xp(xp_morte);
        instance_destroy();
        exit;
    }
    if (variable_global_exists("level_up") && global.level_up) exit;
    if (!instance_exists(obj_player)) exit;

    if (ataque == -1) {
        speed = 0;
        image_speed = 0.6;
        if (--descanso > 0) exit;
        // sorteia um ataque diferente do anterior
        var _n = array_length(ataques), _k = irandom(_n - 1);
        if (_n > 1 && ataques[_k] == ataque_ult) _k = (_k + 1 + irandom(_n - 2)) mod _n;
        ataque = ataques[_k];
        ataque_ult = ataque;
        atk_t = 0;
        atk_n = 0;
        image_speed = 1;
    }
    if (ataque(atk_t)) {          // o ataque devolve true quando acabou
        ataque = -1;
        speed = 0;
        image_alpha = 1;
        descanso = BOSS_INF_DESCANSO + irandom(30);
    }
    atk_t += 1;
}

/// Cria um tiro do boss (obj_projetil_boss) com o sprite do próprio boss.
/// _gira: 0 = não gira | -1 = aponta para onde vai | >0 = gira essa velocidade por frame.
function boss_tiro(_x, _y, _dir, _spd, _dmg, _spr, _gira = -1) {
    var _p = instance_create_layer(_x, _y, "instances", obj_projetil_boss);
    with (_p) {
        sprite_index = _spr;
        direction    = _dir;
        speed        = _spd;
        damage       = _dmg;
        gira         = _gira;
        vida_frames  = BOSS_INF_TIRO_VIDA;
        image_angle  = (_gira == -1) ? _dir : 0;
    }
    return _p;
}

/// Tiro teleguiado (usa o modo "seguidor" do obj_projetil_boss).
function boss_tiro_seguidor(_x, _y, _spd, _max, _dmg, _spr, _frames) {
    var _p = boss_tiro(_x, _y, point_direction(_x, _y, obj_player.x, obj_player.y), _spd, _dmg, _spr, -1);
    with (_p) {
        seguidor  = true;
        target    = obj_player;
        max_speed = _max;
        vida_frames = _frames;
    }
    return _p;
}

/// Leque de _qtd tiros abrindo _abertura graus em volta de _dir.
function boss_leque(_dir, _qtd, _abertura, _spd, _dmg, _spr, _gira = -1) {
    for (var _i = 0; _i < _qtd; _i++) {
        var _a = (_qtd == 1) ? _dir : _dir - _abertura / 2 + _abertura * _i / (_qtd - 1);
        boss_tiro(x, y, _a, _spd, _dmg, _spr, _gira);
    }
}

/// Anel de _qtd tiros em 360°.
function boss_anel(_qtd, _spd, _dmg, _spr, _gira = -1, _offset = 0) {
    for (var _i = 0; _i < _qtd; _i++) boss_tiro(x, y, _offset + 360 * _i / _qtd, _spd, _dmg, _spr, _gira);
}

function boss_dir_player() { return point_direction(x, y, obj_player.x, obj_player.y); }

#endregion

#region ---------- COUVE (folhas) ----------

/// Espiral de folhas girando em volta da couve.
function boss_couve_espiral(_t) {
    if (_t mod 4 == 0) {
        var _a = _t * 13;
        boss_tiro(x, y, _a,       5, 12, spr_boss_proj_folha);
        boss_tiro(x, y, _a + 180, 5, 12, spr_boss_proj_folha);
    }
    return _t >= 100;
}

/// 3 leques de 7 folhas mirados no jogador.
function boss_couve_leque(_t) {
    if (_t mod 25 == 0) boss_leque(boss_dir_player(), 7, 70, 6, 14, spr_boss_proj_folha);
    return _t >= 75;
}

/// Investida de vitaminas: corre atrás do jogador soltando folhas para trás.
function boss_couve_investida(_t) {
    if (_t < 20) { speed = 0; x += random_range(-1, 1); return false; }   // treme avisando
    direction = boss_dir_player();
    speed = 4.5;
    if (_t mod 10 == 0) boss_tiro(x, y, direction + 180 + random_range(-25, 25), 3, 10, spr_boss_proj_folha);
    return _t >= 80;
}

/// 4 folhas teleguiadas.
function boss_couve_teleguiadas(_t) {
    if (_t mod 12 == 0 && _t < 48) boss_tiro_seguidor(x, y, 2, 4.5, 12, spr_boss_proj_folha, 170);
    return _t >= 60;
}

#endregion

#region ---------- BICHO-PAPÃO (sombras) ----------

/// Some na sombra, reaparece perto do jogador e explode em anel.
function boss_papao_teleporte(_t) {
    if (_t < 30) { image_alpha = 1 - _t / 30; return false; }
    if (_t == 30) {
        var _ang = random(360), _d = random_range(170, 230);
        x = clamp(obj_player.x + lengthdir_x(_d, _ang), 64, global.room_width - 64);
        y = clamp(obj_player.y + lengthdir_y(_d, _ang), 64, global.room_height - 64);
    }
    if (_t < 50) { image_alpha = (_t - 30) / 20; return false; }
    if (_t == 50) { image_alpha = 1; boss_anel(16, 4, 15, spr_boss_proj_sombra, 0, random(360)); }
    if (_t == 65) boss_anel(16, 3, 15, spr_boss_proj_sombra, 0, random(360));
    return _t >= 75;
}

/// "Olhos no escuro": sombras aparecem em volta do jogador, esperam e fecham o cerco.
function boss_papao_olhos(_t) {
    if (_t == 0) {
        var _cx = obj_player.x, _cy = obj_player.y, _n = 10;
        for (var _i = 0; _i < _n; _i++) {
            var _a = 360 * _i / _n;
            var _p = boss_tiro(_cx + lengthdir_x(260, _a), _cy + lengthdir_y(260, _a), 0, 0, 15, spr_boss_proj_sombra, 0);
            with (_p) { espera = 45; alvo_x = _cx; alvo_y = _cy; spd_apos = 5; }
        }
    }
    return _t >= 70;
}

/// Rajada tremida mirando no jogador.
function boss_papao_rajada(_t) {
    if (_t mod 6 == 0) boss_tiro(x, y, boss_dir_player() + random_range(-12, 12), 6.5, 12, spr_boss_proj_sombra, 0);
    return _t >= 72;
}

/// 3 sombras teleguiadas.
function boss_papao_perseguir(_t) {
    if (_t mod 15 == 0 && _t < 45) boss_tiro_seguidor(x, y, 2, 5, 15, spr_boss_proj_sombra, 180);
    return _t >= 60;
}

#endregion

#region ---------- LIVRO DE DEVER DE CASA (lápis e papel) ----------

/// Chuva de lápis caindo em cima do jogador.
function boss_livro_chuva(_t) {
    if (_t mod 3 == 0 && _t < 90) {
        var _px = obj_player.x + random_range(-220, 220);
        boss_tiro(_px, obj_player.y - 320, 270, 7, 12, spr_boss_proj_lapis);
    }
    return _t >= 100;
}

/// "Prova surpresa": leques de bolinhas de papel girando.
function boss_livro_prova(_t) {
    if (_t mod 20 == 0) boss_leque(boss_dir_player(), 5, 50, 5, 12, spr_boss_proj_papel, 12);
    return _t >= 80;
}

/// Fecha o livro com força: dois anéis (papel e lápis) desencontrados.
function boss_livro_fechar(_t) {
    if (_t < 25) { image_yscale = 5 * (1 - 0.15 * sin(_t / 25 * pi)); return false; } // "respira" antes
    if (_t == 25) {
        image_yscale = 5;
        boss_anel(20, 4, 15, spr_boss_proj_papel, 10);
        boss_anel(20, 6, 12, spr_boss_proj_lapis, -1, 9);
    }
    return _t >= 50;
}

/// Ditado: lápis rápidos mirando onde o jogador VAI estar.
function boss_livro_ditado(_t) {
    if (_t mod 14 == 0 && _t < 56) {
        var _p = obj_player;
        var _lead = point_distance(x, y, _p.x, _p.y) / 11;
        var _tx = _p.x + (_p.x - _p.xprevious) * _lead;
        var _ty = _p.y + (_p.y - _p.yprevious) * _lead;
        boss_tiro(x, y, point_direction(x, y, _tx, _ty), 11, 14, spr_boss_proj_lapis);
    }
    return _t >= 65;
}

#endregion
