# Graph Report - MAZE-OF-EXISTENCE  (2026-10-22)

## Corpus Check
- Corpus is ~15,091 words - fits in a single context window. You may not need a graph.

## Summary
- 1223 nodes · 3460 edges · 65 communities (53 shown, 12 thin omitted)
- Extraction: 88% EXTRACTED · 12% INFERRED · 0% AMBIGUOUS · INFERRED: 415 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- em torno de Art
- em torno de SAVES.gml
- em torno de obj_par_inimigos
- em torno de scr_vento.gml
- em torno de gerar_monstros_para_bloco()
- em torno de obj_horde
- em torno de scr_boss_infancia.gml
- em torno de inventario.gml
- em torno de itens_geral.gml
- em torno de passiva_niveis()
- em torno de spr_fase_criation.gml
- em torno de obj_player
- em torno de gerar_sprites_projeteis.py
- em torno de scr_generic_calculate_stats()
- em torno de gerar_estruturas_para_bloco()
- em torno de scr_cidade.gml
- em torno de obj_inventario
- em torno de scr_casa_moveis.gml
- em torno de obj_arvore
- em torno de scr_passivas_itens.gml
- em torno de sala_definir_tipos()
- em torno de carregar_sala()
- em torno de inventory_add()
- em torno de colocar_bau_motivo_invalido()
- em torno de scr_rastro_sombrio.gml
- em torno de tutorial_decorar_casa()
- em torno de scr_aviao()
- em torno de room Main_tutorial
- em torno de scr_cutscenes.gml
- em torno de gerar_cidade_para_bloco()
- em torno de procurar_sala_por_numero()
- em torno de terreno_bioma_em()
- em torno de reset_level_data()
- em torno de scr_dialogs()
- em torno de obj_GUI
- em torno de LEVEL_UP.gml
- em torno de IA_INIMIGOS.gml
- em torno de pet_niveis()
- em torno de scr_modificadores.gml
- em torno de get_room_id()
- em torno de room Fase_vamp
- em torno de obj_carro_cidade
- em torno de ojb_control_fase_bebe
- em torno de _sala_finalizar()
- em torno de obj_control_vamp
- em torno de inicializar_tudo()
- em torno de obj_player_tutorial
- em torno de inicializar_itens_venda()
- em torno de obj_borboleta_pet
- em torno de day_night_logic()
- em torno de Control_geral.gml
- em torno de out.gml
- em torno de spr_inimigo.gml
- em torno de Linha.gml
- em torno de spr_dash.gml
- em torno de scr_bomba()
- em torno de desenhar_sombra()
- em torno de scr_menu_config()
- em torno de obj_ant
- em torno de obj_chao_grama_vamp
- em torno de obj_bola_efeito
- em torno de FASE_1.gml
- em torno de SALAS.gml
- em torno de scr_damage_system.gml
- em torno de Templo.gml

## God Nodes (most connected - your core abstractions)
1. `obj_player` - 154 edges
2. `Art` - 91 edges
3. `spr_fase_criation.gml` - 80 edges
4. `itens_geral.gml` - 68 edges
5. `obj_inventario` - 67 edges
6. `inventario.gml` - 58 edges
7. `obj_par_inimigos` - 56 edges
8. `scr_cidade.gml` - 38 edges
9. `obj_control_menu` - 37 edges
10. `SAVES.gml` - 30 edges

## Surprising Connections (you probably didn't know these)
- `obj_control_menu` --calls--> `jogo_resetar_progresso()`  [EXTRACTED]
  objects/obj_control_menu/obj_control_menu.yy → scripts/SAVES/SAVES.gml
- `obj_control_menu` --calls--> `tecla_nome()`  [EXTRACTED]
  objects/obj_control_menu/obj_control_menu.yy → scripts/SAVES/SAVES.gml
