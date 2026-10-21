# Graph Report - MAZE-OF-EXISTENCE  (2026-10-21)

## Corpus Check
- Large corpus: 4062 files · ~4,659,990 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 1026 nodes · 2805 edges · 38 communities (29 shown, 9 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 415 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- em torno de Art
- em torno de scr_cidade.gml
- em torno de obj_inventario
- em torno de scr_horde.gml
- em torno de aplicar_movimento_com_colisao()
- em torno de scr_cutscenes.gml
- em torno de obj_par_inimigos
- em torno de gerar_monstros_para_bloco()
- em torno de scr_generic_calculate_stats()
- em torno de obj_SPERM
- em torno de scr_boss_infancia.gml
- em torno de room Fase_vamp
- em torno de spr_fase_criation.gml
- em torno de obj_player
- em torno de scr_casa_moveis.gml
- em torno de sala_definir_tipos()
- em torno de extract_gml()
- em torno de carregar_sala()
- em torno de reset_level_data()
- em torno de obj_pontos
- em torno de get_room_id()
- em torno de procurar_sala_por_numero()
- em torno de IA_INIMIGOS.gml
- em torno de obj_player36
- em torno de escada_porao_usar()
- em torno de inicializar_itens_venda()
- em torno de scr_explosao()
- em torno de ler_recorde()
- em torno de scr_bola()
- em torno de scr_bomba()
- em torno de desenhar_sombra()
- em torno de obj_ant
- em torno de obj_chao_grama_vamp
- em torno de obj_inimigo_fantasma
- em torno de obj_bola_efeito
- em torno de FASE_1.gml
- em torno de SALAS.gml
- em torno de Templo.gml

## God Nodes (most connected - your core abstractions)
1. `obj_player` - 132 edges
2. `Art` - 91 edges
3. `spr_fase_criation.gml` - 80 edges
4. `obj_inventario` - 55 edges
5. `obj_par_inimigos` - 48 edges
6. `inventario.gml` - 47 edges
7. `itens_geral.gml` - 47 edges
8. `scr_cidade.gml` - 36 edges
9. `gerar_cidade_para_bloco()` - 26 edges
10. `scr_horde.gml` - 26 edges

## Surprising Connections (you probably didn't know these)
- `obj_control_menu` --goes_to_room--> `room Fase_BEBE`  [EXTRACTED]
  objects/obj_control_menu/obj_control_menu.yy → rooms/Fase_BEBE/Fase_BEBE.yy
- `obj_hibox_ataque` --calls--> `calcular_critico()`  [EXTRACTED]
  objects/obj_hibox_ataque/obj_hibox_ataque.yy → scripts/LEVEL_UP/LEVEL_UP.gml
- `obj_par_inimigos` --calls--> `inimigo_desenhar_hud()`  [EXTRACTED]
  objects/obj_par_inimigos/obj_par_inimigos.yy → scripts/IA_INIMIGOS/IA_INIMIGOS.gml
- `obj_par_inimigos` --calls--> `remover_inimigo_por_id()`  [EXTRACTED]
  objects/obj_par_inimigos/obj_par_inimigos.yy → scripts/spr_fase_criation/spr_fase_criation.gml
- `obj_player` --calls--> `coletar_item()`  [EXTRACTED]
  objects/obj_player/obj_player.yy → scripts/itens_geral/itens_geral.gml

## Import Cycles
- None detected.

## Communities (38 total, 9 thin omitted)

### Community 0 - "em torno de Art"
Cohesion: 0.07
Nodes (88): astronauta(), capa_chuva(), casaco(), cavaleiro(), cobertor(), papelao(), pijama_dino(), _shirt() (+80 more)

### Community 1 - "em torno de scr_cidade.gml"
Cohesion: 0.05
Nodes (106): cidade_altura(), cidade_av_y(), cidade_beco(), cidade_beco_fim(), cidade_bloco_de(), cidade_bloco_x(), cidade_calcada_v_em(), cidade_cruzamento() (+98 more)

### Community 2 - "em torno de obj_inventario"
Cohesion: 0.07
Nodes (100): adicionar_item_invent(), atualizar_crafts_disponiveis(), bau_guardar_item(), bau_recolher(), bau_slot_click(), buff_adicionar(), buscar_dados_do_item(), buscar_dados_por_nome() (+92 more)

### Community 3 - "em torno de scr_horde.gml"
Cohesion: 0.08
Nodes (58): _alvo_considerar(), draw_text_colour_outline(), _horde_add(), _horde_collect_circle(), horde_count(), horde_damage_circle(), _horde_director(), _horde_edge_point() (+50 more)

### Community 4 - "em torno de aplicar_movimento_com_colisao()"
Cohesion: 0.06
Nodes (54): aplicar_movimento_com_colisao(), fim_animation(), ganhar_xp_tuto(), level_up_tuto(), obter_inputs_jogador(), parar_som_passo(), scr_amoeba_andar(), scr_amoeba_check_player() (+46 more)

### Community 5 - "em torno de scr_cutscenes.gml"
Cohesion: 0.07
Nodes (47): action_change_sprite(), action_create_instance(), action_destroy_instance(), action_dialogue(), action_finish_cutscene(), action_move_object(), action_play_sound(), action_set_variable() (+39 more)

### Community 6 - "em torno de obj_par_inimigos"
Cohesion: 0.10
Nodes (47): horde_hit_instance(), horde_on_player_hit(), inimigo_colisao_ignorar(), inimigo_mais_proximo(), player_dano_recebido(), scr_enemy_damage_apply(), sprite_ajuste(), obj_bola (+39 more)

### Community 7 - "em torno de gerar_monstros_para_bloco()"
Cohesion: 0.14
Nodes (46): criar_inimigos_em_salas_aleatorias_alet(), gerar_monstros_para_bloco(), horde_split_rule(), inimigo_ia_alarme(), inimigo_ia_criar(), inimigo_ia_desenhar(), inimigo_ia_fim_hit(), inimigo_ia_nivel() (+38 more)

### Community 8 - "em torno de scr_generic_calculate_stats()"
Cohesion: 0.06
Nodes (43): criar_poder(), ds_grid_add_item_vamp(), ds_grid_add_upgrade_vamp(), inicializar_tudo(), scr_adagas_velozes(), scr_adagas_velozes_config(), scr_anel_amplificador(), scr_anel_amplificador_config() (+35 more)

### Community 9 - "em torno de obj_SPERM"
Cohesion: 0.06
Nodes (39): apagar_linhas(), create_random_enemy_folow(), create_wall_instances(), criar_paredes_vermelha_intances(), desenha_linha(), is_within_bounds(), prim_algorithm(), remove_dead_ends() (+31 more)

### Community 10 - "em torno de scr_boss_infancia.gml"
Cohesion: 0.08
Nodes (38): boss_anel(), boss_couve_espiral(), boss_couve_investida(), boss_couve_leque(), boss_couve_teleguiadas(), boss_dir_player(), boss_infancia_init(), boss_infancia_step() (+30 more)

### Community 11 - "em torno de room Fase_vamp"
Cohesion: 0.07
Nodes (39): add_skill(), aplicar_status_level(), calcular_critico(), day_night_cycle_manager(), day_night_logic(), day_night_render(), desenha_barra_vida(), draw_clock_hand() (+31 more)

### Community 12 - "em torno de spr_fase_criation.gml"
Cohesion: 0.10
Nodes (37): array_contains(), carregar_templo(), casa_campos_salvos(), casa_mapas_salvos(), casa_salvar(), create_amoeba_em_salas_aleatorias(), create_escada_porao_em_fundos(), create_inimigos_em_salas_escuras() (+29 more)

### Community 13 - "em torno de obj_player"
Cohesion: 0.08
Nodes (34): atirar_torreta(), horde_instance_only(), horde_on_enemy_death(), horde_player(), inicializar_skill_database(), initialize_global_list(), zoom(), obj_camera (+26 more)

### Community 14 - "em torno de scr_casa_moveis.gml"
Cohesion: 0.19
Nodes (22): _casa_achar(), _casa_candidatos(), _casa_colocar(), _casa_coluna_solida(), casa_gerar_moveis(), casa_gerar_sala(), _casa_item_em(), _casa_linha_solida() (+14 more)

### Community 15 - "em torno de sala_definir_tipos()"
Cohesion: 0.11
Nodes (19): coletar_vela(), sala_definir_tipos(), _sala_tipo(), obj_cerca, obj_chao_banheiro, obj_chao_cozinha, obj_chao_templo, obj_chao_tijolo (+11 more)

### Community 17 - "em torno de carregar_sala()"
Cohesion: 0.18
Nodes (17): carregar_sala(), carregar_sala_templo(), clear_room(), criar_portas_gerais(), criar_portas_gerais_templo(), recriar_inimigos_na_sala_atual(), recriar_inimigos_na_sala_atual_alet(), recriar_pontos_na_sala_atual() (+9 more)

### Community 18 - "em torno de reset_level_data()"
Cohesion: 0.21
Nodes (14): casa_novo_mapa(), casa_restaurar(), conta_salas_adjacentes(), criar_salas_escuras(), criar_salas_lista(), criar_templo_e_jardim(), gera_salas_procedurais(), gerar_inimigos_e_itens_para_o_nivel() (+6 more)

### Community 19 - "em torno de obj_pontos"
Cohesion: 0.17
Nodes (12): coletar_ponto(), criar_parede_circular(), criar_paredes_borda(), criar_random_pontos(), obj_ovulo, obj_pontos, obj_wall_carne, obj_wall_carne_circular (+4 more)

### Community 20 - "em torno de get_room_id()"
Cohesion: 0.27
Nodes (12): furniture_generate_positions(), furniture_respawn_in_room(), furniture_save_state(), furniture_update_state(), get_room_id(), obj_geladeira, obj_guarda_roupa, obj_mesa_1 (+4 more)

### Community 21 - "em torno de procurar_sala_por_numero()"
Cohesion: 0.22
Nodes (10): _boss_inf_mesma_sala(), boss_infancia_spawnar(), cria_salas_e_objetos(), criar_chao_room_inteira(), criar_paredes_intances(), escrever_informacoes_sala(), procurar_sala_por_numero(), recriar_bosses() (+2 more)

### Community 22 - "em torno de IA_INIMIGOS.gml"
Cohesion: 0.38
Nodes (10): inimigo_desenhar_hud(), inimigo_ia_atirar(), inimigo_ia_mover(), scr_ia_andar(), scr_ia_check_player(), scr_ia_escolher_estado(), scr_ia_parado(), scr_ia_perseguir() (+2 more)

### Community 23 - "em torno de obj_player36"
Cohesion: 0.22
Nodes (9): obj_enemy, obj_explosion, obj_player36, obj_wall, obj_wall_cima, spr_explosion, spr_parede, spr_parede_cima (+1 more)

### Community 24 - "em torno de escada_porao_usar()"
Cohesion: 0.29
Nodes (8): _casa_criar_colisao(), escada_porao_checar(), escada_porao_usar(), recriar_escada_na_sala_atual(), obj_escada_porao, obj_parede_bebe, spr_escada_porao_top, spr_parede_bebe

### Community 25 - "em torno de inicializar_itens_venda()"
Cohesion: 0.60
Nodes (6): adicionar_item_venda(), calcular_preco_com_base_no_nivel(), determinar_tier_do_item(), filtrar_itens_por_nivel(), inicializar_itens_venda(), scr_npc_venda.gml

### Community 26 - "em torno de scr_explosao()"
Cohesion: 0.50
Nodes (5): scr_explosao(), scr_explosion_config(), obj_confete, scr_explosao.gml, spr_confete

### Community 27 - "em torno de ler_recorde()"
Cohesion: 0.50
Nodes (3): ler_recorde(), obj_control_menu, SAVES.gml

### Community 28 - "em torno de scr_bola()"
Cohesion: 1.00
Nodes (3): scr_bola(), scr_bola_config(), scr_bola_up.gml

### Community 29 - "em torno de scr_bomba()"
Cohesion: 1.00
Nodes (3): scr_bomb_config(), scr_bomba(), scr_bomba.gml

## Knowledge Gaps
- **124 isolated node(s):** `spr_amoeba_verde`, `spr_amoeba_azul`, `spr_amoeba_laranja`, `spr_amoeba_rosa`, `spr_amoeba_vermelha` (+119 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 170 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `obj_player` connect `em torno de obj_player` to `em torno de scr_cidade.gml`, `em torno de obj_inventario`, `em torno de scr_cutscenes.gml`, `em torno de obj_par_inimigos`?**
  _High betweenness centrality (0.111) - this node is a cross-community bridge._
- **What connects `spr_amoeba_verde`, `spr_amoeba_azul`, `spr_amoeba_laranja` to the rest of the system?**
  _124 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `em torno de Art` be split into smaller, more focused modules?**
  _Cohesion score 0.06601545727780163 - nodes in this community are weakly interconnected._
- **Why does `room Fase_vamp` connect `em torno de room Fase_vamp` to `em torno de scr_cidade.gml`, `em torno de scr_cutscenes.gml`, `em torno de obj_inventario`, `em torno de obj_player`?**
  _High betweenness centrality (0.091) - this node is a cross-community bridge._
- **Should `em torno de scr_cidade.gml` be split into smaller, more focused modules?**
  _Cohesion score 0.051666372773761245 - nodes in this community are weakly interconnected._
- **Should `em torno de obj_inventario` be split into smaller, more focused modules?**
  _Cohesion score 0.06686868686868687 - nodes in this community are weakly interconnected._
- **Should `em torno de scr_horde.gml` be split into smaller, more focused modules?**
  _Cohesion score 0.07743496672716274 - nodes in this community are weakly interconnected._