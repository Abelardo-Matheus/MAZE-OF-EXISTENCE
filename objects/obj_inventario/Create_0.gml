/// @desc Inicialização Completa do Sistema de Inventário e Crafting

// ========================================================
// 1. CONFIGURAÇÕES VISUAIS E DE ESCALA DA UI
// ========================================================
is_open = false;       // Controla se o inventário está visível na tela
scale   = 2.5;         // Fator de escala da UI

// Dimensões do Sprite Base
inventory_w = sprite_get_width(spr_iinventario) * scale;
inventory_h = sprite_get_height(spr_iinventario) * scale;

// --- Layout da Grid de Itens (Mochila) ---
grid_start_x = 21 * scale;   
grid_start_y = 74 * scale;   

slot_width   = 49 * scale;   
slot_height  = 52.3 * scale; 
slot_buffer  = 1.9 * scale;  

// --- Layout dos Slots de Equipamento (Status Lateral) ---
equip_start_x = 513 * scale; 
equip_start_y = 74 * scale;  

// --- Layout de Texto (Descrição e Nome) ---
text_name_x = 19;       
text_name_y = 272;      

text_desc_x = 147 + 90; 
text_desc_y = 271;      

// Posição calculada do inventário na tela (Atualizado no Draw/Step)
inventory_x = 0;
inventory_y = 0;


// ========================================================
// 2. LÓGICA DE CAPACIDADE, SLOTS E CURSOR
// ========================================================
grid_cols = 6; 
grid_rows = 3; 
total_slots = grid_cols * grid_rows;

// Slots de Equipamento
equip_slots_count = 3; 
slot_index_weapon = total_slots;     // Índice da Arma
slot_index_armor  = total_slots + 1; // Índice da Armadura
slot_index_boots  = total_slots + 2; // Índice da Bota

// Flags de Equipamento e Estado
is_weapon_equipped = false; 
is_armor_equipped  = false; 
is_boots_equipped  = false; 
global.inventario_cheio = false; 

// Controle do Mouse / Drag & Drop
selected_item  = -1; // ID do item arrastado
selected_slot  = -1; // Índice do slot onde o mouse está em cima
selected_index = -1; // Índice original do item sendo arrastado
cooldown_timer = 0;  // Timer para evitar cliques duplos acidentais


// ========================================================
// 3. ESTRUTURAS DE DADOS (ENUMS)
// ========================================================
enum Infos {
    item, quantidade, sprite, nome, descricao, sala_x, sala_y, pos_x, pos_y,
    dano, armadura, velocidade, cura, tipo, image_ind, preco, Height
}

// Enums de IDs de Itens
enum itens_ativos { batata, maca, banana, uva, vitamina, leite, Length }
enum itens_passivos { Vela, cobertor, bota, Length }
enum itens_armas { graveto, vassoura, espada_madeira, espada_plastico, espada_ouro, espada_mata_fantasma, Length }
enum itens_pe { tenis_velho, sapato_velho, patins, skate, tenis_novo, sapato_novo, meia_vermelha, meia_amarela, Length }

// Enum de Materiais de Craft
enum itens_craft { madeira, pedra, erva_vermelha, frasco_vazio, barra_ferro, barra_ouro, couro, Length }


// ========================================================
// 4. CRIAÇÃO DA MOCHILA FÍSICA (DS GRID)
// ========================================================
var _grid_height = total_slots + equip_slots_count;
global.grid_itens = ds_grid_create(Infos.Height, _grid_height);

// Limpa todos os slots (Coloca -1 que significa "Vazio")
ds_grid_clear(global.grid_itens, -1);


// ========================================================
// 5. VARIÁVEIS GLOBAIS DE STATUS (Segurança)
// ========================================================
if (!variable_global_exists("moedas"))         global.moedas = 0;
if (!variable_global_exists("mata_fantasma"))  global.mata_fantasma = false; 
if (!variable_global_exists("vida"))           global.vida = 100;
if (!variable_global_exists("vida_max"))       global.vida_max = 100;
if (!variable_global_exists("ataque"))         global.ataque = 10;
if (!variable_global_exists("armadura_bebe"))  global.armadura_bebe = 0;
if (!variable_global_exists("speed_player"))   global.speed_player = 4;
if (!variable_global_exists("level_player"))   global.level_player = 1;

if (!variable_global_exists("dano_base")) {
    global.dano_base = array_create(100, 5); 
}



crafts_disponiveis = ds_list_create();

// ==========================================
// NOVO DESIGN: POSIÇÕES E TAMANHOS DO CRAFT
// ==========================================
// Posição do primeiro bloco de craft (Inferior Esquerda)
craft_box_x = 918; 
craft_box_y = 678;

