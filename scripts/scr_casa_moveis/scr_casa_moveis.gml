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
///  - Sprites em visão de cima (3/4): origem no PÉ (centro de baixo). O pé tem colisão (mesmo objeto
///    das paredes); a parte de cima do desenho não, então o player passa ATRÁS do móvel sem atravessar.
///  - Profundidade: profundidade_pe(y) = -y do pé, a mesma do player e dos inimigos.
///  - Orientação (dados[1]): 0 = de frente, 1 = de costas. Encostado na parede de baixo, de frente pra TV,
///    cadeira na escrivaninha... fica de costas, sempre virado pra dentro do cômodo (_casa_orientacao).
///  - A planta respeita o FORMATO da sala (layout salvo em spr_fase_criation): "parede" = qualquer
///    parede acima do móvel, inclusive as de dentro de um L/T; nada é colocado fora da casa.

/// Catálogo, tapetes e plantas dos cômodos. É aqui que se adiciona/ajusta móvel.
function casa_moveis_definir() {
    // w, h = pé no chão em células de 64 px (colisão) | o desenho sobe acima do pé (dá pra passar atrás)
    // solido: false = decoração de chão sem colisão (brinquedos)
    global.casa_catalogo = {
        // --- abrem (tecla F, frame 1 = aberto) ---
        geladeira:        { spr: spr_geladeira,              w: 2, h: 1, abre: true,  loot: "ativo",    chance_loot: 1.0 },
        guarda_roupa:     { spr: spr_guarda_roupa,           w: 3, h: 1, abre: true,  loot: "arma",     chance_loot: 1.0 },
        escrivaninha:     { spr: spr_mesa,                   w: 3, h: 2, abre: true,  loot: "pe",       chance_loot: 1.0 },
        criado_mudo:      { spr: spr_movel_criado_mudo,      w: 1, h: 1, abre: true,  loot: "material", chance_loot: 0.5 },
        comoda:           { spr: spr_movel_comoda,           w: 3, h: 1, abre: true,  loot: "armadura", chance_loot: 0.5 },
        bau:              { spr: spr_movel_bau,              w: 2, h: 1, abre: true,  loot: "material", chance_loot: 0.5 },
        armario_cozinha:  { spr: spr_movel_armario_cozinha,  w: 2, h: 1, abre: true,  loot: "material", chance_loot: 0.5 },
        balcao:           { spr: spr_movel_balcao,           w: 3, h: 1, abre: true,  loot: "material", chance_loot: 0.4 },
        fogao:            { spr: spr_movel_fogao,            w: 2, h: 1, abre: true,  loot: "ativo",    chance_loot: 0.5 },
        armario_banheiro: { spr: spr_movel_armario_banheiro, w: 2, h: 1, abre: true,  loot: "ativo",    chance_loot: 0.5 },
        maquina_lavar:    { spr: spr_movel_maquina_lavar,    w: 2, h: 2, abre: true,  loot: "armadura", chance_loot: 0.5 },
        bancada:          { spr: spr_movel_bancada,          w: 3, h: 1, abre: true,  loot: "material", chance_loot: 0.6 },
        // --- decoração sólida ---
        cama:        { spr: spr_movel_cama,        w: 3, h: 4, abre: false, loot: "", chance_loot: 0 },
        berco:       { spr: spr_movel_berco,       w: 3, h: 3, abre: false, loot: "", chance_loot: 0 },
        sofa:        { spr: spr_movel_sofa,        w: 4, h: 2, abre: false, loot: "", chance_loot: 0 },
        poltrona:    { spr: spr_movel_poltrona,    w: 2, h: 2, abre: false, loot: "", chance_loot: 0 },
        tv:          { spr: spr_movel_tv,          w: 3, h: 1, abre: false, loot: "", chance_loot: 0 },
        estante:     { spr: spr_movel_estante,     w: 3, h: 1, abre: false, loot: "", chance_loot: 0 },
        mesa_jantar: { spr: spr_movel_mesa_jantar, w: 3, h: 2, abre: false, loot: "", chance_loot: 0 },
        mesa_centro: { spr: spr_movel_mesa_centro, w: 2, h: 1, abre: false, loot: "", chance_loot: 0 },
        cadeira:     { spr: spr_movel_cadeira,     w: 1, h: 1, abre: false, loot: "", chance_loot: 0 },
        pufe:        { spr: spr_movel_pufe,        w: 1, h: 1, abre: false, loot: "", chance_loot: 0 },
        planta:      { spr: spr_movel_planta,      w: 1, h: 1, abre: false, loot: "", chance_loot: 0 },
        luminaria:   { spr: spr_movel_luminaria,   w: 1, h: 1, abre: false, loot: "", chance_loot: 0 },
        privada:     { spr: spr_movel_privada,     w: 1, h: 2, abre: false, loot: "", chance_loot: 0 },
        banheira:    { spr: spr_movel_banheira,    w: 4, h: 2, abre: false, loot: "", chance_loot: 0 },
        cesto_roupa: { spr: spr_movel_cesto_roupa, w: 1, h: 1, abre: false, loot: "", chance_loot: 0 },
        lixeira:     { spr: spr_movel_lixeira,     w: 1, h: 1, abre: false, loot: "", chance_loot: 0 },
        caixas:      { spr: spr_movel_caixas,      w: 1, h: 1, abre: false, loot: "", chance_loot: 0 },
        barril:      { spr: spr_movel_barril,      w: 1, h: 1, abre: false, loot: "", chance_loot: 0 },
        relogio:     { spr: spr_movel_relogio,     w: 1, h: 1, abre: false, loot: "", chance_loot: 0 },
        cavalinho:   { spr: spr_movel_cavalinho,   w: 2, h: 1, abre: false, loot: "", chance_loot: 0 },
        brinquedos:  { spr: spr_movel_brinquedos,  w: 1, h: 1, abre: false, loot: "", chance_loot: 0, solido: false }
    };
    global.casa_tapetes = {
        sala: { frame: 0, w: 5, h: 4 },
        quarto: { frame: 1, w: 5, h: 4 },
        redondo: { frame: 2, w: 5, h: 4 },
        corredor: { frame: 3, w: 5, h: 4 },
        banheiro: { frame: 4, w: 5, h: 4 },
        brincar: { frame: 5, w: 5, h: 4 }
    };
    // [tipo, regra, mínimo, máximo, chance] — a ordem importa: os grandes primeiro, enchimento no fim
    global.casa_plantas = {
        quarto: [
            ["cama", "parede", 1, 1, 1.0],
            ["criado_mudo", "ao_lado:cama", 2, 2, 1.0],
            ["guarda_roupa", "parede", 1, 1, 1.0],
            ["comoda", "parede", 1, 1, 0.9],
            ["escrivaninha", "parede", 1, 1, 0.9],
            ["cadeira", "abaixo:escrivaninha", 1, 1, 1.0],
            ["estante", "parede", 1, 1, 0.8],
            ["bau", "abaixo:cama", 1, 1, 0.7],
            ["poltrona", "canto", 0, 1, 0.6],
            ["luminaria", "canto", 1, 2, 0.8],
            ["cesto_roupa", "lado", 1, 1, 0.7],
            ["planta", "canto", 1, 2, 0.9],
            ["planta", "baixo", 1, 3, 0.7],
            ["caixas", "baixo", 0, 2, 0.5],
            ["lixeira", "lado", 0, 1, 0.5],
            ["brinquedos", "centro", 1, 3, 0.8],
            ["estante", "baixo", 1, 1, 0.8],
            ["comoda", "baixo", 0, 1, 0.6],
            ["bau", "baixo", 0, 1, 0.5],
            ["mesa_centro", "centro", 0, 1, 0.6],
            ["pufe", "volta:mesa_centro", 2, 3, 1.0],
            ["caixas", "canto", 1, 2, 0.8],
            ["planta", "baixo", 1, 2, 0.8],
            ["brinquedos", "lado", 0, 2, 0.6],
            ["tapete:quarto", "frente:cama", 1, 1, 0.9]
        ],
        quarto2: [
            ["berco", "parede", 1, 1, 1.0],
            ["poltrona", "ao_lado:berco", 1, 1, 0.9],
            ["comoda", "parede", 1, 1, 1.0],
            ["guarda_roupa", "parede", 1, 1, 0.9],
            ["estante", "parede", 1, 1, 0.8],
            ["bau", "parede", 1, 1, 0.9],
            ["cavalinho", "baixo", 1, 1, 0.9],
            ["cesto_roupa", "lado", 1, 1, 0.8],
            ["pufe", "lado", 1, 2, 0.7],
            ["luminaria", "canto", 1, 1, 0.8],
            ["planta", "canto", 1, 2, 0.8],
            ["planta", "baixo", 1, 2, 0.6],
            ["brinquedos", "centro", 2, 4, 1.0],
            ["estante", "baixo", 1, 1, 0.7],
            ["bau", "baixo", 1, 1, 0.7],
            ["mesa_centro", "centro", 1, 1, 0.7],
            ["pufe", "volta:mesa_centro", 2, 4, 1.0],
            ["caixas", "canto", 1, 2, 0.7],
            ["brinquedos", "lado", 1, 3, 0.8],
            ["planta", "baixo", 1, 2, 0.7],
            ["tapete:brincar", "centro", 1, 1, 1.0]
        ],
        quarto3: [
            ["cama", "parede", 1, 1, 1.0],
            ["criado_mudo", "ao_lado:cama", 1, 2, 1.0],
            ["escrivaninha", "parede", 1, 1, 1.0],
            ["cadeira", "abaixo:escrivaninha", 1, 1, 1.0],
            ["estante", "parede", 1, 2, 1.0],
            ["guarda_roupa", "parede", 1, 1, 0.9],
            ["comoda", "parede", 0, 1, 0.7],
            ["bau", "lado", 1, 1, 0.8],
            ["pufe", "lado", 0, 2, 0.6],
            ["luminaria", "canto", 1, 1, 0.7],
            ["planta", "canto", 1, 2, 0.8],
            ["planta", "baixo", 1, 2, 0.6],
            ["caixas", "baixo", 0, 2, 0.5],
            ["lixeira", "lado", 0, 1, 0.6],
            ["brinquedos", "centro", 0, 2, 0.6],
            ["estante", "baixo", 1, 1, 0.7],
            ["poltrona", "canto", 1, 1, 0.7],
            ["mesa_centro", "centro", 0, 1, 0.6],
            ["pufe", "volta:mesa_centro", 2, 2, 1.0],
            ["caixas", "canto", 1, 2, 0.6],
            ["planta", "baixo", 1, 2, 0.7],
            ["tapete:quarto", "frente:cama", 1, 1, 0.8]
        ],
        cozinha: [
            ["geladeira", "parede", 1, 1, 1.0],
            ["armario_cozinha", "ao_lado:geladeira", 1, 1, 1.0],
            ["fogao", "ao_lado:armario_cozinha", 1, 1, 1.0],
            ["armario_cozinha", "ao_lado:fogao", 1, 1, 0.9],
            ["armario_cozinha", "ao_lado:armario_cozinha", 0, 2, 0.7],
            ["estante", "parede", 0, 1, 0.6],
            ["relogio", "parede", 0, 1, 0.6],
            ["mesa_jantar", "centro", 1, 1, 1.0],
            ["cadeira", "volta:mesa_jantar", 4, 6, 1.0],
            ["balcao", "baixo", 1, 1, 0.8],
            ["geladeira", "lado", 0, 1, 0.3],
            ["lixeira", "lado", 1, 1, 0.8],
            ["planta", "canto", 1, 2, 0.8],
            ["planta", "baixo", 0, 2, 0.5],
            ["caixas", "lado", 0, 2, 0.5],
            ["barril", "canto", 0, 1, 0.4],
            ["armario_cozinha", "baixo", 1, 2, 0.8],
            ["estante", "baixo", 0, 1, 0.6],
            ["caixas", "canto", 1, 2, 0.6],
            ["barril", "lado", 0, 2, 0.5],
            ["planta", "baixo", 1, 2, 0.6],
            ["tapete:sala", "sob:mesa_jantar", 1, 1, 0.6]
        ],
        banheiro: [
            ["banheira", "parede", 1, 1, 1.0],
            ["privada", "parede", 1, 1, 1.0],
            ["armario_banheiro", "ao_lado:privada", 1, 1, 1.0],
            ["maquina_lavar", "parede", 1, 1, 0.8],
            ["armario_banheiro", "parede", 0, 1, 0.6],
            ["cesto_roupa", "ao_lado:maquina_lavar", 1, 1, 0.8],
            ["lixeira", "ao_lado:privada", 1, 1, 0.8],
            ["planta", "canto", 1, 2, 0.8],
            ["caixas", "baixo", 0, 2, 0.4],
            ["bau", "lado", 0, 1, 0.5],
            ["brinquedos", "centro", 0, 1, 0.4],
            ["armario_banheiro", "baixo", 0, 1, 0.6],
            ["maquina_lavar", "baixo", 0, 1, 0.5],
            ["cesto_roupa", "canto", 0, 1, 0.6],
            ["planta", "baixo", 1, 2, 0.7],
            ["tapete:banheiro", "frente:banheira", 1, 1, 1.0]
        ],
        banheiro2: [
            ["privada", "parede", 1, 1, 1.0],
            ["armario_banheiro", "ao_lado:privada", 1, 1, 1.0],
            ["banheira", "parede", 1, 1, 0.9],
            ["maquina_lavar", "parede", 0, 1, 0.6],
            ["cesto_roupa", "lado", 1, 1, 0.8],
            ["lixeira", "ao_lado:privada", 1, 1, 0.8],
            ["planta", "canto", 1, 2, 0.8],
            ["caixas", "canto", 0, 2, 0.5],
            ["armario_banheiro", "baixo", 0, 1, 0.6],
            ["planta", "baixo", 1, 2, 0.7],
            ["caixas", "baixo", 0, 2, 0.5],
            ["tapete:banheiro", "frente:armario_banheiro", 1, 1, 1.0]
        ],
        sala_estar: [
            ["tv", "parede", 1, 1, 1.0],
            ["sofa", "frente:tv", 1, 1, 1.0],
            ["poltrona", "ao_lado:sofa", 2, 2, 0.9],
            ["mesa_centro", "abaixo:sofa", 1, 1, 0.8],
            ["estante", "parede", 1, 2, 1.0],
            ["relogio", "parede", 1, 1, 0.8],
            ["comoda", "parede", 0, 1, 0.6],
            ["luminaria", "canto", 1, 2, 0.9],
            ["planta", "canto", 1, 2, 1.0],
            ["planta", "baixo", 1, 3, 0.8],
            ["planta", "lado", 0, 2, 0.6],
            ["pufe", "lado", 1, 2, 0.7],
            ["cavalinho", "baixo", 0, 1, 0.5],
            ["mesa_jantar", "centro", 0, 1, 0.5],
            ["cadeira", "volta:mesa_jantar", 4, 4, 1.0],
            ["brinquedos", "centro", 1, 2, 0.7],
            ["estante", "baixo", 1, 2, 0.8],
            ["sofa", "baixo", 0, 1, 0.5],
            ["comoda", "baixo", 0, 1, 0.5],
            ["poltrona", "canto", 0, 2, 0.6],
            ["planta", "baixo", 1, 2, 0.8],
            ["luminaria", "lado", 0, 2, 0.6],
            ["tapete:sala", "sob:sofa", 1, 1, 1.0]
        ],
        fundos: [
            ["maquina_lavar", "parede", 1, 2, 1.0],
            ["cesto_roupa", "ao_lado:maquina_lavar", 1, 1, 0.9],
            ["bancada", "parede", 1, 1, 0.9],
            ["armario_cozinha", "parede", 0, 1, 0.6],
            ["estante", "parede", 0, 1, 0.6],
            ["bau", "parede", 0, 1, 0.6],
            ["barril", "canto", 1, 2, 0.8],
            ["caixas", "canto", 2, 4, 1.0],
            ["caixas", "lado", 1, 3, 0.9],
            ["caixas", "baixo", 1, 3, 0.8],
            ["lixeira", "lado", 1, 1, 0.7],
            ["planta", "canto", 0, 2, 0.6],
            ["bancada", "baixo", 0, 1, 0.6],
            ["estante", "baixo", 1, 1, 0.7],
            ["barril", "centro", 0, 2, 0.5],
            ["tapete:corredor", "centro", 0, 1, 0.5]
        ],
        porao: [
            ["bancada", "parede", 1, 1, 1.0],
            ["estante", "parede", 1, 2, 0.9],
            ["bau", "parede", 1, 2, 0.9],
            ["guarda_roupa", "parede", 0, 1, 0.6],
            ["relogio", "parede", 0, 1, 0.4],
            ["barril", "canto", 2, 4, 1.0],
            ["caixas", "canto", 3, 4, 1.0],
            ["caixas", "lado", 2, 5, 1.0],
            ["caixas", "baixo", 2, 5, 1.0],
            ["barril", "lado", 1, 3, 0.8],
            ["maquina_lavar", "lado", 0, 1, 0.3],
            ["brinquedos", "centro", 0, 2, 0.5],
            ["estante", "baixo", 1, 2, 0.8],
            ["bancada", "baixo", 0, 1, 0.6],
            ["caixas", "centro", 1, 3, 0.8],
            ["barril", "centro", 0, 2, 0.6]
        ]
    };
}

