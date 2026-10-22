// feather disable GM2017
// ============================================================================
//  COLETA: ferramentas (machado, picareta, pá) e o que cada objeto do mundo pede
// ----------------------------------------------------------------------------
//  Itens tipo "coleta" (itens_geral): extra coleta = { tipo, tier (1 madeira, 2 ferro, 3 diamante), forca }
//  Golpe: scr_ataque_player põe a ferramenta da mão em obj_hibox_ataque.coleta.
//  Cada objeto chama, na colisão com o hitbox:
//      var _f = coleta_golpe(other, "<alvo>");   // 0 = ferramenta errada (só balança + aviso)
//      vida -= _f;  if (vida <= 0) coleta_quebrar("<alvo>");
//  Alvos (coleta_alvos): arvore -> machado | pedra -> picareta | terra (obj_monte_terra) -> pá
//  coleta_quebrar dropa o material, marca quebrada = true (o Destroy só marca a entidade
//  virtual como morta nesse caso) e destrói a instância.
// ============================================================================

/// Tabela: qual ferramenta cada alvo pede
function coleta_alvos() {
    if (!variable_global_exists("coleta_alvos_db")) {
        global.coleta_alvos_db = {
            arvore: { ferramenta: "machado",  nome: "um machado"   },
            pedra:  { ferramenta: "picareta", nome: "uma picareta" },
            terra:  { ferramenta: "pa",       nome: "uma pá"       },
        };
    }
    return global.coleta_alvos_db;
}

/// Golpe do hitbox _hb no objeto (escopo do objeto atingido). Retorna o dano (0 = ferramenta errada).
function coleta_golpe(_hb, _alvo) {
    if (!instance_exists(_hb)) return 0;
    // o hitbox vive 1-2 frames: conta só um golpe por hitbox
    if (variable_instance_exists(id, "coleta_ultimo_hb") && coleta_ultimo_hb == _hb.id) return 0;
    coleta_ultimo_hb = _hb.id;

    var _tab = coleta_alvos();
    var _a = _tab[$ _alvo];
    tempo_balancar = 15;
    var _c = variable_instance_exists(_hb, "coleta") ? _hb.coleta : undefined;
    if (!is_struct(_c) || _c.tipo != _a.ferramenta) {
        item_fx_texto("Precisa de " + _a.nome + "!", make_color_rgb(255, 170, 80));
        return 0;
    }
    tempo_piscar = 8;
    audio_play_sound(snd_damage, 1, false);
    coleta_tier = clamp(_c.tier, 1, 3);
    return _c.forca;
}

/// Valor por nível da ferramenta (1 madeira, 2 ferro, 3 diamante)
function coleta_por_tier(_t, _v1, _v2, _v3) {
    return (_t >= 3) ? _v3 : ((_t == 2) ? _v2 : _v1);
}

/// Quebra o objeto: dropa e some (escopo do objeto)
function coleta_quebrar(_alvo) {
    var _t = variable_instance_exists(id, "coleta_tier") ? coleta_tier : 1;
    switch (_alvo) {
        case "arvore":
            criar_drop_especifico(x, y, "madeira", irandom_range(2, 4) + (_t - 1) * 2, 0);
            if (random(100) < 12) criar_drop_especifico(x, y, "pena", 1, 0);              // ninho de passarinho
            break;

        case "pedra":
            var _q = (variable_instance_exists(id, "quantis") && quantis > 0) ? quantis : irandom_range(1, 3);
            criar_drop_especifico(x, y, "pedra", _q + (_t - 1), 0);
            var _gr = (image_index >= 3) ? 2 : 1;                                         // pedra grande: chances em dobro
            if (random(100) < coleta_por_tier(_t, 5, 15, 25) * _gr) criar_drop_especifico(x, y, "ferro", _t, 0);
            if (random(100) < coleta_por_tier(_t, 1, 4, 8) * _gr)   criar_drop_especifico(x, y, "ouro", 1, 0);
            if (random(100) < coleta_por_tier(_t, 0, 3, 8) * _gr)   criar_drop_especifico(x, y, "diamante", 1, 0);
            break;

        case "terra":
            var _deu = false;
            if (image_index == 0 && random(100) < 60) { criar_drop_especifico(x, y, "erva", irandom_range(1, 2) + (_t - 1), 0); _deu = true; }
            if (random(100) < 30) { criar_drop_especifico(x, y, "botao", 1, 0); _deu = true; }
            if (random(100) < 20) { criar_drop_especifico(x, y, "gude", 1, 0);  _deu = true; }
            if (random(100) < 25) { criar_drop_especifico(x, y, "pedra", irandom_range(1, 2), 0); _deu = true; }
            if (random(100) < 3 + _t * 2) { criar_drop_especifico(x, y, "po_estrela", 1, 0); _deu = true; }
            if (!_deu) criar_drop_especifico(x, y, "pedra", 1, 0);
            break;
    }
    // Marca a entidade virtual como morta: o obj_otimizador não recria mais (antes a árvore
    // voltava no frame seguinte porque o Destroy dela nem estava registrado no .yy)
    quebrada = true;
    if (variable_instance_exists(id, "virtual_id")) global.entidades_mortas[? virtual_id] = true;
    instance_destroy();
}
