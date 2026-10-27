// feather disable GM2017
/// @desc CONFIGURAÇÕES (vídeo, áudio, teclas) + SAVE DO JOGO + recorde
/// [O QUE]: tudo que o menu de pausa / opções (obj_control_menu) lê e grava.
/// [ONDE]:  config.ini (configurações) | save_jogo.json (progresso) | Savegame.ini (recorde)
/// [COMO]:  ALL_GLOBAL chama config_carregar() + config_aplicar() quando o jogo abre.
///          O resto do jogo lê as teclas com tecla_segurando("cima") / tecla_apertou("inventario").

#macro CONFIG_ARQUIVO "config.ini"
#macro SAVE_ARQUIVO   "save_jogo.json"
#macro SAVE_VERSAO    1

#region ---------- RECORDE (antigo, mantido) ----------

function salvar_recorde(_recorde_atualizado){
	ini_open("Savegame.ini");
	ini_write_real("Player", "Recorde", _recorde_atualizado);
	ini_close();
}

function ler_recorde(){
	var _recorde_salvo = 0;
	if(file_exists("Savegame.ini")){
		ini_open("Savegame.ini");
		_recorde_salvo = ini_read_real("Player", "Recorde", 0);
		ini_close();
	}
	return _recorde_salvo;
}

#endregion

#region ---------- DADOS PADRÃO (data-driven: para criar uma opção/tecla nova, mexa só aqui) ----------

/// Resoluções de janela oferecidas (as maiores que o monitor somem da lista)
function config_resolucoes_todas() {
    return [[1280, 720], [1366, 768], [1600, 900], [1920, 1080], [2560, 1440]];
}

function config_padrao_video() {
    return { tela_cheia: false, resolucao: 3, vsync: true, mostrar_fps: true };
}

function config_padrao_audio() {
    return { vol_geral: 1, vol_musica: 0.7, vol_efeitos: 1 };
}

/// Ações que podem ser remapeadas: [ação, nome na tela, tecla padrão]
/// (as setas continuam movendo sempre, como teclas extras fixas)
function teclas_lista() {
    return [
        ["cima",       "Mover para cima",     ord("W")],
        ["baixo",      "Mover para baixo",    ord("S")],
        ["esquerda",   "Mover p/ esquerda",   ord("A")],
        ["direita",    "Mover p/ direita",    ord("D")],
        ["correr",     "Correr",              vk_shift],
        ["interagir",  "Interagir / pegar",   ord("F")],
        ["inventario", "Inventário",          ord("I")],
        ["mapa",       "Mapa",                ord("M")],
        ["espada",     "Hotbar 1",            ord("1")],
        ["arco",       "Hotbar 2",            ord("2")],
        ["hot3",       "Hotbar 3",            ord("3")],
        ["hot4",       "Hotbar 4",            ord("4")],
        ["habilidade", "Habilidade da arma",  ord("X")],
    ];
}

function teclas_padrao() {
    var _t = {};
    var _l = teclas_lista();
    for (var _i = 0; _i < array_length(_l); _i++) _t[$ _l[_i][0]] = _l[_i][2];
    return _t;
}

/// Junta as configs padrão de vídeo + áudio num struct só
function config_padrao() {
    var _c = config_padrao_video();
    var _a = config_padrao_audio();
    var _k = variable_struct_get_names(_a);
    for (var _i = 0; _i < array_length(_k); _i++) _c[$ _k[_i]] = _a[$ _k[_i]];
    return _c;
}

#endregion

#region ---------- CARREGAR / SALVAR / APLICAR ----------

/// Lê o config.ini (ou cria com os padrões)
function config_carregar() {
    global.config = config_padrao();
    global.teclas = teclas_padrao();
    global.config_janela_pendente = 0;
    global.config_vsync_aplicado  = undefined;
    if (!variable_global_exists("save_pendente")) global.save_pendente = undefined;

    if (!file_exists(CONFIG_ARQUIVO)) return;
    ini_open(CONFIG_ARQUIVO);
    var _c = global.config;
    _c.tela_cheia  = ini_read_real("video", "tela_cheia",  _c.tela_cheia) == 1;
    _c.resolucao   = ini_read_real("video", "resolucao",   _c.resolucao);
    _c.vsync       = ini_read_real("video", "vsync",       _c.vsync) == 1;
    _c.mostrar_fps = ini_read_real("video", "mostrar_fps", _c.mostrar_fps) == 1;
    _c.vol_geral   = clamp(ini_read_real("audio", "geral",   _c.vol_geral),   0, 1);
    _c.vol_musica  = clamp(ini_read_real("audio", "musica",  _c.vol_musica),  0, 1);
    _c.vol_efeitos = clamp(ini_read_real("audio", "efeitos", _c.vol_efeitos), 0, 1);
    var _l = teclas_lista();
    for (var _i = 0; _i < array_length(_l); _i++) {
        var _a = _l[_i][0];
        global.teclas[$ _a] = ini_read_real("teclas", _a, global.teclas[$ _a]);
    }
    ini_close();
}

