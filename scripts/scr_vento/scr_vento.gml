// feather disable GM2017
// ============================================================================
// VENTO: sistema global e aleatorio de vento
// ----------------------------------------------------------------------------
// global.vento guarda o "clima" do vento:
//   dir     -1 (sopra p/ esquerda) ou 1 (sopra p/ direita)
//   forca   0..1  intensidade atual (vai suavemente ate "alvo")
//   alvo    0..1  intensidade sorteada para o periodo atual
//   rajada  0..1  rajada passando agora (sobe e desce em ~1,5 s)
//   frente_x      posicao (x do mundo) da frente da rajada, que atravessa a tela
// Quem atualiza tudo e o obj_vento (1 por sala, criado sozinho por vento_garantir).
// As arvores leem com vento_inclinacao(x, fase) e escolhem a pose do sprite.
// ============================================================================

#macro VENTO_POSES        7      // poses por variante no spr_arvore_<bioma> (3 = reta)
#macro VENTO_LARGURA_RAJ  520    // largura (px) da faixa de rajada que passa pelas arvores

function vento_init() {
    if (variable_global_exists("vento") && is_struct(global.vento)) return;
    global.vento = {
        dir: choose(-1, 1),
        forca: 0.25,
        alvo: 0.25,
        timer: irandom_range(240, 600),
        rajada: 0,
        rajada_t: 0,          // progresso da rajada (0 = nenhuma)
        rajada_dur: 90,
        frente_x: 0,
        t: 0                  // tempo do vento (steps)
    };
}

/// @desc Garante que existe um obj_vento na sala (chamado pelas arvores)
function vento_garantir() {
    vento_init();
    if (!instance_exists(obj_vento)) instance_create_depth(0, 0, -100000, obj_vento);
}

/// @desc Avanca o vento 1 step (so o obj_vento chama)
function vento_atualizar() {
    vento_init();
    var _v = global.vento;
    _v.t += 1;

    // --- troca de "clima" de tempos em tempos -------------------------------
    _v.timer--;
    if (_v.timer <= 0) {
        _v.timer = irandom_range(360, 1080);            // 6 a 18 s
        var _r = random(1);
        if (_r < 0.25)      _v.alvo = random_range(0.00, 0.12);  // calmaria
        else if (_r < 0.80) _v.alvo = random_range(0.20, 0.55);  // brisa
        else                _v.alvo = random_range(0.65, 1.00);  // ventania
        if (random(1) < 0.3) _v.dir = -_v.dir;          // as vezes vira de lado
    }
    _v.forca = lerp(_v.forca, _v.alvo, 0.006);

    // --- rajadas: uma onda que atravessa a tela -----------------------------
    var _cx = 0, _cw = room_width;
    if (view_enabled && view_camera[0] != -1) {
        _cx = camera_get_view_x(view_camera[0]);
        _cw = camera_get_view_width(view_camera[0]);
    }
    if (_v.rajada_t <= 0) {
        _v.rajada = 0;
        if (random(1) < 0.002 + _v.forca * 0.012) {     // mais vento = mais rajadas
            _v.rajada_t = 1;
            _v.rajada_dur = irandom_range(70, 130);
            // comeca do lado de onde o vento vem
            _v.frente_x = (_v.dir > 0) ? _cx - VENTO_LARGURA_RAJ : _cx + _cw + VENTO_LARGURA_RAJ;
        }
    } else {
        _v.rajada_t++;
        var _p = _v.rajada_t / _v.rajada_dur;
        _v.rajada = sin(pi * clamp(_p, 0, 1)) * (0.6 + _v.forca * 0.4);
        // a frente cruza a tela inteira durante a rajada
        _v.frente_x += _v.dir * ((_cw + VENTO_LARGURA_RAJ * 2) / _v.rajada_dur);
        if (_p >= 1) _v.rajada_t = 0;
    }
}

/// @desc Quanto da rajada esta passando no x informado (0..1)
function vento_rajada_em(_x) {
    var _v = global.vento;
    if (_v.rajada <= 0) return 0;
    var _d = abs(_x - _v.frente_x) / VENTO_LARGURA_RAJ;
    return _v.rajada * clamp(1 - _d, 0, 1);
}

/// @desc Inclinacao da arvore em x (-1 esquerda .. 1 direita)
///       _fase deixa cada arvore balancar num tempo um pouco diferente
function vento_inclinacao(_x, _fase) {
    vento_init();
    var _v = global.vento;
    var _raj = vento_rajada_em(_x);
    // empurrao constante no sentido do vento
    var _base = _v.dir * (_v.forca * 0.55 + _raj * 0.45);
    // vai-e-volta: mais rapido e mais largo quanto mais forte o vento
    var _vel = 0.035 + _v.forca * 0.06 + _raj * 0.05;
    var _osc = sin(_v.t * _vel + _fase + _x * 0.004) * (0.10 + _v.forca * 0.28 + _raj * 0.2);
    return clamp(_base + _osc, -1, 1);
}

/// @desc Converte inclinacao (-1..1) na pose do sprite (0..VENTO_POSES-1)
function vento_pose(_incl) {
    var _meio = (VENTO_POSES - 1) / 2;
    return clamp(round(_meio + _incl * _meio), 0, VENTO_POSES - 1);
}
