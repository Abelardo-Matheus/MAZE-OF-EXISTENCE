// feather disable GM2017
// ============================================================================
//  ITENS GERAL — DATABASE DE ITENS, PASSIVAS, RECEITAS E DROPS
// ----------------------------------------------------------------------------
//  Tudo é data-driven: para criar um item novo basta uma linha em
//  itens_definir_catalogo() (e uma receita em itens_definir_receitas(), se quiser).
//
//  Cada item tem um ID (string) que é guardado em INFOS.ITEM na grid do inventário.
//  Equipamentos têm NÍVEL (sem limite, sobe matando monstros) e PASSIVAS
//  (sorteadas ao nascer + adesivos). Passivas, XP e habilidade X: scripts/scr_passivas_itens
//  Atributo no nível N  = base * (1 + ITEM_CRESC_STAT * (N - 1))
// ============================================================================

#macro ITEM_CRESC_STAT       0.30

#region ---------- RARIDADES / TIPOS ----------

function itens_raridades() {
    // nome, cor do nome, peso no sorteio de drop
    return {
        comum:    { nome: "Comum",    cor: make_color_rgb(240, 240, 240), peso: 100 },
        incomum:  { nome: "Incomum",  cor: make_color_rgb(110, 230, 110), peso: 45  },
        raro:     { nome: "Raro",     cor: make_color_rgb( 90, 190, 255), peso: 18  },
        epico:    { nome: "Épico",    cor: make_color_rgb(205, 130, 255), peso: 7   },
        lendario: { nome: "Lendário", cor: make_color_rgb(255, 185,  40), peso: 2   }
    };
}

/// Struct da raridade (cacheada)
function item_raridade(_rar) {
    if (!variable_global_exists("raridades_db")) global.raridades_db = itens_raridades();
    var _r = global.raridades_db[$ _rar];
    return is_undefined(_r) ? global.raridades_db.comum : _r;
}

/// Nome bonito do tipo do item
function item_tipo_nome(_tipo) {
    switch (_tipo) {
        case "uso":      return "Consumível";
        case "arma":     return "Arma";
        case "coleta":   return "Ferramenta";
        case "armadura": return "Armadura";
        case "cabeca":   return "Chapéu";
        case "bota":     return "Calçado";
        case "material": return "Material";
        case "adesivo":  return "Adesivo";
        case "colocavel":return "Colocável";
        case "arco":     return "Arco";
        case "luz":      return "Luz";
        case "ferramenta": return "Arma, Arco, Luz, Consumível ou Colocável";
    }
    return "Item";
}

function item_tipo_e_equipamento(_tipo) {
    return (_tipo == "arma" || _tipo == "armadura" || _tipo == "bota" || _tipo == "arco" || _tipo == "luz" || _tipo == "cabeca");
}

/// Itens que vão na HOTBAR (arma corpo a corpo, arco/arma de tiro, luz de mão)
function item_tipo_ferramenta(_tipo) {
    return (_tipo == "arma" || _tipo == "arco" || _tipo == "luz");
}

/// O que pode ficar na HOTBAR: armas/arcos/luzes + consumíveis (cura, buffs) + colocáveis (baús).
/// Consumível/colocável na mão: clique esquerdo usa (hotbar_usar_ativo).
function item_tipo_hotbar(_tipo) {
    return item_tipo_ferramenta(_tipo) || _tipo == "coleta" || _tipo == "uso" || _tipo == "colocavel";
}

/// Nome e formato de cada atributo (para tooltip e status)
function item_stat_info(_stat) {
    switch (_stat) {
        case "dano":       return { nome: "Dano",          sufixo: "",  cor: make_color_rgb(255, 120, 100) };
        case "defesa":     return { nome: "Defesa",        sufixo: "",  cor: make_color_rgb(120, 190, 255) };
        case "vel":        return { nome: "Velocidade",    sufixo: "",  cor: make_color_rgb(255, 230, 100) };
        case "vida":       return { nome: "Vida Máx.",     sufixo: "",  cor: make_color_rgb(120, 240, 140) };
        case "crit":       return { nome: "Crítico",       sufixo: "%", cor: make_color_rgb(255, 200,  60) };
        case "dano_pct":   return { nome: "Dano",          sufixo: "%", cor: make_color_rgb(255, 120, 100) };
        case "crit_dano":  return { nome: "Dano Crítico",  sufixo: "%", cor: make_color_rgb(255, 150,  70) };
        case "regen":      return { nome: "Regeneração",   sufixo: "/s",cor: make_color_rgb(255, 120, 160) };
        case "vampirismo": return { nome: "Vampirismo",    sufixo: "%", cor: make_color_rgb(200,  80, 140) };
        case "esquiva":    return { nome: "Esquiva",       sufixo: "%", cor: make_color_rgb(170, 220, 255) };
    }
    return { nome: _stat, sufixo: "", cor: c_white };
}

#endregion

// PASSIVAS: o vetor com todos os tipos de passiva fica em scripts/scr_passivas_itens
// (itens_definir_passivas, passiva_valor, passiva_texto, passivas_sortear).

#region ---------- CATÁLOGO DE ITENS ----------

/// Formata número: inteiro sem casas, quebrado com 1 casa
function item_num_str(_v) {
    if (abs(_v - round(_v)) < 0.05) return string(round(_v));
    return string_format(_v, 0, 1);
}

