// feather disable GM2017
// Coloca o chão na camada mais profunda possível do universo do GameMaker!
// Isso garante que qualquer coisa com "depth = -y" vai ficar na frente dele.
depth = 99999999; // 8 noves!

terreno_inicializar();

// Cache de regioes do chao: "rx,ry" -> surface ja desenhada (script TERRENO)
regioes = ds_map_create();
max_construcoes_extras = 1;   // regioes fora da tela pre-desenhadas por frame
timer_limpeza = 0;
