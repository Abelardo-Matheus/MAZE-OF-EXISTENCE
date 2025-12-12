/// @desc Inicialização do Sistema de Inventário



// ========================================================
// CONFIGURAÇÕES VISUAIS E DE ESCALA
// ========================================================
is_open = false;       // (Antigo: inventario) Controla se está visível
scale   = 2.5;         // (Antigo: escala) Fator de escala da UI

// Dimensões do Sprite Base
inventory_w = sprite_get_width(spr_iinventario) * scale;
inventory_h = sprite_get_height(spr_iinventario) * scale;

// --- Layout da Grid de Itens ---
grid_start_x = 21 * scale;   // (Antigo: comeco_x)
grid_start_y = 74 * scale;   // (Antigo: comeco_y)

slot_width   = 49 * scale;   // (Antigo: tamanho_slot_x)
slot_height  = 52.3 * scale; // (Antigo: tamanho_slot_y)
slot_buffer  = 1.9 * scale;  // Espaçamento entre slots

// --- Layout dos Slots de Equipamento (Status) ---
equip_start_x = 513 * scale; // (Antigo: comeco_x_status)
equip_start_y = 74 * scale;  // (Antigo: comeco_y_status)

// --- Layout de Texto (Descrição e Nome) ---
text_name_x = 19;       // (Antigo: comeco_x_nome)
text_name_y = 272;      // (Antigo: comeco_y_nome)

text_desc_x = 147 + 90; // (Antigo: comeco_x_descricao)
text_desc_y = 271;      // (Antigo: comeco_y_descricao)

// ========================================================
// LÓGICA DE CAPACIDADE E SLOTS
// ========================================================

// Grid Principal (Mochila)
grid_cols = 6; // (Antigo: slots_h)
grid_rows = 3; // (Antigo: slots_v)
total_slots = grid_cols * grid_rows;

// Slots de Equipamento (Ficam no final da DS Grid)
// Índices na Grid: 
// [total_slots]     = Arma
// [total_slots + 1] = Armadura
// [total_slots + 2] = Bota
equip_slots_count = 3; 

// Flags de Equipamento
is_weapon_equipped = false; // arma_equipada
is_armor_equipped  = false; // armadura_equipada
is_boots_equipped  = false; // bota_equipada

// Controle de Estado Global
global.inventario_cheio = false; 

// ========================================================
// CONTROLE DE SELEÇÃO (MOUSE/CURSOR)
// ========================================================
selected_item  = -1; // ID do item selecionado
selected_slot  = -1; // Índice do slot selecionado
selected_index = -1; // (Antigo: pos_index_selecionada) Uso interno visual
cooldown_timer = 0;  // Timer para evitar cliques múltiplos rápidos

// ========================================================
// ESTRUTURAS DE DADOS (ENUMS E GRID)
// ========================================================

// Enum principal para acessar as colunas da Grid
enum Infos {
    item,
    quantidade,
    sprite,
    nome,
    descricao,
    sala_x,     // Onde foi dropado (para persistência)
    sala_y,
    pos_x,
    pos_y,
    dano,
    armadura,
    velocidade,
    cura,
    tipo,       // "uso", "arma", "armadura", "bota"
    image_ind,  // Sub-imagem do sprite
    preco,
    Height      // (Antigo: Altura) Tamanho total do enum
}

// Enums de IDs de Itens (Opcional, útil para comparações rápidas)
enum itens_ativos { batata, maca, banana, uva, vitamina, leite, Length }
enum itens_passivos { Vela, cobertor, bota, Length }
enum itens_armas { graveto, vassoura, espada_madeira, espada_plastico, espada_ouro, espada_mata_fantasma, Length }
enum itens_pe { tenis_velho, sapato_velho, patins, skate, tenis_novo, sapato_novo, meia_vermelha, meia_amarela, Length }

// --- Criação da Grid Global ---
// Altura da Grid = Slots da Mochila + Slots de Equipamento
var _grid_height = total_slots + equip_slots_count;

global.grid_itens = ds_grid_create(Infos.Height, _grid_height);

// Inicializa tudo com -1 (Vazio)
ds_grid_clear(global.grid_itens, -1);

// ========================================================
// VARIÁVEIS DE ESTADO E POSICIONAMENTO (Faltantes)
// ========================================================

// Posição calculada do inventário na tela (Usado no Step e Draw)
inventory_x = 0;
inventory_y = 0;

// Índices fixos para os Slots de Equipamento (Facilita a leitura no código)
// Em vez de usar números mágicos como "total_slots + 1"
slot_index_weapon = total_slots;     // Slot da Arma
slot_index_armor  = total_slots + 1; // Slot da Armadura
slot_index_boots  = total_slots + 2; // Slot da Bota

// ========================================================
// VARIÁVEIS GLOBAIS DE JOGO (Se não estiverem no obj_player)
// ========================================================

// Controle de Moedas (Usado na loja)
if (!variable_global_exists("moedas")) {
    global.moedas = 0;
}

// Lógica Específica de Itens
if (!variable_global_exists("mata_fantasma")) {
    global.mata_fantasma = false; // Controla se pode bater em fantasmas
}

// Stats do Player (Garantia para não crashar o HUD se o player não criar)
if (!variable_global_exists("vida"))           global.vida = 100;
if (!variable_global_exists("vida_max"))       global.vida_max = 100;
if (!variable_global_exists("ataque"))         global.ataque = 10;
if (!variable_global_exists("armadura_bebe"))  global.armadura_bebe = 0;
if (!variable_global_exists("speed_player"))   global.speed_player = 4;
if (!variable_global_exists("level_player"))   global.level_player = 1;

// Arrays de Dano Base (Se usado na lógica de equipar/desequipar)
if (!variable_global_exists("dano_base")) {
    global.dano_base = array_create(100, 5); // Cria array de dano por nível
}
