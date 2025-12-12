/// @description Inicialização do Player
// ========================================================
// 1. MACROS E CONFIGURAÇÕES
// ========================================================
// Definindo nomes para os Alarmes (Clean Code)
#macro ALARM_ESTAMINA 0
#macro ALARM_KNOCKBACK 2
#macro ALARM_INVENCIBILIDADE 3
#macro ALARM_DASH_COOLDOWN 11

// Enum de Armas (Caso não esteja em um script global)
enum Armamentos {
    espada,
    arco,
    Altura
}

// ========================================================
// 2. VARIÁVEIS GLOBAIS (Persistência)
// ========================================================
// Inicializa apenas se não existirem (segurança para mudar de sala)

// --- Status Básicos ---
if (!variable_global_exists("vida"))          global.vida = 100;
if (!variable_global_exists("vida_max"))      global.vida_max = 100;
if (!variable_global_exists("estamina"))      global.estamina = 100;
if (!variable_global_exists("max_estamina"))  global.max_estamina = 100;
if (!variable_global_exists("sanidade"))      global.sanidade = 100;

// --- Atributos de Combate ---
if (!variable_global_exists("ataque"))        global.ataque = 10;
if (!variable_global_exists("armadura_bebe")) global.armadura_bebe = 0; // Defesa
if (!variable_global_exists("speed_player"))  global.speed_player = 4;
if (!variable_global_exists("level_player"))  global.level_player = 1;
if (!variable_global_exists("tamanho_player")) global.tamanho_player = 1;

// --- Equipamento ---
if (!variable_global_exists("armamento"))     global.armamento = Armamentos.espada;
if (!variable_global_exists("mata_fantasma")) global.mata_fantasma = false;

// --- Controle de Estado Global ---
if (!variable_global_exists("level_up"))      global.level_up = false;
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
atacando = false;
tomar_dano = true; // Flag de invencibilidade (true = pode tomar dano)
hit = false;       // Flag de estado de hit (empurrão)
empurrar_dir = 0;  // Direção do knockback

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