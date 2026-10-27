// feather disable GM2017
// ============================================================================
//  MISSÕES E HISTÓRIA — scr_missoes  (pasta Scripts/MISSOES ou Scripts/NPC_DIALOGO)
// ----------------------------------------------------------------------------
//  - 10 missões de buscar itens, cada uma dada por um NPC que nasce perto do jogador.
//  - A ORDEM das missões é embaralhada a cada jogo novo (semente salva no save).
//  - A HISTÓRIA é contada por capítulos ligados à POSIÇÃO (1ª missão concluída,
//    2ª, ...), não à missão. Assim ela faz sentido em qualquer ordem.
//  - Só existe uma missão por vez. Depois de entregar, o NPC some e outro aparece.
//
//  COMO ADICIONAR UMA MISSÃO NOVA
//    1. Copie um bloco _missao(...) em missoes_definir_banco() e troque o id.
//    2. Pronto. Ela entra no sorteio da ordem (inclusive em saves antigos:
//       vai para o fim da fila).
//    Campos opcionais: bioma ("" = qualquer), requer (ids que precisam estar
//    concluídos antes), recompensa {moedas, xp, itens: [[id, qtd], ...]}.
//
//  COMO ADICIONAR UM TIPO DE OBJETIVO NOVO (ex.: "plantar", "visitar")
//    1. Crie um helper mobj_xxx() que devolve { tipo: "xxx", qtd, ... }.
//    2. Registre o tipo em missoes_definir_tipos() com as 5 funções.
//    3. Objetivo por evento: chame missoes_evento("xxx") de onde a ação acontece.
//
//  COMO ADICIONAR CAPÍTULOS DA HISTÓRIA
//    Acrescente arrays em global.missoes_historia.capitulos. Se houver mais
//    missões do que capítulos, as extras usam o texto de "capitulo_extra".
//
//  LIGAÇÕES COM O RESTO DO JOGO (uma linha em cada lugar)
//    obj_player      Step       -> missoes_tick();
//    obj_inventario  Draw GUI   -> missoes_desenhar_gui();      (no fim do evento)
//    item_ao_matar() (scr_passivas_itens) -> missoes_evento("abate");
//    jogo_salvar()   struct _d  -> missoes: missoes_save_dados(),
//    jogo_aplicar_save()        -> missoes_load_dados(_save_campo(_d, "missoes", undefined));
//    jogo_resetar_progresso()   -> missoes_resetar();
//    obj_npc_missao: Create -> npc_missao_criar();  Step -> npc_missao_step();
//                    Draw   -> npc_missao_desenhar();
// ============================================================================

#region ---------- CONFIGURAÇÃO ----------

#macro MISSAO_NPC_OBJ          obj_npc_missao
#macro MISSAO_DIST_FALAR       70            // px: distância para apertar F e falar
#macro MISSAO_DIST_FECHAR      200           // px: diálogo fecha se o jogador se afastar
#macro MISSAO_SPAWN_MIN        350           // px do jogador onde o NPC pode nascer
#macro MISSAO_SPAWN_MAX        900
#macro MISSAO_SPAWN_BIOMA_MAX  2600          // até onde procura o bioma pedido pela missão
#macro MISSAO_ITEM_SPAWN_MIN   450           // itens "espalhados" caem a esta distância do NPC
#macro MISSAO_ITEM_SPAWN_MAX   1300
#macro MISSAO_TEMPO_PRIMEIRA   (60 * 5)      // frames até o 1º NPC aparecer
#macro MISSAO_TEMPO_PROXIMA    (60 * 12)     // frames entre uma missão e a próxima
#macro MISSAO_DLG_VEL          1.3           // letras por frame no diálogo
#macro MISSAO_HUD_Y            0.26          // altura do painel (fração da GUI)
#macro MISSAO_NARRADOR         "Voz do Labirinto"

/// Visuais dos NPCs (mesma ordem de obj_humano_cidade / HUMANOS_VARIANTES)
function missoes_visuais() {
    return [
        spr_humano_vendedora, spr_humano_executivo, spr_humano_vovo,
        spr_humano_carteiro,  spr_humano_padeiro,   spr_humano_jardineira,
        spr_humano_lenhador,  spr_humano_florista,  spr_humano_vovozinho
    ];
}

/// O jogador está no mundo aberto? (onde os NPCs de missão podem nascer)
function missoes_no_mundo() {
    return instance_exists(obj_player) && instance_exists(obj_otimizador);
}

#endregion

#region ---------- BANCO DE MISSÕES (adicione missões aqui) ----------

// Objetivos -------------------------------------------------------------
/// Ter _qtd do item na mochila (é entregue ao NPC). _espalhar = quantos caem
/// no mundo perto do NPC quando a missão é aceita (0 = nenhum).
function mobj_item(_item, _qtd, _espalhar = 0) { return { tipo: "item",  item: _item, qtd: _qtd, espalhar: _espalhar }; }
/// Derrotar _qtd monstros depois de aceitar a missão
function mobj_abate(_qtd)                      { return { tipo: "abate", qtd: _qtd }; }

