// feather disable GM2017
/// @description Inicialização do Player
// ========================================================
// 1. MACROS E CONFIGURAÇÕES
// ========================================================
// Definindo nomes para os Alarmes (Clean Code)
// Ajuste os números se você já usa estes alarmes para outras coisas
#macro ALARM_ESTAMINA 0
#macro ALARM_DASH_COOLDOWN 1
#macro ALARM_KNOCKBACK 2        // Controla o tempo sendo empurrado
#macro ALARM_INVENCIBILIDADE 3  // Controla o tempo piscando sem tomar dano


// ========================================================
// 2. VARIÁVEIS GLOBAIS (Persistência)
// ========================================================
// Inicializa apenas se não existirem (segurança para mudar de sala)

// --- Status Básicos ---

if (!variable_global_exists("estamina"))      global.estamina = 100;
if (!variable_global_exists("max_estamina"))  global.max_estamina = 100;
if (!variable_global_exists("cansado"))       global.cansado = false; // estamina zerou (PERSONAGEM.gml)
if (!variable_global_exists("sanidade"))      global.sanidade = 100;

// --- Atributos de Combate ---
if (!variable_global_exists("ataque"))        global.ataque = 10;
if (!variable_global_exists("armadura_bebe")) global.armadura_bebe = 0; // Defesa
if (!variable_global_exists("speed_player"))  global.speed_player = 4;
if (!variable_global_exists("level_player"))  global.level_player = 1;
if (!variable_global_exists("tamanho_player")) global.tamanho_player = 1;

// --- Equipamento ---
if (!variable_global_exists("armamento"))     global.armamento = ARMAMENTOS.ESPADA;
if (!variable_global_exists("mata_fantasma")) global.mata_fantasma = false;

// --- Controle de Estado Global ---
if (!variable_global_exists("dialogo"))       global.dialogo = false;
if (!variable_global_exists("in_dash"))       global.in_dash = false;

// ========================================================
// 3. MÁQUINA DE ESTADOS
// ========================================================
state = scr_personagem_andando; // Estado inicial padrão
antigo_state = state;           // Para memória de estado (opcional)

// ========================================================
// 4. MOVIMENTAÇÃO E FÍSICA
// ========================================================
hveloc = 0; // Velocidade Horizontal atual
vveloc = 0; // Velocidade Vertical atual
veloc_dir = 0; // Direção do vetor de movimento
dir = 3;    // Direção do olhar (0:Dir, 1:Cima, 2:Esq, 3:Baixo)
andar = false; // Flag se está se movendo (usado p/ regenerar estamina)

// Dash
dash_dir = 0;
dash_veloc = 10; // Velocidade do dash

// Colisão Auxiliar
// Cria o bloco de colisão nos pés se ele não existir
if (!variable_global_exists("bloco_colisao") || !instance_exists(global.bloco_colisao)) {
    global.bloco_colisao = instance_create_layer(x, y + 30, "Instances", obj_colisao_player); // Crie este objeto ou use um genérico
}

// ========================================================
// 5. COMBATE
// ========================================================
hit = false;           // Se está atualmente no estado de "sendo empurrado"
tomar_dano = true;     // Se pode receber dano no momento (invencibilidade)
empurrar_dir = 0;      // A direção para onde será empurrado
dano_alfa = 0;         // Controle visual para piscar
image_blend = c_white; // Garante que começa com a cor normal
dano_visual       = 0;     // frames restantes do efeito de dano (player_sinal_dano / Draw)
dano_visual_total = 1;
dano_cor          = c_red;
estamina_alfa     = 0;     // transparência da bolinha de estamina (some quando cheia)

// Variáveis visuais da arma
desenha_arma = false;
dir_alfa = 0; // Transparência da arma ao trocar

// ========================================================
// 6. VISUAL E ANIMAÇÃO
// ========================================================
image_speed = 1;
dano_alfa = 0; // Controle de piscar quando toma dano

// Variáveis para sombra e interação
piscando_timer = 20;
piscando_alpha = 1;

// ========================================================
// 7. INTERAÇÃO E INVENTÁRIO
// ========================================================
desenha_botao = false; // Mostra "F" ou "E" na cabeça
proximo_de_estrutura = false;
pegar = true; // Controle para não pegar itens infinitamente num frame

// ========================================================
// 8. CONFIGURAÇÃO DE CÂMERA (Opcional, se o player controlar)
// ========================================================
// Se você usa viewports, pode querer inicializar algo aqui, 
// mas geralmente fica num objeto controlador de câmera.

// --- Menu de pausa (Esc) / configurações: objeto persistente único ---
if (!instance_exists(obj_control_menu)) instance_create_depth(0, 0, -15000, obj_control_menu);

// --- NOVO: SISTEMA DE SKILLS ---
var _mgr_index = asset_get_index("obj_skill_manager");
if (_mgr_index != -1 && !instance_exists(_mgr_index)) {
    instance_create_layer(x, y, "Instances", _mgr_index);
}