#region ---------- GERAÇÃO (uma vez por fase, em reset_level_data) ----------

/// Grade de ocupação da sala, lida do LAYOUT salvo (spr_fase_criation): tudo que não é chão
/// já nasce ocupado, e as portas/corredores ficam sempre livres. Funciona com qualquer formato.
function _casa_planta_nova(_coords) {
    var _L = sala_obter_layout(_coords);
    var _cols = _L.largura, _rows = _L.altura;
    var _p = {
        cols: _cols, rows: _rows,
        x0: 1, y0: 1, x1: _cols - 2, y1: _rows - 2,
        layout: _L,
        ocup: ds_grid_create(_cols, _rows),
        itens: [] // [tipo, x0, y0, w, h]
    };
    ds_grid_clear(_p.ocup, 0);
    for (var _i = 0; _i < _cols * _rows; _i++) {
        if (_L.celulas[_i] != SALA_CHAO) ds_grid_set(_p.ocup, _i mod _cols, _i div _cols, 1);
    }
    for (var _i = 0; _i < array_length(_L.corredor); _i++) {
        ds_grid_set(_p.ocup, _L.corredor[_i] mod _cols, _L.corredor[_i] div _cols, 1);
    }
    var _mx = _cols div 2, _my = _rows div 2;
    ds_grid_set_region(_p.ocup, _mx - 2, 1, _mx + 2, 2, 1);                       // porta de cima
    ds_grid_set_region(_p.ocup, _mx - 2, _rows - 3, _mx + 2, _rows - 2, 1);       // porta de baixo
    ds_grid_set_region(_p.ocup, 1, _my - 2, 3, _my + 2, 1);                        // porta esquerda
    ds_grid_set_region(_p.ocup, _cols - 4, _my - 2, _cols - 2, _my + 2, 1);        // porta direita
    // Escada do porão (spr_fase_criation > Escada): área da escada + espaço para entrar
    var _id = get_room_id(_coords);
    if (variable_global_exists("salas_com_escada_porao") && ds_map_exists(global.salas_com_escada_porao, _id)) {
        var _e = global.salas_com_escada_porao[? _id];
        if (is_struct(_e)) {
            var _ex = floor(_e.x / global._cell_size), _ey = floor(_e.y / global._cell_size);
            // _e.y = topo da escada: 2 células de escada + 2 de entrada na frente
            ds_grid_set_region(_p.ocup, max(0, _ex - 2), max(0, _ey), min(_cols - 1, _ex + 2), min(_rows - 1, _ey + 3), 1);
        }
    }
    return _p;
}

