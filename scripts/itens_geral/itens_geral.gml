// feather disable GM2017
// ============================================================================
//  ITENS GERAL — DATABASE DE ITENS, PASSIVAS, RECEITAS E DROPS
// ----------------------------------------------------------------------------
//  Tudo é data-driven: para criar um item novo basta uma linha em
//  itens_definir_catalogo() (e uma receita em itens_definir_receitas(), se quiser).
//
//  Cada item tem um ID (string) que é guardado em INFOS.ITEM na grid do inventário.
//  Equipamentos têm NÍVEL (1..ITEM_NIVEL_MAX) e PASSIVAS (adesivos colados).
//  Atributo no nível N  = base * (1 + ITEM_CRESC_STAT * (N - 1))
//  Passiva no nível N   = base * (1 + ITEM_CRESC_PASSIVA * (N - 1))
//  Espaços de adesivo   = 1 no Nv1, 2 no Nv3, 3 no Nv5 (item_slots_passiva)
// ============================================================================

#macro ITEM_NIVEL_MAX        5
#macro ITEM_CRESC_STAT       0.30
#macro ITEM_CRESC_PASSIVA    0.50
#macro ITEM_CHANCE_PASSIVA_DROP 0.12

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
        case "armadura": return "Armadura";
        case "bota":     return "Calçado";
        case "material": return "Material";
        case "adesivo":  return "Adesivo";
        case "colocavel":return "Colocável";
    }
    return "Item";
}

