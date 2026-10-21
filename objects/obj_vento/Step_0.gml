// feather disable GM2017
if (variable_global_exists("level_up") && global.level_up == true) exit; // pausa junto com o jogo

vento_atualizar();
var _v = global.vento;

// area visivel
var _cx = 0, _cy = 0, _cw = room_width, _ch = room_height;
if (view_enabled && view_camera[0] != -1) {
    _cx = camera_get_view_x(view_camera[0]);
    _cy = camera_get_view_y(view_camera[0]);
    _cw = camera_get_view_width(view_camera[0]);
    _ch = camera_get_view_height(view_camera[0]);
}
// fica por cima de tudo que esta na tela (o cenario usa depth = -y)
depth = -(_cy + _ch) - 2000;

// ---------------- cria particulas (mais vento = mais efeito) ----------------
var _int = _v.forca + _v.rajada;
if (array_length(particulas) < max_part) {
    // risco de vento: aparece em qualquer ponto da tela
    if (random(1) < _int * 0.10) {
        var _e = choose(3, 4);
        array_push(particulas, {
            tipo: 0,
            x: _cx + random(_cw), y: _cy + random(_ch),
            vx: _v.dir * (3 + _v.forca * 6), vy: 0,
            vida: 0, dur: 40, esc: _e, cor: c_white, fase: 0, lado: _v.dir
        });
    }
    // folha: entra pelo lado de onde o vento vem, com a cor do bioma
    if (random(1) < _int * 0.07) {
        var _fx = (_v.dir > 0) ? _cx - 30 : _cx + _cw + 30;
        var _fy = _cy + random(_ch);
        var _cor = merge_colour(terreno_cor_minimapa(terreno_bioma_em(_cx + _cw / 2, _fy)), c_white, 0.2);
        array_push(particulas, {
            tipo: 1,
            x: _fx, y: _fy,
            vx: _v.dir * (2.5 + _v.forca * 5 + _v.rajada * 4) * random_range(0.7, 1.3),
            vy: random_range(-0.6, 0.6),
            vida: 0, dur: 99999, esc: 3, cor: _cor, fase: random(2 * pi), lado: _v.dir
        });
    }
}

// ---------------- move e remove ----------------
for (var _i = array_length(particulas) - 1; _i >= 0; _i--) {
    var _p = particulas[_i];
    _p.vida++;
    // a rajada empurra mais quem esta perto da frente dela
    var _empurra = 1 + vento_rajada_em(_p.x) * 1.5;
    _p.x += _p.vx * _empurra;
    _p.y += _p.vy;
    var _fora = (_p.x < _cx - 200) || (_p.x > _cx + _cw + 200) || (_p.y < _cy - 200) || (_p.y > _cy + _ch + 200);
    if (_p.vida >= _p.dur || _fora) array_delete(particulas, _i, 1);
}