function missoes_definir_banco() {
    global.missoes_db    = {};
    global.missoes_lista = [];

    _missao("bolo_padaria", {
        titulo: "O Bolo da Padaria",
        npc: { nome: "Seu Joaquim", variante: 4 },
        bioma: "cidade",
        objetivos: [ mobj_item("madeira", 6), mobj_item("leite", 2) ],
        recompensa: { moedas: 60, xp: 80, itens: [["biscoito", 5]] },
        falas: {
            intro:    ["Ah, pequeno! Que bom que você apareceu!",
                       "Meu forno apagou e o bolo da festa da cidade não fica pronto sem lenha.",
                       "E o leite acabou também... Você me ajuda?"],
            lembrete: ["O forno está esfriando... depressa!"],
            fim:      ["Que cheirinho! O bolo vai ficar perfeito.",
                       "Leve uns biscoitos fresquinhos para a viagem."],
        },
    });

    _missao("cartas_vento", {
        titulo: "Cartas ao Vento",
        npc: { nome: "Seu Valdir, o carteiro", variante: 3 },
        bioma: "cidade",
        objetivos: [ mobj_item("papel", 5, 5) ],
        recompensa: { moedas: 50, xp: 90, itens: [["tenis_corrida", 1]] },
        falas: {
            intro:    ["Uma ventania levou todas as minhas cartas!",
                       "Elas viraram papéis coloridos espalhados por aí. Junta 5 para mim?"],
            lembrete: ["Cada carta é o recado de alguém que sente saudade."],
            fim:      ["Todas aqui! Agora cada um vai receber seu recado.",
                       "Fique com estes tênis. Carteiro que se preza corre muito!"],
        },
    });

    _missao("jardim_sem_cor", {
        titulo: "O Jardim sem Cor",
        npc: { nome: "Dona Rosa", variante: 5 },
        objetivos: [ mobj_item("erva", 6), mobj_item("giz", 3) ],
        recompensa: { moedas: 70, xp: 90, itens: [["vitamina", 2]] },
        falas: {
            intro:    ["Meu jardim perdeu a cor de um dia para o outro...",
                       "Preciso de ervas vermelhas para replantar.",
                       "E de giz de cera para pintar as plaquinhas dos canteiros."],
            lembrete: ["As flores ficam tristes sem cor, sabia?"],
            fim:      ["Olha só! Vermelho, azul, amarelo... o jardim acordou!",
                       "Tome esta vitamina. Quem cuida das plantas também precisa se cuidar."],
        },
    });

    _missao("lenha_inverno", {
        titulo: "Lenha para o Inverno",
        npc: { nome: "Seu Bento, o lenhador", variante: 6 },
        objetivos: [ mobj_item("madeira", 12), mobj_item("pedra", 5) ],
        recompensa: { moedas: 40, xp: 110, itens: [["machado_ferro", 1]] },
        falas: {
            intro:    ["O inverno está chegando e minha cabana está sem lenha.",
                       "Preciso de bastante madeira e de umas pedras para a lareira."],
            lembrete: ["Árvore boa é árvore grossa. Bate com vontade!"],
            fim:      ["Agora sim, vou passar o inverno quentinho.",
                       "Este machado de ferro era do meu avô. Agora é seu."],
        },
    });

    _missao("novelo_vovo", {
        titulo: "Os Novelos da Vovó",
        npc: { nome: "Vó Cida", variante: 2 },
        objetivos: [ mobj_item("la", 3, 3), mobj_item("botao", 4) ],
        recompensa: { moedas: 40, xp: 100, itens: [["gorro_la", 1]] },
        falas: {
            intro:    ["Você viu meu gato por aí? Ele brincou com meus novelos e espalhou tudo!",
                       "Traz de volta os novelos de lã e uns botões coloridos?",
                       "Quero terminar um gorrinho antes do frio."],
            lembrete: ["Os novelos rolaram para longe, procure bem."],
            fim:      ["Meus novelos! Você é um anjo.",
                       "O gorrinho ficou pronto... e ficou do seu tamanho!"],
        },
    });

    _missao("buque_festa", {
        titulo: "Buquê para a Festa",
        npc: { nome: "Lia, a florista", variante: 7 },
        bioma: "cidade",
        objetivos: [ mobj_item("erva", 4), mobj_item("pena", 3), mobj_item("papel", 3) ],
        recompensa: { moedas: 60, xp: 100, itens: [["pirulito", 3]] },
        falas: {
            intro:    ["Tem casamento hoje e eu ainda não montei o buquê!",
                       "Preciso de ervas, penas macias e papel colorido para embrulhar."],
            lembrete: ["A noiva já está chegando... socorro!"],
            fim:      ["Ficou lindo! O mais bonito que eu já fiz.",
                       "Pirulitos da festa, pode pegar!"],
        },
    });

    _missao("reuniao_importante", {
        titulo: "Monstros no Escritório",
        npc: { nome: "Dr. Otávio", variante: 1 },
        bioma: "cidade",
        objetivos: [ mobj_item("pilha", 3), mobj_abate(12) ],
        recompensa: { moedas: 120, xp: 140, itens: [["lanterna", 1]] },
        falas: {
            intro:    ["Tenho a reunião mais importante da minha vida e a luz acabou!",
                       "Preciso de pilhas para a lanterna...",
                       "E tem monstros rondando o escritório. Espanta uns 12 para mim?"],
            lembrete: ["Meus clientes não gostam de monstros. Nem eu."],
            fim:      ["Reunião salva! Você daria um ótimo sócio.",
                       "Fique com a lanterna. A noite aqui é escura."],
        },
    });

    _missao("estoque_vendedora", {
        titulo: "A Banca Vazia",
        npc: { nome: "Dona Marli", variante: 0 },
        bioma: "cidade",
        objetivos: [ mobj_item("maca", 5), mobj_item("banana", 3), mobj_item("uva", 3) ],
        recompensa: { moedas: 100, xp: 120, itens: [["bau_madeira", 1]] },
        falas: {
            intro:    ["Minha banca de frutas está vazia!",
                       "Se você me trouxer maçãs, bananas e uvas, eu te pago direitinho."],
            lembrete: ["Fruta fresca vende sozinha. Só falta ter fruta!"],
            fim:      ["Banca cheia de novo! Obrigada, freguês.",
                       "Leve este baú para guardar suas coisas."],
        },
    });

    _missao("oculos_vovo", {
        titulo: "Os Óculos do Vovô",
        npc: { nome: "Vô Tonico", variante: 8 },
        objetivos: [ mobj_item("gude", 3, 3), mobj_item("frasco", 2) ],
        recompensa: { moedas: 80, xp: 120, itens: [["curativo", 3]] },
        falas: {
            intro:    ["Hã? Quem está aí? Não enxergo nada sem meus óculos...",
                       "Eles caíram e as lentes rolaram. Pareciam bolinhas de gude!",
                       "Traga também dois frascos vazios, que eu guardo as lentes neles."],
            lembrete: ["Ainda vejo tudo embaçado, meu neto."],
            fim:      ["Ah, agora eu te vejo! Que criança corajosa.",
                       "Tome uns curativos. No meu tempo a gente ralava muito o joelho."],
        },
    });

    _missao("po_estrelas", {
        titulo: "O Céu Apagado",
        npc: { nome: "Seu Astolfo, o astrônomo", variante: 1 },
        objetivos: [ mobj_item("po_estrela", 2), mobj_item("vela", 3), mobj_item("ouro", 1) ],
        recompensa: { moedas: 150, xp: 200, itens: [["pote_vagalumes", 1]] },
        falas: {
            intro:    ["As estrelas estão sumindo do céu, uma por uma.",
                       "Com pó de estrela, velas e um pouco de ouro eu monto um farol para chamá-las."],
            lembrete: ["Olhe para cima... ainda faltam estrelas."],
            fim:      ["Veja! Elas voltaram a brilhar.",
                       "Leve este pote de vaga-lumes. É um pedacinho do céu."],
        },
    });

    missoes_definir_historia();
}

/// Registra uma missão e preenche os campos que faltarem
function _missao(_id, _m) {
    _m.id = _id;
    _mdef(_m, "titulo", _id);
    _mdef(_m, "bioma", "");
    _mdef(_m, "requer", []);
    _mdef(_m, "objetivos", []);
    _mdef(_m, "npc", {});
    _mdef(_m.npc, "nome", "???");
    _mdef(_m.npc, "variante", 0);
    _mdef(_m, "recompensa", {});
    _mdef(_m.recompensa, "moedas", 0);
    _mdef(_m.recompensa, "xp", 0);
    _mdef(_m.recompensa, "itens", []);
    _mdef(_m, "falas", {});
    _mdef(_m.falas, "intro", ["Preciso da sua ajuda!"]);
    _mdef(_m.falas, "lembrete", ["Ainda estou esperando..."]);
    _mdef(_m.falas, "fim", ["Muito obrigado!"]);
    if (variable_struct_exists(global.missoes_db, _id)) show_debug_message("[MISSÕES] id repetido: " + _id);
    else array_push(global.missoes_lista, _id);
    global.missoes_db[$ _id] = _m;
}

