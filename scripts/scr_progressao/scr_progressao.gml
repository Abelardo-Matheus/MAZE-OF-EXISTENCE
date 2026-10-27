// feather disable GM2017
// ============================================================================
//  PROGRESSÃO E BALANCEAMENTO — scr_progressao
// ----------------------------------------------------------------------------
//  Tabela única com os números do jogo. Para deixar mais fácil/difícil, mexa SÓ aqui.
//
//  1. JOGADOR   : XP por nível, vida e dano base por nível           (LEVEL_UP.gml)
//  2. INIMIGOS  : nível da área (bioma + distância), força por nível, XP por tipo
//                 -> aplicado 1x no 1º Step de cada inimigo (obj_par_inimigos Step)
//  3. SPAWN     : raio seguro perto do início, perigo de cada bioma  (spr_inimigos_geracao_vamp)
//  4. NOITE     : 1ª noite mais leve                                  (scr_rondas_noite)
//  5. COMEÇO    : itens/moedas iniciais                               (obj_inventario Create)
//  6. RECEITAS  : só aparecem depois de pegar um dos ingredientes     (inventario.gml)
// ============================================================================

#region ---------- 1. JOGADOR ----------

#macro PROG_XP_BASE            40      // XP para ir do nível n ao n+1 = PROG_XP_BASE * n^PROG_XP_EXPOENTE
#macro PROG_XP_EXPOENTE        1.5
#macro PROG_VIDA_INICIAL       100
#macro PROG_VIDA_POR_NIVEL     12
#macro PROG_DANO_INICIAL       5       // dano base sem arma (a espada de madeira soma +7)
#macro PROG_DANO_POR_NIVEL     1
#macro PROG_ESTAMINA_INICIAL   50
#macro PROG_ESTAMINA_POR_NIVEL 5
#macro PROG_CURA_AO_UPAR       true    // ao subir de nível, ganha a vida extra na hora

function progressao_xp_prox(_nivel) { return round(PROG_XP_BASE * power(max(1, _nivel), PROG_XP_EXPOENTE)); }
function progressao_vida(_nivel)    { return PROG_VIDA_INICIAL + PROG_VIDA_POR_NIVEL * (max(1, _nivel) - 1); }
function progressao_dano(_nivel)    { return PROG_DANO_INICIAL + PROG_DANO_POR_NIVEL * (max(1, _nivel) - 1); }
function progressao_estamina(_nivel){ return PROG_ESTAMINA_INICIAL + PROG_ESTAMINA_POR_NIVEL * (max(1, _nivel) - 1); }

#endregion

#region ---------- 2. INIMIGOS ----------

#macro PROG_DIST_POR_NIVEL     6000    // px do ponto inicial para a área subir 1 nível
#macro PROG_NIVEL_MAX_AREA     30
#macro PROG_INI_VIDA_BASE      1.6     // multiplica a vida do Create de todo inimigo
#macro PROG_INI_DANO_BASE      0.8     // multiplica o dano do Create
#macro PROG_INI_VIDA_POR_NIVEL 0.35    // +35% de vida por nível da área
#macro PROG_INI_DANO_POR_NIVEL 0.12    // +12% de dano por nível
#macro PROG_INI_XP_POR_NIVEL   0.25    // +25% de XP por nível
#macro PROG_INI_ESCALA_POR_NIVEL 0.06  // +6% de tamanho por nível...
#macro PROG_INI_ESCALA_MAX     1.5     // ...até 1.5x
#macro PROG_XP_PADRAO          8
#macro PROG_XP_CHEFE           150

/// Perigo mínimo de cada bioma (o nível da área nunca fica abaixo disso)
function progressao_perigo_bioma(_b) {
    switch (_b) {
        case "prado": case "floresta": case "cidade":  return 1;
        case "deserto": case "neve": case "pantano":   return 2;
        case "floresta_negra": case "cristalino":      return 3;
        case "vulcanico": case "vazia":                return 4;
    }
    return 1;
}

