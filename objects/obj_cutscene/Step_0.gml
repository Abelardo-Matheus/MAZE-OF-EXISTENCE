/// @desc Executa a Ação Atual
if (!cutscene_active) exit; // Se não estiver ativa, não faz nada

// Segurança: Verifica se o array existe e se o índice é válido
if (is_array(cutscene_data) && action_index < array_length(cutscene_data)) 
{
    // 1. Pega a linha atual da cutscene (Ex: [action_move_object, id, x, y...])
    var _current_action_array = cutscene_data[action_index];
    
    // 2. O primeiro item do array é sempre o SCRIPT (a função)
    var _script_to_run = _current_action_array[0];
    
    // 3. Executa o script passando o resto do array como argumentos
    // 'script_execute_ext' pega um array e distribui os valores como argumentos (arg0, arg1...)
    // O '1' no final diz para começar do índice 1 (ignorando o script no índice 0)
    if (script_exists(_script_to_run)) 
    {
        script_execute_ext(_script_to_run, _current_action_array, 1);
    }
}