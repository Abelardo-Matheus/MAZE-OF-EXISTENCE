// feather disable GM2017
/// @description Lógica Principal (Step) ORGANIZADA
depth = profundidade_pe(bbox_bottom); // pé do player: passa atrás/na frente dos móveis (scr_casa_moveis)
// ========================================================
// 1. INPUTS DE SISTEMA (Abrir/Fechar Menus)
// ========================================================
// Tem que vir ANTES da pausa para você conseguir fechar o menu!
if (keyboard_check_pressed(ord("I")) || keyboard_check_pressed(vk_tab)) {
    if (instance_exists(obj_inventario)) {
        obj_inventario.is_open = !obj_inventario.is_open;
        if (obj_inventario.is_open) {
            desenha_botao = false;
        }
    }
}

// ========================================================
// 2. SISTEMA DE PAUSA E CONGELAMENTO
// ========================================================

// --- Pausa: Level Up ---
// ATENÇÃO: Se global.level_up for VERDADEIRO, o jogo PAUSA.
// Verifique se você não tinha um "!" na frente do global.level_up antes.


// --- Pausa: Inventário Aberto ---
if (instance_exists(obj_inventario) && obj_inventario.is_open) {
    image_speed = 0; // Congela animação
    exit; // PARA TUDO AQUI.
}

// ========================================================
// SE O CÓDIGO CHEGOU AQUI, O JOGO NÃO ESTÁ PAUSADO.
// ========================================================
image_speed = 1; // Garante que as animações rodem se não estiver pausado

// ========================================================
// 3. MÁQUINA DE ESTADOS (O Coração do Player)
// ========================================================

// --- VERIFICAÇÃO PRIORITÁRIA DE HIT ---
// Se a flag 'hit' for verdadeira (ativada na colisão com inimigo),
// força o estado a mudar para scr_personagem_hit imediatamente.
if (hit) {
    state = scr_personagem_hit;
}

// Executa o estado atual
if (state != -1) {
    var _isValid = is_method(state);
    if (!_isValid && is_real(state)) _isValid = script_exists(state);
    
    if (_isValid) {
        script_execute(state);
    }
}

// Atualiza posição do bloco de colisão auxiliar (se usar)
if (instance_exists(global.bloco_colisao)) {
    global.bloco_colisao.x = x;
    global.bloco_colisao.y = y + 30;
}

// ========================================================
// 4. SISTEMAS GLOBAIS (Estamina, Vida, Sanidade)
// ========================================================

// --- Regeneração de Estamina ---
if (global.estamina < global.max_estamina && !andar && alarm[ALARM_ESTAMINA] <= 0) {
    global.estamina += 0.5;
}
// --- Exaustão ---
if (global.estamina <= 0 && !andar) {
    andar = true;
    global.estamina = 0;
    alarm[ALARM_ESTAMINA] = 50;
}
// --- Morte ---
if (global.vida <= 0) {
}

// --- Sanidade e Luz ---
var _limite_escuridao = 0.5;
var _recuperacao_sanidade = 0;
var _qtd_luzes = ds_list_size(global.lista_luzes);

for (var _i = 0; _i < _qtd_luzes; _i++) {
    var _luz = global.lista_luzes[| _i];
    if (instance_exists(_luz)) {
        var _distancia = point_distance(x, y, _luz.x, _luz.y);
        if (_distancia < _luz.luz_1) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.09);
        else if (_distancia < _luz.luz_2) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.07);
        else if (_distancia < _luz.luz_3) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.05);
        else if (_distancia < _luz.luz_4) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.04);
        else if (_distancia < _luz.luz_5) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.02);
    }
}
if (global.day_night_cycle.is_day) _recuperacao_sanidade = max(_recuperacao_sanidade, 0.09);

if (_recuperacao_sanidade > 0) {
    global.sanidade += _recuperacao_sanidade;
} else if (!global.day_night_cycle.is_day && global.day_night_cycle.current_light < _limite_escuridao) {
    var _fator_escuridao = 1 - (global.day_night_cycle.current_light / _limite_escuridao);
    global.sanidade -= 0.08 * _fator_escuridao;
}
global.sanidade = clamp(global.sanidade, 0, 100);

// ========================================================
// 5. INTERAÇÃO E VISUAL
// ========================================================

