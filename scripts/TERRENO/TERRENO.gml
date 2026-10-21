// feather disable GM2017
// ============================================================================
// TERRENO: biomas do mundo, clima e desenho otimizado do chao
// ----------------------------------------------------------------------------
// Sprite spr_terreno: 1 frame por bioma (128 x 1216)
//   y 0..127      textura base continua (pedaco escolhido por gx mod 4, gy mod 4)
//   y 128..191    8 decoracoes 32x32
//   y 192 + k*128 borda k recortada da propria textura do bioma
//                 k: 0 N, 1 L, 2 S, 3 O, 4 NE, 5 SE, 6 SO, 7 NO
//
// JUNCAO OTIMIZADA: cada bioma tem uma PRIORIDADE. Quando dois terrenos se
// encontram, o de prioridade maior desenha a sua borda por cima do vizinho.
// Assim cada bioma precisa de so 8 bordas (N biomas -> N conjuntos), em vez de
// um desenho para cada par de biomas (N x N).
//
// DESEMPENHO: o chao e desenhado em "regioes" de 16x16 tiles numa surface,
// uma vez so. Depois cada frame desenha apenas 4~6 surfaces na tela.
// ============================================================================

#macro TERRENO_TILE        32     // tamanho do tile dentro do sprite
#macro TERRENO_ESCALA      3      // escala do chao no mundo
#macro TERRENO_TILE_MUNDO  96     // TERRENO_TILE * TERRENO_ESCALA
#macro TERRENO_REGIAO      16     // tiles por lado de cada surface
#macro TERRENO_DEFORMA     330    // quanto (px) as fronteiras entre biomas ondulam

function terreno_inicializar() {
    if (variable_global_exists("terreno") && is_struct(global.terreno)) return;

    if (!variable_global_exists("semente_terreno")) global.semente_terreno = irandom_range(1, 9999);

    global.terreno = {
        // ordem = indice do frame no spr_terreno
        nomes: ["floresta", "cidade", "vazia", "floresta_negra", "deserto",
                "neve", "pantano", "vulcanico", "prado", "cristalino"],

        // quem tem prioridade maior "invade" o vizinho com a sua borda
        prioridade: [7, 1, 3, 6, 4, 9, 5, 0, 8, 2],

        // cor no minimapa
        cor_mapa: [
            make_color_rgb(70, 140, 50),   // floresta
            make_color_rgb(120, 122, 130), // cidade
            make_color_rgb(184, 172, 142), // vazia
            make_color_rgb(40, 50, 52),    // floresta_negra
            make_color_rgb(226, 188, 120), // deserto
            make_color_rgb(226, 236, 248), // neve
            make_color_rgb(70, 78, 46),    // pantano
            make_color_rgb(90, 40, 30),    // vulcanico
            make_color_rgb(150, 190, 70),  // prado
            make_color_rgb(90, 74, 150)    // cristalino
        ],

        // tom aplicado nas arvores e pedras de cada bioma (c_white = sem mudanca)
        cor_arvore: [
            c_white, c_white, c_white, c_white,
            make_color_rgb(232, 206, 150),  // deserto: folhas secas
            make_color_rgb(214, 230, 255),  // neve: congelada
            make_color_rgb(150, 176, 128),  // pantano
            make_color_rgb(120, 96, 92),    // vulcanico: queimada
            make_color_rgb(236, 255, 210),  // prado
            make_color_rgb(196, 176, 250)   // cristalino
        ],
        cor_pedra: [
            c_white, c_white, c_white, c_white,
            make_color_rgb(244, 212, 168),
            make_color_rgb(222, 232, 248),
            make_color_rgb(164, 172, 140),
            make_color_rgb(120, 100, 100),
            c_white,
            make_color_rgb(204, 170, 255)
        ],

        indice: {}
    };

    var _n = array_length(global.terreno.nomes);
    for (var _i = 0; _i < _n; _i++) {
        global.terreno.indice[$ global.terreno.nomes[_i]] = _i;
    }
    // inverso: qual bioma tem cada prioridade
    global.terreno.por_prioridade = array_create(_n, -1);
    for (var _i = 0; _i < _n; _i++) {
        global.terreno.por_prioridade[global.terreno.prioridade[_i]] = _i;
    }
}

/// @desc Indice (frame) do bioma pelo nome. Desconhecido -> floresta.
function terreno_id(_nome) {
    var _v = global.terreno.indice[$ _nome];
    return is_undefined(_v) ? 0 : _v;
}

// ----------------------------------------------------------------------------
// Ruido suave (value noise) deterministico
// ----------------------------------------------------------------------------
/// @desc Número pseudoaleatório em [0, 1) para o ponto inteiro (ix, iy) e a semente s.
///       ATENÇÃO: no GML frac() de número negativo é NEGATIVO (frac(-3.4) = -0.4). Como sin()
///       é negativo metade das vezes, sem a correção abaixo o ruído ia de -1 a 1 e a
///       "temperatura" ficava perto de 0 -> quase o mundo inteiro virava neve.
function terreno_hash(_ix, _iy, _s) {
    var _v = frac(sin(_ix * 127.1 + _iy * 311.7 + _s * 74.7) * 43758.5453);
    return (_v < 0) ? _v + 1 : _v;
}

