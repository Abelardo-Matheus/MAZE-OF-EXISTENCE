function scr_astar_path(start_x, start_y, end_x, end_y) {
    maze_width = global.maze_width;
    maze_height = global.maze_height;
    var open_list = ds_priority_create();
    var came_from = ds_map_create();
    var g_score = ds_grid_create(maze_width + 2, maze_height + 2);
    var f_score = ds_grid_create(maze_width + 2, maze_height + 2);
    var current, neighbors, current_i, current_z, neighbor_i, neighbor_z, tentative_g_score;

    // Substituir ds_grid_set_all(g_score, 99999) por um loop para preencher a grade
    for (var i = 0; i < maze_width + 2; i++) {
        for (var z = 0; z < maze_height + 2; z++) {
            ds_grid_set(g_score, i, z, 99999);
            ds_grid_set(f_score, i, z, 99999);
        }
    }

    ds_grid_set(g_score, start_x, start_y, 0);
    ds_grid_set(f_score, start_x, start_y, scr_heuristic(start_x, start_y, end_x, end_y));

    ds_priority_add(open_list, [start_x, start_y], ds_grid_get(f_score, start_x, start_y));

    while (!ds_priority_empty(open_list)) {
        current = ds_priority_delete_min(open_list);
        current_i = current[0];
        current_z = current[1];

        if (current_i == end_x && current_z == end_y) {
            return scr_reconstruct_path(came_from, current_i, current_z); // Rebuild path
        }

        neighbors = scr_get_neighbors(current_i, current_z);

        for (var i = 0; i < array_length_1d(neighbors); i++) {
            neighbor_i = neighbors[i][0];
            neighbor_z = neighbors[i][1];

            tentative_g_score = ds_grid_get(g_score, current_i, current_z) + 1;

            if (tentative_g_score < ds_grid_get(g_score, neighbor_i, neighbor_z)) {
                ds_map_add(came_from, string(neighbor_i) + "," + string(neighbor_z), string(current_i) + "," + string(current_z));
                ds_grid_set(g_score, neighbor_i, neighbor_z, tentative_g_score);
                ds_grid_set(f_score, neighbor_i, neighbor_z, tentative_g_score + scr_heuristic(neighbor_i, neighbor_z, end_x, end_y));

                if (!ds_priority_has_value(open_list, [neighbor_i, neighbor_z])) {
                    ds_priority_add(open_list, [neighbor_i, neighbor_z], ds_grid_get(f_score, neighbor_i, neighbor_z));
                }
            }
        }

        ds_list_destroy(neighbors);
    }

    // If no path found, return an empty list
    return ds_list_create();
}

function scr_heuristic(i1, z1, i2, z2) {
    // Use Manhattan distance as the heuristic
    return abs(i1 - i2) + abs(z1 - z2);
}

function scr_get_neighbors(cur_i, cur_z) {
    var neighbors = ds_list_create();
    var directions = [[1, 0], [-1, 0], [0, 1], [0, -1]];

    for (var i = 0; i < 4; i++) {
        var nx = cur_i + directions[i][0];
        var ny = cur_z + directions[i][1];

        if (nx > 0 && ny > 0 && nx <= maze_width && ny <= maze_height && ds_grid_get(global.maze, nx, ny) == 1) {
            ds_list_add(neighbors, [nx, ny]);
        }
    }

    return neighbors;
}

function scr_reconstruct_path(came_from, current_i, current_z) {
    var total_path = ds_list_create();
    ds_list_insert(total_path, 0, [current_i, current_z]);

    while (ds_map_exists(came_from, string(current_i) + "," + string(current_z))) {
        var previous = ds_map_find_value(came_from, string(current_i) + "," + string(current_z));
        var coords = string_split(previous, ",");
        current_i = real(coords[0]);
        current_z = real(coords[1]);
        ds_list_insert(total_path, 0, [current_i, current_z]);
    }

    return total_path;
}
