// Variáveis iniciais (definidas pelo script de lançamento)
target_x = 0;
target_y = 0;
damage = 0;
radius = 0; // O raio real da explosão
push = 0;
splash_damage_multiplier = 0;

state = "flying"; // Pode ser "flying" ou "exploding"

var _dist = point_distance(x, y, target_x, target_y);
throw_height = 40;
throw_speed = _dist / 20;

initial_x = x;
initial_y = y;

// --- NOVAS VARIÁVEIS PARA GERENCIAR O TAMANHO ---
base_bomb_size = 96; // Tamanho base (em pixels) do seu sprite de bomba. Ajuste se necessário.
z = 0;             // Por exemplo, se o seu spr_bomba tem 32x32 pixels.
// --- FIM DAS NOVAS VARIÁVEIS ---

// Variáveis para a explosão
explosion_timer = 0;
explosion_duration = 30;
exploded = false;


image_speed = 0;
image_xscale = 1; // Escala inicial
image_yscale = 1; // Escala inicial