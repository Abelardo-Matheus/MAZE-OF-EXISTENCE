/// @desc Inicialização do Jogador
/// [O QUE]: Define o inventário (Enum), variáveis de estado, física, combate e cria o colisor.
/// [COMO] :
/// 1. Cria o Enum 'Armamentos' para controle de armas.
/// 2. Inicializa sprites e controle visual (alfa, direção).
/// 3. Cria o objeto de colisão auxiliar e salva o ID.
/// 4. Define variáveis de movimento, input e combate com valores padrão para evitar erros de "variable not set".

// --- Configuração de Inventário ---
enum Armamentos {
    espada,
    arco,
    Altura // Usado para saber o tamanho do enum
}

// --- Visual & Animação ---
direction_x = 0;
direction_y = 0;
image_speed = 1;
sprite_index = spr_player_baixo;

desenha_arma = false;
desenha_botao = false;
piscando_alpha = 1;   // Opacidade inicial do botão
piscando_timer = 30;  // Intervalo de piscada
dano_alfa = -1;
dir_alfa = 0;

// --- Colisão ---
// Nota: 'global.bloco_colisao' impede ter 2 players no jogo. No futuro, considere usar variável local (ex: 'meu_colisor').
global.bloco_colisao = instance_create_layer(x, y + 30, "instances", obj_colisao);

// --- Máquina de Estados ---
state = scr_andando;

// Booleans de Estado (Flags)
hit = false;
atacando = false;
andar = false;
pegar = false;
proximo_de_estrutura = false;
tomar_dano = true;

// --- Física & Movimento ---
hveloc = -1;
vveloc = -1;
veloc_dir = -1;
dash_dir = -1;
dash_veloc = 20;

// Inputs (Iniciados como -1 ou sem input)
direita = -1;
esquerda = -1;
cima = -1;
baixo = -1;

// --- Combate & Stats ---
dano = global.ataque;
empurrar_dir = 0;