// feather disable GM2017
/// @desc Menu de PAUSA (Esc) + tela de CONFIGURAÇÕES (também abre pelo botão Opções do Menu)
/// [COMO]: objeto persistente, criado por obj_player / obj_player_tutorial / obj_par_botoes_menu.
///         Lógica = menu_atualizar()  |  Desenho = menu_desenhar()  — os dois chamados no Draw GUI,
///         que roda DEPOIS de todos os Steps (assim o Esc do baú / colocar baú já foi tratado).
///         Enter / Cima / Baixo chegam pelos eventos Key Press (menu_confirmar / menu_navegar).
///         Configurações, teclas e save: scripts/SAVES.

// Só pode existir um
if (instance_number(obj_control_menu) > 1) { instance_destroy(); exit; }
persistent = true;
// ATENÇÃO: NÃO usar -16000. Os desenhos usam a depth como "z" e -16000 fica no limite da câmera:
// tudo que este objeto desenhava era cortado (tela preta na pausa / nada no Opções do Menu).
depth = -15000;

#region ---------- ESTADO ----------
tela        = "fechado";  // "fechado" | "pausa" | "config" | "confirmar_sair" | "confirmar_menu"
tela_volta  = "fechado";  // para onde o "Voltar" das configurações leva
pausado     = false;      // jogo congelado (instâncias desativadas)
aba         = 0;          // configurações: 0 Vídeo | 1 Áudio | 2 Controles
sel         = 0;          // item com foco (teclado / mouse)
mx_ant      = 0;
my_ant      = 0;
esperando_tecla = "";     // ação esperando uma tecla nova ("" = nenhuma)
espera_delay    = 0;      // frames antes de aceitar a tecla (o Enter/clique que abriu não conta)
arrastando      = -1;     // índice do slider sendo arrastado
snapshot        = -1;     // sprite com a imagem do jogo no momento da pausa
anim            = 0;      // 0 -> 1 (fade do fundo)
msg_texto       = "";
msg_cor         = c_white;
msg_timer       = 0;
esc_ocupado_ant = false;  // baú / colocar baú estavam abertos no frame anterior?
carregar_espera = 0;      // frames esperando a fase carregar para aplicar o save
pausa_pendente  = false;  // pausa pedida, congela no próximo frame (Alarm 0)
#endregion

#region ---------- AUXILIARES ----------
/// Escala da UI (tudo foi medido numa tela de 1920x1080)
escala = function() {
    return min(display_get_gui_width() / 1920, display_get_gui_height() / 1080);
};

/// Sala do MENU PRINCIPAL: só existe a tela de Configurações (botão Opções) e o Carregar
no_menu = function() { return room == Menu; };

/// Está numa FASE jogável (Fase_vamp, Fase_BEBE, tutorial): o Esc abre a pausa
em_jogo = function() {
    return room != Menu && (instance_exists(obj_player) || instance_exists(obj_player_tutorial));
};

pode_salvar = function() { return room == Fase_vamp; };

mensagem = function(_txt, _cor = c_white) {
    msg_texto = _txt;
    msg_cor   = _cor;
    msg_timer = 150;
};

/// Algum painel do jogo que usa o Esc está aberto? (baú / modo colocar baú)
esc_ocupado = function() {
    var _bau = variable_global_exists("bau_aberto") && instance_exists(global.bau_aberto);
    var _col = variable_global_exists("colocando_bau") && is_struct(global.colocando_bau) && global.colocando_bau.ativo;
    return _bau || _col;
};

/// Tempo em mm:ss (ou h:mm:ss)
tempo_texto = function(_seg) {
    _seg = floor(_seg);
    var _h = _seg div 3600, _m = (_seg mod 3600) div 60, _s = _seg mod 60;
    var _mm = (_m < 10 ? "0" : "") + string(_m), _ss = (_s < 10 ? "0" : "") + string(_s);
    return (_h > 0 ? string(_h) + ":" : "") + _mm + ":" + _ss;
};
#endregion