function terreno_ruido(_x, _y, _s) {
    var _ix = floor(_x), _iy = floor(_y);
    var _fx = _x - _ix, _fy = _y - _iy;
    _fx = _fx * _fx * (3 - 2 * _fx);
    _fy = _fy * _fy * (3 - 2 * _fy);
    var _a = terreno_hash(_ix, _iy, _s);
    var _b = terreno_hash(_ix + 1, _iy, _s);
    var _c = terreno_hash(_ix, _iy + 1, _s);
    var _d = terreno_hash(_ix + 1, _iy + 1, _s);
    var _top = _a + (_b - _a) * _fx;
    var _bot = _c + (_d - _c) * _fx;
    return _top + (_bot - _top) * _fy;
}

// ----------------------------------------------------------------------------
// CLIMA: escolhe o bioma de uma area pelo "mapa de temperatura e umidade".
// Assim neve fica longe do deserto, pantano perto da floresta etc.
// ----------------------------------------------------------------------------
function terreno_escolher_bioma(_bx, _by) {
    terreno_inicializar();
    if (_bx == 0 && _by == 0) return "cidade"; // o jogador sempre começa numa cidade

    var _s = global.semente_terreno;
    var _temp = terreno_ruido(_bx / 6 + 0.37, _by / 6 + 0.71, _s) * 0.75
              + terreno_ruido(_bx / 2.3, _by / 2.3, _s + 7) * 0.25;
    var _umid = terreno_ruido(_bx / 5 + 0.13, _by / 5 + 0.29, _s + 101) * 0.75
              + terreno_ruido(_bx / 2.1, _by / 2.1, _s + 57) * 0.25;
    var _sorte = random(1);

    if (_sorte < 0.10) return "cidade";       // cidades aparecem em qualquer clima (~10%)
    if (_sorte < 0.16) return "cristalino";   // raro (~6%)

    // O ruído fica concentrado perto de 0.5 (20% dos valores < 0.34 e 20% > 0.65),
    // por isso os cortes ficam nessas faixas. Com isso cada bioma sai com uns 8~17%:
    //   frio (< 0.34)  -> neve
    //   quente (> 0.65) -> deserto (seco) ou vulcânico (úmido)
    //   ameno          -> pela umidade: pântano > floresta negra > floresta > prado > vazia
    // ATENÇÃO: "< baixo" para neve e "> alto" para quente. Inverter (ex.: < 0.66) faz quase tudo virar neve.
    if (_temp < 0.34) return "neve";
    if (_temp > 0.65) return (_umid < 0.5) ? "deserto" : "vulcanico";

    if (_umid > 0.64) return "pantano";
    if (_umid > 0.56) return "floresta_negra";
    if (_umid > 0.46) return "floresta";
    if (_umid > 0.37) return "prado";
    return "vazia";
}

/// @desc Bioma de um ponto do mundo (com as fronteiras onduladas).
function terreno_bioma_em(_x, _y) {
    if (!variable_global_exists("mapa_biomas") || !variable_global_exists("tamanho_bloco")) return "floresta";
    var _s = variable_global_exists("semente_terreno") ? global.semente_terreno : 0;

    var _wx = _x + (terreno_ruido(_x / 900, _y / 900, _s + 11) - 0.5) * 2 * (TERRENO_DEFORMA * 0.8)
                 + (terreno_ruido(_x / 260, _y / 260, _s + 23) - 0.5) * 2 * (TERRENO_DEFORMA * 0.2);
    var _wy = _y + (terreno_ruido(_x / 900, _y / 900, _s + 37) - 0.5) * 2 * (TERRENO_DEFORMA * 0.8)
                 + (terreno_ruido(_x / 260, _y / 260, _s + 51) - 0.5) * 2 * (TERRENO_DEFORMA * 0.2);

    var _id = string(floor(_wx / global.tamanho_bloco)) + "," + string(floor(_wy / global.tamanho_bloco));
    var _b = global.mapa_biomas[? _id];
    return is_undefined(_b) ? "floresta" : _b;
}

function terreno_cor_minimapa(_nome) {
    terreno_inicializar();
    return global.terreno.cor_mapa[terreno_id(_nome)];
}

/// @desc Tom das arvores/pedras conforme o bioma onde elas nasceram.
function terreno_cor_objeto(_x, _y, _tipo) {
    terreno_inicializar();
    var _i = terreno_id(terreno_bioma_em(_x, _y));
    return (_tipo == "arvore") ? global.terreno.cor_arvore[_i] : global.terreno.cor_pedra[_i];
}

// ----------------------------------------------------------------------------
// DESENHO EM REGIOES (surface cache)
// ----------------------------------------------------------------------------