/// true se a célula não é chão (parede, bloco, fora da casa)
function _casa_solido(_p, _x, _y) {
    return sala_celula(_p.layout, _x, _y) != SALA_CHAO;
}

/// Linha horizontal [x, x+w-1] na altura y toda sólida?
function _casa_linha_solida(_p, _x, _y, _w) {
    for (var _i = 0; _i < _w; _i++) if (!_casa_solido(_p, _x + _i, _y)) return false;
    return true;
}

/// Coluna vertical [y, y+h-1] na coluna x toda sólida?
function _casa_coluna_solida(_p, _x, _y, _h) {
    for (var _j = 0; _j < _h; _j++) if (!_casa_solido(_p, _x, _y + _j)) return false;
    return true;
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
/// As regras de parede olham o formato real da sala (L, T, pilares...), não um retângulo fixo.
function _casa_candidatos(_p, _regra, _w, _h) {
    var _c = [], _x, _y;
    switch (_regra) {
        case "parede": // encostado numa parede acima
            for (_y = _p.y0; _y <= _p.y1 - _h + 1; _y++) for (_x = _p.x0; _x <= _p.x1 - _w + 1; _x++)
                if (_casa_linha_solida(_p, _x, _y - 1, _w)) array_push(_c, [_x, _y]);
            return _c;
        case "baixo": // encostado numa parede abaixo
            for (_y = _p.y0; _y <= _p.y1 - _h + 1; _y++) for (_x = _p.x0; _x <= _p.x1 - _w + 1; _x++)
                if (_casa_linha_solida(_p, _x, _y + _h, _w)) array_push(_c, [_x, _y]);
            return _c;
        case "lado": // encostado numa parede lateral (sem colar na de cima)
            for (_y = _p.y0; _y <= _p.y1 - _h + 1; _y++) for (_x = _p.x0; _x <= _p.x1 - _w + 1; _x++) {
                if (_casa_solido(_p, _x, _y - 1) || _casa_solido(_p, _x, _y - 2)) continue;
                if (_casa_coluna_solida(_p, _x - 1, _y, _h) || _casa_coluna_solida(_p, _x + _w, _y, _h)) array_push(_c, [_x, _y]);
            }
            return _c;
        case "canto":
            for (_y = _p.y0; _y <= _p.y1 - _h + 1; _y++) for (_x = _p.x0; _x <= _p.x1 - _w + 1; _x++) {
                var _v = _casa_linha_solida(_p, _x, _y - 1, _w) || _casa_linha_solida(_p, _x, _y + _h, _w);
                var _hz = _casa_coluna_solida(_p, _x - 1, _y, _h) || _casa_coluna_solida(_p, _x + _w, _y, _h);
                if (_v && _hz) array_push(_c, [_x, _y]);
            }
            return _c;
        case "centro": // longe das paredes (4 células na horizontal, 3 na vertical)
            for (_y = _p.y0; _y <= _p.y1 - _h + 1; _y++) for (_x = _p.x0; _x <= _p.x1 - _w + 1; _x++) {
                var _ok = true;
                for (var _yy = _y - 3; _yy <= _y + _h + 2 && _ok; _yy++)
                    for (var _xx = _x - 4; _xx <= _x + _w + 3; _xx++)
                        if (_casa_solido(_p, _xx, _yy)) { _ok = false; break; }
                if (_ok) array_push(_c, [_x, _y]);
            }
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

/// Item do planejamento que ocupa a célula (x, y), ou undefined
function _casa_item_em(_p, _x, _y) {
    for (var _i = 0; _i < array_length(_p.itens); _i++) {
        var _it = _p.itens[_i];
        if (_x >= _it[1] && _x < _it[1] + _it[3] && _y >= _it[2] && _y < _it[2] + _it[4]) return _it;
    }
    return undefined;
}

/// Para onde o móvel olha: 0 = de frente (pra câmera), 1 = de costas (virado pra cima / pra dentro da sala).
/// - encostado na parede de BAIXO (e não na de cima) -> de costas, olhando pro meio do cômodo
/// - "frente:X" (sofá de frente pra TV) e cadeira "abaixo:" da escrivaninha -> de costas, olhando pro X
/// - cadeira "volta:mesa" do lado de baixo da mesa -> de costas
/// - "ao_lado:X" -> copia a orientação do X (poltrona ao lado do sofá, criado-mudo ao lado da cama...)
function _casa_orientacao(_p, _tipo, _regra, _x, _y, _w, _h) {
    if (string_pos("ao_lado:", _regra) == 1) {
        var _viz = _casa_item_em(_p, _x - 1, _y);
        if (is_undefined(_viz)) _viz = _casa_item_em(_p, _x + _w, _y);
        if (!is_undefined(_viz) && array_length(_viz) > 5) return _viz[5];
    }
    if (string_pos("frente:", _regra) == 1) return 1;
    if (string_pos("abaixo:", _regra) == 1 && _tipo == "cadeira") return 1;
    if (string_pos("volta:", _regra) == 1) {
        var _cima = _casa_item_em(_p, _x, _y - 1);
        return (!is_undefined(_cima) && _cima[0] == string_delete(_regra, 1, 6)) ? 1 : 0;
    }
    if (_casa_linha_solida(_p, _x, _y + _h, _w) && !_casa_linha_solida(_p, _x, _y - 1, _w)) return 1;
    return 0;
}

function _casa_colocar(_p, _tipo, _regra, _w, _h) {
    var _c = _casa_candidatos(_p, _regra, _w, _h);
    var _ordem_fixa = (string_pos("frente:", _regra) == 1 || string_pos("volta:", _regra) == 1 || string_pos("abaixo:", _regra) == 1);
    if (!_ordem_fixa) _c = array_shuffle(_c);
    for (var _i = 0; _i < array_length(_c); _i++) {
        var _x = _c[_i][0], _y = _c[_i][1];
        if (_casa_livre(_p, _x, _y, _w, _h)) {
            ds_grid_set_region(_p.ocup, _x, _y, _x + _w - 1, _y + _h - 1, 1);
            array_push(_p.itens, [_tipo, _x, _y, _w, _h, _casa_orientacao(_p, _tipo, _regra, _x, _y, _w, _h)]);
            return true;
        }
    }
    return false;
}

/// Monta a lista de dados de uma sala: [tipo, frame, px, py, aberto] (px, py = pé do móvel / centro do tapete).
function casa_gerar_sala(_tipo_sala, _coords) {
    var _planta = global.casa_plantas[$ _tipo_sala];
    var _dados = [];
    if (is_undefined(_planta)) return _dados;
    var _cs = global._cell_size;
    var _p = _casa_planta_nova(_coords);
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
            var _cand = _casa_candidatos(_p, "centro", _tp.w, _tp.h);
            if (array_length(_cand) == 0) continue;
            var _pc = _cand[irandom(array_length(_cand) - 1)];
            _cx = _pc[0] + _tp.w / 2;
            _cy = _pc[1] + _tp.h / 2;
        }
        array_push(_dados, ["tapete", _tp.frame, _cx * _cs, _cy * _cs, false]);
    }
    for (var _k = 0; _k < array_length(_p.itens); _k++) {
        var _it = _p.itens[_k];
        // [tipo, orientação (0 frente | 1 costas), x do pé, y do pé, aberto]
        array_push(_dados, [_it[0], _it[5], (_it[1] + _it[3] / 2) * _cs, (_it[2] + _it[4]) * _cs, false]);
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
        global.salas_com_moveis[? _id] = casa_gerar_sala(_info.tipo, _coords);
    }
}

#endregion

#region ---------- CRIAÇÃO NA SALA (carregar_sala) ----------

/// Profundidade padrão do mundo: quanto mais embaixo o PÉ, mais na frente.
/// Player, inimigos e móveis usam a mesma regra, então o player passa atrás/na frente dos móveis.
function profundidade_pe(_y_pe) {
    return -_y_pe;
}

/// Cria a caixa de colisão do pé do móvel (mesmo objeto de colisão das paredes da sala = global.sala.parede)
function _casa_criar_colisao(_px, _py, _w, _h) {
    var _cs = global._cell_size;
    var _obj = (is_struct(global.sala) && object_exists(global.sala.parede)) ? global.sala.parede : obj_parede_bebe;
    var _l = _px - _w * _cs / 2 + 6;          // pequena folga nas laterais
    var _t = _py - _h * _cs + 10;             // e no fundo (ajuda a "encostar" atrás)
    var _lw = _w * _cs - 12, _lh = _h * _cs - 12;
    var _c = instance_create_layer(_l, _t, "instances", _obj);
    with (_c) {
        mask_index   = spr_parede_mascara;
        image_angle  = 0;
        image_xscale = _lw / 64;
        image_yscale = _lh / 64;
        image_speed  = 0;
        visible      = false;
    }
    return _c;
}

/// Recria os móveis e tapetes da sala (guardando quem já foi aberto).
function casa_recriar_moveis(_coords) {
    if (!variable_global_exists("salas_com_moveis") || !ds_exists(global.salas_com_moveis, ds_type_map)) return;
    if (!variable_global_exists("casa_catalogo")) casa_moveis_definir();
    var _id = get_room_id(_coords);
    if (!ds_map_exists(global.salas_com_moveis, _id)) {
        // Sala que ainda não tinha mobília (ex.: criada depois): gera agora
        var _info = procurar_sala_por_numero(_coords);
        if (!is_struct(_info)) return;
        global.salas_com_moveis[? _id] = casa_gerar_sala(_info.tipo, _coords);
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
            costas       = _d[1];
            image_index  = casa_movel_frame(sprite_index, _m.abre, costas, aberto);
            pe_w = _m.w * global._cell_size;   // tamanho do pé em px (interação)
            pe_h = _m.h * global._cell_size;
            depth = profundidade_pe(y);        // y = pé do móvel
        }
        if (_m[$ "solido"] ?? true) _casa_criar_colisao(_d[2], _d[3], _m.w, _m.h);
    }
}