- `obj_inventario` --calls--> `draw_estrela()`  [EXTRACTED]
  objects/obj_inventario/obj_inventario.yy → scripts/inventario/inventario.gml
- `obj_inventario` --calls--> `ui_icone_stat()`  [EXTRACTED]
  objects/obj_inventario/obj_inventario.yy → scripts/inventario/inventario.gml
- `obj_par_inimigos` --calls--> `inimigo_desenhar_hud()`  [EXTRACTED]
  objects/obj_par_inimigos/obj_par_inimigos.yy → scripts/IA_INIMIGOS/IA_INIMIGOS.gml

## Import Cycles
- None detected.

## Communities (65 total, 12 thin omitted)

### Community 0 - "em torno de Art"
Cohesion: 0.07
Nodes (88): astronauta(), capa_chuva(), casaco(), cavaleiro(), cobertor(), papelao(), pijama_dino(), _shirt() (+80 more)

### Community 1 - "em torno de SAVES.gml"
Cohesion: 0.05
Nodes (60): config_aplicar(), config_aplicar_audio(), config_aplicar_janela(), config_aplicar_video(), config_carregar(), config_padrao(), config_padrao_audio(), config_padrao_video() (+52 more)

### Community 2 - "em torno de obj_par_inimigos"
Cohesion: 0.09
Nodes (58): _alvo_considerar(), _horde_collect_circle(), horde_damage_circle(), _horde_hit_index(), horde_hit_instance(), horde_hit_instance_tick(), horde_on_player_hit(), _horde_player_contact() (+50 more)

### Community 3 - "em torno de scr_vento.gml"
Cohesion: 0.08
Nodes (54): aplicar_movimento_com_colisao(), clima_atualizar(), clima_dano_player(), clima_desenhar(), clima_furacao_puxar(), clima_iniciar(), clima_init(), clima_nome() (+46 more)

### Community 4 - "em torno de gerar_monstros_para_bloco()"
Cohesion: 0.12
Nodes (49): criar_inimigos_em_salas_aleatorias_alet(), gerar_monstros_para_bloco(), horde_instance_only(), horde_split_rule(), inimigo_ia_alarme(), inimigo_ia_criar(), inimigo_ia_desenhar(), inimigo_ia_fim_hit() (+41 more)

### Community 5 - "em torno de obj_horde"
Cohesion: 0.09
Nodes (47): draw_text_colour_outline(), _horde_add(), horde_count(), _horde_director(), _horde_edge_point(), _horde_enxame_iniciar(), _horde_gem_drop(), _horde_gem_escala() (+39 more)

### Community 6 - "em torno de scr_boss_infancia.gml"
Cohesion: 0.08
Nodes (40): boss_anel(), boss_couve_espiral(), boss_couve_investida(), boss_couve_leque(), boss_couve_teleguiadas(), boss_dir_player(), _boss_inf_mesma_sala(), boss_infancia_init() (+32 more)

### Community 7 - "em torno de inventario.gml"
Cohesion: 0.12
Nodes (40): add_skill(), aplicar_status_level(), buff_adicionar(), colocar_bau_iniciar(), draw_estrela(), draw_player_stats_panel(), equip_aplicar_pos_skill(), equip_calcular_bonus() (+32 more)

### Community 8 - "em torno de itens_geral.gml"
Cohesion: 0.13
Nodes (33): bau_ocupados(), buscar_dados_do_item(), buscar_dados_por_nome(), casa_movel_abrir(), coletar_item(), comprar_item_loja(), crafting_get_item_dados(), criar_drop_aleatorio() (+25 more)

### Community 9 - "em torno de passiva_niveis()"
Cohesion: 0.08
Nodes (27): passiva_niveis(), passiva_nivel_valor(), scr_anel_amplificador_config(), scr_chiclete_config(), scr_curativo_config(), scr_estrelinha_config(), scr_feather_config(), scr_ima_de_almas_config() (+19 more)