#region ---------- AÇÕES ----------
/// Abre o painel na hora, mas o congelamento acontece no próximo frame (Alarm 0 -> pausa_congelar):
/// tirar a "foto" da application_surface e desativar instâncias DENTRO do Draw GUI deixava a tela preta.
abrir_pausa = function() {
    tela = "pausa";
    sel  = 0;
    anim = 0;
    pausa_pendente = true;
    alarm[0] = 1;
};

/// Chamado pelo Alarm 0 (fase de Step): a application_surface ainda tem o último frame desenhado
pausa_congelar = function() {
    if (!pausa_pendente) return;
    pausa_pendente = false;
    if (tela == "fechado") return; // fechou antes de congelar

    if (sprite_exists(snapshot)) sprite_delete(snapshot);
    snapshot = -1;
    if (surface_exists(application_surface)) {
        var _sw = surface_get_width(application_surface), _sh = surface_get_height(application_surface);
        if (_sw > 0 && _sh > 0) snapshot = sprite_create_from_surface(application_surface, 0, 0, _sw, _sh, false, false, 0, 0);
    }
    instance_deactivate_all(true); // congela tudo, menos este objeto
    instance_activate_object(id);  // garantia
    audio_pause_all();
    pausado = true;
};

continuar = function() {
    pausa_pendente = false;
    alarm[0] = -1;
    if (pausado) {
        instance_activate_all();
        audio_resume_all();
        pausado = false;
    }
    if (sprite_exists(snapshot)) sprite_delete(snapshot);
    snapshot = -1;
    tela = "fechado";
    esperando_tecla = "";
    arrastando = -1;
    io_clear(); // o clique/tecla que fechou o menu não vaza para o jogo
};

abrir_config = function(_volta) {
    tela_volta = _volta;
    tela = "config";
    aba  = 0;
    sel  = 0;
    if (_volta == "fechado") {
        anim = 0;
        // no Menu, os botões da sala ficam desligados (senão o clique passa por baixo do painel)
        instance_deactivate_object(obj_par_botoes_menu);
    }
};

fechar_config = function() {
    config_salvar();
    esperando_tecla = "";
    arrastando = -1;
    if (tela_volta == "pausa") {
        tela = "pausa";
        sel  = 2;
    } else {
        tela = "fechado";
        instance_activate_object(obj_par_botoes_menu);
        io_clear();
    }
};

salvar = function() {
    if (!pode_salvar()) { mensagem("Só dá para salvar durante a fase", ui_cor("vermelho")); return false; }
    if (jogo_salvar()) { mensagem("Jogo salvo!", ui_cor("verde")); return true; }
    mensagem("Não foi possível salvar", ui_cor("vermelho"));
    return false;
};

/// Sai da fase e volta para a sala Menu (destrói o que é persistente e zera o progresso)
ir_menu_principal = function() {
    pausa_pendente = false;
    alarm[0] = -1;
    if (pausado) instance_activate_all();
    pausado = false;
    if (sprite_exists(snapshot)) sprite_delete(snapshot);
    snapshot = -1;
    tela = "fechado";
    sel  = 0;
    audio_stop_all();
    with (all) if (persistent && id != other.id) instance_destroy();
    jogo_resetar_progresso();
    io_clear();
    room_goto(Menu);
};

/// Botão "Carregar" do Menu: guarda o save e entra na fase; ele é aplicado quando a fase terminar de criar tudo
carregar_do_menu = function() {
    var _d = jogo_ler_save();
    if (is_undefined(_d)) { mensagem("Nenhum jogo salvo ainda", ui_cor("vermelho")); return; }
    global.save_pendente = _d;
    carregar_espera = 0;
    room_goto(Fase_vamp);
};