// --- Troca de Armas (Teclas 1 e 2) ---

// Tecla 1 para Espada
if (keyboard_check_pressed(ord("1"))) { 
    global.armamento = ARMAMENTOS.ESPADA; // Ou o valor numérico que você usa, ex: 0
    dir_alfa = 1; 
    desenha_arma = true; 
}

// Tecla 2 para Arco
if (keyboard_check_pressed(ord("2"))) { 
    global.armamento = ARMAMENTOS.ARCO;   // Ou o valor numérico que você usa, ex: 1
    dir_alfa = 1; 
    desenha_arma = true; 
}

// Lógica de fade-out do desenho da arma na tela (Mantida igual ao seu original)
if (desenha_arma) { 
    dir_alfa -= 0.02; 
    if (dir_alfa <= 0) { 
        dir_alfa = 0; 
        desenha_arma = false; 
    } 
}
// --- Coletar Itens e NPC ---
var _item_perto = instance_nearest(x, y, obj_item);
var _npc = instance_nearest(x, y, obj_par_npc_vendedor_um);
desenha_botao = false; // Reseta a cada frame

if (_item_perto != noone && distance_to_object(_item_perto) <= 25) {
    desenha_botao = true;
    if (keyboard_check_pressed(ord("F"))) {
        // Coleta pelo sistema novo de itens (ID, nível e adesivos vêm junto)
        if (inventory_pegar_instancia(_item_perto)) {
            coletar_item(_item_perto.pos_x, _item_perto.pos_y, global.current_sala);
            instance_destroy(_item_perto);
        }
        desenha_botao = false;
    }
}
else if (_npc != noone && distance_to_object(_npc) <= 50) {
    desenha_botao = true;
    if (keyboard_check_pressed(ord("P")) && !global.dialogo) {
        andar = true;
        var _dialogo = instance_create_layer(x, y, "Instances_dialogo", obj_dialogo);
        _dialogo.npc_nome = _npc.nome;
    }
}

// --- Efeitos Visuais ---
// Piscar quando toma dano
if (alarm[ALARM_INVENCIBILIDADE] > 0) {
    if (image_alpha >= 1) dano_alfa = -0.05;
    else if (image_alpha <= 0.2) dano_alfa = 0.05;
    image_alpha += dano_alfa;
} else {
    image_alpha = 1;
}

// Piscar botão de interação
if (piscando_timer > 0) piscando_timer--;
else { piscando_alpha = (piscando_alpha == 1) ? 0 : 1; piscando_timer = 20; }

/// @description Loop de Execução de Upgrades e Itens

// --- 1. Executa Upgrades Ativos (ex: Bola, Bomba) ---
var _upgrades_grid = global.upgrades_vamp_grid;
var _upgrades_count = ds_grid_height(_upgrades_grid);

for (var _i = 0; _i < _upgrades_count; _i++)
{
    var _level = _upgrades_grid[# UPGRADES_VAMP.LEVEL, _i];
    if (_level > 0) {
        var _script = _upgrades_grid[# UPGRADES_VAMP.SCRIPT, _i];
        if (_script != -1) {
            var _scr_to_exec = is_string(_script) ? asset_get_index(_script) : _script;
            if (_scr_to_exec != -1 && (script_exists(_scr_to_exec) || is_method(_scr_to_exec) || is_real(_scr_to_exec))) {
                script_execute(_scr_to_exec, _i); 
            }
        }
    }
}

// --- 2. Executa Itens Passivos (ex: Pena) ---
var _itens_grid = global.itens_vamp_grid;
var _itens_count = ds_grid_height(_itens_grid);

for (var _k = 0; _k < _itens_count; _k++)
{
    var _level_item = _itens_grid[# ITENS_VAMP.LEVEL, _k];
    if (_level_item > 0) {
        var _script_item = _itens_grid[# ITENS_VAMP.SCRIPT, _k];
        if (_script_item != -1) {
            var _scr_item_to_exec = is_string(_script_item) ? asset_get_index(_script_item) : _script_item;
            if (_scr_item_to_exec != -1 && (script_exists(_scr_item_to_exec) || is_method(_scr_item_to_exec) || is_real(_scr_item_to_exec))) {
                script_execute(_scr_item_to_exec, _k);
            }
        }
    }
}