function _mdef(_s, _campo, _padrao) {
    if (!variable_struct_exists(_s, _campo)) _s[$ _campo] = _padrao;
}

#endregion

#region ---------- HISTÓRIA (capítulos por posição) ----------
// Falas: string = narrador. Array [quem, texto] = outra pessoa ("voce" = o jogador).

function missoes_definir_historia() {
    global.missoes_historia = {
        abertura: [
            "Este lugar parece uma cidade... mas é feito das suas lembranças.",
            "As pessoas daqui perderam pedaços de si. Cada ajuda devolve um Fragmento de Memória.",
            "Junte todos e talvez você encontre a saída do Labirinto.",
        ],
        capitulos: [
            ["Um Fragmento de Memória brilha: o cheiro de bolo saindo do forno. Alguém cantava na cozinha."],
            ["Outro fragmento: mãos grandes segurando as suas. Seus primeiros passos, tropeçando e rindo."],
            ["Você se lembra de uma bicicleta vermelha. E de alguém soltando o banco sem avisar."],
            ["Uma noite de tempestade. Você tinha medo do escuro, e uma luz ficou acesa no corredor."],
            ["Um amigo que só você enxergava. Ele morava debaixo da cama e contava piadas ruins."],
            ["O primeiro dia de escola. A mochila era maior que você, e você não quis soltar a mão."],
            ["Um joelho ralado, um curativo de dinossauro e um beijo para sarar mais rápido."],
            ["Um aniversário com velas que não apagavam. Todo mundo riu, até você."],
            ["Uma despedida na rodoviária. Alguém prometeu escrever cartas... e escreveu."],
            ["O último fragmento é um espelho. A criança do reflexo é você, só que um pouco maior."],
        ],
        capitulo_extra: ["Mais um Fragmento de Memória brilha no seu bolso."],
        final: [
            "Todos os fragmentos se juntam num só.",
            "O Labirinto não era um lugar para fugir. Era um lugar para crescer.",
            ["voce", "...eu lembro agora. Eu lembro de tudo."],
            "As pessoas da cidade acenam. Elas sempre estiveram aqui, dentro de você.",
        ],
        recompensa_final: { moedas: 300, xp: 500, itens: [["coroa_dourada", 1]] },
    };
}

#endregion

#region ---------- TIPOS DE OBJETIVO (adicione tipos aqui) ----------
// Cada tipo: evento ("" = calculado), progresso, nome, ao_aceitar, entregar.
// Todas recebem (_o objetivo, _mid id da missão, _i índice do objetivo).

function missoes_definir_tipos() {
    global.missoes_tipos = {
        item: {
            evento:     "",
            progresso:  mtipo_item_progresso,
            nome:       mtipo_item_nome,
            ao_aceitar: mtipo_item_aceitar,
            entregar:   mtipo_item_entregar,
        },
        abate: {
            evento:     "abate",
            progresso:  mtipo_contador_progresso,
            nome:       function(_o) { return "Monstros derrotados"; },
            ao_aceitar: mtipo_nada,
            entregar:   mtipo_nada,
        },
    };
}

function mtipo_nada() {}
function mtipo_contador_progresso(_o, _mid, _i) { return missoes_contador(_mid, _i); }

function mtipo_item_progresso(_o, _mid, _i) { return inventory_count_item(_o.item); }
function mtipo_item_nome(_o) {
    var _d = item_db(_o.item);
    return is_undefined(_d) ? _o.item : _d.nome;
}
function mtipo_item_aceitar(_o, _mid, _i) {
    if (_o.espalhar <= 0) return;
    var _M = global.missoes;
    repeat (_o.espalhar) {
        var _p = missoes_achar_ponto(_M.npc_x, _M.npc_y, MISSAO_ITEM_SPAWN_MIN, MISSAO_ITEM_SPAWN_MAX, "");
        item_criar_no_mundo(_p[0], _p[1], _o.item, 1, 1, []);
    }
}
function mtipo_item_entregar(_o, _mid, _i) { inventory_remove_item(_o.item, _o.qtd); }

#endregion

#region ---------- ESTADO ----------

function missoes_garantir() {
    if (!variable_global_exists("missoes_db")) {
        missoes_definir_tipos();
        missoes_definir_banco();
        missoes_validar();
    }
    if (!variable_global_exists("missoes") || !is_struct(global.missoes)) {
        global.missoes = missoes_estado_novo(irandom_range(1, 999999));
    }
    if (!variable_global_exists("missoes_dlg") || !is_struct(global.missoes_dlg)) {
        global.missoes_dlg = { aberto: false, falas: [], i: 0, chars: 0, npc: noone, ao_fim: undefined, trava: false, espera: 0 };
    }
}

/// Avisa no console se alguma missão usa item ou tipo que não existe
function missoes_validar() {
    for (var _i = 0; _i < array_length(global.missoes_lista); _i++) {
        var _m = global.missoes_db[$ global.missoes_lista[_i]];
        for (var _j = 0; _j < array_length(_m.objetivos); _j++) {
            var _o = _m.objetivos[_j];
            if (is_undefined(global.missoes_tipos[$ _o.tipo])) show_debug_message("[MISSÕES] " + _m.id + ": tipo de objetivo desconhecido '" + string(_o.tipo) + "'");
            if (_o.tipo == "item" && variable_global_exists("itens_db") && is_undefined(item_db(_o.item)))
                show_debug_message("[MISSÕES] " + _m.id + ": item inexistente '" + string(_o.item) + "'");
        }
    }
}

function missoes_estado_novo(_seed) {
    return {
        seed:           _seed,
        ordem:          missoes_embaralhar(global.missoes_lista, _seed),
        estado:         {},      // id -> "ativa" | "concluida"   (sem chave = não iniciada)
        contadores:     {},      // id -> [n por objetivo]  (objetivos por evento)
        atual:          "",
        npc_ok:         false,   // já escolheu onde o NPC da missão atual fica
        npc_x:          0,
        npc_y:          0,
        timer:          MISSAO_TEMPO_PRIMEIRA,
        concluidas:     0,
        abertura_vista: false,
        final_visto:    false,
        itens_pendentes:false,   // re-espalhar itens depois de carregar o save
    };
}

/// Fisher-Yates com gerador próprio (não mexe no random do jogo)
function missoes_embaralhar(_lista, _seed) {
    var _n = array_length(_lista);
    var _a = array_create(_n);
    array_copy(_a, 0, _lista, 0, _n);
    var _s = (abs(floor(_seed)) mod 2147483646) + 1;
    for (var _i = _n - 1; _i > 0; _i--) {
        _s = (_s * 48271) mod 2147483647;
        var _j = _s mod (_i + 1);
        var _t = _a[_i]; _a[_i] = _a[_j]; _a[_j] = _t;
    }
    return _a;
}

