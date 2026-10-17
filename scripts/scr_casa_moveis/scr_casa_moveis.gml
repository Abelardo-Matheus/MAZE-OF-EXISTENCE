// feather disable GM2017
/// @desc scr_casa_moveis — Mobília da casa (fase bebê) organizada por cômodo
/// [O QUE]: Cada tipo de sala tem uma "planta" (global.casa_plantas) que diz o que vai nela e ONDE:
///          encostado na parede de cima, nos cantos, no centro, ao lado de outro móvel etc.
///          A posição exata é sorteada, mas a organização é sempre de uma casa de verdade
///          (cama com criado-mudo, mesa com cadeiras em volta, sofá de frente pra TV com tapete...).
/// [COMO] :
///  - casa_gerar_moveis(salas)  -> em reset_level_data: sorteia e guarda tudo em global.salas_com_moveis.
///  - casa_recriar_moveis(sala) -> em carregar_sala: cria obj_movel_casa / obj_movel_abre / obj_tapete_casa.
///  - Móveis que abrem (frame 0 fechado, 1 aberto) guardam o estado e soltam item uma vez (tecla F).
///  - Regras: parede | baixo | lado | canto | centro | ao_lado:X | abaixo:X | frente:X | volta:X
///            tapetes: "tapete:nome" com sob:X | frente:X | centro (ficam por baixo e não ocupam espaço).
///  - Tamanhos em células de 64 px (largura x profundidade do "pé" do móvel). As portas ficam livres.