### Community 10 - "em torno de spr_fase_criation.gml"
Cohesion: 0.11
Nodes (24): array_contains(), carregar_templo(), casa_campos_salvos(), casa_mapas_salvos(), casa_salvar(), coletar_ponto(), create_amoeba_em_salas_aleatorias(), create_inimigos_em_salas_escuras() (+16 more)

### Community 11 - "em torno de obj_player"
Cohesion: 0.10
Nodes (29): atirar_torreta(), horde_on_enemy_death(), horde_player(), inicializar_skill_database(), scr_explosao(), scr_explosion_config(), zoom(), obj_camera (+21 more)

### Community 12 - "em torno de gerar_sprites_projeteis.py"
Cohesion: 0.11
Nodes (8): adaga(), aviao(), canvas(), outline(), pedrinha(), piao(), extract_gml(), main()

### Community 13 - "em torno de scr_generic_calculate_stats()"
Cohesion: 0.11
Nodes (28): scr_adagas_velozes(), scr_adagas_velozes_config(), scr_bola(), scr_bola_config(), scr_boomerang_config(), scr_bumerangue(), scr_generic_calculate_stats(), scr_laminas_giras() (+20 more)

### Community 14 - "em torno de gerar_estruturas_para_bloco()"
Cohesion: 0.16
Nodes (26): cidade_bloco_de(), cidade_registrar_carro(), cidade_registrar_estrutura(), cidade_registrar_poste(), definir_bioma_do_cluster(), gerar_cobertura_cenario(), gerar_estruturas(), gerar_estruturas_para_bloco() (+18 more)

### Community 15 - "em torno de scr_cidade.gml"
Cohesion: 0.27
Nodes (23): cidade_altura(), cidade_av_y(), cidade_beco(), cidade_beco_fim(), cidade_bloco_x(), cidade_calcada_v_em(), cidade_cruzamento(), cidade_desenhar_tile() (+15 more)

### Community 16 - "em torno de obj_inventario"
Cohesion: 0.27
Nodes (22): bau_ui_desenhar(), bau_ui_desenhar_slot(), bau_ui_tooltip(), item_raridade(), item_slots_passiva(), item_stat_info(), item_tipo_nome(), item_tooltip_linhas() (+14 more)

### Community 17 - "em torno de scr_casa_moveis.gml"
Cohesion: 0.20
Nodes (22): _casa_achar(), _casa_candidatos(), _casa_colocar(), _casa_coluna_solida(), _casa_criar_colisao(), casa_gerar_moveis(), casa_gerar_sala(), _casa_item_em() (+14 more)

### Community 18 - "em torno de obj_arvore"
Cohesion: 0.17
Nodes (22): coleta_alvos(), coleta_golpe(), coleta_por_tier(), coleta_quebrar(), desempenho_cull(), desempenho_debug_desenhar(), desempenho_init(), desempenho_view() (+14 more)

### Community 19 - "em torno de scr_passivas_itens.gml"
Cohesion: 0.16
Nodes (22): criar_lista_itens_padronizados(), equip_stats_zero(), item_ao_matar(), item_ativo_init(), item_ativo_input(), item_ativo_usar(), item_fx_desenhar(), item_fx_texto() (+14 more)

### Community 20 - "em torno de sala_definir_tipos()"
Cohesion: 0.10
Nodes (21): coletar_vela(), sala_definir_tipos(), _sala_tipo(), obj_cerca, obj_chao_banheiro, obj_chao_cozinha, obj_chao_grama, obj_chao_templo (+13 more)

### Community 21 - "em torno de carregar_sala()"
Cohesion: 0.14
Nodes (20): carregar_sala(), carregar_sala_templo(), clear_room(), criar_portas_gerais(), criar_portas_gerais_templo(), escada_porao_checar(), escada_porao_usar(), recriar_escada_na_sala_atual() (+12 more)