function config_salvar() {
    if (!variable_global_exists("config")) return;
    var _c = global.config;
    ini_open(CONFIG_ARQUIVO);
    ini_write_real("video", "tela_cheia",  _c.tela_cheia);
    ini_write_real("video", "resolucao",   _c.resolucao);
    ini_write_real("video", "vsync",       _c.vsync);
    ini_write_real("video", "mostrar_fps", _c.mostrar_fps);
    ini_write_real("audio", "geral",       _c.vol_geral);
    ini_write_real("audio", "musica",      _c.vol_musica);
    ini_write_real("audio", "efeitos",     _c.vol_efeitos);
    var _l = teclas_lista();
    for (var _i = 0; _i < array_length(_l); _i++) ini_write_real("teclas", _l[_i][0], global.teclas[$ _l[_i][0]]);
    ini_close();
}

/// Volta uma aba das configurações para o padrão (0 vídeo | 1 áudio | 2 controles)
function config_restaurar(_aba) {
    var _p = (_aba == 0) ? config_padrao_video() : config_padrao_audio();
    if (_aba == 2) {
        global.teclas = teclas_padrao();
    } else {
        var _k = variable_struct_get_names(_p);
        for (var _i = 0; _i < array_length(_k); _i++) global.config[$ _k[_i]] = _p[$ _k[_i]];
    }
    config_aplicar();
    config_salvar();
}

function config_aplicar() {
    config_aplicar_video();
    config_aplicar_audio();
}

/// Tela cheia + VSync. O tamanho da janela é aplicado alguns frames depois
/// (o Windows ignora window_set_size logo depois de sair da tela cheia) -> obj_control_menu
function config_aplicar_video() {
    var _c = global.config;
    if (window_get_fullscreen() != _c.tela_cheia) window_set_fullscreen(_c.tela_cheia);
    if (is_undefined(global.config_vsync_aplicado) || global.config_vsync_aplicado != _c.vsync) {
        display_reset(0, _c.vsync);
        global.config_vsync_aplicado = _c.vsync;
    }
    global.config_janela_pendente = 3;
}

/// Resoluções que cabem no monitor
function config_resolucoes() {
    var _todas = config_resolucoes_todas();
    var _ok = [];
    var _dw = display_get_width(), _dh = display_get_height();
    for (var _i = 0; _i < array_length(_todas); _i++) {
        if (_todas[_i][0] <= _dw && _todas[_i][1] <= _dh) array_push(_ok, _todas[_i]);
    }
    if (array_length(_ok) == 0) array_push(_ok, _todas[0]);
    return _ok;
}

function config_resolucao_atual() {
    var _l = config_resolucoes();
    global.config.resolucao = clamp(global.config.resolucao, 0, array_length(_l) - 1);
    return _l[global.config.resolucao];
}

function config_resolucao_texto() {
    var _r = config_resolucao_atual();
    return string(_r[0]) + " x " + string(_r[1]);
}

/// Muda o tamanho da janela (não faz nada em tela cheia)
function config_aplicar_janela() {
    if (window_get_fullscreen()) return;
    var _r = config_resolucao_atual();
    window_set_size(_r[0], _r[1]);
    window_center();
}

/// Som é "música" se o nome do asset tiver musica/music (ex.: snd_musica_fundo_1)
function som_e_musica(_snd) {
    var _n = string_lower(audio_get_name(_snd));
    return string_pos("musica", _n) > 0 || string_pos("music", _n) > 0;
}

/// Volume geral (master) + ganho de cada asset de som conforme o tipo
function config_aplicar_audio() {
    var _c = global.config;
    audio_master_gain(_c.vol_geral);
    for (var _s = 0; _s < 2000 && audio_exists(_s); _s++) {
        audio_sound_gain(_s, som_e_musica(_s) ? _c.vol_musica : _c.vol_efeitos, 0);
    }
}

#endregion

#region ---------- TECLAS ----------

/// Código da tecla configurada para a ação
function tecla(_acao) {
    if (!variable_global_exists("teclas")) global.teclas = teclas_padrao();
    var _k = global.teclas[$ _acao];
    return is_undefined(_k) ? -1 : _k;
}