/// Catálogo, tapetes e plantas dos cômodos. É aqui que se adiciona/ajusta móvel.
function casa_moveis_definir() {
    global.casa_catalogo = {
        geladeira: { spr: spr_geladeira, w: 1, h: 1, abre: true, loot: "ativo", chance_loot: 1.0 },
        guarda_roupa: { spr: spr_guarda_roupa, w: 2, h: 1, abre: true, loot: "arma", chance_loot: 1.0 },
        escrivaninha: { spr: spr_mesa, w: 2, h: 1, abre: true, loot: "pe", chance_loot: 1.0 },
        criado_mudo: { spr: spr_movel_criado_mudo, w: 1, h: 1, abre: true, loot: "material", chance_loot: 0.5 },
        comoda: { spr: spr_movel_comoda, w: 2, h: 1, abre: true, loot: "armadura", chance_loot: 0.5 },
        bau: { spr: spr_movel_bau, w: 2, h: 1, abre: true, loot: "material", chance_loot: 0.5 },
        armario_cozinha: { spr: spr_movel_armario_cozinha, w: 2, h: 1, abre: true, loot: "material", chance_loot: 0.5 },
        fogao: { spr: spr_movel_fogao, w: 1, h: 1, abre: true, loot: "ativo", chance_loot: 0.5 },
        armario_banheiro: { spr: spr_movel_armario_banheiro, w: 1, h: 1, abre: true, loot: "ativo", chance_loot: 0.5 },
        maquina_lavar: { spr: spr_movel_maquina_lavar, w: 1, h: 1, abre: true, loot: "armadura", chance_loot: 0.5 },
        cama: { spr: spr_movel_cama, w: 2, h: 3, abre: false, loot: "", chance_loot: 0.5 },
        berco: { spr: spr_movel_berco, w: 2, h: 2, abre: false, loot: "", chance_loot: 0.5 },
        sofa: { spr: spr_movel_sofa, w: 3, h: 1, abre: false, loot: "", chance_loot: 0.5 },
        poltrona: { spr: spr_movel_poltrona, w: 1, h: 1, abre: false, loot: "", chance_loot: 0.5 },
        tv: { spr: spr_movel_tv, w: 2, h: 1, abre: false, loot: "", chance_loot: 0.5 },
        estante: { spr: spr_movel_estante, w: 2, h: 1, abre: false, loot: "", chance_loot: 0.5 },
        mesa_jantar: { spr: spr_movel_mesa_jantar, w: 2, h: 2, abre: false, loot: "", chance_loot: 0.5 },
        cadeira: { spr: spr_movel_cadeira, w: 1, h: 1, abre: false, loot: "", chance_loot: 0.5 },
        planta: { spr: spr_movel_planta, w: 1, h: 1, abre: false, loot: "", chance_loot: 0.5 },
        luminaria: { spr: spr_movel_luminaria, w: 1, h: 1, abre: false, loot: "", chance_loot: 0.5 },
        privada: { spr: spr_movel_privada, w: 1, h: 1, abre: false, loot: "", chance_loot: 0.5 },
        banheira: { spr: spr_movel_banheira, w: 3, h: 2, abre: false, loot: "", chance_loot: 0.5 },
        caixas: { spr: spr_movel_caixas, w: 1, h: 1, abre: false, loot: "", chance_loot: 0.5 },
        relogio: { spr: spr_movel_relogio, w: 1, h: 1, abre: false, loot: "", chance_loot: 0.5 }
    };
    global.casa_tapetes = {
        sala: { frame: 0, w: 4, h: 3 },
        quarto: { frame: 1, w: 3, h: 2 },
        redondo: { frame: 2, w: 3, h: 2 },
        corredor: { frame: 3, w: 2, h: 3 },
        banheiro: { frame: 4, w: 2, h: 1 },
        brincar: { frame: 5, w: 4, h: 3 }
    };
    // [tipo, regra, mínimo, máximo, chance]
    global.casa_plantas = {
        quarto: [
            ["cama", "parede", 1, 1, 1.0],
            ["criado_mudo", "ao_lado:cama", 2, 2, 1.0],
            ["guarda_roupa", "parede", 1, 1, 1.0],
            ["comoda", "parede", 1, 1, 0.8],
            ["escrivaninha", "parede", 1, 1, 0.8],
            ["cadeira", "abaixo:escrivaninha", 1, 1, 1.0],
            ["estante", "parede", 0, 1, 0.6],
            ["cama", "parede", 0, 1, 0.35],
            ["criado_mudo", "ao_lado:cama", 0, 1, 0.5],
            ["bau", "lado", 1, 1, 0.8],
            ["luminaria", "canto", 0, 1, 0.6],
            ["planta", "canto", 1, 2, 0.8],
            ["planta", "baixo", 0, 2, 0.5],
            ["caixas", "baixo", 0, 1, 0.3],
            ["tapete:quarto", "frente:cama", 1, 1, 0.9],
            ["tapete:brincar", "centro", 0, 1, 0.5]
        ],
        quarto2: [
            ["berco", "parede", 1, 1, 1.0],
            ["poltrona", "ao_lado:berco", 1, 1, 0.8],
            ["comoda", "parede", 1, 1, 1.0],
            ["guarda_roupa", "parede", 1, 1, 0.8],
            ["bau", "parede", 1, 1, 0.9],
            ["estante", "parede", 0, 1, 0.6],
            ["bau", "lado", 0, 1, 0.5],
            ["luminaria", "canto", 1, 1, 0.7],
            ["planta", "canto", 1, 2, 0.7],
            ["planta", "baixo", 0, 2, 0.5],
            ["tapete:brincar", "centro", 1, 1, 1.0]
        ],
        quarto3: [
            ["cama", "parede", 1, 1, 1.0],
            ["criado_mudo", "ao_lado:cama", 1, 2, 1.0],
            ["escrivaninha", "parede", 1, 1, 1.0],
            ["cadeira", "abaixo:escrivaninha", 1, 1, 1.0],
            ["estante", "parede", 1, 2, 0.9],
            ["guarda_roupa", "parede", 1, 1, 0.9],
            ["comoda", "parede", 0, 1, 0.6],
            ["bau", "lado", 0, 1, 0.7],
            ["luminaria", "canto", 0, 1, 0.6],
            ["planta", "canto", 1, 2, 0.7],
            ["planta", "baixo", 0, 2, 0.4],
            ["tapete:quarto", "frente:cama", 1, 1, 0.8],
            ["tapete:redondo", "centro", 0, 1, 0.7]
        ],
        cozinha: [
            ["geladeira", "parede", 1, 1, 1.0],
            ["armario_cozinha", "ao_lado:geladeira", 1, 1, 1.0],
            ["fogao", "ao_lado:armario_cozinha", 1, 1, 1.0],
            ["armario_cozinha", "ao_lado:fogao", 1, 1, 0.9],
            ["armario_cozinha", "ao_lado:armario_cozinha", 0, 1, 0.6],
            ["estante", "parede", 0, 1, 0.6],
            ["geladeira", "parede", 0, 1, 0.3],
            ["relogio", "parede", 0, 1, 0.5],
            ["mesa_jantar", "centro", 1, 1, 1.0],
            ["cadeira", "volta:mesa_jantar", 4, 4, 1.0],
            ["planta", "canto", 1, 2, 0.8],
            ["planta", "baixo", 0, 2, 0.5],
            ["caixas", "lado", 0, 2, 0.5],
            ["tapete:sala", "sob:mesa_jantar", 1, 1, 0.6]
        ],
        banheiro: [
            ["banheira", "parede", 1, 1, 1.0],
            ["privada", "parede", 1, 1, 1.0],
            ["armario_banheiro", "ao_lado:privada", 1, 1, 1.0],
            ["armario_banheiro", "parede", 0, 1, 0.6],
            ["maquina_lavar", "parede", 1, 1, 0.7],
            ["maquina_lavar", "ao_lado:maquina_lavar", 0, 1, 0.3],
            ["planta", "canto", 1, 2, 0.7],
            ["caixas", "baixo", 0, 2, 0.4],
            ["bau", "lado", 0, 1, 0.4],
            ["tapete:banheiro", "frente:banheira", 1, 1, 1.0],
            ["tapete:banheiro", "frente:armario_banheiro", 1, 1, 0.8]
        ],
        banheiro2: [
            ["privada", "parede", 1, 1, 1.0],
            ["armario_banheiro", "ao_lado:privada", 1, 1, 1.0],
            ["banheira", "parede", 1, 1, 0.8],
            ["maquina_lavar", "parede", 0, 1, 0.6],
            ["planta", "canto", 1, 2, 0.7],
            ["caixas", "canto", 0, 2, 0.5],
            ["tapete:banheiro", "frente:armario_banheiro", 1, 1, 1.0],
            ["tapete:banheiro", "frente:banheira", 1, 1, 0.7]
        ],
        sala_estar: [
            ["tv", "parede", 1, 1, 1.0],
            ["sofa", "frente:tv", 1, 1, 1.0],
            ["poltrona", "ao_lado:sofa", 2, 2, 0.9],
            ["estante", "parede", 1, 2, 1.0],
            ["relogio", "parede", 1, 1, 0.8],
            ["luminaria", "canto", 1, 2, 0.8],
            ["planta", "canto", 1, 2, 0.9],
            ["planta", "baixo", 1, 2, 0.7],
            ["planta", "lado", 0, 2, 0.5],
            ["mesa_jantar", "centro", 0, 1, 0.6],
            ["cadeira", "volta:mesa_jantar", 4, 4, 1.0],
            ["escrivaninha", "parede", 0, 1, 0.3],
            ["tapete:sala", "sob:sofa", 1, 1, 1.0]
        ],
        fundos: [
            ["maquina_lavar", "parede", 1, 2, 1.0],
            ["armario_cozinha", "ao_lado:maquina_lavar", 0, 1, 0.6],
            ["estante", "parede", 0, 1, 0.6],
            ["bau", "parede", 0, 1, 0.6],
            ["caixas", "canto", 2, 4, 1.0],
            ["caixas", "lado", 1, 3, 0.8],
            ["caixas", "baixo", 0, 3, 0.6],
            ["planta", "canto", 0, 2, 0.6],
            ["tapete:corredor", "centro", 0, 1, 0.5]
        ],
        porao: [
            ["caixas", "canto", 3, 4, 1.0],
            ["caixas", "lado", 2, 4, 1.0],
            ["caixas", "parede", 2, 4, 1.0],
            ["caixas", "baixo", 1, 4, 1.0],
            ["estante", "parede", 1, 2, 0.9],
            ["bau", "parede", 1, 2, 0.8],
            ["guarda_roupa", "parede", 0, 1, 0.5],
            ["relogio", "parede", 0, 1, 0.4],
            ["maquina_lavar", "lado", 0, 1, 0.3]
        ]
    };

}