### Community 22 - "em torno de inventory_add()"
Cohesion: 0.25
Nodes (19): adicionar_item_invent(), atualizar_crafts_disponiveis(), bau_guardar_item(), bau_mover_tudo(), bau_recolher(), bau_slot_click(), bau_transferir(), bau_ui_layout() (+11 more)

### Community 23 - "em torno de colocar_bau_motivo_invalido()"
Cohesion: 0.18
Nodes (19): bau_abrir(), bau_cs(), bau_em_casa(), bau_fechar(), bau_instanciar(), bau_largura_celulas(), bau_lista_atual(), bau_objeto_colisao() (+11 more)

### Community 24 - "em torno de scr_rastro_sombrio.gml"
Cohesion: 0.24
Nodes (16): rastro_alfa(), rastro_amostrar(), rastro_atualizar(), rastro_caveira_sprite(), rastro_criar_poca(), rastro_curva(), rastro_desenhar(), rastro_desenhar_gosma() (+8 more)

### Community 25 - "em torno de tutorial_decorar_casa()"
Cohesion: 0.20
Nodes (17): tutorial_colisao_movel(), tutorial_criar_amoeba(), tutorial_decorar_casa(), tutorial_linha_upgrade(), tutorial_moveis_lista(), tutorial_passos(), tutorial_piso_frame(), tutorial_pisos_lista() (+9 more)

### Community 26 - "em torno de scr_aviao()"
Cohesion: 0.23
Nodes (16): scr_aviao(), scr_aviao_config(), scr_bolhas(), scr_bolhas_config(), scr_estilingue(), scr_estilingue_config(), scr_piao(), scr_piao_config() (+8 more)

### Community 27 - "em torno de room Main_tutorial"
Cohesion: 0.17
Nodes (16): obj_armario_pequeno, obj_cadeira_dois, obj_cadeira_quartro, obj_cadeira_tres, obj_cadeira_um, obj_mesa_um, obj_par_cenario_casa, obj_parede_invi (+8 more)

### Community 28 - "em torno de scr_cutscenes.gml"
Cohesion: 0.28
Nodes (15): action_change_sprite(), action_create_instance(), action_destroy_instance(), action_dialogue(), action_finish_cutscene(), action_move_object(), action_play_sound(), action_set_variable() (+7 more)

### Community 29 - "em torno de gerar_cidade_para_bloco()"
Cohesion: 0.20
Nodes (15): cidade_espalhar(), cidade_ponto_ok(), cidade_registrar_enfeite(), gerar_cidade_para_bloco(), obj_casa_1, obj_casa_2, obj_casa_3, obj_casa_4 (+7 more)

### Community 30 - "em torno de procurar_sala_por_numero()"
Cohesion: 0.21
Nodes (14): create_escada_porao_em_fundos(), procurar_sala_por_numero(), recriar_bosses(), sala_ajustar_camadas(), sala_celula(), sala_construir(), sala_desenhar(), sala_eh_solida() (+6 more)

### Community 31 - "em torno de terreno_bioma_em()"
Cohesion: 0.31
Nodes (14): terreno_bioma_em(), terreno_construir_regiao(), terreno_cor_minimapa(), terreno_cor_objeto(), terreno_definir_blocos_da_regiao(), terreno_escolher_bioma(), terreno_hash(), terreno_id() (+6 more)

### Community 32 - "em torno de reset_level_data()"
Cohesion: 0.23
Nodes (13): casa_novo_mapa(), casa_restaurar(), conta_salas_adjacentes(), criar_salas_escuras(), criar_salas_lista(), criar_templo_e_jardim(), gera_salas_procedurais(), reset_global_variables() (+5 more)

### Community 33 - "em torno de scr_dialogs()"
Cohesion: 0.21
Nodes (13): cutscene_fada1(), dialog_add(), dialog_option(), ds_grid_add_row(), ds_grid_add_text(), scr_dialogs(), tutorial_resetar_progresso(), obj_npc_fada (+5 more)