function missoes_db_get(_id) {
    if (!is_string(_id) || _id == "" || !variable_global_exists("missoes_db")) return undefined;
    return global.missoes_db[$ _id];
}

function missoes_estado(_id) {
    if (!is_string(_id) || _id == "") return "";
    var _e = global.missoes.estado[$ _id];
    return is_undefined(_e) ? "" : _e;
}

function missoes_total() { return array_length(global.missoes_lista); }

function missoes_contador(_mid, _i) {
    var _c = global.missoes.contadores[$ _mid];
    return (is_array(_c) && _i < array_length(_c)) ? _c[_i] : 0;
}

/// Próxima missão: uma ativa, senão a primeira da ordem não concluída cujos requisitos estão ok
function missoes_proxima() {
    var _M = global.missoes;
    for (var _i = 0; _i < array_length(_M.ordem); _i++) if (missoes_estado(_M.ordem[_i]) == "ativa") return _M.ordem[_i];
    for (var _i = 0; _i < array_length(_M.ordem); _i++) {
        var _id = _M.ordem[_i];
        var _m = missoes_db_get(_id);
        if (is_undefined(_m) || missoes_estado(_id) == "concluida") continue;
        var _ok = true;
        for (var _r = 0; _r < array_length(_m.requer); _r++) if (missoes_estado(_m.requer[_r]) != "concluida") { _ok = false; break; }
        if (_ok) return _id;
    }
    return "";
}

function missoes_jogador() {
    if (variable_global_exists("current_player") && instance_exists(global.current_player)) return global.current_player;
    return instance_find(obj_player, 0);
}

#endregion

#region ---------- CICLO (chamado no Step do obj_player) ----------

function missoes_tick() {
    missoes_garantir();
    missoes_dialogo_step();
    if (!missoes_no_mundo()) return;
    if (instance_exists(obj_inventario) && obj_inventario.is_open) return;
    if (variable_global_exists("level_up") && global.level_up) return;

    var _M = global.missoes;
    if (_M.atual == "") {
        _M.atual = missoes_proxima();
        _M.npc_ok = false;
        if (_M.atual == "") return;                    // todas concluídas
    }
    var _m = missoes_db_get(_M.atual);
    if (is_undefined(_m)) { _M.atual = ""; return; }

    // 1. Escolhe onde o NPC vai nascer (depois de uma pausa)
    if (!_M.npc_ok) {
        if (_M.timer > 0) { _M.timer--; return; }
        var _p = missoes_jogador();
        if (_p == noone) return;
        var _pt = missoes_achar_ponto(_p.x, _p.y, MISSAO_SPAWN_MIN, MISSAO_SPAWN_MAX, _m.bioma);
        _M.npc_x = _pt[0];
        _M.npc_y = _pt[1];
        _M.npc_ok = true;
        inventory_msg((missoes_estado(_M.atual) == "ativa") ? _m.npc.nome + " ainda espera por você." : "Alguém precisa da sua ajuda! Siga a seta.", ui_cor("ouro"));
    }

    // 2. Garante que a instância do NPC existe (recria se a sala mudou)
    var _mid = _M.atual, _tem = false;
    with (MISSAO_NPC_OBJ) if (missao_id == _mid && !saindo) _tem = true;
    if (!_tem) instance_create_depth(_M.npc_x, _M.npc_y, -_M.npc_y, MISSAO_NPC_OBJ, { missao_id: _mid });

    // 3. Depois de carregar o save, os itens espalhados sumiram com o mapa: espalha de novo
    if (_M.itens_pendentes) {
        _M.itens_pendentes = false;
        if (missoes_estado(_mid) == "ativa") missoes_chamar_tipos(_mid, "ao_aceitar");
    }
}

/// Chama uma função do tipo em todos os objetivos da missão
function missoes_chamar_tipos(_mid, _func) {
    var _m = missoes_db_get(_mid);
    if (is_undefined(_m)) return;
    for (var _i = 0; _i < array_length(_m.objetivos); _i++) {
        var _o = _m.objetivos[_i];
        var _t = global.missoes_tipos[$ _o.tipo];
        if (is_undefined(_t)) continue;
        var _fn = _t[$ _func];
        if (!is_undefined(_fn)) _fn(_o, _mid, _i);
    }
}

/// Ponto livre perto de (_cx,_cy). Com _bioma, procura primeiro nele (cada vez mais longe).
function missoes_achar_ponto(_cx, _cy, _min, _max, _bioma) {
    if (_bioma != "") {
        for (var _t = 0; _t < 80; _t++) {
            var _d = random_range(_min, lerp(_max, MISSAO_SPAWN_BIOMA_MAX, _t / 80));
            var _a = random(360);
            var _x = _cx + lengthdir_x(_d, _a), _y = _cy + lengthdir_y(_d, _a);
            if (terreno_bioma_em(_x, _y) == _bioma && missoes_ponto_livre(_x, _y)) return [_x, _y];
        }
    }
    repeat (60) {
        var _d = random_range(_min, _max);
        var _a = random(360);
        var _x = _cx + lengthdir_x(_d, _a), _y = _cy + lengthdir_y(_d, _a);
        if (missoes_ponto_livre(_x, _y)) return [_x, _y];
    }
    return [_cx + _min, _cy];
}

function missoes_ponto_livre(_x, _y) {
    if (_x < 48 || _y < 48 || _x > room_width - 48 || _y > room_height - 48) return false;
    if (collision_circle(_x, _y, 22, obj_estrutura, false, true) != noone) return false;
    if (collision_circle(_x, _y, 22, obj_par_cenario, false, true) != noone) return false;
    if (terreno_bioma_em(_x, _y) == "cidade" && cidade_tipo_em(_x, _y) == CID_RUA) return false;
    return true;
}

/// Eventos de objetivos (ex.: missoes_evento("abate") em item_ao_matar)
function missoes_evento(_evento, _valor = 1) {
    if (!variable_global_exists("missoes") || !is_struct(global.missoes)) return;
    var _mid = global.missoes.atual;
    if (missoes_estado(_mid) != "ativa") return;
    var _m = missoes_db_get(_mid);
    var _c = global.missoes.contadores[$ _mid];
    if (!is_array(_c)) return;
    var _avisar = false;
    for (var _i = 0; _i < array_length(_m.objetivos); _i++) {
        var _o = _m.objetivos[_i];
        var _t = global.missoes_tipos[$ _o.tipo];
        if (is_undefined(_t) || _t.evento != _evento) continue;
        var _antes = global.missoes.contadores[$ _mid][_i];
        global.missoes.contadores[$ _mid][_i] = _antes + _valor;
        if (_antes < _o.qtd && _antes + _valor >= _o.qtd) _avisar = true;
    }
    if (_avisar && missao_pronta(_mid)) inventory_msg("Missão pronta! Volte e fale com " + _m.npc.nome + ".", ui_cor("verde"));
}