function itens_definir_catalogo() {
    global.itens_db = {};
    global.itens_ordem = [];

    // _def(id, nome, tipo, sprite, frame, preço, raridade, descrição, stats, extra)
    //   stats: { dano, defesa, vel, vida, crit, cura }  (só o que o item tem)
    //   extra: { inata: "id_passiva", buffs: [ {stat, valor, seg} ], stack: bool,
    //            espada: { alcance },                       (arma: tamanho do golpe, 1 = normal)
    //            arco:   { vel, flechas, abertura },        (arco: velocidade da flecha, flechas por tiro, leque em graus)
    //            luz:    { raio, estilo, cor, intensidade } (luz: ilumina em volta do player e recupera sanidade) }
    var _def = function(_id, _nome, _tipo, _spr, _img, _preco, _rar, _desc, _stats = {}, _extra = {}) {
        var _stack = (_tipo == "uso" || _tipo == "material" || _tipo == "adesivo");
        if (variable_struct_exists(_extra, "stack")) _stack = _extra.stack;
        global.itens_db[$ _id] = {
            id: _id, nome: _nome, tipo: _tipo, spr: _spr, img: _img, preco: _preco,
            raridade: _rar, desc: _desc, stats: _stats, stack: _stack,
            inata:  variable_struct_exists(_extra, "inata")   ? _extra.inata   : "",
            buffs:  variable_struct_exists(_extra, "buffs")   ? _extra.buffs   : [],
            passiva_adesivo: variable_struct_exists(_extra, "passiva") ? _extra.passiva : "",
            slots:  variable_struct_exists(_extra, "slots")  ? _extra.slots  : 0,
            escala: variable_struct_exists(_extra, "escala") ? _extra.escala : 1,
            espada: variable_struct_exists(_extra, "espada") ? _extra.espada : { alcance: 1 },
            coleta: variable_struct_exists(_extra, "coleta") ? _extra.coleta : undefined, // machado/picareta/pá (scr_coleta)
            arco:   variable_struct_exists(_extra, "arco")   ? _extra.arco   : undefined,
            luz:    variable_struct_exists(_extra, "luz")    ? _extra.luz    : undefined
        };
        array_push(global.itens_ordem, _id);
    };

    var _C = spr_itens_invent_consumiveis;
    var _W = spr_itens_invent_passivo_armas;
    var _A = spr_itens_invent_passivo_armadura;
    var _P = spr_itens_invent_passivo_pe;
    var _M = spr_itens_craft;

    // ---------------- CONSUMÍVEIS ----------------
    _def("batata",    "Batata",            "uso", _C, 0,  20, "comum",   "Uma batata cozida, quentinha.",           { cura: 20 });
    _def("maca",      "Maçã",              "uso", _C, 1,  10, "comum",   "Crocante e docinha.",                     { cura: 10 });
    _def("banana",    "Banana",            "uso", _C, 2,  15, "comum",   "Energia de macaco!",                      { cura: 13 });
    _def("uva",       "Uva",               "uso", _C, 3,  12, "comum",   "Um cacho cheio de bolinhas.",             { cura: 10 });
    _def("vitamina",  "Vitamina",          "uso", _C, 4,  50, "incomum", "Suco batido da vovó.",                    { cura: 50 });
    _def("leite",     "Leite",             "uso", _C, 5,  35, "comum",   "Deixa os ossos fortes.",                  { cura: 30 });
    _def("biscoito",  "Biscoito",          "uso", _C, 6,  12, "comum",   "Com gotas de chocolate.",                 { cura: 15 });
    _def("sanduiche", "Sanduíche",         "uso", _C, 7,  25, "comum",   "Lanche da lancheira.",                    { cura: 25 });
    _def("pirulito",  "Pirulito Arco-íris","uso", _C, 8,  30, "incomum", "Açúcar nas perninhas!",                   { cura: 10 }, { buffs: [ { stat: "vel", valor: 3, seg: 15 } ] });
    _def("chocolate", "Chocolate Quente",  "uso", _C, 9,  40, "incomum", "Esquenta o coração.",                     { cura: 20 }, { buffs: [ { stat: "regen", valor: 3, seg: 10 } ] });
    _def("algodao",   "Algodão-doce",      "uso", _C, 10, 35, "incomum", "Fofinho como uma nuvem.",                 { cura: 15 }, { buffs: [ { stat: "esquiva", valor: 20, seg: 15 } ] });
    _def("curativo",  "Curativo",          "uso", _C, 11, 40, "comum",   "Com desenho de dinossauro.",              { cura: 40 });
    _def("pocao_coragem","Poção de Coragem","uso",_C, 12, 60, "raro",    "Nada de medo do escuro!",                 { cura: 0  }, { buffs: [ { stat: "dano_pct", valor: 30, seg: 20 }, { stat: "defesa", valor: 5, seg: 20 } ] });
    _def("bala_goma", "Ursinhos de Goma",  "uso", _C, 13, 45, "incomum", "Mastigáveis e mágicos.",                  { cura: 25 }, { buffs: [ { stat: "crit", valor: 15, seg: 20 } ] });

    // ---------------- ARMAS ----------------
    _def("graveto",         "Graveto",            "arma", _W, 0,  5,  "comum",   "É só um graveto... por enquanto.",     { dano: 2 });
    _def("vassoura",        "Vassoura",           "arma", _W, 1,  10, "comum",   "Limpa o chão e os inimigos.",          { dano: 4 });
    _def("espada_plastico", "Espada de Plástico", "arma", _W, 2,  15, "comum",   "Faz um barulhinho legal.",             { dano: 5 });
    _def("espada_madeira",  "Espada de Madeira",  "arma", _W, 3,  25, "incomum", "Treinamento de cavaleiro.",            { dano: 7 });
    _def("espada_dourada",  "Espada Dourada",     "arma", _W, 4,  50, "raro",    "Brilha muito no sol.",                 { dano: 9, crit: 3 });
    _def("mata_fantasma",   "Mata-Fantasma",      "arma", _W, 7,  60, "epico",   "Feita de luz de abajur.",              { dano: 9 }, { inata: "fantasma" });
    _def("regua",           "Régua de Madeira",   "arma", _W, 8,  8,  "comum",   "Mede 30 centímetros de coragem.",      { dano: 3, vel: 0.5 });
    _def("guarda_chuva",    "Guarda-chuva",       "arma", _W, 9,  30, "incomum", "Bate e ainda protege.",                { dano: 5, defesa: 2 });
    _def("martelo",         "Martelo de Brinquedo","arma",_W, 10, 45, "raro",    "Pesadinho. Faz 'póin'.",               { dano: 11, vel: -1 });
    _def("varinha",         "Varinha Mágica",     "arma", _W, 11, 55, "raro",    "Plim! Plim!",                          { dano: 6 }, { inata: "estrela" });
    _def("espada_lapis",    "Espada de Lápis",    "arma", _W, 12, 80, "epico",   "Escreve a vitória.",                   { dano: 13 });
    _def("lanca_bolhas",    "Lança-Bolhas",       "arma", _W, 13, 35, "incomum", "Inimigos escorregam nas bolhas.",      { dano: 4 }, { inata: "nuvem" });
    _def("espada_pirulito", "Espada de Pirulito", "arma", _W, 14, 70, "epico",   "Doce, mas perigosa.",                  { dano: 8 }, { inata: "vampiro" });

    // ---------------- HOTBAR: NOVAS ARMAS, ARCOS E LUZES (spr_itens_ferramentas) ----------------
    // Vão na hotbar (1 2 3 4 / roda do mouse). Arma = golpe, arco = flecha, luz = clareia e acalma.
    var _F = spr_itens_ferramentas;
    _def("espada_ferro",    "Espada de Ferro",       "arma", _F, 0,  45,  "incomum",  "Pesada de verdade. Cuidado com o dedo.",   { dano: 10 });
    _def("espada_cristal",  "Espada de Cristal",     "arma", _F, 1,  90,  "raro",     "Brilha igual pedra de aquário.",          { dano: 12, crit: 5 }, { espada: { alcance: 1.15 } });
    _def("adaga_brinquedo", "Adaga de Brinquedo",    "arma", _F, 2,  18,  "comum",    "Pequena e rapidinha.",                    { dano: 4, vel: 1 },   { espada: { alcance: 0.8 } });
    _def("taco_beisebol",   "Taco de Beisebol",      "arma", _F, 3,  40,  "incomum",  "Home run nos monstros!",                  { dano: 9 },           { espada: { alcance: 1.3 } });
    _def("machadinha",      "Machadinha de Papelão", "arma", _F, 4,  35,  "incomum",  "Corta caixa, corta medo.",                { dano: 8, crit: 4 });
    _def("espada_laser",    "Espada Laser",          "arma", _F, 5,  160, "lendario", "Vrrrum! Faz barulho de filme.",           { dano: 15, crit: 6 }, { espada: { alcance: 1.35 }, inata: "fantasma" });

    _def("arco_madeira",    "Arco de Madeira",       "arco", _F, 6,  20,  "comum",    "O primeiro arco de todo aventureiro.",    { dano: 5 },           { arco: { vel: 12, flechas: 1, abertura: 0 } });
    _def("arco_galho",      "Arco de Galho",         "arco", _F, 7,  8,   "comum",    "Feito com um galho torto e barbante.",    { dano: 3 },           { arco: { vel: 10, flechas: 1, abertura: 0 } });
    _def("arco_ventosa",    "Arco de Ventosa",       "arco", _F, 8,  30,  "incomum",  "Flechas com ventosa: PLOC!",              { dano: 4, vel: 0.5 }, { arco: { vel: 14, flechas: 1, abertura: 0 } });
    _def("besta_brinquedo", "Besta de Brinquedo",    "arco", _F, 9,  70,  "raro",     "Atira longe e forte.",                    { dano: 9 },           { arco: { vel: 17, flechas: 1, abertura: 0 } });
    _def("arco_triplo",     "Arco Triplo",           "arco", _F, 10, 85,  "raro",     "Três flechas de uma vez!",                { dano: 5 },           { arco: { vel: 12, flechas: 3, abertura: 12 } });
    _def("arco_arco_iris",  "Arco-Íris",             "arco", _F, 11, 170, "lendario", "Cada flecha de uma cor.",                 { dano: 10, crit: 5 }, { arco: { vel: 16, flechas: 2, abertura: 8 }, inata: "estrela" });

    _def("lampada",         "Lâmpada",               "luz",  _F, 12, 25,  "comum",    "Ilumina em volta e espanta o medo.",      {},                    { luz: { raio: 200, estilo: "soft",    cor: make_color_rgb(255, 245, 200), intensidade: 0.85 } });
    _def("tocha",           "Tocha",                 "luz",  _F, 13, 15,  "comum",    "Fogo que balança. Não encoste no sofá!",  {},                    { luz: { raio: 240, estilo: "flicker", cor: make_color_rgb(255, 170, 80),  intensidade: 0.9 } });
    _def("lanterna",        "Lanterna",              "luz",  _F, 14, 45,  "incomum",  "Luz forte de pilha.",                     { vel: 0.5 },          { luz: { raio: 300, estilo: "soft",    cor: make_color_rgb(235, 245, 255), intensidade: 1 } });
    _def("lampiao",         "Lampião",               "luz",  _F, 15, 60,  "raro",     "Luz quentinha de acampamento.",           { vida: 10 },          { luz: { raio: 280, estilo: "flicker", cor: make_color_rgb(255, 210, 130), intensidade: 1 } });
    _def("pote_vagalumes",  "Pote de Vaga-lumes",    "luz",  _F, 16, 75,  "epico",    "Os vaga-lumes também te protegem.",       { defesa: 2 },         { luz: { raio: 230, estilo: "soft",    cor: make_color_rgb(220, 255, 140), intensidade: 0.9 }, inata: "coracao" });

    // ---------------- FERRAMENTAS DE COLETA (scr_coleta) ----------------
    // coleta: { tipo: "machado" (árvore) | "picareta" (pedra) | "pa" (montinho de terra), tier 1..3, forca (dano no objeto, vida 100) }
    var _C = spr_itens_coleta;
    _def("machado_madeira",   "Machado de Madeira",   "coleta", _C, 0, 10,  "comum",    "Corta árvores. Devagarinho.",               { dano: 2 }, { coleta: { tipo: "machado",  tier: 1, forca: 12 } });
    _def("machado_ferro",     "Machado de Ferro",     "coleta", _C, 1, 45,  "incomum",  "Corta árvores rapidinho.",                  { dano: 4 }, { coleta: { tipo: "machado",  tier: 2, forca: 25 } });
    _def("machado_diamante",  "Machado de Diamante",  "coleta", _C, 2, 150, "epico",    "Uma árvore em dois golpes!",                { dano: 7 }, { coleta: { tipo: "machado",  tier: 3, forca: 50 } });
    _def("picareta_madeira",  "Picareta de Madeira",  "coleta", _C, 3, 10,  "comum",    "Quebra pedras. Às vezes acha ferro.",       { dano: 2 }, { coleta: { tipo: "picareta", tier: 1, forca: 12 } });
    _def("picareta_ferro",    "Picareta de Ferro",    "coleta", _C, 4, 45,  "incomum",  "Acha mais ferro e até diamante.",           { dano: 4 }, { coleta: { tipo: "picareta", tier: 2, forca: 25 } });
    _def("picareta_diamante", "Picareta de Diamante", "coleta", _C, 5, 150, "epico",    "As pedras tremem de medo.",                 { dano: 7 }, { coleta: { tipo: "picareta", tier: 3, forca: 50 } });
    _def("pa_madeira",        "Pá de Madeira",        "coleta", _C, 6, 8,   "comum",    "Cava montinhos de terra.",                  { dano: 1 }, { coleta: { tipo: "pa",       tier: 1, forca: 15 } });
    _def("pa_ferro",          "Pá de Ferro",          "coleta", _C, 7, 40,  "incomum",  "Cava rápido e acha mais coisas.",           { dano: 3 }, { coleta: { tipo: "pa",       tier: 2, forca: 30 } });
    _def("pa_diamante",       "Pá de Diamante",       "coleta", _C, 8, 140, "epico",    "Tesouros escondidos aparecem!",             { dano: 6 }, { coleta: { tipo: "pa",       tier: 3, forca: 55 } });
    _def("diamante",          "Diamante",             "material", _C, 9, 60, "raro",    "Sai das pedras com picareta de ferro ou melhor.");

    // ---------------- ARMADURAS ----------------
    _def("cobertor",     "Cobertor",                "armadura", _A, 0, 10,  "comum",   "Nenhum monstro passa do cobertor.",  { defesa: 1, vida: 5 });
    _def("papelao",      "Armadura de Papelão",     "armadura", _A, 1, 20,  "comum",   "Feita com a caixa da geladeira.",    { defesa: 2 });
    _def("toalha",       "Toalhas Dobradas",        "armadura", _A, 2, 30,  "comum",   "Macias e cheirosas.",                { defesa: 3 });
    _def("capa_chuva",   "Capa de Chuva",           "armadura", _A, 3, 40,  "incomum", "Pula poça sem medo.",                { defesa: 4 });
    _def("casaco",       "Casaco Almofadado",       "armadura", _A, 4, 50,  "incomum", "Muito fofo e quentinho.",            { defesa: 5, vida: 10 });
    _def("travesseiro",  "Armadura de Travesseiro", "armadura", _A, 5, 60,  "raro",    "Proteção suprema da guerra de travesseiro.", { defesa: 6 }, { inata: "nuvem" });
    _def("super_capa",   "Capa de Super-Herói",     "armadura", _A, 6, 100, "epico",   "Sinta-se poderoso!",                 { defesa: 7, vel: 1 }, { inata: "forca" });
    _def("pijama_dino",  "Pijama de Dinossauro",    "armadura", _A, 7, 45,  "incomum", "RAWR! Muito assustador.",            { defesa: 4, vida: 20 }, { inata: "urso" });
    _def("cavaleiro",    "Fantasia de Cavaleiro",   "armadura", _A, 8, 80,  "raro",    "Brilhante como uma panela.",         { defesa: 9 });
    _def("astronauta",   "Macacão de Astronauta",   "armadura", _A, 9, 110, "epico",   "Pronto para o espaço sideral.",      { defesa: 8, vida: 15 }, { inata: "coracao" });

    // ---------------- CHAPÉUS (CABEÇA) — tema infância (spr_itens_cabeca) ----------------
    // Vão no 1º espaço de equipamento do personagem (antes era da arma; armas agora só na hotbar).
    var _K = spr_itens_cabeca;
    _def("bone",              "Boné Virado",                "cabeca", _K, 0,  8,   "comum",    "Aba pra trás = mais rápido.",              { defesa: 1, vel: 0.5 });
    _def("chapeu_pirata",     "Chapéu de Pirata de Jornal", "cabeca", _K, 1,  10,  "comum",    "Dobrado com o jornal de domingo. Arrr!",   { defesa: 2, crit: 2 });
    _def("coroa_papel",       "Coroa de Papel",             "cabeca", _K, 2,  12,  "comum",    "Rei ou rainha da festa de aniversário.",   { defesa: 1, vida: 10 });
    _def("capacete_bike",     "Capacete de Bicicleta",      "cabeca", _K, 3,  30,  "incomum",  "A mamãe mandou usar.",                     { defesa: 4 });
    _def("gorro_la",          "Gorro com Pompom",           "cabeca", _K, 4,  28,  "incomum",  "Quentinho até a ponta da orelha.",         { defesa: 2, vida: 15 });
    _def("capacete_panela",   "Capacete de Panela",         "cabeca", _K, 10, 35,  "incomum",  "Barulhento, mas aguenta tudo.",            { defesa: 6, vel: -0.5 });
    _def("orelhas_gato",      "Orelhinhas de Gato",         "cabeca", _K, 11, 32,  "incomum",  "Miau! Ágil como um gatinho.",              { defesa: 1, vel: 1.5, crit: 3 });
    _def("chapeu_bruxa",      "Chapéu de Bruxinha",         "cabeca", _K, 5,  55,  "raro",     "Abracadabra... estrelas de sorte!",        { defesa: 2 },            { inata: "estrela" });
    _def("tiara_unicornio",   "Tiara de Unicórnio",         "cabeca", _K, 6,  60,  "raro",     "Brilha e deixa tudo mais fofinho.",        { defesa: 3, vel: 1 },    { inata: "nuvem" });
    _def("capuz_dino",        "Capuz de Dinossauro",        "cabeca", _K, 7,  65,  "raro",     "RAWR! Os monstros ficam com medo.",        { defesa: 5, vida: 10 });
    _def("capacete_astronauta","Capacete de Astronauta",    "cabeca", _K, 8,  110, "epico",    "Respira tranquilo em qualquer planeta.",   { defesa: 7 },            { inata: "coracao" });
    _def("coroa_dourada",     "Coroa do Rei da Pracinha",   "cabeca", _K, 9,  160, "lendario", "Todo mundo obedece no escorregador.",      { defesa: 6, crit: 5 },   { inata: "forca" });

    // ---------------- CALÇADOS ----------------
    _def("sapato_velho",  "Sapato Velho",     "bota", _P, 0,  5,   "comum",    "Já viu dias melhores.",          { vel: 1 });
    _def("tenis_rasgado", "Tênis Rasgado",    "bota", _P, 1,  10,  "comum",    "Ainda serve.",                   { vel: 2 });
    _def("patins",        "Patins",           "bota", _P, 2,  60,  "raro",     "Velocidade máxima!",             { vel: 7 });
    _def("skate",         "Skate",            "bota", _P, 3,  40,  "raro",     "Radical!",                       { vel: 6 });
    _def("tenis_corrida", "Tênis de Corrida", "bota", _P, 4,  30,  "incomum",  "Feito para correr.",             { vel: 5 });
    _def("sapato_social", "Sapato Social",    "bota", _P, 5,  25,  "comum",    "Elegância no recreio.",          { vel: 4 });
    _def("meias_novas",   "Meias Novas",      "bota", _P, 6,  15,  "comum",    "Escorregam bem no piso.",        { vel: 3 });
    _def("meias_sorte",   "Meias da Sorte",   "bota", _P, 7,  30,  "incomum",  "Nunca foram lavadas.",           { vel: 2 }, { inata: "estrela" });
    _def("pantufa",       "Pantufa de Coelho","bota", _P, 8,  35,  "incomum",  "Pulinhos silenciosos.",          { vel: 3, defesa: 1 }, { inata: "nuvem" });
    _def("galocha",       "Galocha",          "bota", _P, 9,  20,  "comum",    "À prova de lama.",               { vel: 2, defesa: 3 });
    _def("tenis_luz",     "Tênis de Luzinha", "bota", _P, 10, 90,  "epico",    "Pisca a cada passo!",            { vel: 6 }, { inata: "raio" });
    _def("botas_mola",    "Botas de Mola",    "bota", _P, 11, 120, "lendario", "Boing! Boing!",                  { vel: 8 }, { inata: "nuvem" });

    // ---------------- MATERIAIS ----------------
    _def("madeira",     "Madeira",        "material", _M, 0,  2,  "comum",   "Material essencial para construções.");
    _def("pedra",       "Pedra",          "material", _M, 1,  2,  "comum",   "Material bruto e duro.");
    _def("erva",        "Erva Vermelha",  "material", _M, 2,  4,  "comum",   "Planta com propriedades medicinais.");
    _def("frasco",      "Frasco Vazio",   "material", _M, 3,  5,  "comum",   "Usado para guardar líquidos.");
    _def("ferro",       "Barra de Ferro", "material", _M, 4,  15, "incomum", "Ferro fundido, ótimo para armas.");
    _def("couro",       "Couro",          "material", _M, 5,  10, "comum",   "Pele resistente para armaduras.");
    _def("ouro",        "Barra de Ouro",  "material", _M, 6,  30, "raro",    "Brilha mais que o sol.");
    _def("la",          "Novelo de Lã",   "material", _M, 7,  6,  "comum",   "A vovó tricota com isso.");
    _def("botao",       "Botão Colorido", "material", _M, 8,  4,  "comum",   "Caiu de algum casaco.");
    _def("giz",         "Giz de Cera",    "material", _M, 9,  5,  "comum",   "Desenha nas paredes (não conte pra mamãe).");
    _def("gude",        "Bolinhas de Gude","material",_M, 10, 8,  "incomum", "Rolam pra baixo do sofá.");
    _def("pena",        "Pena Macia",     "material", _M, 11, 6,  "comum",   "Faz cócegas.");
    _def("po_estrela",  "Pó de Estrela",  "material", _M, 12, 25, "raro",    "Usado para MELHORAR equipamentos.");
    _def("pilha",       "Pilha",          "material", _M, 13, 12, "incomum", "Dá energia aos brinquedos.");
    _def("papel",       "Papel Colorido", "material", _M, 14, 3,  "comum",   "Base para fazer adesivos.");
    _def("vela",        "Vela",           "material", spr_itens_invent_passivo, 0, 8, "comum", "Uma velinha para iluminar o escuro.");

    // ---------------- COLOCÁVEIS ----------------
    // TODO: trocar spr_movel_bau (placeholder, mesmo sprite dos móveis de casa) por sprites
    // próprios (menores, visual de "baú portátil") quando forem criados na IDE — ver escala
    // abaixo, que já diminui o placeholder pra não ficar do tamanho de um móvel de casa.
    // extra: { slots: espaços de guarda, escala: tamanho do sprite no mundo }
    _def("bau_madeira",   "Baú de Madeira",   "colocavel", spr_movel_bau, 0, 0, "comum",
         "Craftado para guardar itens. Use e clique no chão para posicionar.", {}, { slots: 6,  escala: 0.55 });
    _def("bau_ferro",     "Baú de Ferro",     "colocavel", spr_movel_bau, 0, 0, "incomum",
         "Mais resistente, guarda mais itens.",                                {}, { slots: 12, escala: 0.70 });
    _def("bau_ouro",      "Baú de Ouro",      "colocavel", spr_movel_bau, 0, 0, "raro",
         "Reforçado com ouro, guarda bem mais itens.",                        {}, { slots: 18, escala: 0.85 });
    _def("bau_lendario",  "Baú Lendário",     "colocavel", spr_movel_bau, 0, 0, "lendario",
         "O maior baú portátil que existe.",                                  {}, { slots: 24, escala: 1.0  });

    // ---------------- ADESIVOS (passivas) ----------------
    // Arraste um adesivo até um equipamento para colar a passiva nele.
    // (só as passivas que têm adesivo; frame = ad_frame no spr_itens_craft)
    var _n = array_length(global.passivas_ordem);
    for (var _i = 0; _i < _n; _i++) {
        var _pid = global.passivas_ordem[_i];
        var _pd  = global.passivas_db[$ _pid];
        if (_pd.adesivo == "") continue;
        var _rar = (_pid == "fantasma" || _pid == "vampiro" || _pid == "bum") ? "raro" : "incomum";
        _def(_pd.adesivo, "Adesivo: " + _pd.nome, "adesivo", _M, _pd.ad_frame, 40, _rar,
             "Arraste até um equipamento para colar a passiva.", {}, { passiva: _pid });
    }

    // Todo equipamento tem uma passiva própria: se o catálogo não deu, ganha a do tipo
    for (var _i = 0; _i < array_length(global.itens_ordem); _i++) {
        var _di = global.itens_db[$ global.itens_ordem[_i]];
        if (item_tipo_e_equipamento(_di.tipo) && _di.inata == "") _di.inata = item_passiva_padrao(_di.tipo);
    }
}

