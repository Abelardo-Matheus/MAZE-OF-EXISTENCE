
// EVENTO CLEANUP (QUANDO O OBJETO É DESTRUÍDO):

if (surface_exists(global.day_night_cycle.overlay)) {
    surface_free(global.day_night_cycle.overlay);
}