#endregion

#region ---------- AÇÕES (aceitar, entregar, recompensa) ----------

function missao_progresso(_mid, _i) {
    var _m = missoes_db_get(_mid);
    var _o = _m.objetivos[_i];
    var _t = global.missoes_tipos[$ _o.tipo];
    if (is_undefined(_t)) return 0;
    return min(_o.qtd, _t.progresso(_o, _mid, _i));
}

function missao_pronta(_mid) {
    var _m = missoes_db_get(_mid);
    if (is_undefined(_m) || missoes_estado(_mid) != "ativa") return false;
    for (var _i = 0; _i < array_length(_m.objetivos); _i++) if (missao_progresso(_mid, _i) < _m.objetivos[_i].qtd) return false;
    return true;
}

/// "Madeira x6, Leite x2"  (_so_faltando = mostra só o que falta, com x/y)
function missoes_objetivos_texto(_mid, _so_faltando) {
    var _m = missoes_db_get(_mid);
    var _partes = [];
    for (var _i = 0; _i < array_length(_m.objetivos); _i++) {
        var _o = _m.objetivos[_i];
        var _t = global.missoes_tipos[$ _o.tipo];
        var _nome = is_undefined(_t) ? _o.tipo : _t.nome(_o);
        if (!_so_faltando) array_push(_partes, _nome + " x" + string(_o.qtd));
        else {
            var _p = missao_progresso(_mid, _i);
            if (_p < _o.qtd) array_push(_partes, _nome + " " + string(_p) + "/" + string(_o.qtd));
        }
    }
    return missoes_juntar(_partes, ", ");
}

function missoes_juntar(_arr, _sep) {
    var _s = "";
    for (var _i = 0; _i < array_length(_arr); _i++) _s += (_i > 0 ? _sep : "") + string(_arr[_i]);
    return _s;
}

function missao_aceitar(_mid) {
    var _M = global.missoes;
    var _m = missoes_db_get(_mid);
    if (is_undefined(_m) || missoes_estado(_mid) != "") return;
    _M.estado[$ _mid] = "ativa";
    _M.contadores[$ _mid] = array_create(array_length(_m.objetivos), 0);
    missoes_chamar_tipos(_mid, "ao_aceitar");
    inventory_msg("Nova missão: " + _m.titulo, ui_cor("ouro"));
    if (missao_pronta(_mid)) inventory_msg("Você já tem tudo! Fale com " + _m.npc.nome + ".", ui_cor("verde"));
}

/// Entrega, dá a recompensa e monta as falas finais (+ capítulo da história).
/// O estado muda na hora (se o jogador sair no meio do diálogo, nada se perde).
function missao_concluir(_mid, _npc) {
    var _M = global.missoes;
    var _m = missoes_db_get(_mid);
    if (!missao_pronta(_mid)) return;

    missoes_chamar_tipos(_mid, "entregar");
    var _txt_rec = missoes_dar_recompensa(_m.recompensa);
    _M.estado[$ _mid] = "concluida";
    _M.concluidas += 1;
    _M.atual  = "";
    _M.npc_ok = false;
    _M.timer  = MISSAO_TEMPO_PROXIMA;

    var _falas = [];
    missoes_falas_add(_falas, _m.falas.fim, _m.npc.nome, _m.npc.variante);
    if (_txt_rec != "") array_push(_falas, { quem: "", txt: "Recompensa: " + _txt_rec, retrato: -1 });

    var _H = global.missoes_historia;
    var _n = _M.concluidas, _tot = missoes_total();
    var _cap = (_n - 1 < array_length(_H.capitulos)) ? _H.capitulos[_n - 1] : _H.capitulo_extra;
    array_push(_falas, { quem: MISSAO_NARRADOR, txt: "Fragmento de Memória " + string(_n) + "/" + string(_tot), retrato: -1 });
    missoes_falas_add(_falas, _cap, MISSAO_NARRADOR, -1);

    if (_n >= _tot && !_M.final_visto) {
        _M.final_visto = true;
        missoes_falas_add(_falas, _H.final, MISSAO_NARRADOR, -1);
        var _rf = missoes_dar_recompensa(_H.recompensa_final);
        if (_rf != "") array_push(_falas, { quem: "", txt: "Recompensa final: " + _rf, retrato: -1 });
    }

    inventory_msg("Missão concluída: " + _m.titulo, ui_cor("verde"));
    missoes_dialogo_abrir(_falas, _npc, method(undefined, function() {
        with (MISSAO_NPC_OBJ) if (missoes_estado(missao_id) == "concluida") saindo = true;
    }));
}

/// Entrega moedas, XP e itens. Devolve o texto "60 moedas, 80 XP, Biscoito x5".
function missoes_dar_recompensa(_r) {
    var _partes = [];
    var _moedas = variable_struct_exists(_r, "moedas") ? _r.moedas : 0;
    var _xp     = variable_struct_exists(_r, "xp") ? _r.xp : 0;
    var _itens  = variable_struct_exists(_r, "itens") ? _r.itens : [];
    if (_moedas > 0) { global.moedas += _moedas; array_push(_partes, string(_moedas) + " moedas"); }
    if (_xp > 0)     { global.xp     += _xp;     array_push(_partes, string(_xp) + " XP"); }
    for (var _i = 0; _i < array_length(_itens); _i++) {
        var _id = _itens[_i][0], _q = _itens[_i][1];
        var _d = item_db(_id);
        if (is_undefined(_d)) continue;
        if (!inventory_add(_id, _q)) {                       // mochila cheia: cai no chão
            var _p = missoes_jogador();
            if (_p != noone) item_criar_no_mundo(_p.x, _p.y + 12, _id, _q);
        }
        array_push(_partes, _d.nome + (_q > 1 ? " x" + string(_q) : ""));
    }
    return missoes_juntar(_partes, ", ");
}

/// Converte falas do banco em { quem, txt, retrato }
function missoes_falas_add(_dest, _src, _quem, _retrato) {
    for (var _i = 0; _i < array_length(_src); _i++) {
        var _f = _src[_i];
        if (is_string(_f)) array_push(_dest, { quem: _quem, txt: _f, retrato: _retrato });
        else if (is_array(_f)) {
            var _q = (_f[0] == "voce") ? "Você" : _f[0];
            array_push(_dest, { quem: _q, txt: _f[1], retrato: -1 });
        }
    }
}