// O tamanho do painel de craft inteiro (Largura e Altura)
// Defini um tamanho grande (160x100) para caber o item, ingredientes e botão
craft_pane_width = 501; 
craft_pane_height = 65;
craft_buffer = 15; // Espaçamento entre um painel e outro

// Tamanho do ícone do item de resultado (a espada)
craft_item_icon_size = 32; 

// Tamanho dos ícones pequenininhos de ingrediente (a madeira)
craft_ing_icon_size = 16; 

// Posição e tamanho do botão "CRAFT"
craft_btn_w = 80;
craft_btn_h = 30;


// ========================================================
// 1. PRIMEIRO: CARREGAR A DATABASE DE ITENS
// ========================================================
// Precisamos carregar os itens ANTES das receitas, para as receitas poderem copiar os sprites!
if (script_exists(asset_get_index("criar_lista_itens_padronizados"))) {
    criar_lista_itens_padronizados();
}

// ==========================================
// 2. BANCO DE DADOS DE CRAFTING (AUTOMATIZADO)
// ==========================================
global.receitas_craft = [];

// Criamos uma mini-função mágica que procura o NOME do item e preenche o Sprite e Index sozinha!
var add_receita = function(_enum_resultado, _nome_item_db, _ingredientes) {
    var _dados = buscar_dados_por_nome(_nome_item_db);
    
    if (_dados != undefined) {
        array_push(global.receitas_craft, {
            resultado: _enum_resultado,  
            spr_resultado: _dados[0], // Puxa o Sprite real direto da Database!
            idx_resultado: _dados[7], // Puxa o Index real direto da Database!
            qtd_resultado: 1,               
            ingredientes: _ingredientes
        });
    } else {
        show_debug_message("ERRO NO CRAFT: O item '" + _nome_item_db + "' não foi encontrado na Database!");
    }
};

// --- LISTA DE RECEITAS ---

// 1. Arma Básica
add_receita(itens_armas.espada_madeira, "Espada de Madeira", [
    { item: itens_craft.madeira, qtd: 2 }, 
    { item: itens_craft.pedra, qtd: 1 }   
]);

// 2. Arma de Sobrevivência
add_receita(itens_armas.graveto, "Graveto", [
    { item: itens_craft.madeira, qtd: 1 }
]);

// 3. Poção / Consumível
add_receita(itens_ativos.vitamina, "Vitamina", [
    { item: itens_craft.erva_vermelha, qtd: 3 },
    { item: itens_craft.frasco_vazio, qtd: 1 }
]);

// 4. Arma Intermediária
add_receita(itens_armas.vassoura, "Vassoura", [
    { item: itens_craft.madeira, qtd: 3 },
    { item: itens_craft.erva_vermelha, qtd: 2 } 
]);

// 5. Equipamento de Defesa
add_receita(itens_passivos.cobertor, "Cobertor", [
    { item: itens_craft.couro, qtd: 4 }
]);

// 6. Equipamento de Velocidade
add_receita(itens_pe.tenis_novo, "Tênis de Corrida", [
    { item: itens_craft.couro, qtd: 2 },
    { item: itens_craft.barra_ferro, qtd: 1 } 
]);

// 7. Arma Avançada 
add_receita(itens_armas.espada_ouro, "Espada Dourada", [
    { item: itens_craft.barra_ouro, qtd: 3 },
    { item: itens_craft.madeira, qtd: 1 },
    { item: itens_craft.couro, qtd: 1 } 
]);

// 8. Arma Lendária Especial
add_receita(itens_armas.espada_mata_fantasma, "Mata-Fantasma", [
    { item: itens_craft.barra_ferro, qtd: 3 },
    { item: itens_craft.barra_ouro, qtd: 1 },
    { item: itens_craft.frasco_vazio, qtd: 1 } 
]);

// 7.3 Calcula pela primeira vez se o jogador pode craftar algo
if (script_exists(asset_get_index("atualizar_crafts_disponiveis"))) {
    atualizar_crafts_disponiveis();
}


// ==========================================
// DAR ITENS INICIAIS PARA TESTAR O CRAFT
// ==========================================
// Chama a função nova passando Nome, Quantidade e o Enum
dar_item_ao_jogador("Madeira", 5, itens_craft.madeira);
dar_item_ao_jogador("Pedra", 5, itens_craft.pedra);
dar_item_ao_jogador("Erva Vermelha", 5, itens_craft.erva_vermelha);
dar_item_ao_jogador("Frasco Vazio", 5, itens_craft.frasco_vazio);
dar_item_ao_jogador("Couro", 5, itens_craft.couro);
dar_item_ao_jogador("Barra de Ferro", 5, itens_craft.barra_ferro);

// Atualiza a lista pra UI saber que ganhamos itens
atualizar_crafts_disponiveis();