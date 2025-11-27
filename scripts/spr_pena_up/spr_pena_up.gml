/// @desc Calcula os atributos da 'Pena' (Passive Item)
/// [O QUE]: Define a porcentagem de velocidade ganha em cada nível.
/// [COMO] : Retorna um struct com o valor 'speed_bonus' (em porcentagem, ex: 10 = 10%).
function scr_feather_calculate_stats(_level) 
{
    var _stats = {
        speed_bonus: 0 // Valor a ser adicionado (ex: 5 para 5%)
    };

    // Define o ganho por nível
    switch (_level) 
    {
        case 1: _stats.speed_bonus = 5;  break; // +5%
        case 2: _stats.speed_bonus = 5;  break; // +5% (acumulando na lógica principal)
        case 3: _stats.speed_bonus = 10; break; // +10%
        case 4: _stats.speed_bonus = 10; break; // +10%
        case 5: _stats.speed_bonus = 15; break; // +15% (bônus maior no final)
        default: _stats.speed_bonus = 5; break; // Padrão para níveis extras
    }

    return _stats;
}
/// @desc Lógica da 'Pena' (Aumento de Velocidade)
/// [O QUE]: Aplica um bônus permanente na velocidade do jogador sempre que o item sobe de nível.
/// [COMO] : 
/// 1. Verifica se o nível atual do item é maior que o último nível aplicado ('last_applied_level').
/// 2. Se for, calcula o bônus e multiplica a velocidade global.
/// 3. Atualiza a descrição na grid e marca o nível como aplicado.
function scr_pena() 
{
    // 1. Obter Nível Atual (Grid de Itens Passivos)
    // Nota: 0 é o índice da PENA na grid de ITENS (confirme se é 0 ou 1 na sua grid)
    var _current_level = global.itens_vamp_grid[# Itens_vamp.level, 0]; 

    // 2. Inicialização Segura da Variável de Controle
    if (!variable_global_exists("feather_last_applied_level")) 
    {
        global.feather_last_applied_level = 0;
    }

    // 3. Checagem: Só aplica se subiu de nível
    if (global.feather_last_applied_level < _current_level) 
    {
        var _config = scr_feather_calculate_stats(_current_level); 

        // --- Aplica o Bônus ---
        // Exemplo: Se speed_bonus é 10, multiplica por 1.10
        var _multiplier = 1 + (_config.speed_bonus / 100);
        global.speed_player *= _multiplier;

        // --- Atualiza UI ---
        // Atualiza a descrição para mostrar o que acabou de acontecer
        global.itens_vamp_grid[# Itens_vamp.description, 0] = "VELOCIDADE AUMENTADA EM " + string(_config.speed_bonus) + "%!";

        // --- Marca como Aplicado ---
        // Iguala as variáveis para que este bloco não rode novamente até o próximo level up
        global.feather_last_applied_level = _current_level;
        
        // Debug (Opcional)
        show_debug_message("Pena Upada! Nova Velocidade: " + string(global.speed_player));
    }
}