/// Jogador apertou F perto do NPC
function missoes_interagir(_npc) {
    var _M = global.missoes;
    var _mid = _npc.missao_id;
    var _m = missoes_db_get(_mid);
    if (is_undefined(_m)) return;
    var _est = missoes_estado(_mid);
    var _falas = [];

    if (_est == "") {
        if (!_M.abertura_vista) {
            _M.abertura_vista = true;
            missoes_falas_add(_falas, global.missoes_historia.abertura, MISSAO_NARRADOR, -1);
        }
        missoes_falas_add(_falas, _m.falas.intro, _m.npc.nome, _m.npc.variante);
        array_push(_falas, { quem: _m.npc.nome, txt: "Preciso de: " + missoes_objetivos_texto(_mid, false) + ".", retrato: _m.npc.variante });
        missoes_dialogo_abrir(_falas, _npc, method(undefined, function() { missao_aceitar(global.missoes.atual); }));
    }
    else if (_est == "ativa") {
        if (missao_pronta(_mid)) { missao_concluir(_mid, _npc); return; }
        missoes_falas_add(_falas, _m.falas.lembrete, _m.npc.nome, _m.npc.variante);
        array_push(_falas, { quem: _m.npc.nome, txt: "Ainda falta: " + missoes_objetivos_texto(_mid, true) + ".", retrato: _m.npc.variante });
        missoes_dialogo_abrir(_falas, _npc, undefined);
    }
}

#endregion

#region ---------- DIÁLOGO ----------

function missoes_dialogo_aberto() {
    return variable_global_exists("missoes_dlg") && is_struct(global.missoes_dlg) && global.missoes_dlg.aberto;
}

function missoes_dialogo_abrir(_falas, _npc, _ao_fim) {
    if (array_length(_falas) == 0) return;
    var _d = global.missoes_dlg;
    _d.aberto = true;
    _d.falas  = _falas;
    _d.i      = 0;
    _d.chars  = 0;
    _d.npc    = _npc;
    _d.ao_fim = _ao_fim;
    _d.trava  = true;      // ignora o mesmo F que abriu
}

function missoes_dialogo_fechar(_completo) {
    var _d = global.missoes_dlg;
    var _cb = _d.ao_fim;
    _d.aberto = false;
    _d.ao_fim = undefined;
    _d.espera = 12;        // evita reabrir com o mesmo F
    if (_completo && is_method(_cb)) _cb();
}

function missoes_dialogo_step() {
    var _d = global.missoes_dlg;
    if (_d.espera > 0) _d.espera--;
    if (!_d.aberto) return;
    if (_d.trava) { _d.trava = false; return; }

    var _p = missoes_jogador();
    if (instance_exists(_d.npc) && _p != noone && point_distance(_p.x, _p.y, _d.npc.x, _d.npc.y) > MISSAO_DIST_FECHAR) {
        missoes_dialogo_fechar(false);
        return;
    }
    var _len = string_length(_d.falas[_d.i].txt);
    _d.chars = min(_len, _d.chars + MISSAO_DLG_VEL);
    if (tecla_apertou("interagir") || keyboard_check_pressed(vk_enter)) {
        if (_d.chars < _len) _d.chars = _len;
        else {
            _d.i++;
            _d.chars = 0;
            if (_d.i >= array_length(_d.falas)) missoes_dialogo_fechar(true);
        }
    }
}

#endregion

#region ---------- NPC DE MISSÃO (eventos do obj_npc_missao) ----------

function npc_missao_criar() {
    if (!variable_instance_exists(id, "missao_id")) missao_id = "";
    var _m   = missoes_db_get(missao_id);
    var _vis = missoes_visuais();
    variante     = is_undefined(_m) ? 0 : clamp(_m.npc.variante, 0, array_length(_vis) - 1);
    nome         = is_undefined(_m) ? "???" : _m.npc.nome;
    sprite_index = _vis[variante];
    image_speed  = 0;
    image_index  = 1;
    dir      = 0;          // 0 baixo, 1 esquerda, 2 direita, 3 cima
    saindo   = false;
    alfa     = 0;
    balanco  = random(360);
    perto    = false;
    olhar_t  = irandom_range(90, 240);
}

function npc_missao_step() {
    depth = -y;
    balanco = (balanco + 4) mod 360;

    if (saindo) {
        alfa -= 0.03;
        if (alfa <= 0) instance_destroy();
        return;
    }
    alfa = min(1, alfa + 0.05);

    var _conversando = missoes_dialogo_aberto() && global.missoes_dlg.npc == id;
    // a missão mudou (e não está falando comigo) -> vai embora
    if (!_conversando && (!variable_global_exists("missoes") || global.missoes.atual != missao_id)) { saindo = true; return; }
    // duplicado (sala reativada): fica só o mais antigo
    var _eu = id, _dup = false;
    with (MISSAO_NPC_OBJ) if (id < _eu && missao_id == _eu.missao_id && !saindo) _dup = true;
    if (_dup) { instance_destroy(); return; }

    if (instance_exists(obj_inventario) && obj_inventario.is_open) return;
    if (variable_global_exists("level_up") && global.level_up) return;

    var _p = missoes_jogador();
    perto = false;
    if (_p != noone) {
        var _dist = point_distance(x, y, _p.x, _p.y);
        perto = (_dist < MISSAO_DIST_FALAR);
        if (_dist < 160) {                                     // olha para o jogador
            var _dx = _p.x - x, _dy = _p.y - y;
            if (abs(_dx) > abs(_dy)) dir = (_dx < 0) ? 1 : 2;
            else dir = (_dy < 0) ? 3 : 0;
        } else {                                               // olha em volta
            olhar_t--;
            if (olhar_t <= 0) { dir = choose(0, 0, 1, 2); olhar_t = irandom_range(90, 240); }
        }
        if (perto && !missoes_dialogo_aberto() && global.missoes_dlg.espera <= 0 && tecla_apertou("interagir")) missoes_interagir(id);
    }
    image_index = dir * 4 + 1;
    global.missoes.npc_x = x;
    global.missoes.npc_y = y;
}

function npc_missao_desenhar() {
    if (sprite_exists(spr_sombra)) draw_sprite_ext(spr_sombra, 0, x, y - 1, 0.9, 0.8, 0, c_white, 0.55 * alfa);
    draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, c_white, alfa);
    if (saindo) exit;

    // Ícone acima da cabeça: "!" = missão nova, "?" dourado = pronta, "?" cinza = em andamento
    var _est = missoes_estado(missao_id);
    var _simb = (_est == "") ? "!" : "?";
    var _cor  = (_est == "" || missao_pronta(missao_id)) ? make_color_rgb(255, 200, 58) : make_color_rgb(190, 180, 170);
    var _iy = y - 122 + dsin(balanco) * 3;
    draw_set_alpha(alfa);
    draw_set_color(make_color_rgb(52, 32, 26));
    draw_circle(x, _iy, 10, false);
    draw_set_color(_cor);
    draw_circle(x, _iy, 8, false);
    draw_set_font(fnt_dialogos);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(72, 46, 34));
    draw_text_transformed(x, _iy, _simb, 0.4, 0.4, 0);

    // Nome e dica quando perto
    if (perto && !missoes_dialogo_aberto()) {
        var _t = nome + "   [" + tecla_nome(tecla("interagir")) + "] Falar";
        var _esc = 0.28;
        var _w = string_width(_t) * _esc / 2 + 6;
        var _ty = y - 142;
        draw_set_color(make_color_rgb(52, 32, 26));
        draw_set_alpha(0.8 * alfa);
        draw_roundrect_ext(x - _w, _ty - 8, x + _w, _ty + 8, 8, 8, false);
        draw_set_alpha(alfa);
        draw_set_color(make_color_rgb(255, 250, 238));
        draw_text_transformed(x, _ty, _t, _esc, _esc, 0);
    }
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