function tecla_segurando(_acao) { var _k = tecla(_acao); return _k > 0 && keyboard_check(_k); }
function tecla_apertou(_acao)   { var _k = tecla(_acao); return _k > 0 && keyboard_check_pressed(_k); }

/// Troca a tecla de uma ação. Se outra ação usava essa tecla, as duas trocam entre si.
function tecla_definir(_acao, _k) {
    if (_k <= 0 || _k == vk_escape) return;
    var _antiga = tecla(_acao);
    var _l = teclas_lista();
    for (var _i = 0; _i < array_length(_l); _i++) {
        var _a = _l[_i][0];
        if (_a != _acao && global.teclas[$ _a] == _k) global.teclas[$ _a] = _antiga;
    }
    global.teclas[$ _acao] = _k;
}

/// Nome legível da tecla
function tecla_nome(_k) {
    switch (_k) {
        case vk_shift:     return "Shift";
        case vk_lshift:    return "Shift Esq.";
        case vk_rshift:    return "Shift Dir.";
        case vk_control:   return "Ctrl";
        case vk_lcontrol:  return "Ctrl Esq.";
        case vk_rcontrol:  return "Ctrl Dir.";
        case vk_alt:       return "Alt";
        case vk_lalt:      return "Alt Esq.";
        case vk_ralt:      return "Alt Dir.";
        case vk_space:     return "Espaço";
        case vk_enter:     return "Enter";
        case vk_tab:       return "Tab";
        case vk_backspace: return "Backspace";
        case vk_up:        return "Seta cima";
        case vk_down:      return "Seta baixo";
        case vk_left:      return "Seta esq.";
        case vk_right:     return "Seta dir.";
        case vk_insert:    return "Insert";
        case vk_delete:    return "Delete";
        case vk_home:      return "Home";
        case vk_end:       return "End";
        case vk_pageup:    return "Page Up";
        case vk_pagedown:  return "Page Down";
    }
    if (_k >= vk_f1 && _k <= vk_f12)           return "F" + string(_k - vk_f1 + 1);
    if (_k >= vk_numpad0 && _k <= vk_numpad9)  return "Num " + string(_k - vk_numpad0);
    if ((_k >= ord("A") && _k <= ord("Z")) || (_k >= ord("0") && _k <= ord("9"))) return chr(_k);
    switch (_k) {
        case 186: return "Ç";
        case 187: return "=";
        case 188: return ",";
        case 189: return "-";
        case 190: return ".";
        case 191: return ";";
        case 192: return "'";
        case 219: return "´";
        case 221: return "[";
        case 220: return "]";
        case 222: return "~";
        case 226: return "\\";
    }
    return "Tecla " + string(_k);
}

#endregion

#region ---------- SAVE DO JOGO (progresso do jogador) ----------
// Guarda: nível, XP, vida, sanidade, moedas, arma, tempo e a mochila inteira (itens, nível e adesivos).
// NÃO guarda o mapa: ao carregar, a fase é gerada de novo e o jogador começa no início dela.
// Também não guarda as skills escolhidas nos level ups.

function _save_campo(_d, _campo, _padrao) {
    return (is_struct(_d) && variable_struct_exists(_d, _campo)) ? _d[$ _campo] : _padrao;
}

function jogo_tem_save() { return file_exists(SAVE_ARQUIVO); }