/// XP base de cada tipo de inimigo (antes do nível da área)
function progressao_xp_tipo(_obj) {
    switch (_obj) {
        case obj_rato: case obj_morcego:                       return 6;
        case obj_amoeba: case obj_amoeba_azul:                 return 8;
        case obj_amoeba_rosa: case obj_amoeba_laranja:         return 10;
        case obj_amoeba_vermelha: case obj_cogumelo:           return 11;
        case obj_cogumelo_venenoso:                            return 12;
        case obj_esqueleto: case obj_esqueleto_corredor:       return 12;
        case obj_inimigo_fantasma: case obj_fantasma_azul:
        case obj_fantasma_verde:                               return 14;
        case obj_esqueleto_arqueiro: case obj_morcego_vampiro: return 15;
        case obj_esqueleto_guerreiro:                          return 22;
        case obj_fantasma_vermelho:                            return 24;
        case obj_rato_gigante:                                 return 25;
        case obj_olho_vazio:                                   return 28;
    }
    return PROG_XP_PADRAO;
}

/// Ponto onde o jogador começa no mundo: a porta da casa inicial (scr_cidade), sempre o mesmo
function progressao_origem() {
    return [cidade_spawn_x(), cidade_spawn_y()];
}

/// (antigo) primeira posição do jogador — não usado
function progressao_origem_antiga() {
    if (!variable_global_exists("prog_origem") || !is_array(global.prog_origem)) {
        if (!instance_exists(obj_player) || !instance_exists(obj_otimizador)) return [0, 0];
        global.prog_origem = [obj_player.x, obj_player.y];
    }
    return global.prog_origem;
}

function progressao_dist_origem(_x, _y) {
    var _o = progressao_origem();
    return point_distance(_o[0], _o[1], _x, _y);
}

/// Nível de uma área do mundo: o maior entre o perigo do bioma e a distância do início
function progressao_nivel_area(_x, _y, _bioma = undefined) {
    if (!instance_exists(obj_otimizador)) return 1;    // fora do mundo aberto (casa, fases antigas)
    if (is_undefined(_bioma)) _bioma = terreno_bioma_em(_x, _y);
    var _dist = 1 + floor(progressao_dist_origem(_x, _y) / PROG_DIST_POR_NIVEL);
    return clamp(max(progressao_perigo_bioma(_bioma), _dist), 1, PROG_NIVEL_MAX_AREA);
}

/// Aplica nível, força e XP no inimigo (escopo da instância). Chamado 1x no 1º Step.
/// Inimigos da noite (xp_ronda) já vêm com os multiplicadores da ronda: só ganham o XP.
function progressao_inimigo_aplicar() {
    if (variable_instance_exists(id, "prog_aplicado") && prog_aplicado) return;
    prog_aplicado = true;

    if (variable_instance_exists(id, "xp_ronda")) { xp_valor = xp_ronda; return; }
    if (string_pos("boss", object_get_name(object_index)) > 0) { xp_valor = PROG_XP_CHEFE; return; } // chefes têm status próprios

    var _l = (variable_instance_exists(id, "lvl") && is_real(lvl) && lvl > 0) ? lvl : progressao_nivel_area(x, y);
    lvl = _l;
    lvl_inimigo = _l;

    vida     = max(1, round(vida * PROG_INI_VIDA_BASE * (1 + PROG_INI_VIDA_POR_NIVEL * (_l - 1))));
    max_vida = vida;
    dano     = max(1, round(dano * PROG_INI_DANO_BASE * (1 + PROG_INI_DANO_POR_NIVEL * (_l - 1))));
    if (variable_instance_exists(id, "dano_tiro")) dano_tiro = max(1, round(dano_tiro * PROG_INI_DANO_BASE * (1 + PROG_INI_DANO_POR_NIVEL * (_l - 1))));
    xp_valor = round(progressao_xp_tipo(object_index) * (1 + PROG_INI_XP_POR_NIVEL * (_l - 1)));

    var _esc = min(PROG_INI_ESCALA_MAX, 1 + PROG_INI_ESCALA_POR_NIVEL * (_l - 1));
    escala *= _esc;
    image_xscale = escala;
    image_yscale = escala;
}

#endregion

#region ---------- 3. SPAWN ----------

#macro PROG_RAIO_SEGURO        2600    // px do início: só inimigos fracos e em menor número
#macro PROG_SEGURO_QTD_MULT    0.5