#region ---------- GERAÇÃO (uma vez por fase, em reset_level_data) ----------

/// Grade de ocupação da sala (células internas). As portas ficam sempre livres.
function _casa_planta_nova() {
    var _cols = global._maze_width, _rows = global._maze_height;
    var _p = {
        cols: _cols, rows: _rows,
        x0: 1, y0: 1, x1: _cols - 2, y1: _rows - 2,
        ocup: ds_grid_create(_cols, _rows),
        itens: [] // [tipo, x0, y0, w, h]
    };
    ds_grid_clear(_p.ocup, 0);
    var _mx = _cols div 2, _my = _rows div 2;
    ds_grid_set_region(_p.ocup, _mx - 2, 1, _mx + 2, 2, 1);                       // porta de cima
    ds_grid_set_region(_p.ocup, _mx - 2, _rows - 3, _mx + 2, _rows - 2, 1);       // porta de baixo
    ds_grid_set_region(_p.ocup, 1, _my - 2, 3, _my + 2, 1);                        // porta esquerda
    ds_grid_set_region(_p.ocup, _cols - 4, _my - 2, _cols - 2, _my + 2, 1);        // porta direita
    return _p;
}

function _casa_livre(_p, _x, _y, _w, _h) {
    if (_x < _p.x0 || _y < _p.y0 || _x + _w - 1 > _p.x1 || _y + _h - 1 > _p.y1) return false;
    return ds_grid_get_max(_p.ocup, _x, _y, _x + _w - 1, _y + _h - 1) == 0;
}

