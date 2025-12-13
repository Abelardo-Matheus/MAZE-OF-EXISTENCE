/// @description Lógica Principal (Step)
// Executa o script do estado atual (Andando, Atacando, Dash, etc.)
script_execute(state);

// --- Abrir/Fechar Inventário ---
// Isso DEVE vir antes da pausa, senão você nunca consegue fechar!
if (keyboard_check_pressed(ord("I")) || keyboard_check_pressed(vk_tab)) {
    if (instance_exists(obj_inventario)) {
        obj_inventario.is_open = !obj_inventario.is_open;
        
        // Reseta estados visuais ao abrir
        if (obj_inventario.is_open) {
            image_speed = 0;
            desenha_botao = false;
            // Opcional: Parar sons de passos, etc.
        }
    }
}
// ========================================================
// 1. SISTEMA DE PAUSA E CONGELAMENTO
// ========================================================

// Pausa: Level Up

if (!global.level_up) {
    // Congela os alarmes para não perderem tempo
    alarm[ALARM_ESTAMINA]++; 
    alarm[ALARM_KNOCKBACK]++; 
    alarm[ALARM_INVENCIBILIDADE]++; 
    alarm[ALARM_DASH_COOLDOWN]++; 
    
    image_speed = 0;
    exit; // Para o código aqui
}

// Pausa: Inventário Aberto
if (instance_exists(obj_inventario) && obj_inventario.is_open) {
    image_speed = 0;
    // Opcional: image_index = 0; // Se quiser forçar a pose parada
    exit; // Para o código aqui
}

// ========================================================
// 2. SISTEMA DE SANIDADE E LUZ
// ========================================================
var _limite_escuridao = 0.5;
var _recuperacao_sanidade = 0;
var _qtd_luzes = ds_list_size(global.lista_luzes);

// Verifica proximidade com luzes
for (var i = 0; i < _qtd_luzes; i++) {
    var _luz = global.lista_luzes[| i];
    
    if (instance_exists(_luz)) {
        var _distancia = point_distance(x, y, _luz.x, _luz.y);
        
        // Define recuperação baseada na intensidade/distância da luz
        if (_distancia < _luz.luz_1)      _recuperacao_sanidade = max(_recuperacao_sanidade, 0.09);
        else if (_distancia < _luz.luz_2) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.07);
        else if (_distancia < _luz.luz_3) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.05);
        else if (_distancia < _luz.luz_4) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.04);
        else if (_distancia < _luz.luz_5) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.02);
        
        // Se for dia, recupera independente da luz artificial
        if (global.day_night_cycle.is_day) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.09);
    }
}

// Aplica Recuperação ou Dano
if (_recuperacao_sanidade > 0) {
    global.sanidade += _recuperacao_sanidade;
} 
else if (!global.day_night_cycle.is_day && global.day_night_cycle.current_light < _limite_escuridao) {
    // Dano progressivo pela escuridão
    var _fator_escuridao = 1 - (global.day_night_cycle.current_light / _limite_escuridao);
    global.sanidade -= 0.08 * _fator_escuridao;
}

// Limita sanidade
global.sanidade = clamp(global.sanidade, 0, 100);

// ========================================================
// 3. MÁQUINA DE ESTADOS (Movimento e Ação)
// ========================================================
image_speed = 1;

// Força estado de Hit se tomou dano (Knockback)
if (hit) {
    state = scr_personagem_hit;
}



// Atualiza posição do bloco de colisão auxiliar
if (instance_exists(global.bloco_colisao)) {
    global.bloco_colisao.x = x;
    global.bloco_colisao.y = y + 30;
}

// ========================================================
// 4. ESTAMINA E VIDA
// ========================================================

// Regeneração de Estamina
// Só regenera se não estiver correndo/gastando (andar == false) e alarm[0] zerado
if (global.estamina < global.max_estamina && !andar && alarm[ALARM_ESTAMINA] <= 0) {
    global.estamina += 0.5;
}