### Community 34 - "em torno de obj_GUI"
Cohesion: 0.21
Nodes (12): desenha_barra_vida(), desenha_estamina_bolinha(), draw_clock_hand(), draw_fps(), mini_mapa_bebe(), mini_mapa_vamp(), relogio(), obj_GUI (+4 more)

### Community 35 - "em torno de LEVEL_UP.gml"
Cohesion: 0.33
Nodes (13): draw_text_colour_outline_escalado(), ganhar_xp(), gui_desenhar_level_up(), gui_desenhar_slots(), gui_icone_caber(), level_up_aplicar_carta(), level_up_resortear(), level_upp() (+5 more)

### Community 36 - "em torno de IA_INIMIGOS.gml"
Cohesion: 0.28
Nodes (13): inimigo_cor_atual(), inimigo_cor_por_poder(), inimigo_desenhar_hud(), inimigo_ia_atirar(), inimigo_ia_mover(), inimigo_poder(), scr_ia_andar(), scr_ia_check_player() (+5 more)

### Community 37 - "em torno de pet_niveis()"
Cohesion: 0.17
Nodes (13): pet_linha_escolhida(), pet_niveis(), pet_visual(), scr_cachorro_config(), scr_coelho_config(), scr_gato_config(), scr_tartaruga_config(), upgrade_e_pet() (+5 more)

### Community 38 - "em torno de scr_modificadores.gml"
Cohesion: 0.29
Nodes (12): calcular_critico(), mods_aplicar_stats(), mods_get(), mods_padrao(), mods_recalcular(), mods_resetar(), mods_resolver_script(), mods_tick() (+4 more)

### Community 39 - "em torno de get_room_id()"
Cohesion: 0.27
Nodes (12): furniture_generate_positions(), furniture_respawn_in_room(), furniture_save_state(), furniture_update_state(), get_room_id(), obj_geladeira, obj_guarda_roupa, obj_mesa_1 (+4 more)

### Community 40 - "em torno de room Fase_vamp"
Cohesion: 0.24
Nodes (11): obj_botao_exit, obj_botao_load, obj_botao_new, obj_botao_op, obj_par_botoes_menu, room Fase_vamp, room Menu, spr_botoes_menu_exit (+3 more)

### Community 41 - "em torno de obj_carro_cidade"
Cohesion: 0.29
Nodes (10): cidade_dx(), cidade_dy(), cidade_oposta(), cidade_tipo_em(), obj_carro_cidade, obj_enfeite_cidade, obj_humano_cidade, spr_cid_banco (+2 more)

### Community 42 - "em torno de ojb_control_fase_bebe"
Cohesion: 0.25
Nodes (8): cria_salas_e_objetos(), criar_chao_room_inteira(), criar_parede_circular(), criar_paredes_borda(), criar_paredes_intances(), escrever_informacoes_sala(), sala_layout_texto(), ojb_control_fase_bebe

### Community 43 - "em torno de _sala_finalizar()"
Cohesion: 0.39
Nodes (8): _sala_abrir_centro(), _sala_cavar(), _sala_finalizar(), _sala_flood(), sala_garantir_portas(), sala_gerar_layout(), _sala_porta_celula(), sala_portas_necessarias()

### Community 44 - "em torno de obj_control_vamp"
Cohesion: 0.33
Nodes (7): cidade_gerar_quadra_inicial(), cidade_spawn_x(), cidade_spawn_y(), inicializar_gerador_mundo(), init_night_waves(), recriar_estruturas(), obj_control_vamp

### Community 45 - "em torno de inicializar_tudo()"
Cohesion: 0.48
Nodes (6): criar_poder(), ds_grid_add_item_vamp(), ds_grid_add_upgrade_vamp(), inicializar_tudo(), scr_generic_calculate_passive_upgrade(), poderes_lista.gml