/// Retorna a struct do item (ou undefined)
function item_db(_id) {
    if (!variable_global_exists("itens_db")) return undefined;
    if (!is_string(_id)) return undefined;
    return global.itens_db[$ _id];
}

/// Busca o ID pelo nome ("Madeira" -> "madeira"). Aceita o próprio ID.
function item_id_por_nome(_nome) {
    if (!is_string(_nome)) return undefined;
    if (!is_undefined(item_db(_nome))) return _nome;
    var _n = array_length(global.itens_ordem);
    for (var _i = 0; _i < _n; _i++) {
        var _d = global.itens_db[$ global.itens_ordem[_i]];
        if (_d.nome == _nome) return _d.id;
    }
    return undefined;
}

/// Atributo do item num nível. Valores negativos não crescem.
function item_stat(_id, _stat, _nivel = 1) {
    var _d = item_db(_id);
    if (is_undefined(_d) || !variable_struct_exists(_d.stats, _stat)) return 0;
    var _b = _d.stats[$ _stat];
    if (_stat == "cura" || _b <= 0) return _b;
    return _b * (1 + ITEM_CRESC_STAT * (max(1, floor(_nivel)) - 1));
}

/// Quantas passivas (sorteadas + adesivos) o item aceita — sempre ITEM_PASSIVAS_MAX
function item_slots_passiva(_nivel) {
    return ITEM_PASSIVAS_MAX;
}

#endregion

#region ---------- RECEITAS ----------

function itens_definir_receitas() {
    global.receitas_craft = [];
    var _r = function(_resultado, _ings, _qtd = 1) {
        var _d = item_db(_resultado);
        if (is_undefined(_d)) { show_debug_message("ERRO NO CRAFT: item '" + string(_resultado) + "' não existe!"); return; }
        var _lista = [];
        var _nomes = variable_struct_get_names(_ings);
        for (var _i = 0; _i < array_length(_nomes); _i++) {
            if (is_undefined(item_db(_nomes[_i]))) show_debug_message("ERRO NO CRAFT: ingrediente '" + _nomes[_i] + "' não existe!");
            array_push(_lista, { item: _nomes[_i], qtd: _ings[$ _nomes[_i]] });
        }
        array_push(global.receitas_craft, {
            resultado: _resultado, spr_resultado: _d.spr, idx_resultado: _d.img,
            qtd_resultado: _qtd, ingredientes: _lista
        });
    };

    // --- Armas ---
    _r("graveto",         { madeira: 1 });
    _r("regua",           { madeira: 2, giz: 1 });
    _r("vassoura",        { madeira: 3, erva: 2 });
    _r("espada_madeira",  { madeira: 2, pedra: 1 });
    _r("guarda_chuva",    { madeira: 1, papel: 2, ferro: 1 });
    _r("lanca_bolhas",    { frasco: 2, pilha: 1, botao: 1 });
    _r("martelo",         { madeira: 2, ferro: 2, giz: 1 });
    _r("varinha",         { madeira: 1, po_estrela: 2, pena: 1 });
    _r("espada_dourada",  { ouro: 3, madeira: 1, couro: 1 });
    _r("mata_fantasma",   { ferro: 3, ouro: 1, frasco: 1, pilha: 1 });
    _r("espada_pirulito", { ouro: 2, papel: 2, erva: 2 });
    _r("espada_lapis",    { madeira: 3, giz: 3, ouro: 1 });
    _r("espada_ferro",    { ferro: 3, madeira: 1 });
    _r("adaga_brinquedo", { madeira: 1, papel: 1 });
    _r("taco_beisebol",   { madeira: 4 });
    _r("machadinha",      { papel: 3, madeira: 1, ferro: 1 });
    // --- Arcos ---
    _r("arco_galho",      { madeira: 2 });
    _r("arco_madeira",    { madeira: 3, la: 1 });
    _r("arco_ventosa",    { madeira: 2, couro: 1, botao: 1 });
    _r("besta_brinquedo", { madeira: 3, ferro: 2, la: 1 });
    _r("arco_triplo",     { madeira: 4, la: 2, ferro: 1 });
    // --- Luzes ---
    _r("tocha",           { madeira: 2, erva: 1 });
    _r("lampada",         { frasco: 1, ferro: 1, pilha: 1 });
    _r("lanterna",        { ferro: 2, pilha: 2, frasco: 1 });
    _r("lampiao",         { ferro: 2, frasco: 1, erva: 2 });
    // --- Armaduras ---
    _r("cobertor",        { la: 2, couro: 1 });
    _r("papelao",         { papel: 3, couro: 1 });
    _r("casaco",          { la: 3, botao: 2 });
    _r("pijama_dino",     { la: 3, botao: 1, couro: 2 });
    _r("cavaleiro",       { ferro: 4, couro: 2, botao: 2 });
    _r("super_capa",      { la: 4, ouro: 1, po_estrela: 1 });
    _r("astronauta",      { ferro: 2, pilha: 2, la: 2, gude: 1 });
    // --- Chapéus ---
    _r("bone",            { la: 1, papel: 1 });
    _r("chapeu_pirata",   { papel: 3 });
    _r("coroa_papel",     { papel: 2, botao: 1 });
    _r("capacete_bike",   { ferro: 1, couro: 1, botao: 1 });
    _r("gorro_la",        { la: 3 });
    _r("capacete_panela", { ferro: 3 });
    _r("orelhas_gato",    { la: 2, couro: 1 });
    _r("chapeu_bruxa",    { la: 2, po_estrela: 1, papel: 1 });
    _r("tiara_unicornio", { ouro: 1, po_estrela: 1, la: 1 });
    _r("capuz_dino",      { la: 3, couro: 2, botao: 1 });
    // --- Calçados ---
    _r("galocha",         { couro: 2, papel: 1 });
    _r("pantufa",         { la: 2, pena: 1 });
    _r("tenis_corrida",   { couro: 2, ferro: 1 });
    _r("tenis_luz",       { couro: 2, pilha: 2, gude: 1 });
    _r("botas_mola",      { ferro: 3, couro: 1, pilha: 2 });
    // --- Consumíveis ---
    _r("vitamina",        { erva: 3, frasco: 1 });
    _r("curativo",        { papel: 1, erva: 1 });
    _r("pocao_coragem",   { frasco: 1, erva: 2, po_estrela: 1 });
    // --- Materiais ---
    _r("papel",           { madeira: 1 }, 2);
    _r("po_estrela",      { gude: 1, giz: 1, pena: 1 }, 2);
    // --- Colocáveis --- (cada baú é mais caro que o anterior, exige o material do nível antes)
    _r("bau_madeira",     { madeira: 6, pedra: 2 });
    _r("bau_ferro",       { madeira: 6, ferro: 4, pedra: 2 });
    _r("bau_ouro",        { ferro: 6, ouro: 3, couro: 2 });
    _r("bau_lendario",    { ouro: 6, po_estrela: 3, ferro: 4, couro: 2 });
    // --- Adesivos ---
    _r("ad_coracao",      { papel: 1, erva: 2 });
    _r("ad_estrela",      { papel: 1, po_estrela: 1, giz: 1 });
    _r("ad_forca",        { papel: 1, ferro: 1, pedra: 1 });
    _r("ad_escudo",       { papel: 1, ferro: 1, couro: 1 });
    _r("ad_raio",         { papel: 1, pilha: 1 });
    _r("ad_vampiro",      { papel: 1, erva: 1, frasco: 1, giz: 1 });
    _r("ad_nuvem",        { papel: 1, la: 1, pena: 1 });
    _r("ad_urso",         { papel: 1, la: 2, botao: 1 });
    _r("ad_fantasma",     { papel: 1, pilha: 1, frasco: 1, giz: 1 });
    _r("ad_bum",          { papel: 1, po_estrela: 1, gude: 1 });

    // Ferramentas de coleta: madeira -> ferro -> diamante
    _r("machado_madeira",   { madeira: 4 });
    _r("picareta_madeira",  { madeira: 5 });
    _r("pa_madeira",        { madeira: 3 });
    _r("machado_ferro",     { madeira: 2, ferro: 3 });
    _r("picareta_ferro",    { madeira: 2, ferro: 3 });
    _r("pa_ferro",          { madeira: 2, ferro: 2 });
    _r("machado_diamante",  { madeira: 2, diamante: 3 });
    _r("picareta_diamante", { madeira: 2, diamante: 3 });
    _r("pa_diamante",       { madeira: 2, diamante: 2 });
}

