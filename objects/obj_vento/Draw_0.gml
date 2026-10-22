// feather disable GM2017
// Clima por baixo dos riscos/folhas: céu escuro, chuva/neve/areia, furacões, raios
clima_desenhar();

for (var _i = 0; _i < array_length(particulas); _i++) {
    var _p = particulas[_i];
    if (_p.tipo == 0) {
        // risco: 10 frames ao longo da vida (aparece, faz a curvinha e some)
        var _f = min(9, floor(_p.vida / (_p.dur / 10)));
        draw_sprite_ext(spr_vento, _f, _p.x, _p.y, _p.esc * _p.lado, _p.esc, 0, c_white, 0.8);
    } else {
        // folha girando e ondulando
        var _ff = floor(_p.vida / 5) mod 4;
        var _oy = sin(_p.vida * 0.09 + _p.fase) * 8;
        draw_sprite_ext(spr_folha_vento, _ff, _p.x, _p.y + _oy, _p.esc, _p.esc, 0, _p.cor, 1);
    }
}