/// Executa o item _w (botão, aba, opção...). _dir = -1/+1 para mudar valores.
executar = function(_w, _dir) {
    switch (_w.tipo) {
        case "aba":
            aba = _w.valor;
            sel = _w.valor;
            esperando_tecla = "";
            break;

        case "toggle":
            global.config[$ _w.chave] = !global.config[$ _w.chave];
            config_aplicar_video();
            config_salvar();
            break;

        case "opcao": // resolução
            var _n = array_length(config_resolucoes());
            global.config.resolucao = (clamp(global.config.resolucao, 0, _n - 1) + _dir + _n) mod _n;
            config_aplicar_janela();
            config_salvar();
            break;

        case "slider":
            global.config[$ _w.chave] = clamp(global.config[$ _w.chave] + 0.05 * _dir, 0, 1);
            config_aplicar_audio();
            config_salvar();
            break;

        case "tecla":
            esperando_tecla = _w.chave;
            espera_delay = 2;
            break;

        case "botao":
            if (!_w.ativo) break;
            switch (_w.acao) {
                case "continuar":     continuar(); break;
                case "salvar":        salvar(); break;
                case "config":        abrir_config("pausa"); break;
                case "menu":          tela = "confirmar_menu"; sel = 2; break;
                case "sair":          tela = "confirmar_sair"; sel = 2; break;
                case "cancelar":      tela = "pausa"; sel = 0; break;
                case "menu_salvando": if (salvar()) ir_menu_principal(); break;
                case "menu_ja":       ir_menu_principal(); break;
                case "sair_salvando": if (salvar()) game_end(); break;
                case "sair_ja":       game_end(); break;
                case "padrao":        config_restaurar(aba); mensagem("Padrões restaurados", ui_cor("verde")); break;
                case "voltar_config": fechar_config(); break;
            }
            break;
    }
};

/// Slider: posição do mouse -> valor (arredondado de 5 em 5%)
slider_definir = function(_w, _mx) {
    var _c  = _w.c;
    var _x1 = _c[0], _x2 = _c[2] - 90 * escala();
    var _v  = clamp((_mx - _x1) / max(1, _x2 - _x1), 0, 1);
    global.config[$ _w.chave] = round(_v * 20) / 20;
    config_aplicar_audio();
};
#endregion