#endregion

#region ---------- INICIALIZAÇÃO (compatível com o código antigo) ----------

/// @desc Cria TODA a database. Mantém global.lista_itens no formato antigo:
/// [0:spr, 1:nome, 2:desc, 3:cura, 4:dano, 5:arm, 6:vel, 7:img_idx, 8:tipo, 9:preco, 10:qtd, 11:id]
function criar_lista_itens_padronizados() {
    itens_definir_passivas();
    itens_definir_catalogo();
    itens_definir_receitas();

    if (variable_global_exists("lista_itens") && ds_exists(global.lista_itens, ds_type_list)) {
        ds_list_destroy(global.lista_itens);
    }
    global.lista_itens = ds_list_create();
    var _n = array_length(global.itens_ordem);
    for (var _i = 0; _i < _n; _i++) {
        var _d = global.itens_db[$ global.itens_ordem[_i]];
        var _cura = variable_struct_exists(_d.stats, "cura") ? _d.stats.cura : -1;
        var _dano = variable_struct_exists(_d.stats, "dano") ? _d.stats.dano : -1;
        var _arm  = variable_struct_exists(_d.stats, "defesa") ? _d.stats.defesa : -1;
        var _vel  = variable_struct_exists(_d.stats, "vel") ? _d.stats.vel : -1;
        ds_list_add(global.lista_itens, [_d.spr, _d.nome, _d.desc, _cura, _dano, _arm, _vel, _d.img, _d.tipo, _d.preco, 1, _d.id]);
    }

    if (!variable_global_exists("equip_stats")) global.equip_stats = equip_stats_zero();
    if (!variable_global_exists("buffs_ativos")) global.buffs_ativos = [];
    if (!variable_global_exists("inventario_cheio")) global.inventario_cheio = false;
}

/// @desc Busca o array antigo pelo sprite + frame
function buscar_dados_do_item(_spr, _idx) {
    var _tam = ds_list_size(global.lista_itens);
    for (var _i = 0; _i < _tam; _i++) {
        var _it = global.lista_itens[| _i];
        if (_it[0] == _spr && _it[7] == _idx) return _it;
    }
    return undefined;
}

/// @desc Busca o array antigo pelo NOME (ou ID)
function buscar_dados_por_nome(_nome) {
    var _tam = ds_list_size(global.lista_itens);
    for (var _i = 0; _i < _tam; _i++) {
        var _it = global.lista_itens[| _i];
        if (_it[1] == _nome || _it[11] == _nome) return _it;
    }
    return undefined;
}

#endregion

#region ---------- ADICIONAR ITENS NA MOCHILA ----------

