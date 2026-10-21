// feather disable GM2017
/// @desc scr_horde_config — Ajustes da horda noturna (Fase_vamp)
/// [O QUE]: Constantes e ganchos do sistema de horda. É o ÚNICO arquivo que você precisa
///          mexer para balancear. Os inimigos e as rondas da noite ficam em scr_rondas_noite
///          e nos eventos Create de cada objeto inimigo.
/// [COMO] : A horda lê vida/dano/velocidade/sprite/comportamento direto do Create do objeto
///          (instância-protótipo criada uma única vez por tipo), então nada é duplicado aqui.

// ---------------------------------------------------------------------------
// CAPACIDADE / PERFORMANCE
// ---------------------------------------------------------------------------
#macro HORDE_MAX               3000   // inimigos vivos (memória pré-alocada)
#macro HORDE_SPAWN_BUDGET      24     // nascimentos máximos por frame (evita pico)
#macro HORDE_AI_SLICES         3      // separação recalculada em 1/N dos inimigos por frame
#macro HORDE_MAX_NEIGHBORS     6      // vizinhos considerados na separação
#macro HORDE_SEPARATION_FORCE  0.6
#macro HORDE_GRID_CELL         48     // célula do hash espacial
#macro HORDE_GRID_MARGIN       320    // área além da câmera coberta pelo hash (alvos/colisão)
#macro HORDE_DEBUG             false  // contador + fps no canto da tela

// ---------------------------------------------------------------------------
// DENSIDADE (estilo Vampire Survivors)
// ---------------------------------------------------------------------------
#macro HORDE_GRUPO_POR_SPAWN   3      // (sem uso) o tamanho do grupo agora vem de "grupo" em scr_rondas_noite
#macro HORDE_GRUPO_ESPALHAR    40     // raio do grupinho
#macro HORDE_ENXAME_INTERVALO  0      // cerco automático extra (s); 0 = só os anéis definidos nas rondas
#macro HORDE_ENXAME_QTD        60     // inimigos no anel
#macro HORDE_WRAP_BORDA        64     // (sem uso) o teleporte agora usa o quadrado de spawn: SPAWN_QUADRADO_LADO em Camera.gml
#macro HORDE_SOME_AO_AMANHECER true
#macro HORDE_AMANHECER_POR_FRAME 15

// ---------------------------------------------------------------------------
// COMBATE (valores espelhados do obj_par_inimigos)
// ---------------------------------------------------------------------------
#macro HORDE_STUN_FRAMES       5      // = alarm[1] = 5 (estado de hit)
#macro HORDE_HPBAR_FRAMES      180    // = alarm[2] = 180 (barra de vida visível)
#macro HORDE_TICK_IFRAMES      10     // armas de contato contínuo acertam o mesmo inimigo a cada N frames
#macro HORDE_POPUP_MAX         96     // números de dano simultâneos (pool)
#macro HORDE_SOM_DANO_INTERVALO 4     // frames mínimos entre sons de dano

// ---------------------------------------------------------------------------
// XP
// ---------------------------------------------------------------------------
#macro HORDE_GEM_MAX           1500   // gemas no chão; acima disso o XP soma na gema mais próxima
#macro HORDE_GEM_JUNTAR_RAIO   48     // gema que cai a menos disso de outra se junta a ela (soma o XP)
#macro HORDE_GEM_ESCALA        3      // tamanho da gema de valor base (= image_xscale do obj_xp_um)
#macro HORDE_GEM_ESCALA_MAX    2.2    // gemas muito valiosas crescem até 2.2x o tamanho base
#macro HORDE_XP_BASE           20     // = base_xp do obj_xp_um
#macro HORDE_XP_POR_LVL        0      // obj_xp_um pretendia lvl*10, mas o bônus nunca era aplicado
#macro HORDE_GEM_VELOC         4      // = spd do obj_xp_um

// ---------------------------------------------------------------------------
// REGRAS POR OBJETO
// ---------------------------------------------------------------------------

/// Inimigos que continuam sendo instâncias reais (comportamento complexo, ex.: atiram).
function horde_instance_only(_obj) {
    return (_obj == obj_esqueleto_arqueiro || _obj == obj_olho_vazio);
}

/// Inimigos que se dividem ao morrer (antigo Step do obj_amoeba_laranja).
function horde_split_rule(_obj) {
    if (_obj == obj_amoeba_laranja) return { obj: obj_amoeba, count: 3 };
    return undefined;
}

// ---------------------------------------------------------------------------
// GANCHOS DO JOGO
// ---------------------------------------------------------------------------

function horde_player() {
    if (variable_global_exists("current_player") && instance_exists(global.current_player)) {
        return global.current_player;
    }
    return instance_exists(obj_player) ? instance_find(obj_player, 0) : noone;
}

/// Dano de contato no jogador — mesma lógica de obj_par_inimigos/Collision_obj_player.
function horde_on_player_hit(_player, _dano, _from_x, _from_y) {
    var _ok = false;
    with (_player) {
        if (!tomar_dano) break;
        _dano = player_dano_recebido(_dano); // defesa e esquiva (scripts/inventario)
        if (_dano <= 0) break;
        _ok = true;
        global.vida -= _dano;
        empurrar_dir = (x == _from_x && y == _from_y) ? 0 : point_direction(_from_x, _from_y, x, y);
        hit = true;
        alarm[ALARM_KNOCKBACK] = 15;
        tomar_dano = false;
        alarm[ALARM_INVENCIBILIDADE] = 90;
        image_blend = c_red;
    }
    if (_ok && object_exists(obj_dano)) {
        var _inst = instance_create_layer(_player.x, _player.y - 30, "Instances", obj_dano);
        _inst.dano = _dano;
        _inst.cor  = c_red;
    }
}

/// Colisão arma -> inimigo-instância: true = ignorar este inimigo.
/// Fantasmas especiais (par_inimigos_fantasmas) só levam dano com o item global.mata_fantasma.
/// _sempre_fantasma = true para a espada, que já trata eles no evento Collision_par_inimigos_fantasmas.
function inimigo_colisao_ignorar(_inst, _sempre_fantasma = false) {
    if (!instance_exists(_inst) || _inst.vida <= 0) return true;
    var _obj = _inst.object_index;
    var _fantasma = (_obj == par_inimigos_fantasmas) || object_is_ancestor(_obj, par_inimigos_fantasmas);
    if (!_fantasma) return false;
    return _sempre_fantasma || !global.mata_fantasma;
}

/// Chamado a cada inimigo da horda que morre (XP e divisão são tratados pelo sistema).
function horde_on_enemy_death(_obj, _x, _y) {
    with (obj_player) alarm[6] = 3; // mesmo efeito do obj_par_inimigos ao morrer
}