#region ---------- LAYOUT (itens de cada tela, em pixels da GUI) ----------
/// Retorna { painel, titulo, texto, itens[] }. Cada item: { tipo, txt, r (linha inteira), c (controle), ... }
menu_widgets = function() {
    var _k  = escala();
    var _cx = display_get_gui_width() / 2, _cy = display_get_gui_height() / 2;
    var _it = [];
    var _pw, _ph, _px1, _py1, _px2, _py2;

    switch (tela) {
        // ------------------------------------------------ PAUSA
        case "pausa":
            _pw = 560 * _k; _ph = 650 * _k;
            _px1 = _cx - _pw / 2; _py1 = _cy - _ph / 2;
            var _bw = 440 * _k, _bh = 72 * _k, _bg = 18 * _k;
            var _by = _py1 + 150 * _k;
            var _bot = [
                ["Continuar",      "continuar", ui_cor("verde"),    true],
                ["Salvar jogo",    "salvar",    ui_cor("azul"),     pode_salvar()],
                ["Configurações",  "config",    ui_cor("borda2"),   true],
                ["Menu principal", "menu",      ui_cor("borda"),    true],
                ["Sair do jogo",   "sair",      ui_cor("vermelho"), true],
            ];
            for (var _i = 0; _i < array_length(_bot); _i++) {
                var _y1 = _by + _i * (_bh + _bg);
                var _r  = [_cx - _bw / 2, _y1, _cx + _bw / 2, _y1 + _bh];
                array_push(_it, { tipo: "botao", txt: _bot[_i][0], acao: _bot[_i][1], cor: _bot[_i][2], ativo: _bot[_i][3], r: _r, c: _r });
            }
            return { painel: [_px1, _py1, _px1 + _pw, _py1 + _ph], titulo: "PAUSADO", texto: "", itens: _it };

        // ------------------------------------------------ CONFIRMAÇÕES
        case "confirmar_sair":
        case "confirmar_menu":
            var _sair = (tela == "confirmar_sair");
            _pw = 860 * _k; _ph = 340 * _k;
            _px1 = _cx - _pw / 2; _py1 = _cy - _ph / 2;
            var _cw = 250 * _k, _ch = 70 * _k, _cg = 22 * _k;
            var _cx1 = _cx - (3 * _cw + 2 * _cg) / 2, _cy1 = _py1 + 210 * _k;
            var _opc = [
                [_sair ? "Salvar e sair" : "Salvar e voltar", _sair ? "sair_salvando" : "menu_salvando", ui_cor("azul"), pode_salvar()],
                [_sair ? "Sair" : "Voltar",                   _sair ? "sair_ja" : "menu_ja",             ui_cor("vermelho"), true],
                ["Cancelar",                                  "cancelar",                                ui_cor("verde"), true],
            ];
            for (var _i = 0; _i < 3; _i++) {
                var _x1 = _cx1 + _i * (_cw + _cg);
                var _r  = [_x1, _cy1, _x1 + _cw, _cy1 + _ch];
                array_push(_it, { tipo: "botao", txt: _opc[_i][0], acao: _opc[_i][1], cor: _opc[_i][2], ativo: _opc[_i][3], r: _r, c: _r });
            }
            return { painel: [_px1, _py1, _px1 + _pw, _py1 + _ph],
                     titulo: _sair ? "SAIR DO JOGO?" : "VOLTAR AO MENU?",
                     texto: "O que não foi salvo será perdido.", itens: _it };

        // ------------------------------------------------ CONFIGURAÇÕES
        case "config":
            _pw = 1100 * _k; _ph = 800 * _k;
            _px1 = _cx - _pw / 2; _py1 = _cy - _ph / 2; _px2 = _px1 + _pw; _py2 = _py1 + _ph;

            // abas (sempre os 3 primeiros itens)
            var _abas = ["Vídeo", "Áudio", "Controles"];
            var _aw = 240 * _k, _ah = 62 * _k, _ag = 16 * _k;
            var _ax = _cx - (3 * _aw + 2 * _ag) / 2, _ay = _py1 + 64 * _k;
            for (var _i = 0; _i < 3; _i++) {
                var _r = [_ax + _i * (_aw + _ag), _ay, _ax + _i * (_aw + _ag) + _aw, _ay + _ah];
                array_push(_it, { tipo: "aba", txt: _abas[_i], valor: _i, r: _r, c: _r });
            }

            // linhas da aba
            var _lx1 = _px1 + 60 * _k, _lx2 = _px2 - 60 * _k;
            var _ly  = _py1 + 170 * _k, _lh = 70 * _k, _lg = 12 * _k;
            if (aba == 2) {
                var _l = teclas_lista();
                var _colg = 40 * _k;
                var _colw = (_lx2 - _lx1 - _colg) / 2;
                // 2 colunas; com mais de 10 teclas (hotbar 1-4) as linhas ficam mais baixas para caber no mesmo espaço
                var _nl  = ceil(array_length(_l) / 2);
                var _lht = min(_lh, (5 * (_lh + _lg)) / _nl - _lg);
                for (var _i = 0; _i < array_length(_l); _i++) {
                    var _col = _i div _nl, _lin = _i mod _nl;
                    var _x1 = _lx1 + _col * (_colw + _colg);
                    var _y1 = _ly + _lin * (_lht + _lg);
                    array_push(_it, { tipo: "tecla", txt: _l[_i][1], chave: _l[_i][0],
                        r: [_x1, _y1, _x1 + _colw, _y1 + _lht],
                        c: [_x1 + _colw - 200 * _k, _y1 + 6 * _k, _x1 + _colw, _y1 + _lht - 6 * _k] });
                }
            } else {
                var _defs = (aba == 0)
                    ? [["toggle", "Tela cheia", "tela_cheia"], ["opcao", "Resolução da janela", "resolucao"],
                       ["toggle", "VSync", "vsync"],           ["toggle", "Mostrar FPS", "mostrar_fps"]]
                    : [["slider", "Volume geral", "vol_geral"], ["slider", "Música", "vol_musica"],
                       ["slider", "Efeitos sonoros", "vol_efeitos"]];
                var _cw = 420 * _k;
                for (var _i = 0; _i < array_length(_defs); _i++) {
                    var _y1 = _ly + _i * (_lh + _lg);
                    array_push(_it, { tipo: _defs[_i][0], txt: _defs[_i][1], chave: _defs[_i][2],
                        r: [_lx1, _y1, _lx2, _y1 + _lh],
                        c: [_lx2 - _cw, _y1 + 8 * _k, _lx2, _y1 + _lh - 8 * _k] });
                }
            }

            // rodapé
            var _fw = 330 * _k, _fh = 68 * _k, _fy = _py2 - 104 * _k;
            var _r1 = [_lx1, _fy, _lx1 + _fw, _fy + _fh];
            var _r2 = [_lx2 - _fw, _fy, _lx2, _fy + _fh];
            array_push(_it, { tipo: "botao", txt: "Restaurar padrões", acao: "padrao", cor: ui_cor("borda2"), ativo: true, r: _r1, c: _r1 });
            array_push(_it, { tipo: "botao", txt: "Voltar", acao: "voltar_config", cor: ui_cor("verde"), ativo: true, r: _r2, c: _r2 });
            return { painel: [_px1, _py1, _px2, _py2], titulo: "CONFIGURAÇÕES", texto: "", itens: _it };
    }
    return { painel: [0, 0, 0, 0], titulo: "", texto: "", itens: [] };
};
#endregion