/// Inimigos permitidos no raio seguro
function progressao_inimigo_seguro() {
    return choose(obj_amoeba, obj_amoeba, obj_rato, obj_morcego);
}

/// Dificuldade (1..5) dos grupos de inimigos: sobe com o nível da área
function progressao_dificuldade_grupo(_sorteio_1a5, _nivel_area) {
    return clamp(_sorteio_1a5 + floor((_nivel_area - 1) / 2) - 1, 1, 5);
}

#endregion

#region ---------- 4. NOITE ----------

#macro PROG_NOITE1_RONDA_MAX   2       // na 1ª noite só aparecem as rondas 0..2 (amebas, morcegos, ratos)
#macro PROG_NOITE1_ANEL_MULT   0.5     // cercos da 1ª noite com metade dos inimigos

#endregion

#region ---------- 5. COMEÇO DO JOGO ----------

#macro PROG_MOEDAS_INICIAIS    0
#macro PROG_ARMA_INICIAL       "espada_madeira"

#endregion

#region ---------- 6. RECEITAS POR DESCOBERTA ----------

function progressao_descobertos() {
    if (!variable_global_exists("itens_descobertos") || !is_struct(global.itens_descobertos)) global.itens_descobertos = {};
    return global.itens_descobertos;
}

function item_descoberto(_id) {
    return is_string(_id) && variable_struct_exists(progressao_descobertos(), _id);
}

/// A receita aparece na oficina se o jogador já pegou pelo menos um dos ingredientes
function receita_visivel(_rec) {
    for (var _j = 0; _j < array_length(_rec.ingredientes); _j++) {
        if (item_descoberto(_rec.ingredientes[_j].item)) return true;
    }
    return item_descoberto(_rec.resultado);
}

/// Marca o item como descoberto. Avisa quando isso libera receitas novas.
function item_descobrir(_id, _avisar = true) {
    if (!is_string(_id) || item_descoberto(_id)) return;
    var _antes = [];
    if (_avisar && variable_global_exists("receitas_craft") && is_array(global.receitas_craft)) {
        for (var _i = 0; _i < array_length(global.receitas_craft); _i++) _antes[_i] = receita_visivel(global.receitas_craft[_i]);
    }
    global.itens_descobertos[$ _id] = true;
    if (!_avisar || array_length(_antes) == 0) return;

    var _novas = 0, _nome = "";
    for (var _i = 0; _i < array_length(global.receitas_craft); _i++) {
        if (!_antes[_i] && receita_visivel(global.receitas_craft[_i])) {
            _novas++;
            if (_nome == "") { var _d = item_db(global.receitas_craft[_i].resultado); _nome = is_undefined(_d) ? "" : _d.nome; }
        }
    }
    if (_novas == 1)     inventory_msg("Nova receita: " + _nome + "!", ui_cor("ouro"));
    else if (_novas > 1) inventory_msg(string(_novas) + " receitas novas na oficina!", ui_cor("ouro"));
}

/// Marca tudo o que está na mochila/equipamentos/hotbar (saves antigos)
function progressao_descobrir_inventario() {
    if (!variable_global_exists("grid_itens") || !ds_exists(global.grid_itens, ds_type_grid)) return;
    var _g = global.grid_itens;
    for (var _i = 0; _i < ds_grid_height(_g); _i++) {
        var _id = _g[# INFOS.ITEM, _i];
        if (is_string(_id)) item_descobrir(_id, false);
    }
}

#endregion

#region ---------- SAVE ----------

function progressao_save_dados() {
    return { descobertos: variable_struct_get_names(progressao_descobertos()) };
}

function progressao_load_dados(_d) {
    global.itens_descobertos = {};
    if (is_struct(_d) && variable_struct_exists(_d, "descobertos") && is_array(_d.descobertos)) {
        for (var _i = 0; _i < array_length(_d.descobertos); _i++) global.itens_descobertos[$ _d.descobertos[_i]] = true;
    }
    progressao_descobrir_inventario();   // o que já está na mochila conta como descoberto
    atualizar_crafts_disponiveis();
}

function progressao_resetar() {
    global.itens_descobertos = {};
    global.prog_origem = undefined;     // o próximo mundo grava o novo ponto inicial
}

#endregion