/// @desc Garante que os blocos que uma regiao toca ja tem bioma definido.
function terreno_definir_blocos_da_regiao(_rx, _ry) {
    if (!variable_global_exists("mapa_biomas") || !variable_global_exists("tamanho_bloco")) return;
    var _tam = TERRENO_TILE_MUNDO * TERRENO_REGIAO;
    var _m = TERRENO_DEFORMA + TERRENO_TILE_MUNDO;
    var _bx0 = floor((_rx * _tam - _m) / global.tamanho_bloco);
    var _bx1 = floor(((_rx + 1) * _tam + _m) / global.tamanho_bloco);
    var _by0 = floor((_ry * _tam - _m) / global.tamanho_bloco);
    var _by1 = floor(((_ry + 1) * _tam + _m) / global.tamanho_bloco);
    for (var _bx = _bx0; _bx <= _bx1; _bx++) {
        for (var _by = _by0; _by <= _by1; _by++) {
            definir_bioma_do_cluster(_bx, _by);
        }
    }
}

/// @desc Desenha uma regiao inteira (16x16 tiles) numa surface nova e a retorna.
function terreno_construir_regiao(_rx, _ry) {
    terreno_inicializar();
    terreno_definir_blocos_da_regiao(_rx, _ry);

    var _n = TERRENO_REGIAO;
    var _t = TERRENO_TILE;
    var _gx0 = _rx * _n - 1;
    var _gy0 = _ry * _n - 1;
    var _prio = global.terreno.prioridade;
    var _por_prio = global.terreno.por_prioridade;
    var _max_prio = array_length(_por_prio) - 1;

    // 1) bioma de cada tile (com 1 tile de borda para olhar os vizinhos)
    var _bio = array_create(_n + 2);
    for (var _i = 0; _i < _n + 2; _i++) {
        var _col = array_create(_n + 2, 0);
        for (var _j = 0; _j < _n + 2; _j++) {
            var _wx = (_gx0 + _i + 0.5) * TERRENO_TILE_MUNDO;
            var _wy = (_gy0 + _j + 0.5) * TERRENO_TILE_MUNDO;
            _col[_j] = terreno_id(terreno_bioma_em(_wx, _wy));
        }
        _bio[_i] = _col;
    }

    // ordem das bordas: N, L, S, O e quinas NE, SE, SO, NO
    var _dx = [0, 1, 0, -1];
    var _dy = [-1, 0, 1, 0];
    var _qx = [1, 1, -1, -1];
    var _qy = [-1, 1, 1, -1];

    var _surf = surface_create(_n * _t, _n * _t);
    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);
    // mantem o alfa da surface opaco mesmo desenhando sombras semi-transparentes
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);

    var _id_cidade = terreno_id("cidade");
    var _viz = array_create(4, 0);
    var _diag = array_create(4, 0);

    for (var _i = 1; _i <= _n; _i++) {
        for (var _j = 1; _j <= _n; _j++) {
            var _gx = _gx0 + _i;
            var _gy = _gy0 + _j;
            var _mx = ((_gx mod 4) + 4) mod 4;
            var _my = ((_gy mod 4) + 4) mod 4;
            var _px = (_i - 1) * _t;
            var _py = (_j - 1) * _t;
            var _b = _bio[_i][_j];

            // chao base (pedaco da textura continua)
            draw_sprite_part(spr_terreno, _b, _mx * _t, _my * _t, _t, _t, _px, _py);

            // cidade: ruas, calcadas e gramados (script scr_cidade)
            var _sem_deco = false;
            if (_b == _id_cidade) _sem_deco = cidade_desenhar_tile(_gx, _gy, _px, _py, _mx, _my);

            // decoracao (deterministica por tile)
            var _h = abs((_gx * 73856093) ^ (_gy * 19349663));
            if (!_sem_deco && (_h mod 100) < 35) {
                var _d = (_h div 100) mod 8;
                draw_sprite_part(spr_terreno, _b, (_d mod 4) * _t, 128 + (_d div 4) * _t, _t, _t, _px, _py);
            }

            // juncao com vizinhos de prioridade maior
            var _tem_diferente = false;
            for (var _k = 0; _k < 4; _k++) {
                _viz[_k] = _bio[_i + _dx[_k]][_j + _dy[_k]];
                _diag[_k] = _bio[_i + _qx[_k]][_j + _qy[_k]];
                if (_viz[_k] != _b || _diag[_k] != _b) _tem_diferente = true;
            }
            if (!_tem_diferente) continue;

            var _minha_prio = _prio[_b];
            for (var _p = _minha_prio + 1; _p <= _max_prio; _p++) {
                var _a = _por_prio[_p];
                if (_a < 0) continue;

                for (var _k = 0; _k < 4; _k++) {
                    if (_viz[_k] == _a) {
                        draw_sprite_part(spr_terreno, _a, _mx * _t, 192 + _k * 128 + _my * _t, _t, _t, _px, _py);
                    }
                }
                for (var _k = 0; _k < 4; _k++) {
                    if (_diag[_k] == _a && _viz[_k] != _a && _viz[(_k + 1) mod 4] != _a) {
                        draw_sprite_part(spr_terreno, _a, _mx * _t, 192 + (4 + _k) * 128 + _my * _t, _t, _t, _px, _py);
                    }
                }
            }
        }
    }

    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    return _surf;
}