// Exaustão (Estamina zerada)
if (global.estamina <= 0 && !andar) {
    andar = true; // Trava corrida
    global.estamina = 0;
    alarm[ALARM_ESTAMINA] = 50; // Tempo de penalidade
}

// Morte
if (global.vida <= 0) {
    // Lógica de Game Over
    game_restart(); 
}

// ========================================================
// 5. TROCA DE ARMAS
// ========================================================
if (mouse_wheel_up() && dir_alfa <= 0) {
    global.armamento++;
    dir_alfa = 1;
    desenha_arma = true;
}
if (mouse_wheel_down() && dir_alfa <= 0) {
    global.armamento--;
    dir_alfa = 1;
    desenha_arma = true;
}

// Loop cíclico (Wrap)
if (global.armamento >= Armamentos.Altura) global.armamento = 0;
else if (global.armamento < 0) global.armamento = Armamentos.Altura - 1;

// Fade out do ícone da arma
if (desenha_arma) {
    dir_alfa -= 0.02;
    if (dir_alfa <= 0) {
        dir_alfa = 0;
        desenha_arma = false;
    }
}


// --- Coletar Itens (Proximidade) ---
var _item_perto = instance_nearest(x, y, obj_item);
var _dist_coleta = 25; // Distância em pixels para aparecer o botão

if (_item_perto != noone && distance_to_object(_item_perto) <= _dist_coleta && !global.inventario_cheio) {
    desenha_botao = true; // Mostra ícone "F"
    
    if (keyboard_check_pressed(ord("F"))) {
        // Adiciona ao inventário
        adicionar_item_invent(
            _item_perto.image_index,
            _item_perto.quantidade,
            _item_perto.sprite_index,
            _item_perto.nome,
            _item_perto.descricao,
            _item_perto.sala_x,
            _item_perto.sala_y,
            _item_perto.pos_x,
            _item_perto.pos_y,
            _item_perto.dano,
            _item_perto.armadura,
            _item_perto.velocidade,
            _item_perto.cura,
            _item_perto.tipo,
            _item_perto.ind,
            _item_perto.preco
        );
        
        // Remove da persistência e destrói
        coletar_item(_item_perto.pos_x, _item_perto.pos_y, global.current_sala);
        instance_destroy(_item_perto);
        
        desenha_botao = false;
    }
} else {
    desenha_botao = false;
}

// --- Interação com NPC ---
var _npc = instance_nearest(x, y, par_npc_vendedor_um); // Use seu objeto pai de NPC
if (_npc != noone && distance_to_object(_npc) <= 50) {
    desenha_botao = true;
    
    if (keyboard_check_pressed(ord("P")) && !global.dialogo) {
        andar = true; // Trava movimento
        var _dialogo = instance_create_layer(x, y, "Instances_dialogo", obj_dialogo);
        _dialogo.npc_nome = _npc.nome;
    }
}

// ========================================================
// 7. UPGRADES E EFEITOS VISUAIS
// ========================================================

// Executa Upgrades Passivos
var _qtd_upgrades = ds_list_size(global.active_upgrades);
for (var i = 0; i < _qtd_upgrades; i++) {
    script_execute(global.active_upgrades[| i]); 
}

// Efeito de Dano (Piscar)
if (alarm[ALARM_INVENCIBILIDADE] > 0) {
    if (image_alpha >= 1) dano_alfa = -0.05;
    else if (image_alpha <= 0.2) dano_alfa = 0.05; // Mínimo 0.2 para não sumir
    image_alpha += dano_alfa;
} else {
    image_alpha = 1;
}

// Efeito Botão de Interação (Piscar)
if (piscando_timer > 0) {
    piscando_timer--;
} else {
    piscando_alpha = (piscando_alpha == 1) ? 0 : 1; // Alterna 0 e 1
    piscando_timer = 20;
}