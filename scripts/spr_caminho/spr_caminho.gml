// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function acha_caminho(start_x, start_y, end_x, end_y) {
    
    var queue = ds_queue_create();
    var visited = ds_grid_create(ds_grid_width(global.maze), ds_grid_height(global.maze));
    var parent = ds_grid_create(ds_grid_width(global.maze), ds_grid_height(global.maze));

    ds_queue_enqueue(queue, [start_x, start_y]);
    ds_grid_set(visited, start_x, start_y, 1);
    ds_grid_set(parent, start_x, start_y, -1);

    var directions = [[1, 0], [0, 1], [-1, 0], [0, -1]];
    var path_found = false;

    while (!ds_queue_empty(queue)) {
        var current = ds_queue_dequeue(queue);
        var cur_i = current[0];
        var cur_z = current[1];

        if (cur_i == end_x && cur_z == end_y) {
            path_found = true;
            break;
        }

        for (var i = 0; i < array_length_1d(directions); i++) {
            var dir_x = directions[i][0];
            var dir_y = directions[i][1];
            var new_x = cur_i + dir_x;
            var new_y = cur_z + dir_y;

            if (new_x >= 0 && new_x < ds_grid_width(global.maze) && new_y >= 0 && new_y < ds_grid_height(global.maze) &&
                ds_grid_get(global.maze, new_x, new_y) == 1 && ds_grid_get(visited, new_x, new_y) == 0) {

                ds_queue_enqueue(queue, [new_x, new_y]);
                ds_grid_set(visited, new_x, new_y, 1);
                ds_grid_set(parent, new_x, new_y, cur_i + cur_z * ds_grid_width(global.maze));
            }
        }
    }

    if (!path_found) {

        ds_queue_destroy(queue);
        ds_grid_destroy(visited);
        ds_grid_destroy(parent);
        return undefined;
    }

    var path = [];
    var curr_i = end_x;
    var curr_z = end_y;

    while (curr_i != start_x || curr_z != start_y) {
        array_push(path, [curr_i, curr_z]);
        var parent_index = ds_grid_get(parent, curr_i, curr_z);
        var parent_x = parent_index mod ds_grid_width(global.maze);
        var parent_y = floor(parent_index / ds_grid_width(global.maze));
        curr_i = parent_x;
        curr_z = parent_y;
    }

    array_push(path, [start_x, start_y]);

    ds_queue_destroy(queue);
    ds_grid_destroy(visited);
    ds_grid_destroy(parent);

    path = array_reverse(path);
    return path;
}