#endregion

#region ---------- GUI (painel, seta e caixa de diálogo) ----------

/// Chamar no Draw GUI do obj_inventario
function missoes_desenhar_gui() {
    if (!variable_global_exists("missoes") || !is_struct(global.missoes)) return;
    if (variable_global_exists("level_up") && global.level_up) return;
    var _aberto = instance_exists(obj_inventario) && obj_inventario.is_open;
    if (!_aberto && missoes_no_mundo()) {
        missoes_desenhar_painel();
        missoes_desenhar_seta();
    }
    missoes_desenhar_dialogo();
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_alpha(1); draw_set_color(c_white);
}

function missoes_desenhar_painel() {
    var _M = global.missoes;
    if (_M.atual == "" || !_M.npc_ok || missoes_dialogo_aberto()) return;
    var _m = missoes_db_get(_M.atual);
    if (is_undefined(_m)) return;

    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _k = max(1, _gh / 360);
    draw_set_font(fnt_descricao);
    var _fh = max(1, string_height("Ag"));
    var _ts = (7.5 * _k) / _fh, _tt = (9 * _k) / _fh;
    var _lh = 10 * _k;

    // Linhas do painel
    var _linhas = [];
    var _est = missoes_estado(_M.atual);
    if (_est == "") array_push(_linhas, ["Fale com " + _m.npc.nome, ui_cor("texto2")]);
    else if (missao_pronta(_M.atual)) array_push(_linhas, ["Volte e fale com " + _m.npc.nome, ui_cor("verde")]);
    else {
        for (var _i = 0; _i < array_length(_m.objetivos); _i++) {
            var _o = _m.objetivos[_i];
            var _t = global.missoes_tipos[$ _o.tipo];
            var _p = missao_progresso(_M.atual, _i);
            var _nome = is_undefined(_t) ? _o.tipo : _t.nome(_o);
            array_push(_linhas, [((_p >= _o.qtd) ? "v " : "- ") + _nome + "  " + string(_p) + "/" + string(_o.qtd), (_p >= _o.qtd) ? ui_cor("verde") : ui_cor("texto")]);
        }
    }

    var _w = 128 * _k;
    var _h = 26 * _k + array_length(_linhas) * _lh;
    var _x2 = _gw - 8 * _k, _x1 = _x2 - _w;
    var _y1 = _gh * MISSAO_HUD_Y, _y2 = _y1 + _h;
    ui_card(_x1, _y1, _x2, _y2, 6 * _k, ui_cor("papel"), ui_cor("borda"), max(1, round(1.5 * _k)));

    draw_set_halign(fa_left); draw_set_valign(fa_top);
    var _cab = "MISSÃO  " + string(_M.concluidas + 1) + "/" + string(missoes_total());
    ui_text(_x1 + 6 * _k, _y1 + 4 * _k, _cab, ui_cor("ouro"), _ts, ui_cor("escuro"));
    ui_text_fit(_x1 + 6 * _k, _y1 + 12 * _k, _m.titulo, c_white, _tt, _w - 12 * _k);
    for (var _i = 0; _i < array_length(_linhas); _i++) {
        draw_set_color(_linhas[_i][1]);
        draw_text_transformed(_x1 + 7 * _k, _y1 + 24 * _k + _i * _lh, _linhas[_i][0], _ts, _ts, 0);
    }
    draw_set_color(c_white);
}

/// Seta na borda da tela apontando para o NPC (quando ele está fora da câmera)
function missoes_desenhar_seta() {
    var _M = global.missoes;
    if (_M.atual == "" || !_M.npc_ok || missoes_dialogo_aberto()) return;
    var _nx = _M.npc_x, _ny = _M.npc_y - 50;
    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
    var _vw = camera_get_view_width(_cam), _vh = camera_get_view_height(_cam);
    if (point_in_rectangle(_nx, _ny, _vx, _vy, _vx + _vw, _vy + _vh)) return;

    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _k = max(1, _gh / 360);
    var _cx = _gw / 2, _cy = _gh / 2;
    var _dx = (_nx - _vx) / _vw * _gw - _cx;
    var _dy = (_ny - _vy) / _vh * _gh - _cy;
    var _mg = 24 * _k;
    var _s = min((_gw / 2 - _mg) / max(0.001, abs(_dx)), (_gh / 2 - _mg) / max(0.001, abs(_dy)));
    var _px = _cx + _dx * _s, _py = _cy + _dy * _s;
    var _ang = point_direction(0, 0, _dx, _dy);
    var _pul = 1 + dsin(current_time * 0.4) * 0.08;
    var _r = 8 * _k * _pul;

    // triângulo
    var _ax = _px + lengthdir_x(_r * 1.9, _ang), _ay = _py + lengthdir_y(_r * 1.9, _ang);
    var _bx = _px + lengthdir_x(_r * 0.9, _ang + 90), _by = _py + lengthdir_y(_r * 0.9, _ang + 90);
    var _ccx = _px + lengthdir_x(_r * 0.9, _ang - 90), _ccy = _py + lengthdir_y(_r * 0.9, _ang - 90);
    draw_set_color(ui_cor("escuro"));
    draw_circle(_px, _py, _r + 2 * _k, false);
    draw_triangle(_ax, _ay, _bx, _by, _ccx, _ccy, false);
    draw_set_color(ui_cor("ouro"));
    draw_circle(_px, _py, _r, false);

    draw_set_font(fnt_descricao);
    var _fh = max(1, string_height("Ag"));
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    ui_text(_px, _py, (missoes_estado(_M.atual) == "") ? "!" : "?", ui_cor("texto"), (9 * _k) / _fh, ui_cor("ouro"));
    var _p = missoes_jogador();
    if (_p != noone) {
        var _m = string(floor(point_distance(_p.x, _p.y, _M.npc_x, _M.npc_y) / 32)) + "m";
        ui_text(_px - lengthdir_x(_r * 2.2, _ang), _py - lengthdir_y(_r * 2.2, _ang), _m, c_white, (6.5 * _k) / _fh);
    }
}

