// feather disable GM2017
// ============================================================================
// 7. FUNÇÃO DE SPAWN DE MONSTROS (Filhos Reais com Scaling)
// ============================================================================
function gerar_monstros_para_bloco(_bx, _by, _bioma_atual, _dist_minima) 
{
    var _bloco_id = "monstros_" + string(_bx) + "," + string(_by);
    if (ds_map_exists(global.blocos_gerados, _bloco_id)) return;
    ds_map_add(global.blocos_gerados, _bloco_id, true);

    var _centro_x = (_bx + 0.5) * global.tamanho_bloco;
    var _centro_y = (_by + 0.5) * global.tamanho_bloco;

    var _distancia_da_origem = point_distance(0, 0, _centro_x, _centro_y);
    var _distancia_por_level = 8000; 
    var _level_da_area = 1 + floor(_distancia_da_origem / _distancia_por_level);

    var _qtd_base = 0;
    var _obj_monstro = noone; 
    
    switch (_bioma_atual) 
    {
        case "floresta":
            _qtd_base = irandom_range(3, 6);
            // slimes + cogumelos disfarcados
            _obj_monstro = choose(obj_amoeba, obj_amoeba_azul, obj_cogumelo, obj_cogumelo_venenoso); 
            break;
            
        case "cidade":
            _qtd_base = irandom_range(5, 10);
            // slimes + ratos de esgoto + morcegos
            _obj_monstro = choose(obj_amoeba_laranja, obj_amoeba_rosa, obj_rato, obj_rato_gigante, obj_morcego);
            break;
            
        case "floresta_negra":
            _qtd_base = irandom_range(8, 15);
            // familia dos esqueletos + familia dos fantasmas + morcego vampiro
            _obj_monstro = choose(
                obj_esqueleto, obj_esqueleto_guerreiro, obj_esqueleto_arqueiro, obj_esqueleto_corredor,
                obj_inimigo_fantasma, obj_fantasma_azul, obj_fantasma_verde, obj_fantasma_vermelho,
                obj_morcego_vampiro
            );
            break;
            
        case "vazia":
            _qtd_base = irandom_range(1, 3);
            _obj_monstro = choose(obj_esqueleto, obj_esqueleto_guerreiro, obj_olho_vazio, obj_fantasma_vermelho); 
            break;

        // ---------------- BIOMAS NOVOS ----------------
        case "deserto":
            _qtd_base = irandom_range(3, 6);
            _obj_monstro = choose(obj_rato_gigante, obj_esqueleto_corredor, obj_esqueleto_arqueiro, obj_amoeba_laranja);
            break;

        case "neve":
            _qtd_base = irandom_range(3, 7);
            _obj_monstro = choose(obj_fantasma_azul, obj_morcego, obj_esqueleto, obj_amoeba_azul);
            break;

        case "pantano":
            _qtd_base = irandom_range(5, 9);
            _obj_monstro = choose(obj_cogumelo_venenoso, obj_fantasma_verde, obj_amoeba, obj_rato);
            break;

        case "vulcanico":
            _qtd_base = irandom_range(6, 10);
            _obj_monstro = choose(obj_fantasma_vermelho, obj_morcego_vampiro, obj_esqueleto_guerreiro, obj_amoeba_vermelha);
            break;

        case "prado":
            _qtd_base = irandom_range(2, 5);
            _obj_monstro = choose(obj_amoeba, obj_amoeba_rosa, obj_cogumelo, obj_rato);
            break;

        case "cristalino":
            _qtd_base = irandom_range(4, 8);
            _obj_monstro = choose(obj_olho_vazio, obj_fantasma_azul, obj_inimigo_fantasma, obj_amoeba_azul);
            break;
    }

    if (_obj_monstro == noone) return;

    var _quantidade_final = _qtd_base + floor(_level_da_area / 2);
    var _escala_monstro = 1 + (_level_da_area * 0.15); 
    
    var _hp_calculado = 50 * _level_da_area;
    var _dano_calculado = 5 * _level_da_area;

    var _gerados = 0;
    var _tentativas = 0;
    var _max_tentativas = _quantidade_final * 3;

    while (_gerados < _quantidade_final && _tentativas < _max_tentativas) 
    {
        var _pos_x = _centro_x + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);
        var _pos_y = _centro_y + random_range(-global.tamanho_bloco / 2 + 100, global.tamanho_bloco / 2 - 100);

        // PERFORMANCE: Spatial Hashing
        if (!posicao_conflitante_geracao(_pos_x, _pos_y, _dist_minima)) 
        {
            randomize();
            var _seed = random_get_seed();

            // VIRTUALIZAÇÃO: Apenas dados
            var _dados = [_pos_x, _pos_y, _seed, _obj_monstro, _escala_monstro, _hp_calculado, _dano_calculado, _level_da_area];
            ds_list_add(global.posicoes_monstros, _dados);
            registrar_entidade_no_bloco(_bx, _by, "monstro", _dados);
            registrar_posicao_geracao(_pos_x, _pos_y);

            _gerados++;
        }
        _tentativas++;
    }
}

// ===========================================================================
// RONDAS DA NOITE
// init_night_waves() / process_night_waves() agora ficam em scr_rondas_noite.
// ===========================================================================

/// @function spawn_night_enemy(spec)
/// @description Recebe um pedido de scr_rondas_noite: { obj, qtd, mult } (ver rondas_spec).
/// Inimigos comuns viram horda (obj_horde). Os de horde_instance_only (arqueiro, olho)
/// continuam instâncias reais e recebem os mesmos multiplicadores.
function spawn_night_enemy(_spec) {
    if (horde_spawn_ronda(_spec)) return;

    var _m = _spec.mult;
    // Posição: borda do quadrado de spawn fixo (Camera.gml), sempre maior que o zoom máximo
    spawn_ponto_quadrado();
    var _bx = global.spawn_px;
    var _by = global.spawn_py;

    repeat (_spec.qtd) {
        var _enemy_id = global.enemy_id_counter++;
        // 1. Cria a instância (o Create define os status base)
        var _novo_inimigo = instance_create_layer(_bx + random_range(-40, 40), _by + random_range(-40, 40), "instances", _spec.obj);

        // 2. Aplica os multiplicadores da ronda
        with (_novo_inimigo) {
            vida     = max(1, vida * _m.hp);
            max_vida = vida;
            dano     = dano * _m.dmg;
            escala   = escala * _m.esc;
            veloc_perse = veloc_perse * _m.spd;
            xp_ronda = round(HORDE_XP_BASE * _m.xp); // lido no Step do obj_par_inimigos ao morrer
            dist_aggro    = 2000;
            dist_desaggro = 2000;
            id_inimigo = _enemy_id;
            image_xscale = escala;
            image_yscale = escala;
        }
        ds_list_add(global.enemy_list, _enemy_id);
    }
}