#region ---------- LÓGICA (chamada no Draw GUI) ----------
menu_atualizar = function() {
    if (msg_timer > 0) msg_timer--;

    // Tamanho da janela pendente (aplicado alguns frames depois de mexer na tela cheia)
    if (variable_global_exists("config_janela_pendente") && global.config_janela_pendente > 0) {
        global.config_janela_pendente--;
        if (global.config_janela_pendente == 0) config_aplicar_janela();
    }

    // Save esperando a fase terminar de carregar
    if (variable_global_exists("save_pendente") && is_struct(global.save_pendente)) {
        if (room == Fase_vamp && instance_exists(obj_player) && instance_exists(obj_inventario)) {
            carregar_espera++;
            if (carregar_espera >= 3) {
                jogo_aplicar_save(global.save_pendente);
                global.save_pendente = undefined;
                carregar_espera = 0;
                mensagem("Jogo carregado!", ui_cor("verde"));
            }
        }
    }

    var _esc = keyboard_check_pressed(vk_escape);

    // ---------- Nada aberto: cada sala tem o seu comportamento ----------
    if (tela == "fechado") {
        if (no_menu()) {
            // === SALA MENU: botões Opções e Carregar (Novo jogo e Sair têm Mouse_4 próprios) ===
            if (mouse_check_button_released(mb_left)) {
                if (position_meeting(mouse_x, mouse_y, obj_botao_op))        abrir_config("fechado");
                else if (position_meeting(mouse_x, mouse_y, obj_botao_load)) carregar_do_menu();
            }
            esc_ocupado_ant = false;
        } else {
            // === FASE (Fase_vamp etc.): Esc abre a pausa ===
            var _ocupado = esc_ocupado();
            if (_esc && !_ocupado && !esc_ocupado_ant && em_jogo()) {
                if (instance_exists(obj_inventario) && obj_inventario.is_open) obj_inventario.is_open = false; // Esc fecha o inventário primeiro
                else abrir_pausa();
            }
            esc_ocupado_ant = _ocupado;
        }
        return;
    }

    anim = min(1, anim + 0.15);
    var _L  = menu_widgets();
    var _it = _L.itens;
    var _n  = array_length(_it);
    sel = clamp(sel, 0, max(0, _n - 1));
    var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);

    // 1. Esperando uma tecla nova (aba Controles). Esc cancela.
    if (esperando_tecla != "") {
        if (espera_delay > 0) { espera_delay--; return; }
        if (_esc) { esperando_tecla = ""; return; }
        if (keyboard_check_pressed(vk_anykey) && keyboard_lastkey > 0) {
            tecla_definir(esperando_tecla, keyboard_lastkey);
            config_salvar();
            esperando_tecla = "";
            io_clear();
        }
        return;
    }

    // 2. Esc = voltar uma tela
    if (_esc) {
        switch (tela) {
            case "pausa":  continuar(); break;
            case "config": fechar_config(); break;
            default:       tela = no_menu() ? "fechado" : "pausa"; sel = 0; break;
        }
        return;
    }

    // 3. Mouse: o foco segue o mouse quando ele se mexe
    var _moveu = (_mx != mx_ant || _my != my_ant);
    mx_ant = _mx; my_ant = _my;
    var _hover = -1;
    for (var _i = 0; _i < _n; _i++) {
        var _r = _it[_i].r;
        if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) { _hover = _i; break; }
    }
    if (_moveu && _hover != -1) sel = _hover;

    // 4. Slider sendo arrastado
    if (arrastando != -1) {
        if (arrastando < _n && _it[arrastando].tipo == "slider" && mouse_check_button(mb_left)) {
            slider_definir(_it[arrastando], _mx);
        } else {
            arrastando = -1;
            config_salvar();
        }
        return;
    }

    // 5. Clique (age ao SOLTAR o botão, para o clique não vazar para o jogo)
    if (_hover != -1) {
        var _w = _it[_hover];
        var _c = _w.c;
        var _no_ctrl = point_in_rectangle(_mx, _my, _c[0], _c[1], _c[2], _c[3]);
        if (_w.tipo == "slider") {
            if (mouse_check_button_pressed(mb_left) && _no_ctrl) { arrastando = _hover; slider_definir(_w, _mx); }
        } else if (mouse_check_button_released(mb_left)) {
            switch (_w.tipo) {
                case "opcao":  if (_no_ctrl) executar(_w, (_mx < (_c[0] + _c[2]) / 2) ? -1 : 1); break;
                case "tecla":  if (_no_ctrl) executar(_w, 1); break;
                default:       executar(_w, 1); break; // botão, aba, toggle (linha inteira)
            }
            return;
        }
    }

    // 6. Teclado: esquerda/direita mudam o valor do item focado | Tab troca a aba
    var _dir = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
    if (_dir != 0 && _n > 0) {
        var _w = _it[sel];
        switch (_w.tipo) {
            case "slider": case "opcao": case "toggle": executar(_w, _dir); break;
            case "aba":    aba = (aba + _dir + 3) mod 3; sel = aba; break;
            default:       if (tela != "pausa") sel = (sel + _dir + _n) mod _n; break; // botões lado a lado
        }
    }
    if (tela == "config" && keyboard_check_pressed(vk_tab)) {
        aba = (aba + (keyboard_check(vk_shift) ? 2 : 1)) mod 3;
        sel = aba;
    }
};