function item_tipo_e_equipamento(_tipo) {
    return (_tipo == "arma" || _tipo == "armadura" || _tipo == "bota");
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

#region ---------- PASSIVAS (ADESIVOS) ----------

function itens_definir_passivas() {
    global.passivas_db = {};
    global.passivas_ordem = [];
    var _p = function(_id, _nome, _stat, _base, _desc, _cor, _adesivo) {
        global.passivas_db[$ _id] = { id: _id, nome: _nome, stat: _stat, base: _base, desc: _desc, cor: _cor, adesivo: _adesivo };
        array_push(global.passivas_ordem, _id);
    };
    // {v} vira o valor já escalado pelo nível do item
    _p("coracao",  "Coração Quentinho",   "regen",         0.5, "Recupera {v} de vida por segundo.",       make_color_rgb(255, 110, 140), "ad_coracao");
    _p("estrela",  "Estrela da Sorte",    "crit",          4,   "+{v}% de chance de crítico.",             make_color_rgb(255, 210,  60), "ad_estrela");
    _p("forca",    "Músculo de Brinquedo","dano_pct",      8,   "+{v}% de dano.",                          make_color_rgb(255, 140, 110), "ad_forca");
    _p("escudo",   "Escudinho",           "defesa",        2,   "+{v} de defesa.",                         make_color_rgb(110, 180, 255), "ad_escudo");
    _p("raio",     "Raio Veloz",          "vel",           0.5, "+{v} de velocidade.",                     make_color_rgb(255, 225,  80), "ad_raio");
    _p("vampiro",  "Dentinho de Vampiro", "vampirismo",    3,   "Cura {v}% do dano que você causa.",       make_color_rgb(200,  80, 150), "ad_vampiro");
    _p("nuvem",    "Nuvem Fofinha",       "esquiva",       4,   "{v}% de chance de esquivar de um golpe.", make_color_rgb(170, 220, 255), "ad_nuvem");
    _p("urso",     "Abraço de Urso",      "vida",          10,  "+{v} de vida máxima.",                    make_color_rgb(200, 150, 100), "ad_urso");
    _p("fantasma", "Caça-Fantasmas",      "mata_fantasma", 1,   "Seus golpes acertam fantasmas.",          make_color_rgb(190, 200, 255), "ad_fantasma");
    _p("bum",      "Bum!",                "crit_dano",     15,  "+{v}% de dano crítico.",                  make_color_rgb(255, 150,  70), "ad_bum");
}

/// Valor da passiva num item de nível _nivel
function passiva_valor(_pid, _nivel) {
    var _d = global.passivas_db[$ _pid];
    if (is_undefined(_d)) return 0;
    if (_d.stat == "mata_fantasma") return 1;
    return _d.base * (1 + ITEM_CRESC_PASSIVA * (max(1, _nivel) - 1));
}

/// Texto da passiva com o valor do nível
function passiva_texto(_pid, _nivel) {
    var _d = global.passivas_db[$ _pid];
    if (is_undefined(_d)) return "";
    return string_replace(_d.desc, "{v}", item_num_str(passiva_valor(_pid, _nivel)));
}

#endregion

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
    //   extra: { inata: "id_passiva", buffs: [ {stat, valor, seg} ], stack: bool }
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
            escala: variable_struct_exists(_extra, "escala") ? _extra.escala : 1
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
    var _n = array_length(global.passivas_ordem);
    for (var _i = 0; _i < _n; _i++) {
        var _pid = global.passivas_ordem[_i];
        var _pd  = global.passivas_db[$ _pid];
        var _rar = (_pid == "fantasma" || _pid == "vampiro" || _pid == "bum") ? "raro" : "incomum";
        _def(_pd.adesivo, "Adesivo: " + _pd.nome, "adesivo", _M, 15 + _i, 40, _rar,
             "Arraste até um equipamento para colar a passiva.", {}, { passiva: _pid });
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
    return _b * (1 + ITEM_CRESC_STAT * (max(1, _nivel) - 1));
}

/// Quantos adesivos o item aceita no nível
function item_slots_passiva(_nivel) {
    return 1 + (_nivel >= 3) + (_nivel >= 5);
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
    // --- Armaduras ---
    _r("cobertor",        { la: 2, couro: 1 });
    _r("papelao",         { papel: 3, couro: 1 });
    _r("casaco",          { la: 3, botao: 2 });
    _r("pijama_dino",     { la: 3, botao: 1, couro: 2 });
    _r("cavaleiro",       { ferro: 4, couro: 2, botao: 2 });
    _r("super_capa",      { la: 4, ouro: 1, po_estrela: 1 });
    _r("astronauta",      { ferro: 2, pilha: 2, la: 2, gude: 1 });
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
function item_slot_preencher(_grid, _slot, _id, _qtd, _nivel = 1, _passivas = undefined) {
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
    _grid[# INFOS.NIVEL,      _slot] = clamp(_nivel, 1, ITEM_NIVEL_MAX);
    _grid[# INFOS.PASSIVAS,   _slot] = _passivas;
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
    return ds_grid_height(global.grid_itens) - 3;
}

/// @desc Adiciona um item pelo ID. Retorna true se coube tudo.
function inventory_add(_id, _qtd = 1, _nivel = 1, _passivas = undefined) {
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
        var _vazio = inventory_find_empty_slot();
        if (_vazio == -1) { global.inventario_cheio = true; inventory_msg("Mochila cheia!", c_red); return false; }
        item_slot_preencher(_grid, _vazio, _id, _qtd, 1, []);
    } else {
        repeat (_qtd) {
            var _vazio = inventory_find_empty_slot();
            if (_vazio == -1) { global.inventario_cheio = true; inventory_msg("Mochila cheia!", c_red); return false; }
            var _pas = is_array(_passivas) ? array_create(array_length(_passivas)) : [];
            if (is_array(_passivas)) array_copy(_pas, 0, _passivas, 0, array_length(_passivas));
            item_slot_preencher(_grid, _vazio, _id, 1, _nivel, _pas);
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
        return inventory_add(_id, max(1, _inst.quantidade), _nv, _pas);
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
function item_criar_no_mundo(_x, _y, _id, _qtd, _nivel = 1, _passivas = undefined, _prof = undefined) {
    var _d = item_db(_id);
    if (is_undefined(_d)) return noone;
    var _inst = layer_exists("Instances_itens")
        ? instance_create_layer(_x, _y, "Instances_itens", obj_item)
        : instance_create_depth(_x, _y, -_y, obj_item);

    var _pas = [];
    if (is_array(_passivas)) { _pas = array_create(array_length(_passivas)); array_copy(_pas, 0, _passivas, 0, array_length(_passivas)); }

    with (_inst) {
        item_id      = _id;
        nivel        = _nivel;
        passivas     = _pas;
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
    if (random(1) < ITEM_CHANCE_PASSIVA_DROP) {
        var _ops = [];
        for (var _i = 0; _i < array_length(global.passivas_ordem); _i++) {
            var _p = global.passivas_ordem[_i];
            if (_p != "fantasma" && _p != _d.inata) array_push(_ops, _p);
        }
        array_push(_r.passivas, _ops[irandom(array_length(_ops) - 1)]);
    }
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
    ds_list_add(_lista, [
        _pos_x, _pos_y,
        _inst.sprite_index, _inst.image_index,
        _inst.quantidade, _inst.nome, _inst.descricao,
        _inst.dano, _inst.armadura, _inst.velocidade, _inst.cura,
        _inst.tipo, _inst.ind,
        _inst.sala_x, _inst.sala_y,
        _inst.pos_x, _inst.pos_y,
        _inst.profundidade, _inst.preco,
        _id, _nv, _pas                       // [19] id  [20] nível  [21] passivas
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
        }
    }
}

#endregion

#region ---------- BAÚ PORTÁTIL (COLOCÁVEL NO CHÃO, QUALQUER SALA) ----------
// [O QUE]: Item "colocavel" (ver catálogo acima) craftado, usado no inventário e depois
//          clicado no mapa pra ser plantado. Funciona em QUALQUER sala (casa, corredor,
//          masmorra...) porque a validação usa só duas coisas universais do jogo:
//          1) a célula precisa ser SALA_CHAO no layout da própria sala (spr_fase_criation)
//          2) nenhuma instância sólida (parede de qualquer bioma, móvel, outro baú...) pode
//             estar em cima — checado via a flag `solid`, sem precisar saber o nome do objeto.
// [COMO] : inventory_use_item() chama colocar_bau_iniciar() -> obj_player (Step/Draw End)
//          mostra o fantasma seguindo o mouse e confirma com clique esquerdo em
//          colocar_bau_confirmar() -> cria obj_bau_jogador e guarda em global.sala_com_bau
//          (mesmo padrão de global.sala_com_item_drop), recriado em toda sala por
//          recriar_baus() (chamado em carregar_sala, spr_fase_criation).

/// @desc Entra no modo "clique no chão pra posicionar": fecha o inventário e segue o mouse.
function colocar_bau_iniciar(_slot) {
    var _grid = global.grid_itens;
    var _id = _grid[# INFOS.ITEM, _slot];
    var _d = item_db(_id);
    if (is_undefined(_d) || _d.slots <= 0) return;

    global.colocando_bau = {
        ativo: true, slot: _slot, item_id: _id,
        spr: _d.spr, slots: _d.slots, escala: _d.escala,
        gx: 0, gy: 0, valido: false
    };
    if (instance_exists(obj_inventario)) obj_inventario.is_open = false;
    inventory_msg("Clique no chão para posicionar o " + _d.nome + " (botão direito cancela)", c_yellow);
}

/// @desc Sai do modo de posicionamento sem gastar o item.
function colocar_bau_cancelar() {
    global.colocando_bau = { ativo: false };
}

/// @desc A célula do mundo em (_wx, _wy) é chão livre (sem parede/móvel/outro baú em cima)?
/// Funciona em QUALQUER sala/fase (casa, corredor, Fase_vamp...): não depende do sistema de
/// layout da maze (sala_obter_layout só é confiável dentro de carregar_sala/FASE_BEBE — em
/// outras fases, que trocam de room com room_goto, global.current_sala pode não corresponder
/// à sala visível e o layout viria errado). Em vez disso usa só duas checagens universais:
function colocar_bau_posicao_valida(_wx, _wy) {
    var _cs = global._cell_size;

    // 1) dentro dos limites da room atual, seja qual for a fase
    if (_wx < 0 || _wy < 0 || _wx >= room_width || _wy >= room_height) return false;

    // 2) nenhuma instância sólida (qualquer parede do bioma, móvel, outro baú) pode ocupar a célula
    var _margem = _cs / 2 - 6;
    var _livre = true;
    with (all) {
        if (!solid) continue;
        if (!(bbox_right < _wx - _margem || bbox_left > _wx + _margem || bbox_bottom < _wy - _margem || bbox_top > _wy + _margem)) {
            _livre = false;
        }
    }
    return _livre;
}

/// @desc Confirma a colocação em (_wx, _wy): cria o baú, guarda na sala e consome o item.
function colocar_bau_confirmar(_wx, _wy) {
    var _b = global.colocando_bau;
    var _grid_player = global.grid_itens;
    if (_grid_player[# INFOS.ITEM, _b.slot] != _b.item_id) { colocar_bau_cancelar(); return; } // slot mudou nesse meio tempo

    var _sala_id = get_room_id(global.current_sala);
    if (!ds_map_exists(global.sala_com_bau, _sala_id)) ds_map_add(global.sala_com_bau, _sala_id, ds_list_create());
    var _lista = ds_map_find_value(global.sala_com_bau, _sala_id);

    var _grid_bau = ds_grid_create(INFOS.HEIGHT, _b.slots);
    ds_grid_clear(_grid_bau, -1);
    var _dados = { x: _wx, y: _wy, item_id: _b.item_id, slots: _b.slots, spr: _b.spr, escala: _b.escala, grid: _grid_bau };
    ds_list_add(_lista, _dados);

    var _inst = instance_create_depth(_wx, _wy, profundidade_pe(_wy), obj_bau_jogador);
    with (_inst) {
        dados  = _dados;
        grid   = _dados.grid;
        slots  = _dados.slots;
        sprite_index = _dados.spr;
        image_xscale = _dados.escala;
        image_yscale = _dados.escala;
        aberto = false;
    }

    _grid_player[# INFOS.QUANTIDADE, _b.slot]--;
    if (_grid_player[# INFOS.QUANTIDADE, _b.slot] <= 0) inventory_clear_slot(_b.slot);
    inventory_pos_mudanca();
    colocar_bau_cancelar();
}

/// @desc Chamado em carregar_sala (spr_fase_criation): recria os baús já colocados nessa sala.
function recriar_baus(_coords) {
    var _sala_id = get_room_id(_coords);
    if (!ds_map_exists(global.sala_com_bau, _sala_id)) return;
    var _lista = ds_map_find_value(global.sala_com_bau, _sala_id);
    for (var _i = 0; _i < ds_list_size(_lista); _i++) {
        var _d = _lista[| _i];
        var _inst = instance_create_depth(_d.x, _d.y, profundidade_pe(_d.y), obj_bau_jogador);
        with (_inst) {
            dados  = _d;
            grid   = _d.grid;
            slots  = _d.slots;
            sprite_index = _d.spr;
            image_xscale = _d.escala;
            image_yscale = _d.escala;
            aberto = false;
        }
    }
}

/// @desc Tira 1 item do grid do baú (_i) e devolve pra mochila (clique num slot do baú aberto).
function bau_slot_click(_bau, _i) {
    with (_bau) {
        if (grid[# INFOS.ITEM, _i] == -1) return;
        var _dest = inventory_find_empty_slot();
        if (_dest == -1) { inventory_msg("Mochila cheia!", c_red); return; }
        for (var _c = 0; _c < INFOS.HEIGHT; _c++) {
            global.grid_itens[# _c, _dest] = grid[# _c, _i];
            grid[# _c, _i] = -1;
        }
        inventory_pos_mudanca();
    }
}

/// @desc Guarda o item do slot _slot_bag da mochila no primeiro espaço livre do baú aberto.
function bau_guardar_item(_bau, _slot_bag) {
    with (_bau) {
        if (global.grid_itens[# INFOS.ITEM, _slot_bag] == -1) return;
        var _dest = -1;
        for (var _i = 0; _i < slots; _i++) if (grid[# INFOS.ITEM, _i] == -1) { _dest = _i; break; }
        if (_dest == -1) { inventory_msg("Baú cheio!", c_red); return; }
        for (var _c = 0; _c < INFOS.HEIGHT; _c++) grid[# _c, _dest] = global.grid_itens[# _c, _slot_bag];
    }
    inventory_clear_slot(_slot_bag);
    inventory_pos_mudanca();
}

/// @desc Recolhe o baú _inst de volta pro inventário (só se estiver vazio). Chamado pelo F.
function bau_recolher(_inst) {
    for (var _i = 0; _i < _inst.slots; _i++) {
        if (_inst.grid[# INFOS.ITEM, _i] != -1) { inventory_msg("Esvazie o baú antes de recolher!", c_orange); return; }
    }
    var _destino = inventory_find_empty_slot();
    if (_destino == -1) { inventory_msg("Mochila cheia!", c_red); return; }

    var _d = _inst.dados;
    var _item = item_db(_d.item_id);
    var _grid = global.grid_itens;
    _grid[# INFOS.ITEM, _destino]       = _d.item_id;
    _grid[# INFOS.QUANTIDADE, _destino] = 1;
    _grid[# INFOS.SPRITE, _destino]     = _item.spr;
    _grid[# INFOS.IMAGE_IND, _destino]  = _item.img;
    _grid[# INFOS.NOME, _destino]       = _item.nome;
    _grid[# INFOS.DESCRICAO, _destino]  = _item.desc;
    _grid[# INFOS.TIPO, _destino]       = _item.tipo;
    _grid[# INFOS.PRECO, _destino]      = _item.preco;
    _grid[# INFOS.DANO, _destino]       = 0;
    _grid[# INFOS.ARMADURA, _destino]   = 0;
    _grid[# INFOS.VELOCIDADE, _destino] = 0;
    _grid[# INFOS.CURA, _destino]       = 0;
    _grid[# INFOS.NIVEL, _destino]      = 1;
    _grid[# INFOS.PASSIVAS, _destino]   = [];

    var _sala_id = get_room_id(global.current_sala);
    if (ds_map_exists(global.sala_com_bau, _sala_id)) {
        var _lista = ds_map_find_value(global.sala_com_bau, _sala_id);
        for (var _i = 0; _i < ds_list_size(_lista); _i++) {
            if (_lista[| _i] == _d) { ds_list_delete(_lista, _i); break; }
        }
    }
    ds_grid_destroy(_d.grid);
    inventory_pos_mudanca();
    instance_destroy(_inst);
}

#endregion
