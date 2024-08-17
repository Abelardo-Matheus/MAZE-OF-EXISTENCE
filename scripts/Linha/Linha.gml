function desenha_linha(path) {
    var path_length = array_length_1d(path);

    // Loop através do caminho
    for (var i = 0; i < path_length - 1; i++) {
        var start_x = path[i][0] * cell_size + cell_size / 2;
        var start_y = path[i][1] * cell_size + cell_size / 2;
        var end_x = path[i + 1][0] * cell_size + cell_size / 2;
        var end_y = path[i + 1][1] * cell_size + cell_size / 2;

        // Calcular o ângulo da linha
        var angle = point_direction(start_x, start_y, end_x, end_y);
        
        // Criar a instância do sprite na posição do início do segmento
        var traco_instance = instance_create_layer(start_x, start_y, "Layer_Linhas", obj_traco);
		with (traco_instance) {
        // Definir o ângulo e o tamanho da instância
		image_angle = angle;
        
        // Ajustar o comprimento do traço conforme a distância entre os pontos
        var scale_x = point_distance(start_x, start_y, end_x, end_y) / sprite_width[spr_traco];
		image_xscale = scale_x+0.1;

        // Centralizar a instância
		x = (start_x + end_x) / 2;
        y = (start_y + end_y) / 2 ;
		}
    }
}
function apagar_linhas() {
    // Apagar todas as instâncias de obj_traco
    with (obj_traco) {
        instance_destroy();
    }
}