/// Seta cima/baixo (Key Press 38 / 40)
menu_navegar = function(_d) {
    if (tela == "fechado" || esperando_tecla != "") return;
    var _n = array_length(menu_widgets().itens);
    if (_n == 0) return;
    if (tela == "config") {
        if (sel < 3 && _d > 0)  { sel = 3; return; }   // das abas desce para a 1ª linha
        if (sel == 3 && _d < 0) { sel = aba; return; } // da 1ª linha sobe para a aba atual
    }
    sel = (sel + _d + _n) mod _n;
};

/// Enter (Key Press 13)
menu_confirmar = function() {
    if (tela == "fechado" || esperando_tecla != "") return;
    var _it = menu_widgets().itens;
    if (sel >= 0 && sel < array_length(_it)) executar(_it[sel], 1);
};
#endregion

#region ---------- DESENHO (chamado no Draw GUI) ----------
menu_desenhar = function() {
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _k  = escala();
    var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
    draw_set_font(fnt_descricao);
    var _fh    = max(1, string_height("Ag"));
    var _t_tit = 40 * _k / _fh;
    var _t_btn = 30 * _k / _fh;
    var _t_lbl = 28 * _k / _fh;
    var _t_sml = 22 * _k / _fh;
    var _contorno = ui_cor("chip");

    // Estado de desenho limpo (algum objeto pode ter deixado blend/shader/fog ligado no frame em que pausou)
    gpu_set_blendmode(bm_normal);
    gpu_set_fog(false, c_white, 0, 0);
    gpu_set_colorwriteenable(true, true, true, true);
    shader_reset();
    draw_set_alpha(1);

    if (tela != "fechado") {
        // --- Fundo ---
        if (no_menu()) {
            // MENU PRINCIPAL: a sala continua desenhando por baixo, só escurece
            draw_set_alpha(0.65 * anim);
        } else {
            // FASE: imagem congelada do jogo (os objetos estão desativados) + escurecido
            if (pausado && sprite_exists(snapshot)) draw_sprite_stretched_ext(snapshot, 0, 0, 0, _gw, _gh, c_white, 1);
            draw_set_alpha(0.55 * anim);
        }
        draw_set_color(c_black);
        draw_rectangle(0, 0, _gw, _gh, false);
        draw_set_alpha(1);

        var _L = menu_widgets();
        var _p = _L.painel;
        var _pcx = (_p[0] + _p[2]) / 2;

        // --- Painel + fita do título ---
        ui_card(_p[0], _p[1], _p[2], _p[3], 22 * _k, ui_cor("papel"), ui_cor("borda"), max(2, 4 * _k));
        var _th = 66 * _k;
        var _tw = string_width(_L.titulo) * _t_tit + _th * 1.4;
        ui_tab(_pcx - _tw / 2, _p[1] - _th / 2, _th, _L.titulo, ui_cor("borda"), _t_tit);

        // --- Textos extras de cada tela ---
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        switch (tela) {
            case "pausa":
                var _info = "Nível " + string(global.level_player)
                          + "  ·  Tempo " + tempo_texto(variable_global_exists("timer") ? global.timer : 0)
                          + "  ·  Moedas " + string(global.moedas);
                ui_text(_pcx, _p[1] + 90 * _k, _info, ui_cor("texto2"), _t_sml, _contorno);
                break;
            case "confirmar_sair":
            case "confirmar_menu":
                ui_text(_pcx, _p[1] + 120 * _k, _L.texto, ui_cor("texto"), _t_lbl, _contorno);
                if (!pode_salvar()) ui_text(_pcx, _p[1] + 165 * _k, "(só dá para salvar durante a fase)", ui_cor("texto2"), _t_sml, _contorno);
                break;
            case "config":
                if (aba == 2) {
                    ui_text(_pcx, _p[3] - 150 * _k, "Clique numa tecla e aperte a nova (Esc cancela). As setas também movem.", ui_cor("texto2"), _t_sml, _contorno);
                } else if (aba == 0 && global.config.tela_cheia) {
                    ui_text(_pcx, _p[3] - 150 * _k, "A resolução vale para o modo janela.", ui_cor("texto2"), _t_sml, _contorno);
                }
                break;
        }

        // --- Itens ---
        var _it = _L.itens;
        for (var _i = 0; _i < array_length(_it); _i++) {
            var _w = _it[_i];
            var _r = _w.r, _c = _w.c;
            var _foco = (_i == sel);
            var _rmid = (_r[1] + _r[3]) / 2;

            switch (_w.tipo) {
                case "botao":
                case "aba":
                    var _cor = (_w.tipo == "aba") ? ((_w.valor == aba) ? ui_cor("borda") : ui_cor("borda2")) : _w.cor;
                    var _ativo = (_w.tipo == "aba") ? true : _w.ativo;
                    if (_foco) ui_rrect(_r[0] - 6 * _k, _r[1] - 6 * _k, _r[2] + 6 * _k, _r[3] + 12 * _k, (_r[3] - _r[1]) * 0.4, ui_cor("ouro"));
                    ui_button(_r[0], _r[1], _r[2], _r[3], _w.txt, _ativo, _cor, _t_btn, _mx, _my);
                    break;

                default: // linhas de configuração
                    if (_foco) ui_rrect(_r[0] - 12 * _k, _r[1], _r[2] + 12 * _k, _r[3], 14 * _k, ui_cor("papel2"));
                    draw_set_halign(fa_left); draw_set_valign(fa_middle);
                    ui_text(_r[0] + 16 * _k, _rmid, _w.txt, ui_cor("texto"), _t_lbl, _contorno);

                    switch (_w.tipo) {
                        case "toggle":
                            var _v = global.config[$ _w.chave];
                            ui_button(_c[0], _c[1], _c[2], _c[3], _v ? "LIGADO" : "DESLIGADO", true,
                                _v ? ui_cor("verde") : make_color_rgb(150, 112, 92), _t_lbl, _mx, _my);
                            break;

                        case "opcao":
                            ui_card(_c[0], _c[1], _c[2], _c[3], 12 * _k, ui_cor("chip"), ui_cor("borda2"), max(1, 3 * _k), false);
                            var _cmid = (_c[1] + _c[3]) / 2;
                            var _ctxt = global.config.tela_cheia ? ui_cor("texto2") : ui_cor("texto");
                            draw_set_halign(fa_center);
                            ui_text((_c[0] + _c[2]) / 2, _cmid, config_resolucao_texto(), _ctxt, _t_lbl, _contorno);
                            ui_text(_c[0] + 26 * _k, _cmid, "<", ui_cor("borda"), _t_btn, _contorno);
                            ui_text(_c[2] - 26 * _k, _cmid, ">", ui_cor("borda"), _t_btn, _contorno);
                            break;

                        case "slider":
                            var _v  = global.config[$ _w.chave];
                            var _x1 = _c[0], _x2 = _c[2] - 90 * _k;
                            var _sy = (_c[1] + _c[3]) / 2;
                            ui_bar(_x1, _sy - 11 * _k, _x2, _sy + 11 * _k, _v, ui_cor("verde"));
                            var _kx = _x1 + (_x2 - _x1) * _v;
                            var _kr = (arrastando == _i) ? 20 * _k : 17 * _k;
                            draw_set_color(ui_cor("escuro")); draw_circle(_kx, _sy, _kr + 3 * _k, false);
                            draw_set_color(ui_cor("chip"));   draw_circle(_kx, _sy, _kr, false);
                            draw_set_color(ui_cor("ouro"));   draw_circle(_kx, _sy, _kr * 0.45, false);
                            draw_set_halign(fa_right);
                            ui_text(_c[2], _sy, string(round(_v * 100)) + "%", ui_cor("texto"), _t_lbl, _contorno);
                            break;

                        case "tecla":
                            var _esp = (esperando_tecla == _w.chave);
                            var _txt = _esp ? "Aperte..." : tecla_nome(tecla(_w.chave));
                            var _cor = _esp ? merge_color(ui_cor("ouro"), c_white, 0.25 + 0.25 * sin(current_time / 120)) : ui_cor("azul");
                            ui_button(_c[0], _c[1], _c[2], _c[3], _txt, true, _cor, _t_lbl, _mx, _my);
                            break;
                    }
                    break;
            }
        }
    }

    // --- Aviso rápido (salvo / carregado / erro) ---
    if (msg_timer > 0) {
        var _ph  = 56 * _k;
        var _pwt = string_width(msg_texto) * _t_lbl + _ph * 0.9;
        ui_pill(_gw / 2 - _pwt / 2, _gh - 150 * _k, _ph, msg_texto, ui_cor("escuro"), msg_cor, _t_lbl, c_black);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_alpha(1);
};
#endregion

// Aplica as configurações salvas (tela cheia, VSync, volumes, tamanho da janela) assim que o jogo começa
if (!variable_global_exists("config")) config_carregar();
config_aplicar();