/// Preenche um slot da grid com todos os dados do item no nível
function item_slot_preencher(_grid, _slot, _id, _qtd, _nivel = 1, _passivas = undefined, _xp = 0) {
    var _d = item_db(_id);
    if (is_undefined(_d)) return;
    if (!is_array(_passivas)) _passivas = [];
    _grid[# INFOS.ITEM,       _slot] = _id;
    _grid[# INFOS.QUANTIDADE, _slot] = _qtd;
    _grid[# INFOS.SPRITE,     _slot] = _d.spr;
    _grid[# INFOS.IMAGE_IND,  _slot] = _d.img;
    _grid[# INFOS.NOME,       _slot] = _d.nome;
    _grid[# INFOS.DESCRICAO,  _slot] = _d.desc;
    _grid[# INFOS.TIPO,       _slot] = _d.tipo;
    _grid[# INFOS.PRECO,      _slot] = _d.preco;
    _grid[# INFOS.SALA_X,     _slot] = -1;
    _grid[# INFOS.SALA_Y,     _slot] = -1;
    _grid[# INFOS.POS_X,      _slot] = -1;
    _grid[# INFOS.POS_Y,      _slot] = -1;
    _grid[# INFOS.NIVEL,      _slot] = max(1, floor(_nivel));
    _grid[# INFOS.PASSIVAS,   _slot] = _passivas;
    _grid[# INFOS.XP,         _slot] = is_real(_xp) ? _xp : 0;
    item_slot_atualizar_stats(_grid, _slot);
}

/// Recalcula as colunas antigas (DANO/ARMADURA/...) com o nível atual
function item_slot_atualizar_stats(_grid, _slot) {
    var _id  = _grid[# INFOS.ITEM, _slot];
    var _lvl = _grid[# INFOS.NIVEL, _slot];
    if (is_undefined(item_db(_id))) return;
    _grid[# INFOS.DANO,       _slot] = item_stat(_id, "dano", _lvl);
    _grid[# INFOS.ARMADURA,   _slot] = item_stat(_id, "defesa", _lvl);
    _grid[# INFOS.VELOCIDADE, _slot] = item_stat(_id, "vel", _lvl);
    _grid[# INFOS.CURA,       _slot] = item_stat(_id, "cura", _lvl);
}

/// Quantos slots da mochila (sem os de equipamento)
function inventory_bag_slots() {
    if (instance_exists(obj_inventario)) return obj_inventario.total_slots;
    return ds_grid_height(global.grid_itens) - 3 - HOTBAR_SLOTS; // 3 equipamentos + hotbar no fim da grid
}

/// @desc Adiciona um item pelo ID. Retorna true se coube tudo.
/// Equipamento novo (sem _passivas) nasce com 0..3 passivas sorteadas (passivas_sortear).
function inventory_add(_id, _qtd = 1, _nivel = 1, _passivas = undefined, _xp = 0) {
    var _d = item_db(_id);
    if (is_undefined(_d) || _qtd <= 0) return false;
    var _grid = global.grid_itens;
    var _bag  = inventory_bag_slots();

    if (_d.stack) {
        for (var _i = 0; _i < _bag; _i++) {
            if (_grid[# INFOS.ITEM, _i] == _id) {
                _grid[# INFOS.QUANTIDADE, _i] += _qtd;
                inventory_pos_mudanca();
                return true;
            }
        }
        // a pilha pode estar na hotbar (consumível arrastado para lá)
        for (var _h = 0; _h < HOTBAR_SLOTS; _h++) {
            var _hs = hotbar_slot(_h);
            if (_hs < ds_grid_height(_grid) && _grid[# INFOS.ITEM, _hs] == _id) {
                _grid[# INFOS.QUANTIDADE, _hs] += _qtd;
                inventory_pos_mudanca();
                return true;
            }
        }
        var _vazio = inventory_find_empty_slot();
        if (_vazio == -1) { global.inventario_cheio = true; inventory_msg("Mochila cheia!", c_red); return false; }
        item_slot_preencher(_grid, _vazio, _id, _qtd, 1, []);
    } else {
        repeat (_qtd) {
            var _vazio = inventory_find_empty_slot();
            if (_vazio == -1) { global.inventario_cheio = true; inventory_msg("Mochila cheia!", c_red); return false; }
            var _pas = is_array(_passivas) ? array_create(array_length(_passivas)) : passivas_sortear(_d.tipo, _d.inata);
            if (is_array(_passivas)) array_copy(_pas, 0, _passivas, 0, array_length(_passivas));
            item_slot_preencher(_grid, _vazio, _id, 1, _nivel, _pas, _xp);
        }
    }
    inventory_pos_mudanca();
    return true;
}

/// Chamado depois que a mochila muda (atualiza craft e flag de cheio)
function inventory_pos_mudanca() {
    global.inventario_cheio = (inventory_find_empty_slot() == -1);
    if (instance_exists(obj_inventario)) atualizar_crafts_disponiveis();
}

/// @desc (ANTIGA) Adiciona item passando todos os campos. Mantida p/ compatibilidade.
/// Se _item for um ID da database, usa o sistema novo.
function adicionar_item_invent(_item, _quantidade, _sprite, _nome, _descricao, _sala_x = -1, _sala_y = -1, _pos_x = -1, _pos_y = -1, _dano = 0, _armadura = 0, _velocidade = 0, _cura = 0, _tipo = -1, _ind = 0, _preco = 0) {
    var _id = item_id_por_nome(_item);
    if (is_undefined(_id)) _id = item_id_por_nome(_nome);
    if (!is_undefined(_id)) return inventory_add(_id, _quantidade);

    // Item que não está na database (legado)
    var _grid = global.grid_itens;
    var _bag  = inventory_bag_slots();
    for (var _i = 0; _i < _bag; _i++) {
        if (_grid[# INFOS.ITEM, _i] == _item && _grid[# INFOS.SPRITE, _i] == _sprite) {
            _grid[# INFOS.QUANTIDADE, _i] += _quantidade;
            return true;
        }
    }
    var _s = inventory_find_empty_slot();
    if (_s == -1) { global.inventario_cheio = true; return false; }
    _grid[# INFOS.ITEM, _s] = _item;           _grid[# INFOS.QUANTIDADE, _s] = _quantidade;
    _grid[# INFOS.SPRITE, _s] = _sprite;       _grid[# INFOS.NOME, _s] = _nome;
    _grid[# INFOS.DESCRICAO, _s] = _descricao; _grid[# INFOS.DANO, _s] = _dano;
    _grid[# INFOS.ARMADURA, _s] = _armadura;   _grid[# INFOS.VELOCIDADE, _s] = _velocidade;
    _grid[# INFOS.CURA, _s] = _cura;           _grid[# INFOS.TIPO, _s] = _tipo;
    _grid[# INFOS.IMAGE_IND, _s] = _ind;       _grid[# INFOS.PRECO, _s] = _preco;
    _grid[# INFOS.NIVEL, _s] = 1;              _grid[# INFOS.PASSIVAS, _s] = [];
    inventory_pos_mudanca();
    return true;
}

/// @desc Dá um item ao jogador pelo nome OU id. (_enum_id é ignorado, mantido p/ compatibilidade)
function dar_item_ao_jogador(_nome_item, _quantidade, _enum_id = -1) {
    var _id = item_id_por_nome(_nome_item);
    if (is_undefined(_id)) {
        show_debug_message("ERRO: O item '" + string(_nome_item) + "' não foi encontrado na Database!");
        return false;
    }
    return inventory_add(_id, _quantidade);
}

/// @desc Pega um obj_item do chão. Retorna true se coube.
function inventory_pegar_instancia(_inst) {
    var _id = variable_instance_exists(_inst, "item_id") ? _inst.item_id : "";
    if (is_undefined(item_db(_id))) {
        var _arr = buscar_dados_do_item(_inst.sprite_index, _inst.image_index);
        if (!is_undefined(_arr)) _id = _arr[11];
    }
    if (!is_undefined(item_db(_id))) {
        var _nv  = variable_instance_exists(_inst, "nivel") ? _inst.nivel : 1;
        var _pas = variable_instance_exists(_inst, "passivas") ? _inst.passivas : [];
        var _xpi = variable_instance_exists(_inst, "xp_item") ? _inst.xp_item : 0;
        return inventory_add(_id, max(1, _inst.quantidade), _nv, _pas, _xpi);
    }
    return adicionar_item_invent(_inst.image_index, _inst.quantidade, _inst.sprite_index, _inst.nome, _inst.descricao, _inst.sala_x, _inst.sala_y, _inst.pos_x, _inst.pos_y, _inst.dano, _inst.armadura, _inst.velocidade, _inst.cura, _inst.tipo, _inst.ind, _inst.preco);
}

#endregion

#region ---------- LOJA ----------

/// @desc Compra um item da loja baseado no slot selecionado
function comprar_item_loja(_slot_index) {
    var _grid = inventario_venda;
    if (_slot_index < 0 || _slot_index >= ds_grid_height(_grid)) return;
    if (_grid[# INFOS.ITEM, _slot_index] == -1) return;

    var _preco = _grid[# INFOS.PRECO, _slot_index];
    if (global.moedas < _preco) { show_debug_message("Moedas insuficientes!"); return; }

    var _id = item_id_por_nome(_grid[# INFOS.NOME, _slot_index]);
    var _ok = false;
    if (!is_undefined(_id)) _ok = inventory_add(_id, 1);
    if (!_ok) return; // mochila cheia: não cobra

    global.moedas -= _preco;
    _grid[# INFOS.ITEM, _slot_index] = -1;       _grid[# INFOS.QUANTIDADE, _slot_index] = 0;
    _grid[# INFOS.SPRITE, _slot_index] = -1;     _grid[# INFOS.NOME, _slot_index] = "";
    _grid[# INFOS.DESCRICAO, _slot_index] = "";  _grid[# INFOS.DANO, _slot_index] = 0;
    _grid[# INFOS.ARMADURA, _slot_index] = 0;    _grid[# INFOS.VELOCIDADE, _slot_index] = 0;
    _grid[# INFOS.CURA, _slot_index] = 0;        _grid[# INFOS.TIPO, _slot_index] = -1;
    _grid[# INFOS.IMAGE_IND, _slot_index] = 0;   _grid[# INFOS.PRECO, _slot_index] = 0;
    global.item_selecionado_venda = -1;
}

#endregion

#region ---------- DROPS NO MUNDO ----------

/// Cria o obj_item no mundo já configurado e salvo na sala
function item_criar_no_mundo(_x, _y, _id, _qtd, _nivel = 1, _passivas = undefined, _prof = undefined, _xp = 0) {
    var _d = item_db(_id);
    if (is_undefined(_d)) return noone;
    var _inst = layer_exists("Instances_itens")
        ? instance_create_layer(_x, _y, "Instances_itens", obj_item)
        : instance_create_depth(_x, _y, -_y, obj_item);

    var _pas = is_array(_passivas) ? [] : passivas_sortear(_d.tipo, _d.inata); // item novo: passivas sorteadas
    if (is_array(_passivas)) { _pas = array_create(array_length(_passivas)); array_copy(_pas, 0, _passivas, 0, array_length(_passivas)); }

    with (_inst) {
        item_id      = _id;
        nivel        = _nivel;
        passivas     = _pas;
        xp_item      = _xp;
        sprite_index = _d.spr;
        image_index  = _d.img;
        image_speed  = 0;
        ind          = _d.img;
        nome         = _d.nome;
        descricao    = _d.desc;
        dano         = item_stat(_id, "dano", _nivel);
        armadura     = item_stat(_id, "defesa", _nivel);
        velocidade   = item_stat(_id, "vel", _nivel);
        cura         = item_stat(_id, "cura", _nivel);
        tipo         = _d.tipo;
        preco        = _d.preco;
        quantidade   = _qtd;
        sala_x       = global.current_sala[0];
        sala_y       = global.current_sala[1];
        pos_x        = _x;
        pos_y        = _y;
        profundidade = is_undefined(_prof) ? -_y : _prof;
        depth        = profundidade;
    }
    salvar_item(_inst.sala_x, _inst.sala_y, _x, _y, _inst);
    return _inst;
}

/// Sorteia passiva/nível de um equipamento que caiu no chão
function item_sortear_extras(_id) {
    var _d = item_db(_id);
    var _r = { nivel: 1, passivas: [] };
    if (is_undefined(_d) || !item_tipo_e_equipamento(_d.tipo)) return _r;
    if (random(1) < 0.15) _r.nivel = 2;
    _r.passivas = passivas_sortear(_d.tipo, _d.inata); // 0..3 passivas aleatórias
    return _r;
}

/// @desc Drop aleatório por tipo, ponderado pela RARIDADE do item
/// @arg _raridade chance (0-100) de NÃO dropar nada
/// @arg _tipo_filtro "uso", "arma", "armadura", "bota", "material", "adesivo" ou "qualquer"
function criar_drop_aleatorio(_pos_x, _pos_y, _prof, _raridade, _tipo_filtro) {
    if (random(100) < _raridade) return;

    var _ops = [];
    var _total = 0;
    var _n = array_length(global.itens_ordem);
    for (var _i = 0; _i < _n; _i++) {
        var _d = global.itens_db[$ global.itens_ordem[_i]];
        var _ok = (_tipo_filtro == "qualquer" || _d.tipo == _tipo_filtro);
        if (_tipo_filtro == "material" && _d.tipo == "adesivo") _ok = true; // adesivos raros saem de caixas de material
        if (!_ok) continue;
        var _peso = item_raridade(_d.raridade).peso;
        if (_d.tipo == "adesivo") _peso *= 0.25;
        array_push(_ops, [_d.id, _peso]);
        _total += _peso;
    }
    if (_total <= 0) return;

    var _roll = random(_total);
    var _acc = 0;
    var _id = _ops[0][0];
    for (var _i = 0; _i < array_length(_ops); _i++) {
        _acc += _ops[_i][1];
        if (_roll < _acc) { _id = _ops[_i][0]; break; }
    }
    var _ex = item_sortear_extras(_id);
    item_criar_no_mundo(_pos_x, _pos_y, _id, 1, _ex.nivel, _ex.passivas, _prof - 1);
}

// --- Wrappers antigos ---
function criar_item_aleatorio_ativos(_x, _y, _prof, _rar)             { criar_drop_aleatorio(_x, _y, _prof, _rar, "uso"); }
function criar_item_aleatorio_passivos_armadura(_x, _y, _prof, _rar)  { criar_drop_aleatorio(_x, _y, _prof, _rar, "armadura"); }
function criar_item_aleatorio_passivos_arma(_x, _y, _prof, _rar)      { criar_drop_aleatorio(_x, _y, _prof, _rar, "arma"); }
function criar_item_aleatorio_passivos_pe(_x, _y, _prof, _rar)        { criar_drop_aleatorio(_x, _y, _prof, _rar, "bota"); }
function criar_item_aleatorio_material(_x, _y, _prof, _rar)           { criar_drop_aleatorio(_x, _y, _prof, _rar, "material"); }
function criar_item_aleatorio_adesivo(_x, _y, _prof, _rar)            { criar_drop_aleatorio(_x, _y, _prof, _rar, "adesivo"); }

#endregion

#region ---------- PERSISTÊNCIA DOS ITENS NO CHÃO ----------

function coletar_item(_x, _y, _sala_atual) {
    var _sala_id = string(_sala_atual[0]) + "_" + string(_sala_atual[1]);
    var _map_drop = global.sala_com_item_drop;
    if (ds_map_exists(_map_drop, _sala_id)) {
        var _lista = ds_map_find_value(_map_drop, _sala_id);
        for (var _i = 0; _i < ds_list_size(_lista); _i++) {
            var _info = _lista[| _i];
            if (_info[0] == _x && _info[1] == _y) { ds_list_delete(_lista, _i); break; }
        }
    }
}

function salvar_item(_sala_x, _sala_y, _pos_x, _pos_y, _inst) {
    var _sala_id = string(_sala_x) + "_" + string(_sala_y);
    var _lista;
    if (ds_map_exists(global.sala_com_item_drop, _sala_id)) {
        _lista = ds_map_find_value(global.sala_com_item_drop, _sala_id);
    } else {
        _lista = ds_list_create();
        ds_map_add(global.sala_com_item_drop, _sala_id, _lista);
    }
    var _id  = variable_instance_exists(_inst, "item_id")  ? _inst.item_id  : "";
    var _nv  = variable_instance_exists(_inst, "nivel")    ? _inst.nivel    : 1;
    var _pas = variable_instance_exists(_inst, "passivas") ? _inst.passivas : [];
    var _xpi = variable_instance_exists(_inst, "xp_item")  ? _inst.xp_item  : 0;
    ds_list_add(_lista, [
        _pos_x, _pos_y,
        _inst.sprite_index, _inst.image_index,
        _inst.quantidade, _inst.nome, _inst.descricao,
        _inst.dano, _inst.armadura, _inst.velocidade, _inst.cura,
        _inst.tipo, _inst.ind,
        _inst.sala_x, _inst.sala_y,
        _inst.pos_x, _inst.pos_y,
        _inst.profundidade, _inst.preco,
        _id, _nv, _pas,                      // [19] id  [20] nível  [21] passivas
        _xpi                                 // [22] XP do item
    ]);
}

function recriar_item_dropado(_sala_x, _sala_y) {
    var _sala_id = string(_sala_x) + "_" + string(_sala_y);
    if (!ds_map_exists(global.sala_com_item_drop, _sala_id)) return;
    var _lista = ds_map_find_value(global.sala_com_item_drop, _sala_id);
    for (var _i = 0; _i < ds_list_size(_lista); _i++) {
        var _d = _lista[| _i];
        var _inst = instance_create_depth(_d[0], _d[1], _d[17], obj_item);
        with (_inst) {
            sprite_index = _d[2];  image_index = _d[3];  image_speed = 0;
            quantidade   = _d[4];  nome        = _d[5];  descricao   = _d[6];
            dano         = _d[7];  armadura    = _d[8];  velocidade  = _d[9];
            cura         = _d[10]; tipo        = _d[11]; ind         = _d[12];
            sala_x       = _d[13]; sala_y      = _d[14];
            pos_x        = _d[15]; pos_y       = _d[16];
            profundidade = _d[17]; depth       = _d[17];
            preco        = _d[18];
            if (array_length(_d) > 21) { item_id = _d[19]; nivel = _d[20]; passivas = _d[21]; }
            xp_item = (array_length(_d) > 22) ? _d[22] : 0;
        }
    }
}

#endregion

#region ---------- BAÚ PORTÁTIL (COLOCÁVEL NO CHÃO, CASA OU MUNDO ABERTO) ----------
// [O QUE]: Item "colocavel" (ver catálogo acima) craftado, usado no inventário e plantado
//          numa célula do grid. Funciona dentro das casas (room Fase_BEBE) e fora delas
//          (mundo aberto Fase_vamp ou qualquer outra room).
// [ONDE FICA SALVO] (bau_lista_atual):
//   - Casa : global.sala_com_bau["x_y"] -> ds_list. Esse mapa está em casa_mapas_salvos()
//            (spr_fase_criation), então é salvo junto com a seed da casa e volta igual em
//            cada visita (casa_restaurar). Antes ele era limpo ao entrar na casa.
//   - Fora : global.baus_fora[nome da room] -> ds_list. reset_level_data nunca mexe nele;
//            os baús voltam no Create do obj_control_vamp (recriar_baus).
//   Cada baú é um struct { x, y (pé: centro embaixo), cw (largura em células), item_id,
//   slots, spr, escala, grid }. O ds_grid dos itens é guardado por referência, então
//   guardar/retirar item já atualiza o save.
// [COMO] : inventory_use_item() -> colocar_bau_iniciar() -> obj_player (Step / Draw End)
//          mostra a pegada no grid seguindo o mouse -> clique confirma em colocar_bau_confirmar().
//          A UI (Baú | Mochila) é bau_ui_step() (obj_inventario Step) + bau_ui_desenhar()
//          (obj_inventario Draw GUI).

#macro BAU_ALCANCE_CELULAS 4    // distância máx. (em células) do player até onde dá pra plantar o baú
#macro BAU_DIST_ABRIR      40   // px entre o player e o baú para abrir com E

#region --- dados / persistência ---

/// Tamanho da célula do grid do jogo (com valor seguro se ainda não existir)
function bau_cs() {
    return variable_global_exists("_cell_size") ? global._cell_size : 64;
}

/// Dentro de uma casa (salas geradas pelo sistema de salas)?
function bau_em_casa() {
    return room == Fase_BEBE;
}

/// ds_list dos baús da sala/room atual. Com _criar = false devolve -1 se não houver nenhum.
function bau_lista_atual(_criar = false) {
    var _mapa, _chave;
    if (bau_em_casa()) {
        if (!variable_global_exists("sala_com_bau") || !ds_exists(global.sala_com_bau, ds_type_map)) global.sala_com_bau = ds_map_create();
        _mapa  = global.sala_com_bau;
        _chave = get_room_id(global.current_sala);
    } else {
        if (!variable_global_exists("baus_fora") || !ds_exists(global.baus_fora, ds_type_map)) global.baus_fora = ds_map_create();
        _mapa  = global.baus_fora;
        _chave = room_get_name(room);
    }
    if (!ds_map_exists(_mapa, _chave)) {
        if (!_criar) return -1;
        ds_map_add(_mapa, _chave, ds_list_create());
    }
    return _mapa[? _chave];
}

/// Objeto com que o player colide agora (mesma regra de scr_player_colisao)
function bau_objeto_colisao() {
    if (variable_global_exists("sala") && is_struct(global.sala) && variable_struct_exists(global.sala, "parede") && object_exists(global.sala.parede)) {
        return global.sala.parede;
    }
    return obj_wall;
}

/// Cria a instância do baú (e a caixa de colisão do pé) a partir do struct salvo
function bau_instanciar(_d) {
    var _cs = bau_cs();
    var _inst = instance_create_depth(_d.x, _d.y, profundidade_pe(_d.y), obj_bau_jogador);
    with (_inst) {
        dados  = _d;
        grid   = _d.grid;
        slots  = _d.slots;
        sprite_index = _d.spr;
        image_xscale = _d.escala;
        image_yscale = _d.escala;
        image_index  = 0;
        aberto = false;

        // Caixa de colisão só no pé (o player passa por trás da tampa, igual aos móveis)
        var _cw = variable_struct_exists(_d, "cw") ? _d.cw : 1;
        var _l  = _d.x - _cw * _cs / 2 + 4;
        var _t  = _d.y - _cs * 0.55;
        colisao = instance_create_depth(_l, _t, 0, bau_objeto_colisao());
        with (colisao) {
            mask_index   = spr_parede_mascara;   // 64x64, origem no canto
            image_angle  = 0;
            image_xscale = (_cw * _cs - 8) / 64;
            image_yscale = (_cs * 0.55 - 2) / 64;
            image_speed  = 0;
            visible      = false;
            bau_colisao  = true;
        }
    }
    return _inst;
}

/// Recria os baús já colocados na sala/room atual.
/// Chamado em carregar_sala (casas) e no Create do obj_control_vamp (mundo aberto).
/// _coords é ignorado (mantido para compatibilidade): a sala vem de bau_lista_atual().
function recriar_baus(_coords = undefined) {
    global.bau_aberto = noone;
    var _lista = bau_lista_atual(false);
    if (_lista == -1) return;
    for (var _i = 0; _i < ds_list_size(_lista); _i++) {
        var _d = _lista[| _i];
        if (!is_struct(_d) || !ds_exists(_d.grid, ds_type_grid)) continue;
        if (instance_exists(obj_bau_jogador)) {
            // já existe (ex.: chamado duas vezes no mesmo frame)? não duplica
            var _ja = false;
            with (obj_bau_jogador) if (dados == _d) _ja = true;
            if (_ja) continue;
        }
        bau_instanciar(_d);
    }
}

#endregion

#region --- posicionar no grid ---

/// Largura do baú em células, pelo tamanho real do sprite na escala do item
function bau_largura_celulas(_spr, _escala) {
    return max(1, round(sprite_get_width(_spr) * _escala / bau_cs()));
}

/// Pegada do baú no grid quando o mouse está na célula (_cx, _cy)
/// Retorna { cx, cy, cw, x1, y1, x2, y2 (retângulo do pé), px, py (onde o sprite é desenhado) }
function bau_pegada(_cx, _cy, _cw) {
    var _cs = bau_cs();
    var _lx = _cx - ((_cw - 1) div 2);
    var _x1 = _lx * _cs, _y1 = _cy * _cs;
    return {
        cx: _lx, cy: _cy, cw: _cw,
        x1: _x1, y1: _y1, x2: _x1 + _cw * _cs, y2: _y1 + _cs,
        px: _x1 + _cw * _cs / 2, py: _y1 + _cs - 4
    };
}

/// Entra no modo "clique no chão pra posicionar": fecha o inventário e segue o mouse.
function colocar_bau_iniciar(_slot) {
    var _grid = global.grid_itens;
    var _id = _grid[# INFOS.ITEM, _slot];
    var _d = item_db(_id);
    if (is_undefined(_d) || !variable_struct_exists(_d, "slots") || _d.slots <= 0) return;

    global.colocando_bau = {
        ativo: true, slot: _slot, item_id: _id,
        spr: _d.spr, slots: _d.slots, escala: _d.escala,
        cw: bau_largura_celulas(_d.spr, _d.escala),
        pegada: undefined, valido: false, motivo: "",
        espera: 2   // ignora o clique que usou o item no inventário
    };
    if (instance_exists(obj_inventario)) obj_inventario.is_open = false;
    inventory_msg("Clique numa célula livre perto de você (botão direito / Esc cancela)", c_yellow);
}

/// Sai do modo de posicionamento sem gastar o item.
function colocar_bau_cancelar() {
    global.colocando_bau = { ativo: false };
}

/// A pegada _P (bau_pegada) pode receber o baú? Retorna "" se pode, ou o motivo se não pode.
function colocar_bau_motivo_invalido(_P) {
    var _cs = bau_cs();

    // 1) perto do player
    if (instance_exists(obj_player)) {
        var _cx = (_P.x1 + _P.x2) / 2, _cy = (_P.y1 + _P.y2) / 2;
        var _dx = max(0, abs(obj_player.x - _cx) - (_P.x2 - _P.x1) / 2);
        var _dy = max(0, abs(obj_player.y - _cy) - (_P.y2 - _P.y1) / 2);
        if (point_distance(0, 0, _dx, _dy) > BAU_ALCANCE_CELULAS * _cs) return "Longe demais";
    }

    // 2) dentro da casa: todas as células do pé precisam ser chão da própria sala
    if (bau_em_casa() && variable_global_exists("salas_layout")) {
        var _L = sala_obter_layout(global.current_sala);
        for (var _k = 0; _k < _P.cw; _k++) {
            if (sala_celula(_L, _P.cx + _k, _P.cy) != SALA_CHAO) return "Fora do chão";
        }
    }

    // 3) nada ocupando o pé
    var _lista = ds_list_create();
    var _n = collision_rectangle_list(_P.x1 + 2, _P.y1 + 2, _P.x2 - 3, _P.y2 - 3, all, false, true, _lista, false);
    var _parede = bau_objeto_colisao();
    var _motivo = "";
    for (var _i = 0; _i < _n; _i++) {
        var _o  = _lista[| _i];
        var _oi = _o.object_index;

        // Coisas altas (casa, árvore, pedra, baú, player): só a faixa do pé ocupa o chão
        var _fator = 0;
        if (_oi == obj_estrutura || object_is_ancestor(_oi, obj_estrutura)) _fator = 0.5;
        else if (object_is_ancestor(_oi, par_objetos) || _oi == obj_bau_jogador || _oi == obj_player) _fator = 0.3;
        if (_fator > 0) {
            var _h  = _o.bbox_bottom - _o.bbox_top;
            var _bt = _o.bbox_bottom - max(_cs * 0.5, min(_cs, _h * _fator));
            if (_o.bbox_bottom > _P.y1 + 2 && _bt < _P.y2 - 3) { _motivo = (_oi == obj_player) ? "Você está em cima" : "Ocupado"; break; }
            continue;
        }

        // Parede, caixa de colisão de móvel/baú ou qualquer outra coisa sólida: o bbox inteiro
        if (_o.solid || _oi == _parede || object_is_ancestor(_oi, _parede) || _oi == obj_wall || object_is_ancestor(_oi, obj_wall)) {
            _motivo = "Ocupado";
            break;
        }
    }
    ds_list_destroy(_lista);
    return _motivo;
}

/// Compatibilidade com o código antigo: posição (centro da célula) é válida?
function colocar_bau_posicao_valida(_wx, _wy) {
    var _cs = bau_cs();
    var _cw = global.colocando_bau.ativo ? global.colocando_bau.cw : 1;
    return colocar_bau_motivo_invalido(bau_pegada(floor(_wx / _cs), floor(_wy / _cs), _cw)) == "";
}

/// Atualiza o fantasma (chamado no Step do obj_player enquanto colocando_bau.ativo)
function colocar_bau_atualizar() {
    var _b = global.colocando_bau;
    var _cs = bau_cs();
    _b.pegada = bau_pegada(floor(mouse_x / _cs), floor(mouse_y / _cs), _b.cw);
    _b.motivo = colocar_bau_motivo_invalido(_b.pegada);
    _b.valido = (_b.motivo == "");

    if (_b.espera > 0) { _b.espera--; return; }
    if (mouse_check_button_pressed(mb_left)) {
        if (_b.valido) colocar_bau_confirmar();
        else inventory_msg(_b.motivo + "!", c_orange);
    } else if (mouse_check_button_pressed(mb_right) || keyboard_check_pressed(vk_escape)) {
        colocar_bau_cancelar();
    }
}

/// Desenha a pegada no grid + o baú transparente (Draw End do obj_player)
function colocar_bau_desenhar() {
    var _b = global.colocando_bau;
    if (!_b.ativo || is_undefined(_b.pegada)) return;
    var _P = _b.pegada;
    var _cs = bau_cs();
    var _cor = _b.valido ? make_color_rgb(90, 220, 110) : make_color_rgb(235, 70, 60);

    // células vizinhas bem fraquinhas, pra mostrar o grid
    draw_set_color(c_white);
    draw_set_alpha(0.10);
    for (var _gx = _P.cx - 1; _gx <= _P.cx + _P.cw; _gx++) {
        for (var _gy = _P.cy - 1; _gy <= _P.cy + 1; _gy++) {
            draw_rectangle(_gx * _cs, _gy * _cs, (_gx + 1) * _cs - 1, (_gy + 1) * _cs - 1, true);
        }
    }
    // pegada
    draw_set_color(_cor);
    draw_set_alpha(0.28);
    draw_rectangle(_P.x1, _P.y1, _P.x2 - 1, _P.y2 - 1, false);
    draw_set_alpha(0.9);
    draw_rectangle(_P.x1, _P.y1, _P.x2 - 1, _P.y2 - 1, true);
    draw_rectangle(_P.x1 + 1, _P.y1 + 1, _P.x2 - 2, _P.y2 - 2, true);
    draw_set_alpha(1);

    // baú
    draw_sprite_ext(_b.spr, 0, _P.px, _P.py, _b.escala, _b.escala, 0, _b.valido ? c_white : make_color_rgb(255, 120, 110), 0.65);
    draw_set_color(c_white);
}

/// Confirma a colocação na pegada atual: cria o baú, guarda na sala e consome o item.
function colocar_bau_confirmar() {
    var _b = global.colocando_bau;
    var _grid_player = global.grid_itens;
    if (_grid_player[# INFOS.ITEM, _b.slot] != _b.item_id) { colocar_bau_cancelar(); return; } // slot mudou nesse meio tempo
    var _P = _b.pegada;

    var _grid_bau = ds_grid_create(INFOS.HEIGHT, _b.slots);
    ds_grid_clear(_grid_bau, -1);
    var _dados = {
        x: _P.px, y: _P.py, cw: _P.cw,
        item_id: _b.item_id, slots: _b.slots, spr: _b.spr, escala: _b.escala, grid: _grid_bau
    };
    ds_list_add(bau_lista_atual(true), _dados);
    bau_instanciar(_dados);

    _grid_player[# INFOS.QUANTIDADE, _b.slot]--;
    if (_grid_player[# INFOS.QUANTIDADE, _b.slot] <= 0) inventory_clear_slot(_b.slot);
    inventory_pos_mudanca();
    colocar_bau_cancelar();
    inventory_msg("Baú colocado! Aperte E perto dele para abrir.", c_lime);
}

#endregion

#region --- abrir / fechar / recolher ---

function bau_abrir(_inst) {
    if (instance_exists(global.bau_aberto) && global.bau_aberto != _inst) bau_fechar();
    global.bau_aberto = _inst;
    with (_inst) aberto = true;
    if (instance_exists(obj_inventario)) {
        obj_inventario.is_open = false;
        obj_inventario.bau_hover = { lado: -1, slot: -1 };
    }
}

function bau_fechar() {
    if (instance_exists(global.bau_aberto)) with (global.bau_aberto) aberto = false;
    global.bau_aberto = noone;
}

/// Baú vazio?
function bau_vazio(_inst) {
    for (var _i = 0; _i < _inst.slots; _i++) if (_inst.grid[# INFOS.ITEM, _i] != -1) return false;
    return true;
}

/// Recolhe o baú _inst de volta pro inventário (só se estiver vazio). Botão "Recolher" do painel.
function bau_recolher(_inst) {
    if (!bau_vazio(_inst)) { inventory_msg("Esvazie o baú antes de recolher!", c_orange); return false; }
    var _d = _inst.dados;
    if (!inventory_add(_d.item_id, 1)) { inventory_msg("Mochila cheia!", c_red); return false; }

    var _lista = bau_lista_atual(false);
    if (_lista != -1) {
        for (var _i = 0; _i < ds_list_size(_lista); _i++) {
            if (_lista[| _i] == _d) { ds_list_delete(_lista, _i); break; }
        }
    }
    if (ds_exists(_d.grid, ds_type_grid)) ds_grid_destroy(_d.grid);
    if (global.bau_aberto == _inst) global.bau_aberto = noone;
    if (instance_exists(_inst.colisao)) instance_destroy(_inst.colisao);
    instance_destroy(_inst);
    inventory_pos_mudanca();
    return true;
}

#endregion

#region --- mover itens entre baú e mochila ---

/// Move _qtd unidades (-1 = a pilha toda) do slot _src de _g_src para _g_dst (slots 0.._n_dst-1).
/// Empilha com o mesmo item quando dá; senão usa o primeiro espaço vazio. Retorna quantas moveu.
function bau_transferir(_g_src, _src, _g_dst, _n_dst, _qtd = -1) {
    var _id = _g_src[# INFOS.ITEM, _src];
    if (_id == -1) return 0;
    var _tem = _g_src[# INFOS.QUANTIDADE, _src];
    if (!is_real(_tem) || _tem < 1) _tem = 1;
    if (_qtd < 0 || _qtd > _tem) _qtd = _tem;

    var _d = item_db(_id);
    var _stack = !is_undefined(_d) && _d.stack;

    // 1) junta numa pilha igual
    var _dest = -1;
    if (_stack) {
        for (var _i = 0; _i < _n_dst; _i++) if (_g_dst[# INFOS.ITEM, _i] == _id) { _dest = _i; break; }
    }
    if (_dest != -1) {
        _g_dst[# INFOS.QUANTIDADE, _dest] += _qtd;
    } else {
        // 2) primeiro espaço vazio
        for (var _i = 0; _i < _n_dst; _i++) if (_g_dst[# INFOS.ITEM, _i] == -1) { _dest = _i; break; }
        if (_dest == -1) return 0;
        for (var _c = 0; _c < INFOS.HEIGHT; _c++) _g_dst[# _c, _dest] = _g_src[# _c, _src];
        _g_dst[# INFOS.QUANTIDADE, _dest] = _qtd;
    }

    // tira da origem
    if (_qtd >= _tem) {
        for (var _c = 0; _c < INFOS.HEIGHT; _c++) _g_src[# _c, _src] = -1;
    } else {
        _g_src[# INFOS.QUANTIDADE, _src] = _tem - _qtd;
    }
    return _qtd;
}

/// Clique num slot do baú: devolve pra mochila (_qtd = -1 pilha toda, 1 = uma unidade)
function bau_slot_click(_bau, _i, _qtd = -1) {
    if (_bau.grid[# INFOS.ITEM, _i] == -1) return;
    if (bau_transferir(_bau.grid, _i, global.grid_itens, inventory_bag_slots(), _qtd) == 0) {
        inventory_msg("Mochila cheia!", c_red);
        return;
    }
    inventory_pos_mudanca();
}

/// Clique num slot da mochila: guarda no baú aberto
function bau_guardar_item(_bau, _slot_bag, _qtd = -1) {
    if (global.grid_itens[# INFOS.ITEM, _slot_bag] == -1) return;
    if (bau_transferir(global.grid_itens, _slot_bag, _bau.grid, _bau.slots, _qtd) == 0) {
        inventory_msg("Baú cheio!", c_red);
        return;
    }
    inventory_pos_mudanca();
}

/// Botões "Guardar tudo" / "Pegar tudo"
function bau_mover_tudo(_bau, _para_bau) {
    var _movidos = 0, _sobrou = false;
    if (_para_bau) {
        var _bag = inventory_bag_slots();
        for (var _i = 0; _i < _bag; _i++) {
            if (global.grid_itens[# INFOS.ITEM, _i] == -1) continue;
            if (bau_transferir(global.grid_itens, _i, _bau.grid, _bau.slots) > 0) _movidos++; else _sobrou = true;
        }
    } else {
        for (var _i = 0; _i < _bau.slots; _i++) {
            if (_bau.grid[# INFOS.ITEM, _i] == -1) continue;
            if (bau_transferir(_bau.grid, _i, global.grid_itens, inventory_bag_slots()) > 0) _movidos++; else _sobrou = true;
        }
    }
    if (_sobrou) inventory_msg(_para_bau ? "Baú cheio! Nem tudo coube." : "Mochila cheia! Nem tudo coube.", c_orange);
    if (_movidos > 0) inventory_pos_mudanca();
}

/// Quantos espaços do grid estão ocupados
function bau_ocupados(_g, _n) {
    var _c = 0;
    for (var _i = 0; _i < _n; _i++) if (_g[# INFOS.ITEM, _i] != -1) _c++;
    return _c;
}

#endregion

#region --- UI do baú (painel Baú | Mochila) ---
// Layout em "pixels de design", multiplicados por uma escala que segue a GUI (igual ao inventário).
// Os dois painéis têm posição própria (CONVENTIONS: cada contêiner com seu posicionamento).

/// Calcula o layout da janela do baú aberto. Retorna um struct com retângulos já em GUI.
function bau_ui_layout(_bau) {
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _cols = 6;
    var _slot = 40, _gap = 6, _padx = 14, _topo = 34, _base = 14;
    var _rows_bau = max(1, ceil(_bau.slots / _cols));
    var _bag = inventory_bag_slots();
    var _rows_bag = max(1, ceil(_bag / _cols));
    var _rows = max(_rows_bau, _rows_bag);

    var _pw = _padx * 2 + _cols * _slot + (_cols - 1) * _gap;           // largura de cada painel
    var _ph = _topo + _rows * _slot + (_rows - 1) * _gap + _base;        // altura dos painéis
    var _sep = 18;                                                        // espaço entre os painéis
    var _rod = 44;                                                        // rodapé (botões + dica)
    var _W = _pw * 2 + _sep, _H = _ph + _rod;

    var _s = max(1, floor(min(_gw * 0.92 / _W, _gh * 0.80 / _H) * 2) / 2);
    var _x0 = floor(_gw / 2 - _W * _s / 2);
    var _y0 = floor(_gh / 2 - _H * _s / 2);

    var _L = {
        s: _s, cols: _cols, slot: _slot * _s, gap: _gap * _s,
        n_bau: _bau.slots, n_bag: _bag,
        // painel do baú (esquerda) e da mochila (direita)
        p_bau: [_x0, _y0, _x0 + _pw * _s, _y0 + _ph * _s],
        p_bag: [_x0 + (_pw + _sep) * _s, _y0, _x0 + _W * _s, _y0 + _ph * _s],
        topo: _topo * _s, padx: _padx * _s
    };

    // botões do rodapé (centralizados embaixo dos painéis)
    var _by = _y0 + (_ph + 10) * _s, _bh = 22 * _s, _bw = 104 * _s, _bg = 10 * _s;
    var _bx = _gw / 2 - (_bw * 4 + _bg * 3) / 2;
    _L.btn_guardar  = [_bx,                    _by, _bx + _bw,               _by + _bh];
    _L.btn_pegar    = [_bx + (_bw + _bg),      _by, _bx + _bw * 2 + _bg,     _by + _bh];
    _L.btn_recolher = [_bx + (_bw + _bg) * 2,  _by, _bx + _bw * 3 + _bg * 2, _by + _bh];
    _L.btn_fechar   = [_bx + (_bw + _bg) * 3,  _by, _bx + _bw * 4 + _bg * 3, _by + _bh];
    return _L;
}

/// Retângulo GUI do slot _i do painel _p ([x1,y1,x2,y2] do painel)
function bau_ui_slot_rect(_L, _p, _i) {
    var _x = _p[0] + _L.padx + (_i mod _L.cols) * (_L.slot + _L.gap);
    var _y = _p[1] + _L.topo + (_i div _L.cols) * (_L.slot + _L.gap);
    return [_x, _y, _x + _L.slot, _y + _L.slot];
}

/// Lógica do painel (cliques/teclas). Chamar no Step do obj_inventario.
/// Clique esquerdo = move a pilha | direito = move 1 | E / Esc / Tab = fecha
function bau_ui_step() {
    var _bau = global.bau_aberto;
    if (!instance_exists(_bau)) { global.bau_aberto = noone; return; }

    // fecha se o player se afastar (ex.: empurrado) ou apertar E / Esc / Tab / I
    var _longe = !instance_exists(obj_player) || point_distance(obj_player.x, obj_player.y, _bau.x, _bau.y) > BAU_DIST_ABRIR + 120;
    if (_longe || keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_tab) || tecla_apertou("inventario")) {
        bau_fechar();
        return;
    }
    // (o E é tratado no Step do próprio baú, que abre e fecha)

    var _L  = bau_ui_layout(_bau);
    var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
    var _h  = { lado: -1, slot: -1 };   // lado 0 = baú, 1 = mochila
    for (var _i = 0; _i < _L.n_bau; _i++) {
        var _r = bau_ui_slot_rect(_L, _L.p_bau, _i);
        if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) { _h = { lado: 0, slot: _i }; break; }
    }
    if (_h.lado == -1) {
        for (var _j = 0; _j < _L.n_bag; _j++) {
            var _r2 = bau_ui_slot_rect(_L, _L.p_bag, _j);
            if (point_in_rectangle(_mx, _my, _r2[0], _r2[1], _r2[2], _r2[3])) { _h = { lado: 1, slot: _j }; break; }
        }
    }
    if (instance_exists(obj_inventario)) obj_inventario.bau_hover = _h;

    var _esq = mouse_check_button_pressed(mb_left), _dir = mouse_check_button_pressed(mb_right);
    if ((_esq || _dir) && _h.lado != -1) {
        var _q = _esq ? -1 : 1;
        if (_h.lado == 0) bau_slot_click(_bau, _h.slot, _q);
        else              bau_guardar_item(_bau, _h.slot, _q);
        return;
    }

    if (_esq) {
        var _b;
        _b = _L.btn_guardar;  if (point_in_rectangle(_mx, _my, _b[0], _b[1], _b[2], _b[3])) { bau_mover_tudo(_bau, true);  return; }
        _b = _L.btn_pegar;    if (point_in_rectangle(_mx, _my, _b[0], _b[1], _b[2], _b[3])) { bau_mover_tudo(_bau, false); return; }
        _b = _L.btn_recolher; if (point_in_rectangle(_mx, _my, _b[0], _b[1], _b[2], _b[3])) { bau_recolher(_bau);         return; }
        _b = _L.btn_fechar;   if (point_in_rectangle(_mx, _my, _b[0], _b[1], _b[2], _b[3])) { bau_fechar();               return; }
    }
}

/// Desenha um slot (fundo, item, quantidade, raridade, nível)
function bau_ui_desenhar_slot(_r, _g, _i, _hover, _s, _fh) {
    var _r0 = _r[0], _r1 = _r[1], _r2 = _r[2], _r3 = _r[3];
    var _rad = 5 * _s;
    ui_rrect(_r0, _r1 + _s, _r2, _r3 + _s, _rad, c_black, 0.18);                   // sombra
    ui_rrect(_r0, _r1, _r2, _r3, _rad, ui_cor("borda2"));
    ui_rrect(_r0 + _s, _r1 + _s, _r2 - _s, _r3 - _s, max(0, _rad - _s), _hover ? ui_cor("chip") : ui_cor("papel2"));

    var _id = _g[# INFOS.ITEM, _i];
    if (_id != -1) {
        var _cx = (_r0 + _r2) / 2, _cy = (_r1 + _r3) / 2;
        var _d = item_db(_id);
        var _spr = _g[# INFOS.SPRITE, _i], _img = _g[# INFOS.IMAGE_IND, _i];
        if (sprite_exists(_spr)) ui_icon(_spr, _img, _cx, _cy, (_r2 - _r0) * 0.72);
        else if (!is_undefined(_d)) ui_icon(_d.spr, _d.img, _cx, _cy, (_r2 - _r0) * 0.72);

        if (!is_undefined(_d)) {
            if (_d.raridade != "comum") {
                draw_set_color(item_raridade(_d.raridade).cor);
                draw_rectangle(_r0 + 3 * _s, _r3 - 3 * _s, _r2 - 3 * _s, _r3 - 2 * _s, false);
            }
            if (item_tipo_e_equipamento(_d.tipo)) {
                var _nv = _g[# INFOS.NIVEL, _i];
                if (is_real(_nv) && _nv > 1) {
                    draw_set_halign(fa_left); draw_set_valign(fa_top);
                    ui_text(_r0 + 2 * _s, _r1 + 1 * _s, "Nv" + string(_nv), make_color_rgb(255, 220, 90), (8 * _s) / _fh);
                }
            }
        }
        var _q = _g[# INFOS.QUANTIDADE, _i];
        if (is_real(_q) && _q > 1) {
            draw_set_halign(fa_right); draw_set_valign(fa_bottom);
            ui_text(_r2 - 3 * _s, _r3 - 1 * _s, string(_q), c_white, (9 * _s) / _fh);
        }
        draw_set_halign(fa_left); draw_set_valign(fa_top);
    }
    if (_hover) {
        draw_set_color(ui_cor("ouro"));
        for (var _k = 0; _k < max(1, _s); _k++) draw_roundrect_ext(_r0 - _k, _r1 - _k, _r2 + _k, _r3 + _k, _rad, _rad, true);
    }
    draw_set_color(c_white);
}

/// Tooltip no estilo do inventário (linhas de item_tooltip_linhas)
function bau_ui_tooltip(_tip, _cor_borda, _mx, _my, _s, _fh) {
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _base = (9.5 * _s) / _fh;
    var _pad = 6 * _s, _maxw = 170 * _s;
    var _tw = 0, _th = 0;
    for (var _k = 0; _k < array_length(_tip); _k++) {
        var _ln = _tip[_k], _sc = _base * _ln.s, _w, _hh;
        if (variable_struct_exists(_ln, "wrap")) {
            _w  = min(_maxw, string_width_ext(_ln.t, -1, _maxw / _sc) * _sc);
            _hh = string_height_ext(_ln.t, -1, _maxw / _sc) * _sc;
        } else {
            _w = string_width(_ln.t) * _sc;
            _hh = _fh * _sc;
        }
        _tw = max(_tw, _w);
        _th += _hh + 1.5 * _s;
    }
    var _bw = _tw + _pad * 2, _bh = _th + _pad * 2;
    var _tx = _mx + 14 * _s, _ty = _my + 10 * _s;
    if (_tx + _bw > _gw - 4) _tx = _mx - _bw - 10 * _s;
    if (_ty + _bh > _gh - 4) _ty = _gh - 4 - _bh;
    _tx = max(4, _tx); _ty = max(4, _ty);

    draw_set_alpha(0.93); draw_set_color(make_color_rgb(40, 24, 20));
    draw_roundrect_ext(_tx, _ty, _tx + _bw, _ty + _bh, 6 * _s, 6 * _s, false);
    draw_set_alpha(1); draw_set_color(_cor_borda);
    for (var _k = 0; _k < max(1, _s); _k++) draw_roundrect_ext(_tx + _k, _ty + _k, _tx + _bw - _k, _ty + _bh - _k, 6 * _s, 6 * _s, true);

    draw_set_halign(fa_left); draw_set_valign(fa_top);
    var _yy = _ty + _pad;
    for (var _k = 0; _k < array_length(_tip); _k++) {
        var _ln = _tip[_k], _sc = _base * _ln.s;
        if (variable_struct_exists(_ln, "wrap")) {
            draw_set_color(_ln.c);
            draw_text_ext_transformed(_tx + _pad, _yy, _ln.t, -1, _maxw / _sc, _sc, _sc, 0);
            _yy += string_height_ext(_ln.t, -1, _maxw / _sc) * _sc + 1.5 * _s;
        } else {
            ui_text(_tx + _pad, _yy, _ln.t, _ln.c, _sc);
            _yy += _fh * _sc + 1.5 * _s;
        }
        if (_k == 1) { draw_set_color(make_color_rgb(110, 80, 60)); draw_line(_tx + _pad, _yy, _tx + _bw - _pad, _yy); _yy += 1.5 * _s; }
    }
    draw_set_color(c_white);
}

/// Desenha o painel do baú aberto. Chamar no Draw GUI do obj_inventario.
function bau_ui_desenhar() {
    var _bau = global.bau_aberto;
    if (!instance_exists(_bau)) return;

    var _L  = bau_ui_layout(_bau);
    var _s  = _L.s;
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
    var _hv = instance_exists(obj_inventario) ? obj_inventario.bau_hover : { lado: -1, slot: -1 };

    draw_set_font(fnt_descricao);
    var _fh = max(1, string_height("Ag"));
    var _ts = (10 * _s) / _fh;   // escala de texto padrão

    // fundo escurecido
    draw_set_alpha(0.55); draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1); draw_set_color(c_white);

    var _d_bau = item_db(_bau.dados.item_id);
    var _nome  = is_undefined(_d_bau) ? "Baú" : _d_bau.nome;
    var _cor_b = is_undefined(_d_bau) ? ui_cor("borda") : merge_color(item_raridade(_d_bau.raridade).cor, ui_cor("borda"), 0.35);

    // ---------- painel do BAÚ ----------
    var _p = _L.p_bau;
    ui_card(_p[0], _p[1], _p[2], _p[3], 8 * _s, ui_cor("papel"), ui_cor("borda"), 2 * _s);
    ui_tab(_p[0] + 10 * _s, _p[1] - 9 * _s, 18 * _s, _nome, _cor_b, _ts);
    var _occ = bau_ocupados(_bau.grid, _bau.slots);
    var _txt_occ = string(_occ) + "/" + string(_bau.slots);
    var _pw = string_width(_txt_occ) * _ts * 0.9 + 16 * _s * 0.9;
    ui_pill(_p[2] - 10 * _s - _pw, _p[1] + 8 * _s, 16 * _s, _txt_occ, (_occ >= _bau.slots) ? ui_cor("vermelho") : ui_cor("escuro"), c_white, _ts * 0.9);
    for (var _i = 0; _i < _L.n_bau; _i++) {
        bau_ui_desenhar_slot(bau_ui_slot_rect(_L, _p, _i), _bau.grid, _i, (_hv.lado == 0 && _hv.slot == _i), _s, _fh);
    }

    // ---------- painel da MOCHILA ----------
    var _q = _L.p_bag;
    ui_card(_q[0], _q[1], _q[2], _q[3], 8 * _s, ui_cor("papel"), ui_cor("borda"), 2 * _s);
    ui_tab(_q[0] + 10 * _s, _q[1] - 9 * _s, 18 * _s, "Mochila", ui_cor("azul"), _ts);
    var _occ2 = bau_ocupados(global.grid_itens, _L.n_bag);
    var _txt2 = string(_occ2) + "/" + string(_L.n_bag);
    var _pw2 = string_width(_txt2) * _ts * 0.9 + 16 * _s * 0.9;
    ui_pill(_q[2] - 10 * _s - _pw2, _q[1] + 8 * _s, 16 * _s, _txt2, (_occ2 >= _L.n_bag) ? ui_cor("vermelho") : ui_cor("escuro"), c_white, _ts * 0.9);
    for (var _j = 0; _j < _L.n_bag; _j++) {
        bau_ui_desenhar_slot(bau_ui_slot_rect(_L, _q, _j), global.grid_itens, _j, (_hv.lado == 1 && _hv.slot == _j), _s, _fh);
    }

    // ---------- rodapé: botões + dica ----------
    var _vazio = bau_vazio(_bau);
    var _b;
    _b = _L.btn_guardar;  ui_button(_b[0], _b[1], _b[2], _b[3], "Guardar tudo", _occ2 > 0,  ui_cor("verde"),    _ts, _mx, _my);
    _b = _L.btn_pegar;    ui_button(_b[0], _b[1], _b[2], _b[3], "Pegar tudo",   _occ > 0,   ui_cor("azul"),     _ts, _mx, _my);
    _b = _L.btn_recolher; ui_button(_b[0], _b[1], _b[2], _b[3], "Recolher baú", _vazio,     ui_cor("ouro"),     _ts, _mx, _my);
    _b = _L.btn_fechar;   ui_button(_b[0], _b[1], _b[2], _b[3], "Fechar (E)",   true,       ui_cor("vermelho"), _ts, _mx, _my);

    draw_set_halign(fa_center); draw_set_valign(fa_top);
    ui_text(_gw / 2, _L.btn_fechar[3] + 8 * _s, "Clique: move a pilha   |   Botão direito: move 1", make_color_rgb(235, 225, 210), _ts * 0.85);
    draw_set_halign(fa_left);

    // mensagem rápida (Baú cheio!, Mochila cheia!...) em cima da janela
    if (instance_exists(obj_inventario) && obj_inventario.msg_timer > 0 && obj_inventario.msg_texto != "") {
        draw_set_halign(fa_center);
        draw_set_alpha(min(1, obj_inventario.msg_timer / 30));
        ui_text(_gw / 2, max(6 * _s, _L.p_bau[1] - 34 * _s), obj_inventario.msg_texto, obj_inventario.msg_cor, _ts * 1.1);
        draw_set_alpha(1);
        draw_set_halign(fa_left);
    }

    // ---------- tooltip ----------
    if (_hv.lado != -1) {
        var _g  = (_hv.lado == 0) ? _bau.grid : global.grid_itens;
        var _id = _g[# INFOS.ITEM, _hv.slot];
        if (_id != -1) {
            var _d = item_db(_id);
            var _tip, _cor = make_color_rgb(230, 150, 40);
            if (!is_undefined(_d)) {
                _tip = item_tooltip_linhas(_id, _g[# INFOS.NIVEL, _hv.slot], _g[# INFOS.PASSIVAS, _hv.slot], _g[# INFOS.QUANTIDADE, _hv.slot], "mochila");
                _cor = item_raridade(_d.raridade).cor;
            } else {
                _tip = [ { t: string(_g[# INFOS.NOME, _hv.slot]), c: c_white, s: 1.25 },
                         { t: string(_g[# INFOS.DESCRICAO, _hv.slot]), c: make_color_rgb(230, 220, 205), s: 0.9, wrap: true } ];
            }
            bau_ui_tooltip(_tip, _cor, _mx, _my, _s, _fh);
        }
    }
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(c_white); draw_set_alpha(1);
}

#endregion

#endregion
