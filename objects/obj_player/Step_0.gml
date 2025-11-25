/// @desc Lógica Principal (Sanidade, Movimento, Armas)
/// [O QUE]: Gerencia o cálculo de sanidade baseado na luz, pausa de level up, regeneração de estamina, troca de armas e execução de estados.
/// [COMO] :
/// 1. Itera sobre 'global.lista_luzes' calculando a distância para recuperar sanidade.
/// 2. Aplica penalidade de sanidade se estiver no escuro.
/// 3. Se 'global.level_up' estiver ativo, pausa alarmes e encerra o evento (exit).
/// 4. Executa a máquina de estados ('state') e gerencia inputs de troca de arma.
/// 5. Executa scripts de upgrades passivos.

// --- 1. Sistema de Sanidade e Luz ---
var _limite_escuridao = 0.5;
var _recuperacao_sanidade = 0; // Acumulador local

// Otimização: Cache do tamanho da lista para não recalcular a cada loop
var _qtd_luzes = ds_list_size(global.lista_luzes);

for (var i = 0; i < _qtd_luzes; i++) 
{
    var _luz = global.lista_luzes[| i];
    
    if (instance_exists(_luz)) 
    {
        // Nota: Usamos 'x' e 'y' diretamente pois estamos no objeto do player
        var _distancia = point_distance(x, y, _luz.x, _luz.y);

        // Verifica a potência da luz baseada na distância
        if (_distancia < _luz.luz_1)      _recuperacao_sanidade = max(_recuperacao_sanidade, 0.09);
        else if (_distancia < _luz.luz_2) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.07);
        else if (_distancia < _luz.luz_3) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.05);
        else if (_distancia < _luz.luz_4) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.04);
        else if (_distancia < _luz.luz_5) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.02);
        else if (global.day_night_cycle.is_day) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.09);
    }
}

// Aplica a recuperação ou o dano de sanidade
if (_recuperacao_sanidade > 0) 
{
    global.sanidade += _recuperacao_sanidade;
} 
else if (!global.day_night_cycle.is_day && global.day_night_cycle.current_light < _limite_escuridao) 
{
    var _fator_escuridao = 1 - (global.day_night_cycle.current_light / _limite_escuridao);
    global.sanidade -= 0.08 * _fator_escuridao; // Dano progressivo no escuro
}

// Mantém a sanidade dentro dos limites (0 a 100)
global.sanidade = clamp(global.sanidade, 0, 100);


// --- 2. Pause de Level Up ---
if (global.level_up == true) 
{
    // Congela alarmes para não perderem o tempo enquanto o jogo está pausado
    alarm[0]++; alarm[2]++; alarm[3]++; alarm[6]++; alarm[11]++;
    image_speed = 0;
    exit; // O CÓDIGO PARA AQUI. Nada abaixo executa se for level up.
}

// --- 3. Execução Normal do Jogo ---
image_speed = 1;

// Troca de estado por Dano
if (hit) 
{
    state = scr_personagem_hit;
}

// Executa o Estado Atual
script_execute(state);

// --- 4. Gerenciamento de Estamina ---
// Regeneração
if (global.estamina <= global.max_estamina && !andar) 
{
    global.estamina += 0.5;
}

// Verificação de Morte (Game Over)
if (global.vida <= 0) 
{
    // game_end(); // Descomentar quando implementar tela de game over
}

// Exaustão (Estamina zerada)
if (global.estamina <= 0 && !andar) 
{
    andar = true;
    global.estamina = 0;
    alarm[0] = 50; // Tempo de recarga
}

// --- 5. Troca de Armas (Input) ---
// Rolar para Cima
if (mouse_wheel_up() && dir_alfa <= 0) 
{
    global.armamento += 1;
    dir_alfa = 1;
    desenha_arma = true;
}

// Rolar para Baixo
if (mouse_wheel_down() && dir_alfa <= 0) 
{
    global.armamento -= 1;
    dir_alfa = 1;
    desenha_arma = true;
}

// Loop Cíclico das Armas (Wrap)
if (global.armamento >= Armamentos.Altura) 
{
    global.armamento = 0; // Volta para o início
} 
else if (global.armamento < 0) 
{
    global.armamento = Armamentos.Altura - 1; // Vai para o final
}

// --- 6. Efeito Visual da Arma (Fade Out) ---
if (desenha_arma) 
{
    dir_alfa -= 0.02;

    if (dir_alfa <= 0) 
    {
        dir_alfa = 0;
        desenha_arma = false;
    }
}

// --- 7. Upgrades Passivos ---
var _qtd_upgrades = ds_list_size(global.active_upgrades);

for (var i = 0; i < _qtd_upgrades; i++) 
{
    var _script = global.active_upgrades[| i];
    script_execute(_script); 
}


/// @desc Lógica Visual e Interação (Timer e NPCs)
/// [O QUE]: Controla oscilação de transparência (dano/botão) e interação com NPCs.
/// [COMO] :
/// 1. Se alarm[3] estiver ativo, faz o sprite piscar (efeito de dano).
/// 2. Controla o timer do botão de interação para piscar.
/// 3. Define 'desenha_botao' baseado na proximidade da estrutura.
/// 4. Checa proximidade e input 'P' para iniciar diálogo com NPC Vendedor.

// --- 1. Efeito de Dano (Piscar Sprite) ---
if (alarm[3] > 0) 
{
    // Lógica "Ping-Pong" do Alpha
    if (image_alpha >= 1) 
    {
        dano_alfa = -0.05;
    } 
    else if (image_alpha <= 0) 
    {
        dano_alfa = 0.05;
    }
    image_alpha += dano_alfa;
} 
else 
{
    // Garante que o sprite volte ao normal quando o alarme acabar
    image_alpha = 1;
}

// --- 2. Controle do Botão de Interação (Piscar) ---
if (piscando_timer > 0) 
{
    piscando_timer--; // Contagem regressiva
} 
else 
{
    piscando_alpha = 1 - piscando_alpha; // Alterna entre 0 e 1 matematicamente
    piscando_timer = 20; // Reseta timer
}

// Lógica simplificada: Se estiver próximo, desenha.
if (proximo_de_estrutura) 
{
    desenha_botao = true;
} 
else 
{
    desenha_botao = false;
}

// --- 3. Interação com NPC (Vendedor) ---
var _distancia_npc = 100;

if (distance_to_object(par_npc_vendedor_um) <= _distancia_npc) 
{
    // Input de Interação
    if (keyboard_check_pressed(ord("P")) && !global.dialogo) 
    {
        andar = true; // Trava/Destrava movimento (conforme sua lógica original)
        
        // Busca o NPC mais próximo para pegar o nome dele
        var _npc = instance_nearest(x, y, par_npc_vendedor_um);
        var _dialogo = instance_create_layer(x, y, "Instances_dialogo", obj_dialogo);
        _dialogo.npc_nome = _npc.nome;
    }
}

// Importante: Reseta a variável para o próximo frame
proximo_de_estrutura = false;