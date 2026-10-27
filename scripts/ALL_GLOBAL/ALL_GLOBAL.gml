// feather disable GM2017
/// @desc Inicialização de Variáveis Globais (Garantia de Execução Única)

// Função auxiliar para inicializar listas globais com segurança
function initialize_global_list(_name) {
    if (!variable_global_exists(_name)) {
        variable_global_set(_name, ds_list_create());
    } else {
        var _list = variable_global_get(_name);
        if (ds_exists(_list, ds_type_list)) ds_list_clear(_list);
        else variable_global_set(_name, ds_list_create());
    }
}

// --- Listas e Estruturas de Dados ---
initialize_global_list("enemy_list");
initialize_global_list("lista_luzes");
initialize_global_list("active_upgrades");

// --- Definições de Tipos ---
enum ARMAMENTOS {
    ESPADA,
    ARCO,
    ALTURA
}

enum INFOS {
    ITEM, QUANTIDADE, SPRITE, NOME, DESCRICAO, SALA_X, SALA_Y, POS_X, POS_Y,
    DANO, ARMADURA, VELOCIDADE, CURA, TIPO, IMAGE_IND, PRECO,
    NIVEL,    // nível do equipamento (1.., sem limite — sobe matando monstros)
    PASSIVAS, // array com os IDs das passivas (sorteadas + adesivos), até ITEM_PASSIVAS_MAX
    XP,       // XP do item rumo ao próximo nível (scr_passivas_itens)
    HEIGHT
}

// Enums de IDs de Itens
enum ITENS_ATIVOS { BATATA, MACA, BANANA, UVA, VITAMINA, LEITE, LENGTH }
enum ITENS_PASSIVOS { VELA, COBERTOR, BOTA, LENGTH }
enum ITENS_ARMAS { GRAVETO, VASSOURA, ESPADA_MADEIRA, ESPADA_PLASTICO, ESPADA_OURO, ESPADA_MATA_FANTASMA, LENGTH }
enum ITENS_PE { TENIS_VELHO, SAPATO_VELHO, PATINS, SKATE, TENIS_NOVO, SAPATO_NOVO, MEIA_VERMELHA, MEIA_AMARELA, LENGTH }

// Enum de Materiais de Craft
enum ITENS_CRAFT { MADEIRA, PEDRA, ERVA_VERMELHA, FRASCO_VAZIO, BARRA_FERRO, BARRA_OURO, COURO, LENGTH }

// --- Configurações de Jogo ---
global.armamento = ARMAMENTOS.ESPADA;
global.levels_pendentes = 0;
global.debug = true;
global.max_sanidade = 100;
global.sanidade = 100;
global.minimap_expandido = false;
global.map_vamp = true;
global.map_bebe = true;
global.pos_x_map = -1;
global.pos_y_map = -1;
global.sair = false;
global.moedas = PROG_MOEDAS_INICIAIS; // scr_progressao
global.seed_map = random_get_seed();
global.estruturas_criadas = false;
global.vetor_estruturas = [];
global.dist_aggro_amoeba = 200;
global.fase = 0;
global.dist_desaggro_amoeba = 400;
global.level_fase = 1;
global.sala = noone;
global.ovulo_sala_pos = noone;
global.in_slow = false;
global.current_player = obj_player;
global.slow = obj_slow_bebe;
global.cor_dano = c_white;
global.permitido = true;
global.inimigo_id_count = 0;
global.enemy_id_counter = 0; // Unifica nomes para compatibilidade
global.level_player = 1;      // Nível base do jogador
global.mata_fantasma = false;
global.current_level = 1;
global.armadura_bebe = 0;
global.speed_player_base = 10;
global.speed_player = 10;
global.encontrou_sala_escura = false;
global.xp = 0;
global.tamanho_player = 1;
global.tamanho_player_max = 5;
global.direcao_templo = 0;
global.vinda_templo = 0;
global.origem_templo = noone;
global.destino_templo = noone;
global.distancia_parede_templo = 4; 
global.dash_tempo_recarga = 60*6; 
global.map = true;
global.full = false;
global.raio_lanterna = 20;
global.recorde = 0;
global.vela_coletada = false;
global.direcao_escada_porao = 0;
global.direcao_escada = 0;
global.sala_entrada = noone;
global.entrou = false;
global.passada = noone;
global.seed_atual = noone;
global.coleta = 50;
global.moving_towards_player = true;
global.upgrade_num = 4;
global.timer = 0;
global.timer_running = true;
global.area_anel = 1;
global.cooldown_tomo = 1;
// --- NOVAS VARIÁVEIS DO SISTEMA DE SKILLS ---
global.player_area_mod = 1.0;
global.player_cooldown_mod = 1.0;
global.speed_player_base = 10.0; // Referência para as passivas de velocidade

global.moedas_iniciais = global.moedas; // usado ao voltar para o Menu (jogo_resetar_progresso)

// --- Configurações (vídeo, áudio, teclas) — scripts/SAVES ---
config_carregar(); // aplicado pelo obj_control_menu quando ele nasce (já existe janela)

// Inicializa catálogo de itens se necessário
criar_lista_itens_padronizados();