function _casa_achar(_p, _tipo) {
    var _l = [];
    for (var _i = 0; _i < array_length(_p.itens); _i++) if (_p.itens[_i][0] == _tipo) array_push(_l, _p.itens[_i]);
    return (array_length(_l) > 0) ? _l[irandom(array_length(_l) - 1)] : undefined;
}

/// Lista de posições [x, y] candidatas para a regra (ver cabeçalho).
function _casa_candidatos(_p, _regra, _w, _h) {
    var _c = [], _x, _y;
    switch (_regra) {
        case "parede": for (_x = _p.x0; _x <= _p.x1 - _w + 1; _x++) array_push(_c, [_x, _p.y0]); return _c;
        case "baixo":  for (_x = _p.x0; _x <= _p.x1 - _w + 1; _x++) array_push(_c, [_x, _p.y1 - _h + 1]); return _c;
        case "lado":
            for (_y = _p.y0 + 2; _y <= _p.y1 - _h + 1; _y++) { array_push(_c, [_p.x0, _y]); array_push(_c, [_p.x1 - _w + 1, _y]); }
            return _c;
        case "canto":
            return [[_p.x0, _p.y0], [_p.x1 - _w + 1, _p.y0], [_p.x0, _p.y1 - _h + 1], [_p.x1 - _w + 1, _p.y1 - _h + 1]];
        case "centro":
            for (_x = 7; _x <= _p.cols - 7 - _w; _x++) for (_y = 5; _y <= _p.rows - 5 - _h; _y++) array_push(_c, [_x, _y]);
            return _c;
    }
    // Regras relativas a outro móvel: "ao_lado:X", "frente:X", "abaixo:X", "volta:X"
    var _sep = string_pos(":", _regra);
    if (_sep == 0) return _c;
    var _modo = string_copy(_regra, 1, _sep - 1);
    var _a = _casa_achar(_p, string_delete(_regra, 1, _sep));
    if (is_undefined(_a)) return _c;
    var _ax = _a[1], _ay = _a[2], _aw = _a[3], _ah = _a[4];
    var _cx = _ax + (_aw div 2) - (_w div 2);
    switch (_modo) {
        case "ao_lado": return [[_ax - _w, _ay], [_ax + _aw, _ay]];
        case "abaixo":  return [[_cx, _ay + _ah], [_cx - 1, _ay + _ah], [_cx + 1, _ay + _ah]];
        case "frente":
            var _dys = [2, 3, 1, 4], _dxs = [0, -1, 1];
            for (var _i = 0; _i < 4; _i++) for (var _j = 0; _j < 3; _j++) array_push(_c, [_cx + _dxs[_j], _ay + _ah + _dys[_i]]);
            return _c;
        case "volta":
            return [[_ax - 1, _ay + 1], [_ax + _aw, _ay + 1], [_ax, _ay + _ah], [_ax + _aw - 1, _ay + _ah], [_ax - 1, _ay], [_ax + _aw, _ay]];
    }
    return _c;
}

