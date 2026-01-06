/// @description Lógica Principal (Step) ORGANIZADA

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
if (script_exists(state)) {
    script_execute(state);
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
    game_restart();
}

// --- Sanidade e Luz ---
var _limite_escuridao = 0.5;
var _recuperacao_sanidade = 0;
var _qtd_luzes = ds_list_size(global.lista_luzes);

for (var i = 0; i < _qtd_luzes; i++) {
    var _luz = global.lista_luzes[| i];
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

// --- Troca de Armas ---
if (mouse_wheel_up() && dir_alfa <= 0) { global.armamento++; dir_alfa = 1; desenha_arma = true; }
if (mouse_wheel_down() && dir_alfa <= 0) { global.armamento--; dir_alfa = 1; desenha_arma = true; }
if (global.armamento >= Armamentos.Altura) global.armamento = 0;
else if (global.armamento < 0) global.armamento = Armamentos.Altura - 1;
if (desenha_arma) { dir_alfa -= 0.02; if (dir_alfa <= 0) { dir_alfa = 0; desenha_arma = false; } }

// --- Coletar Itens e NPC ---
var _item_perto = instance_nearest(x, y, obj_item);
var _npc = instance_nearest(x, y, par_npc_vendedor_um);
desenha_botao = false; // Reseta a cada frame

if (_item_perto != noone && distance_to_object(_item_perto) <= 25 && !global.inventario_cheio) {
    desenha_botao = true;
    if (keyboard_check_pressed(ord("F"))) {
        // ... (Seu código de adicionar ao inventário aqui) ...
        // Para economizar espaço, não colei tudo, mas mantenha sua lógica de coleta aqui.
        adicionar_item_invent(_item_perto.image_index, _item_perto.quantidade, _item_perto.sprite_index, _item_perto.nome, _item_perto.descricao, _item_perto.sala_x, _item_perto.sala_y, _item_perto.pos_x, _item_perto.pos_y, _item_perto.dano, _item_perto.armadura, _item_perto.velocidade, _item_perto.cura, _item_perto.tipo, _item_perto.ind, _item_perto.preco);
        coletar_item(_item_perto.pos_x, _item_perto.pos_y, global.current_sala);
        instance_destroy(_item_perto);
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

// Executa Upgrades Passivos
var _qtd_upgrades = ds_list_size(global.active_upgrades);
for (var i = 0; i < _qtd_upgrades; i++) {
    script_execute(global.active_upgrades[| i]);
}