/// Frame do móvel: [frente fechado, frente aberto, costas fechado, costas aberto] (os que abrem)
///                   [frente, costas] (os outros). Móveis simétricos só têm a frente.
function casa_movel_frame(_spr, _abre, _costas, _aberto) {
    var _por = _abre ? 2 : 1;
    var _f = (_abre && _aberto) ? 1 : 0;
    if (_costas == 1 && sprite_get_number(_spr) >= _por * 2) _f += _por;
    return min(_f, sprite_get_number(_spr) - 1);
}

/// true se o player está encostado no móvel (distância do pé do player até o retângulo do pé do móvel)
function casa_movel_perto(_inst, _p, _alcance = 36) {
    var _l = _inst.x - _inst.pe_w / 2, _r = _inst.x + _inst.pe_w / 2;
    var _t = _inst.y - _inst.pe_h, _b = _inst.y;
    var _py = _p.bbox_bottom;
    var _cx = clamp(_p.x, _l, _r), _cy = clamp(_py, _t, _b);
    return point_distance(_p.x, _py, _cx, _cy) <= _alcance;
}

#endregion

#region ---------- INTERAÇÃO (obj_movel_abre) ----------

function casa_movel_abrir(_inst) {
    with (_inst) {
        if (aberto) break;
        aberto = true;
        image_index = casa_movel_frame(sprite_index, true, (variable_instance_exists(id, "costas") ? costas : 0), true);
        if (is_array(dados)) dados[@ 4] = true;
        if (instance_exists(obj_player)) obj_player.alarm[6] = 3;

        var _m = global.casa_catalogo[$ tipo];
        if (is_undefined(_m) || _m.loot == "" || random(1) > _m.chance_loot) break;
        var _ix = x - 16, _iy = y + 24;   // item cai na frente do móvel (fora da colisão)
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