function _casa_colocar(_p, _tipo, _regra, _w, _h) {
    var _c = _casa_candidatos(_p, _regra, _w, _h);
    var _ordem_fixa = (string_pos("frente:", _regra) == 1 || string_pos("volta:", _regra) == 1 || string_pos("abaixo:", _regra) == 1);
    if (!_ordem_fixa) _c = array_shuffle(_c);
    for (var _i = 0; _i < array_length(_c); _i++) {
        var _x = _c[_i][0], _y = _c[_i][1];
        if (_casa_livre(_p, _x, _y, _w, _h)) {
            ds_grid_set_region(_p.ocup, _x, _y, _x + _w - 1, _y + _h - 1, 1);
            array_push(_p.itens, [_tipo, _x, _y, _w, _h]);
            return true;
        }
    }
    return false;
}

/// Monta a lista de dados de uma sala: [tipo, frame, px, py, aberto] (px, py = pé do móvel / centro do tapete).
function casa_gerar_sala(_tipo_sala) {
    var _planta = global.casa_plantas[$ _tipo_sala];
    var _dados = [];
    if (is_undefined(_planta)) return _dados;
    var _cs = global._cell_size;
    var _p = _casa_planta_nova();
    var _tapetes = [];

    for (var _i = 0; _i < array_length(_planta); _i++) {
        var _l = _planta[_i];
        if (random(1) > _l[4]) continue;
        if (string_pos("tapete:", _l[0]) == 1) { array_push(_tapetes, [string_delete(_l[0], 1, 7), _l[1]]); continue; }
        var _m = global.casa_catalogo[$ _l[0]];
        if (is_undefined(_m)) continue;
        var _qtd = max(1, irandom_range(_l[2], _l[3]));
        repeat (_qtd) _casa_colocar(_p, _l[0], _l[1], _m.w, _m.h);
    }

    // Tapetes por baixo (não ocupam espaço)
    for (var _t = 0; _t < array_length(_tapetes); _t++) {
        var _tp = global.casa_tapetes[$ _tapetes[_t][0]], _regra = _tapetes[_t][1];
        if (is_undefined(_tp)) continue;
        var _cx, _cy;
        if (string_pos("sob:", _regra) == 1 || string_pos("frente:", _regra) == 1) {
            var _sep = string_pos(":", _regra);
            var _a = _casa_achar(_p, string_delete(_regra, 1, _sep));
            if (is_undefined(_a)) continue;
            _cx = _a[1] + _a[3] / 2;
            _cy = (string_pos("sob:", _regra) == 1) ? (_a[2] + _a[4] / 2 - 0.8) : (_a[2] + _a[4] + _tp.h / 2 + 0.3);
        } else {
            _cx = irandom_range(9, _p.cols - 10) + 0.5;
            _cy = irandom_range(6, _p.rows - 7) + 0.5;
        }
        array_push(_dados, ["tapete", _tp.frame, _cx * _cs, _cy * _cs, false]);
    }
    for (var _k = 0; _k < array_length(_p.itens); _k++) {
        var _it = _p.itens[_k];
        array_push(_dados, [_it[0], 0, (_it[1] + _it[3] / 2) * _cs, (_it[2] + _it[4]) * _cs, false]);
    }
    ds_grid_destroy(_p.ocup);
    return _dados;
}

