/// @desc Inicialização do Sistema de Diálogo
/// [O QUE]: Cria a grid de armazenamento de texto e inicializa as variáveis de controle de fluxo, digitação e menu de opções.
/// [COMO] : 
/// 1. Cria 'text_grid' com 5 colunas para armazenar os dados do diálogo.
/// 2. Define variáveis de controle (página atual, índice do caractere).
/// 3. Inicializa arrays vazios para o sistema de escolhas.

// --- Identificação ---
npc_nome = ""; // Nome usado no switch para carregar o texto correto

// --- Estrutura de Dados ---
// Colunas: 0=Texto, 1=Retrato, 2=Lado, 3=Nome, 4=É Opção?
text_grid = ds_grid_create(5, 0); 

// --- Controle de Leitura ---
page = 0;              // Página atual do diálogo (antigo: pagina)
char_index = 0;        // Índice do caractere para efeito typewriter (antigo: caracter)
initialized = false;   // Flag de controle (antigo: inicializar)

// Trigger para carregar o texto (1 frame depois)
alarm[0] = 1;

// --- Sistema de Opções (Branching) ---
op[0] = "";            // Texto da opção
op_resposta[0] = "";   // ID do próximo diálogo se escolher esta
op_num = 0;            // Quantidade de opções
op_selected = 0;       // Cursor atual (antigo: op_selecionada)
op_draw = false;       // Flag para desenhar menu (antigo: op_draw)

// --- Definições Globais ---
// (Recomendo deixar isso num script separado, mas mantive aqui para contexto)
enum DialogInfo {
    TEXT,
    PORTRAIT,
    SIDE,
    NAME,
    IS_OPTION
}