function missoes_desenhar_dialogo() {
    if (!missoes_dialogo_aberto()) return;
    var _d = global.missoes_dlg;
    var _f = _d.falas[_d.i];
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _k = max(1, _gh / 360);
    draw_set_font(fnt_descricao);
    var _fh = max(1, string_height("Ag"));

    var _w = min(_gw - 32 * _k, 440 * _k), _h = 76 * _k;
    var _x1 = (_gw - _w) / 2, _x2 = _x1 + _w;
    var _y2 = _gh - 14 * _k, _y1 = _y2 - _h;
    var _narr = (_f.quem == MISSAO_NARRADOR);
    ui_card(_x1, _y1, _x2, _y2, 8 * _k, _narr ? make_color_rgb(44, 40, 72) : ui_cor("papel"), ui_cor("borda"), max(1, round(2 * _k)));

    // Retrato
    var _tx = _x1 + 14 * _k;
    if (_f.retrato >= 0) {
        var _vis = missoes_visuais();
        var _spr = _vis[clamp(_f.retrato, 0, array_length(_vis) - 1)];
        var _rx1 = _x1 + 8 * _k, _ry1 = _y1 + 8 * _k, _rs = _h - 16 * _k;
        ui_rrect(_rx1, _ry1, _rx1 + _rs, _ry1 + _rs, 6 * _k, ui_cor("papel2"));
        var _sc = _rs * 0.95 / sprite_get_height(_spr);
        draw_sprite_ext(_spr, 1, _rx1 + _rs / 2, _ry1 + _rs - 2 * _k, _sc, _sc, 0, c_white, 1);
        _tx = _rx1 + _rs + 10 * _k;
    }

    // Nome
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    if (_f.quem != "") ui_text(_tx, _y1 + 6 * _k, _f.quem, _narr ? make_color_rgb(170, 200, 255) : ui_cor("ouro"), (8 * _k) / _fh, ui_cor("escuro"));

    // Texto (máquina de escrever)
    var _ts = (8.5 * _k) / _fh;
    var _tw = _x2 - 12 * _k - _tx;
    draw_set_color(_narr ? make_color_rgb(235, 232, 255) : ui_cor("texto"));
    draw_text_ext_transformed(_tx, _y1 + (_f.quem != "" ? 20 : 12) * _k, string_copy(_f.txt, 1, floor(_d.chars)), _fh * 1.1, _tw / _ts, _ts, _ts, 0);

    // Dica para continuar
    if (_d.chars >= string_length(_f.txt) && (current_time div 400) mod 2 == 0) {
        draw_set_halign(fa_right); draw_set_valign(fa_bottom);
        var _fim = (_d.i >= array_length(_d.falas) - 1) ? "fechar" : "continuar";
        ui_text(_x2 - 8 * _k, _y2 - 5 * _k, "[" + tecla_nome(tecla("interagir")) + "] " + _fim, ui_cor("texto2"), (6.5 * _k) / _fh, ui_cor("papel"));
    }
    draw_set_color(c_white);
}

#endregion

#region ---------- SAVE ----------

function missoes_save_dados() {
    if (!variable_global_exists("missoes") || !is_struct(global.missoes)) return undefined;
    var _M = global.missoes;
    return {
        seed: _M.seed, ordem: _M.ordem, estado: _M.estado, contadores: _M.contadores,
        atual: _M.atual, abertura_vista: _M.abertura_vista, final_visto: _M.final_visto,
    };
}

function missoes_load_dados(_d) {
    if (!variable_global_exists("missoes_db")) { missoes_definir_tipos(); missoes_definir_banco(); }
    if (!is_struct(_d)) { global.missoes = missoes_estado_novo(irandom_range(1, 999999)); missoes_garantir(); return; }

    var _M = missoes_estado_novo(_save_campo(_d, "seed", 1));

    // Ordem salva, sem ids que não existem mais + missões novas no fim (embaralhadas)
    var _ordem = [], _salva = _save_campo(_d, "ordem", []);
    for (var _i = 0; _i < array_length(_salva); _i++) if (!is_undefined(missoes_db_get(_salva[_i]))) array_push(_ordem, _salva[_i]);
    var _novas = [];
    for (var _i = 0; _i < array_length(global.missoes_lista); _i++) {
        var _id = global.missoes_lista[_i], _tem = false;
        for (var _j = 0; _j < array_length(_ordem); _j++) if (_ordem[_j] == _id) { _tem = true; break; }
        if (!_tem) array_push(_novas, _id);
    }
    _novas = missoes_embaralhar(_novas, _M.seed + 7);
    for (var _i = 0; _i < array_length(_novas); _i++) array_push(_ordem, _novas[_i]);
    _M.ordem = _ordem;

    var _est = _save_campo(_d, "estado", {});
    var _cont = _save_campo(_d, "contadores", {});
    if (is_struct(_est))  _M.estado = _est;
    if (is_struct(_cont)) _M.contadores = _cont;
    _M.abertura_vista = _save_campo(_d, "abertura_vista", false);
    _M.final_visto    = _save_campo(_d, "final_visto", false);

    // Conta concluídas e corrige contadores de missões ativas que ganharam objetivos
    var _ids = variable_struct_get_names(_M.estado);
    for (var _i = 0; _i < array_length(_ids); _i++) {
        var _m = missoes_db_get(_ids[_i]);
        if (is_undefined(_m)) continue;
        if (_M.estado[$ _ids[_i]] == "concluida") _M.concluidas++;
        else {
            var _c = _M.contadores[$ _ids[_i]];
            if (!is_array(_c)) _c = [];
            while (array_length(_c) < array_length(_m.objetivos)) array_push(_c, 0);
            _M.contadores[$ _ids[_i]] = _c;
        }
    }

    var _atual = _save_campo(_d, "atual", "");
    _M.atual = (is_string(_atual) && _M.estado[$ _atual] == "ativa") ? _atual : "";
    _M.npc_ok = false;                     // o mapa é gerado de novo: NPC renasce perto
    _M.timer  = 60 * 2;
    _M.itens_pendentes = true;
    global.missoes = _M;
    missoes_garantir();
}

function missoes_resetar() {
    global.missoes = undefined;           // próximo missoes_tick cria um jogo novo (nova ordem)
    if (variable_global_exists("missoes_dlg") && is_struct(global.missoes_dlg)) global.missoes_dlg.aberto = false;
    if (object_exists(MISSAO_NPC_OBJ)) with (MISSAO_NPC_OBJ) instance_destroy();
}

#endregion

#region ---------- DEBUG ----------

/// Conclui a missão atual na hora (para testar a história)
function missoes_debug_pular() {
    missoes_garantir();
    var _mid = global.missoes.atual;
    if (_mid == "") return;
    if (missoes_estado(_mid) == "") missao_aceitar(_mid);
    var _m = missoes_db_get(_mid);
    for (var _i = 0; _i < array_length(_m.objetivos); _i++) {
        var _o = _m.objetivos[_i];
        if (_o.tipo == "item") inventory_add(_o.item, _o.qtd);
        else global.missoes.contadores[$ _mid][_i] = _o.qtd;
    }
    var _npc = noone;
    with (MISSAO_NPC_OBJ) if (missao_id == _mid) _npc = id;
    missao_concluir(_mid, _npc);
}

#endregion