/// Chamado em reset_level_data: mobília de todas as salas comuns da fase.
function casa_gerar_moveis(_salas_geradas) {
    if (!variable_global_exists("casa_catalogo")) casa_moveis_definir();
    if (!variable_global_exists("salas_com_moveis") || !ds_exists(global.salas_com_moveis, ds_type_map)) {
        global.salas_com_moveis = ds_map_create();
    }
    for (var _i = 0; _i < array_length(_salas_geradas); _i++) {
        var _coords = _salas_geradas[_i];
        var _id = get_room_id(_coords);
        if (ds_map_exists(global.salas_com_moveis, _id)) continue;
        var _info = procurar_sala_por_numero(_coords);
        if (!is_struct(_info)) continue;
        global.salas_com_moveis[? _id] = casa_gerar_sala(_info.tipo);
    }
}

#endregion

#region ---------- CRIAÇÃO NA SALA (carregar_sala) ----------

/// Recria os móveis e tapetes da sala (guardando quem já foi aberto).
function casa_recriar_moveis(_coords) {
    if (!variable_global_exists("salas_com_moveis") || !ds_exists(global.salas_com_moveis, ds_type_map)) return;
    var _id = get_room_id(_coords);
    if (!ds_map_exists(global.salas_com_moveis, _id)) {
        // Sala que ainda não tinha mobília (ex.: criada depois): gera agora
        var _info = procurar_sala_por_numero(_coords);
        if (!is_struct(_info)) return;
        global.salas_com_moveis[? _id] = casa_gerar_sala(_info.tipo);
    }
    var _lista = global.salas_com_moveis[? _id];
    for (var _i = 0; _i < array_length(_lista); _i++) {
        var _d = _lista[_i];
        if (_d[0] == "tapete") {
            var _tap = instance_create_layer(_d[2], _d[3], "Instances_Abaixo_moveis", obj_tapete_casa);
            _tap.image_index = _d[1];
            continue;
        }
        var _m = global.casa_catalogo[$ _d[0]];
        if (is_undefined(_m)) continue;
        var _inst = instance_create_layer(_d[2], _d[3], "Instances", _m.abre ? obj_movel_abre : obj_movel_casa);
        with (_inst) {
            tipo   = _d[0];
            dados  = _d;            // referência: abrir aqui atualiza o save da sala
            aberto = _d[4];
            sprite_index = _m.spr;
            image_index  = aberto ? 1 : 0;
            depth = -y;
        }
    }
}

#endregion

#region ---------- INTERAÇÃO (obj_movel_abre) ----------

function casa_movel_abrir(_inst) {
    with (_inst) {
        if (aberto) break;
        aberto = true;
        image_index = 1;
        if (is_array(dados)) dados[@ 4] = true;
        if (instance_exists(obj_player)) obj_player.alarm[6] = 3;

        var _m = global.casa_catalogo[$ tipo];
        if (is_undefined(_m) || _m.loot == "" || random(1) > _m.chance_loot) break;
        var _ix = x - 16, _iy = y + 6;
        switch (_m.loot) {
            case "ativo":    criar_item_aleatorio_ativos(_ix, _iy, depth, 1); break;
            case "pe":       criar_item_aleatorio_passivos_pe(_ix, _iy, depth, 1); break;
            case "arma":     criar_item_aleatorio_passivos_arma(_ix, _iy, depth, 1); break;
            case "armadura": criar_item_aleatorio_passivos_armadura(_ix, _iy, depth, 1); break;
            case "material": criar_item_aleatorio_material(_ix, _iy, depth, 1); break;
        }
    }
}

#endregion