### Community 46 - "em torno de obj_player_tutorial"
Cohesion: 0.33
Nodes (7): obj_colisao, obj_control_dialogo, obj_dialogo, obj_player_tutorial, obj_player_vamp, spr_colisao_1, spr_player_direita

### Community 47 - "em torno de inicializar_itens_venda()"
Cohesion: 0.60
Nodes (6): adicionar_item_venda(), calcular_preco_com_base_no_nivel(), determinar_tier_do_item(), filtrar_itens_por_nivel(), inicializar_itens_venda(), scr_npc_venda.gml

### Community 48 - "em torno de obj_borboleta_pet"
Cohesion: 0.40
Nodes (6): scr_borboleta(), scr_butterfly_config(), obj_borboleta_pet, obj_par_pet, scr_pet_borboleta.gml, spr_borboleta_idle

### Community 49 - "em torno de day_night_logic()"
Cohesion: 0.60
Nodes (5): day_night_cycle_manager(), day_night_logic(), day_night_render(), obj_control_dia_noite, dia_noite.gml

### Community 50 - "em torno de Control_geral.gml"
Cohesion: 0.50
Nodes (3): is_within_bounds(), remove_dead_ends(), Control_geral.gml

### Community 51 - "em torno de out.gml"
Cohesion: 0.60
Nodes (4): draw_text_outlined(), draw_text_outlined_ext(), draw_text_outlined_wrapped_block(), out.gml

### Community 55 - "em torno de scr_bomba()"
Cohesion: 1.00
Nodes (3): scr_bomb_config(), scr_bomba(), scr_bomba.gml

## Knowledge Gaps
- **122 isolated node(s):** `spr_esqueleto`, `spr_casa2`, `spr_xp_um`, `spr_cogumelo_parado`, `spr_totem_boss` (+117 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 181 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **12 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `obj_player` connect `em torno de obj_player` to `em torno de SAVES.gml`, `em torno de obj_GUI`, `em torno de obj_par_inimigos`, `em torno de scr_modificadores.gml`, `em torno de inventario.gml`, `em torno de itens_geral.gml`, `em torno de obj_player_tutorial`, `em torno de gerar_estruturas_para_bloco()`, `em torno de obj_inventario`, `em torno de scr_casa_moveis.gml`, `em torno de scr_passivas_itens.gml`, `em torno de colocar_bau_motivo_invalido()`, `em torno de scr_rastro_sombrio.gml`?**
  _High betweenness centrality (0.189) - this node is a cross-community bridge._
- **What connects `spr_esqueleto`, `spr_casa2`, `spr_xp_um` to the rest of the system?**
  _122 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `em torno de Art` be split into smaller, more focused modules?**
  _Cohesion score 0.06733001658374793 - nodes in this community are weakly interconnected._
- **Why does `obj_control_menu` connect `em torno de obj_inventario` to `em torno de SAVES.gml`, `em torno de inventario.gml`, `em torno de room Fase_vamp`, `em torno de obj_player`, `em torno de obj_player_tutorial`, `em torno de scr_passivas_itens.gml`?**
  _High betweenness centrality (0.089) - this node is a cross-community bridge._
- **Should `em torno de SAVES.gml` be split into smaller, more focused modules?**
  _Cohesion score 0.05427547363031234 - nodes in this community are weakly interconnected._
- **Why does `room Fase_vamp` connect `em torno de room Fase_vamp` to `em torno de obj_GUI`, `em torno de obj_player`, `em torno de obj_control_vamp`, `em torno de obj_player_tutorial`, `em torno de obj_inventario`, `em torno de day_night_logic()`, `em torno de obj_arvore`, `em torno de terreno_bioma_em()`?**
  _High betweenness centrality (0.076) - this node is a cross-community bridge._
- **Should `em torno de obj_par_inimigos` be split into smaller, more focused modules?**
  _Cohesion score 0.09074410163339383 - nodes in this community are weakly interconnected._