function jogo_salvar() {
    var _d = {
        versao:       SAVE_VERSAO,
        data:         date_datetime_string(date_current_datetime()),
        level_player: global.level_player,
        xp:           global.xp,
        vida:         global.vida,
        sanidade:     global.sanidade,
        moedas:       global.moedas,
        armamento:    global.armamento,
        timer:        variable_global_exists("timer") ? global.timer : 0,
        inventario:   [],
        missoes:      missoes_save_dados(),   // scr_missoes
        progressao:   progressao_save_dados(), // receitas descobertas (scr_progressao)
    };

    // Mochila + equipamentos: só o que precisa para recriar o slot (item_slot_preencher)
    if (variable_global_exists("grid_itens") && ds_exists(global.grid_itens, ds_type_grid)) {
        var _g = global.grid_itens;
        for (var _i = 0; _i < ds_grid_height(_g); _i++) {
            var _id = _g[# INFOS.ITEM, _i];
            if (!is_string(_id)) continue; // slot vazio = -1
            var _pas = _g[# INFOS.PASSIVAS, _i];
            array_push(_d.inventario, {
                slot: _i, id: _id,
                qtd: _g[# INFOS.QUANTIDADE, _i],
                nivel: _g[# INFOS.NIVEL, _i],
                passivas: is_array(_pas) ? _pas : [],
                xp: item_xp_slot(_g, _i),
            });
        }
    }

    var _f = file_text_open_write(SAVE_ARQUIVO);
    if (_f == -1) return false;
    file_text_write_string(_f, json_stringify(_d));
    file_text_close(_f);
    return true;
}

/// Lê o save. Retorna o struct ou undefined.
function jogo_ler_save() {
    if (!jogo_tem_save()) return undefined;
    var _f = file_text_open_read(SAVE_ARQUIVO);
    if (_f == -1) return undefined;
    var _txt = "";
    while (!file_text_eof(_f)) { _txt += file_text_read_string(_f); file_text_readln(_f); }
    file_text_close(_f);
    try { return json_parse(_txt); } catch (_e) { return undefined; }
}

/// Aplica o save na fase que acabou de carregar (chamado pelo obj_control_menu)
function jogo_aplicar_save(_d) {
    // 1. Nível: sobe do atual até o salvo aplicando o crescimento normal de cada nível
    var _alvo = max(1, _save_campo(_d, "level_player", 1));
    while (global.level_player < _alvo) {
        global.level_player += 1;
        aplicar_status_level();
    }
    global.max_xp = progressao_xp_prox(global.level_player);
    global.xp     = _save_campo(_d, "xp", 0);
    global.levels_pendentes = 0;
    global.level_up = false;

    // 2. Mochila
    var _g = global.grid_itens;
    ds_grid_clear(_g, -1);
    var _inv = _save_campo(_d, "inventario", []);
    for (var _i = 0; _i < array_length(_inv); _i++) {
        var _s = _inv[_i];
        if (_s.slot < 0 || _s.slot >= ds_grid_height(_g) || is_undefined(item_db(_s.id))) continue;
        item_slot_preencher(_g, _s.slot, _s.id, _s.qtd, _s.nivel, _s.passivas, _save_campo(_s, "xp", 0));
    }
    inventory_pos_mudanca();
    player_stats_recalcular();

    // 3. Resto
    global.vida      = clamp(_save_campo(_d, "vida", global.vida_max), 1, global.vida_max);
    global.sanidade  = clamp(_save_campo(_d, "sanidade", global.max_sanidade), 0, global.max_sanidade);
    global.moedas    = _save_campo(_d, "moedas", global.moedas);
    global.armamento = _save_campo(_d, "armamento", ARMAMENTOS.ESPADA);
    global.timer     = _save_campo(_d, "timer", 0);

    // 4. Missões (ordem sorteada, progresso, história)
    missoes_load_dados(_save_campo(_d, "missoes", undefined));
    progressao_load_dados(_save_campo(_d, "progressao", undefined));
    idade_sincronizar(); // a idade vem do relógio salvo: sem aviso ao carregar (scr_idade)
}

/// Volta o progresso para o começo (usado ao voltar para o Menu principal)
function jogo_resetar_progresso() {
    global.level_player     = 1;
    global.xp               = 0;
    global.max_xp           = progressao_xp_prox(1);
    global.levels_pendentes = 0;
    global.level_up         = false;
    global.vida_max     = (variable_global_exists("vida_max_calc")) ? global.vida_max_calc[1] : 100;
    global.vida         = global.vida_max;
    global.max_estamina = (variable_global_exists("max_estamina_calc")) ? global.max_estamina_calc[1] : 100;
    global.estamina     = global.max_estamina;
    global.cansado      = false;
    global.ataque       = (variable_global_exists("dano_base") && array_length(global.dano_base) > 1) ? global.dano_base[1] : 6;
    global.speed_player = global.speed_player_base;
    global.sanidade     = global.max_sanidade;
    global.moedas       = variable_global_exists("moedas_iniciais") ? global.moedas_iniciais : 0;
    global.armamento    = ARMAMENTOS.ESPADA;
    global.timer        = 0;
    global.timer_running = true;
    global.equip_aplicado = { vel: 0, vida: 0 };
    global.buffs_ativos   = [];
    global.bau_aberto     = noone;
    global.colocando_bau  = { ativo: false };
    global.dialogo        = false;
    if (ds_exists(global.active_upgrades, ds_type_list)) ds_list_clear(global.active_upgrades);
    missoes_resetar(); // novo jogo = nova ordem de missões
    progressao_resetar(); // receitas voltam a ficar escondidas
    idade_sincronizar();  // volta a ser criança
}

#endregion
