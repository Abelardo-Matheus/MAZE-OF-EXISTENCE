if (cutscene_active) {
        var _current_action = cutscene_data[action];
        var _let = array_length(_current_action) - 1;

        // Executa a ação com base no número de parâmetros
        switch (_let) {
            case 0:
                script_execute(_current_action[0]);
                break;
            case 1:
                script_execute(_current_action[0], _current_action[1]);
                break;
            case 2:
                script_execute(_current_action[0], _current_action[1], _current_action[2]);
                break;
            case 3:
                script_execute(_current_action[0], _current_action[1], _current_action[2], _current_action[3]);
                break;
            case 4:
                script_execute(_current_action[0], _current_action[1], _current_action[2], _current_action[3], _current_action[4]);
                break;
            case 5:
                script_execute(_current_action[0], _current_action[1], _current_action[2], _current_action[3], _current_action[4], _current_action[5]);
                break;
            case 6:
                script_execute(_current_action[0], _current_action[1], _current_action[2], _current_action[3], _current_action[4], _current_action[5], _current_action[6]);
                break;
        }
}
