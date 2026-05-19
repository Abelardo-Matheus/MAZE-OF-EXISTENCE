/// @desc Destruição de Grids do Labirinto
if (ds_exists(global._maze, ds_type_grid)) ds_grid_destroy(global._maze);
if (ds_exists(global.visited, ds_type_grid)) ds_grid_destroy(global.visited);
